pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// Libraries
import "../util/CompoundRatesLib.sol";
import "../util/NumbersLib.sol";
import "../util/AddressArrayLib.sol";

// Commons

// Interfaces
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../interfaces/LendingPoolInterface.sol";
import "../interfaces/LoansInterface.sol";
import "../interfaces/IMarketRegistry.sol";

// Contracts
import "@openzeppelin/contracts-ethereum-package/contracts/utils/ReentrancyGuard.sol";
import "compound-protocol/contracts/CToken.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "./Base.sol";
import "./TToken.sol";

/*****************************************************************************************************/
/**                                             WARNING                                             **/
/**                                  THIS CONTRACT IS UPGRADEABLE!                                  **/
/**  ---------------------------------------------------------------------------------------------  **/
/**  Do NOT change the order of or PREPEND any storage variables to this or new versions of this    **/
/**  contract as this will cause the the storage slots to be overwritten on the proxy contract!!    **/
/**                                                                                                 **/
/**  Visit https://docs.openzeppelin.com/upgrades/2.6/proxies#upgrading-via-the-proxy-pattern for   **/
/**  more information.                                                                              **/
/*****************************************************************************************************/
/**
    @notice The LendingPool contract holds all of the tokens that lenders transfer into the protocol.
    It is the contract that lenders interact with to deposit and withdraw their tokens including interest.

    @author develop@teller.finance
 */
contract LendingPool is LendingPoolInterface, Base, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Detailed;
    using CompoundRatesLib for CToken;
    using NumbersLib for uint256;

    /** Constants */

    uint8 public constant EXCHANGE_RATE_DECIMALS = 36;

    IUniswapV2Router02 public constant ROUTER =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    /* State Variables */

    TToken public tToken;

    ERC20Detailed public lendingToken;

    CToken public cToken;

    Comptroller public compound;

    Comp public comp;

    IMarketRegistry public marketRegistry;

    /**
        The total amount of underlying asset that has been originally been supplied by each
        lender not including interest earned.
    */
    mapping(address => uint256) internal _totalSuppliedUnderlyingLender;

    // The total amount of underlying asset that has been lent out for loans.
    uint256 internal _totalBorrowed;

    // The total amount of underlying asset that has been repaid from loans.
    uint256 internal _totalRepaid;

    // The total amount of underlying interest that has been claimed for each lender.
    mapping(address => uint256) internal _totalInterestEarnedLender;

    // The total amount of underlying interest the pool has earned from loans being repaid.
    uint256 public totalInterestEarned;

    /** Modifiers */

    /**
        @notice It checks the address is the Loans contract address.
        @dev It throws a require error if parameter is not equal to loans contract address.
     */
    modifier isLoan() {
        _requireIsLoan();
        _;
    }

    /* Constructor */

    /** External Functions */

    /**
        @notice It allows users to deposit tokens into the pool.
        @dev the user must call ERC20.approve function previously.
        @dev If the cToken is available (not 0x0), it deposits the lending token amount into Compound directly.
        @param lendingTokenAmount of tokens to deposit in the pool.
    */
    function deposit(uint256 lendingTokenAmount)
        external
        isInitialized
        whenNotPaused
        whenLendingPoolNotPaused(address(this))
        onlyAuthorized
    {
        _accrueInterest();
        uint256 previousSupply = _getTotalSupplied();

        // Transferring tokens to the LendingPool
        lendingTokenAmount = tokenTransferFrom(msg.sender, lendingTokenAmount);

        require(
            previousSupply.add(lendingTokenAmount) <=
                settings.assetSettings().getMaxTVLAmount(address(lendingToken)),
            "MAX_TVL_REACHED"
        );

        _totalSuppliedUnderlyingLender[
            msg.sender
        ] = _totalSuppliedUnderlyingLender[msg.sender].add(lendingTokenAmount);

        // Depositing to Compound accrues interest which changes the exchange rate.
        _depositToCompoundIfSupported(lendingTokenAmount);

        // Mint tToken tokens
        uint256 tTokenAmount =
            _tTokensFromLendingTokens(
                lendingTokenAmount,
                _exchangeRateForSupply(previousSupply)
            );
        tTokenMint(msg.sender, tTokenAmount);

        // Emit event
        emit TokenDeposited(msg.sender, lendingTokenAmount, tTokenAmount);
    }

    /**
        @notice It allows any tToken holder to burn their tToken tokens and withdraw their tokens.
        @dev If the cToken is available (not 0x0), it withdraws the lending tokens from Compound before
        transferring the tokens to the holder.
        @param lendingTokenAmount of tokens to withdraw.
     */
    function withdraw(uint256 lendingTokenAmount)
        external
        isInitialized
        whenNotPaused
        whenLendingPoolNotPaused(address(this))
        nonReentrant
        onlyAuthorized
    {
        uint256 exchangeRate = _exchangeRateCurrent();
        uint256 tTokenAmount =
            _tTokensFromLendingTokens(lendingTokenAmount, exchangeRate);

        require(tTokenAmount > 0, "WITHDRAW_TTOKEN_DUST");
        require(
            tToken.balanceOf(msg.sender) > tTokenAmount,
            "TTOKEN_NOT_ENOUGH_BALANCE"
        );

        _withdraw(lendingTokenAmount, tTokenAmount, exchangeRate);
    }

    function withdrawAll()
        external
        isInitialized
        whenNotPaused
        whenLendingPoolNotPaused(address(this))
        nonReentrant
        onlyAuthorized
        returns (uint256)
    {
        uint256 tTokenAmount = tToken.balanceOf(msg.sender);
        uint256 exchangeRate = _exchangeRateCurrent();
        uint256 lendingTokenAmount =
            _lendingTokensFromTTokens(tTokenAmount, exchangeRate);

        _withdraw(lendingTokenAmount, tTokenAmount, exchangeRate);

        return lendingTokenAmount;
    }

    /**
        @notice It allows a borrower repaying their loan.
        @dev This function can be called ONLY by the Loans contract.
        @dev It requires a ERC20.approve call before calling it.
        @dev It throws a require error if borrower called ERC20.approve function before calling it.
        @param principalAmount amount of tokens towards the principal.
        @param interestAmount amount of tokens towards the interest.
        @param borrower address that is repaying the loan.
     */
    function repay(
        uint256 principalAmount,
        uint256 interestAmount,
        address borrower
    )
        external
        isInitialized
        isLoan
        whenLendingPoolNotPaused(address(this))
        onlyAuthorized
    {
        uint256 totalAmount = principalAmount.add(interestAmount);
        require(totalAmount > 0, "REPAY_ZERO");

        // Transfers tokens to LendingPool.
        tokenTransferFrom(borrower, totalAmount);

        _totalRepaid = _totalRepaid.add(principalAmount);
        totalInterestEarned = totalInterestEarned.add(interestAmount);

        _depositToCompoundIfSupported(totalAmount);

        // Emits event.
        emit TokenRepaid(borrower, totalAmount);
    }

    /**
        @notice Once the loan is created, it transfers the amount of tokens to the borrower.

        @param amount of tokens to transfer.
        @param borrower address which will receive the tokens.
        @dev This function only can be invoked by the LoansInterface implementation.
        @dev It withdraws the lending tokens from Compound before transferring tokens to the borrower.
     */
    function createLoan(uint256 amount, address borrower)
        external
        isInitialized
        isLoan()
        whenLendingPoolNotPaused(address(this))
        onlyAuthorized
    {
        uint256 lendingTokenBalance = lendingToken.balanceOf(address(this));
        if (lendingTokenBalance < amount) {
            _withdrawFromCompoundIfSupported(amount.sub(lendingTokenBalance));
        }

        // Transfer tokens to the borrower.
        tokenTransfer(borrower, amount);

        _totalBorrowed = _totalBorrowed.add(amount);
    }

    function swapAccumulatedComp() external isInitialized {
        _swapAccumulatedComp();
    }

    function getMarketStateCurrent()
        external
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            uint256 totalRepaid,
            uint256 totalOnLoan
        )
    {
        _accrueInterest();
        return _getMarketState();
    }

    /**
        @notice It calculates the market state values across all markets.
        @return values that represent the global state across all markets.
     */
    function getMarketState()
        external
        view
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            uint256 totalRepaid,
            uint256 totalOnLoan
        )
    {
        return _getMarketState();
    }

    /**
        @notice It returns the balance of underlying tokens a lender owns with the amount
        of TTokens owned and the current exchange rate.
        @return a lender's balance of the underlying token in the pool.
     */
    function balanceOfUnderlying(address lender) external returns (uint256) {
        return
            _lendingTokensFromTTokens(
                tToken.balanceOf(lender),
                _exchangeRateCurrent()
            );
    }

    /**
        @notice Returns the total amount of interest earned by a lender.
        @dev This value includes already claimed + unclaimed interest earned.
        @return total interest earned by lender.
     */
    function getLenderInterestEarned(address lender)
        external
        returns (uint256)
    {
        uint256 currentLenderInterest =
            _calculateLenderInterestEarned(lender, _exchangeRateCurrent());
        return _totalInterestEarnedLender[lender].add(currentLenderInterest);
    }

    /**
        @notice Returns the amount of claimable interest a lender has earned.
        @return claimable interest value.
     */
    function getClaimableInterestEarned(address lender)
        external
        returns (uint256)
    {
        return _calculateLenderInterestEarned(lender, _exchangeRateCurrent());
    }

    /**
        @notice It gets the debt-to-supply (DtS) ratio for a given market, including a new loan amount.
        @notice The formula to calculate DtS ratio (including a new loan amount) is:

            DtS = (SUM(total borrowed) - SUM(total repaid) + NewLoanAmount) / SUM(total supplied)

        @notice The value has 2 decimal places.
            Example:
                100 => 1%
        @param loanAmount a new loan amount to consider in the ratio.
        @return the debt-to-supply ratio value.
     */
    function getDebtRatioFor(uint256 loanAmount)
        external
        view
        returns (uint256)
    {
        uint256 totalSupplied = _getTotalSupplied();
        return
            totalSupplied == 0
                ? 0
                : _totalBorrowed.add(loanAmount).sub(_totalRepaid).ratioOf(
                    totalSupplied
                );
    }

    /**
        @notice It calculates the current exchange rate for the TToken based on the total supply of the lending token.
        @return the exchange rate for 1 TToken to the underlying token.
     */
    function exchangeRateCurrent() external returns (uint256) {
        return _exchangeRateCurrent();
    }

    /**
        @notice It calculates the stored exchange rate for the TToken based on the total supply of the lending token.
        @return the exchange rate for 1 TToken to the underlying token.
     */
    function exchangeRate() external view returns (uint256) {
        return _exchangeRateStored();
    }

    function tTokensFromLendingTokens(uint256 lendingTokenAmount)
        external
        returns (uint256)
    {
        return
            _tTokensFromLendingTokens(
                lendingTokenAmount,
                _exchangeRateCurrent()
            );
    }

    function lendingTokensFromTTokens(uint256 tTokenAmount)
        external
        returns (uint256)
    {
        return _lendingTokensFromTTokens(tTokenAmount, _exchangeRateCurrent());
    }

    /**
        @notice It initializes the contract state variables.
        @param aMarketRegistry the MarketRegistry contract.
        @param aTToken the Teller token to link to the lending pool.
        @param settingsAddress Settings contract address.
        @dev It throws a require error if the contract is already initialized.
     */
    function initialize(
        IMarketRegistry aMarketRegistry,
        TToken aTToken,
        address settingsAddress
    ) external isNotInitialized {
        address(aTToken).requireNotEmpty("TTOKEN_ADDRESS_IS_REQUIRED");

        _initialize(settingsAddress);
        ReentrancyGuard.initialize();

        marketRegistry = aMarketRegistry;
        tToken = aTToken;
        lendingToken = tToken.underlying();
        cToken = CToken(settings.getCTokenAddress(address(lendingToken)));
        compound = Comptroller(cToken.comptroller());
        comp = Comp(compound.getCompAddress());
    }

    /** Internal functions */

    function _calculateLenderInterestEarned(
        address lender,
        uint256 exchangeRate
    ) internal view returns (uint256) {
        uint256 lenderUnderlyingBalance =
            _lendingTokensFromTTokens(tToken.balanceOf(lender), exchangeRate);
        return
            lenderUnderlyingBalance.sub(_totalSuppliedUnderlyingLender[lender]);
    }

    /**
        @notice It calculates the current exchange rate for the TToken based on the total supply of the lending token.
        @dev This will accrue interest for us before we calculate anything.
        @return the exchange rate for 1 TToken to the underlying token.
     */
    function _exchangeRateCurrent() internal returns (uint256) {
        _accrueInterest();
        return _exchangeRateStored();
    }

    /**
        @notice It calculates the exchange rate for the TToken based on the total supply of the lending token.
        @dev If the lending token is deposited into Compound the value calculated uses the exchangeRateStored value.
        @dev If the intended use case is for the current exchange rate, call the _exchangeRateCurrent function above.
        @return the exchange rate for 1 TToken to the underlying token.
     */
    function _exchangeRateStored() internal view returns (uint256) {
        return _exchangeRateForSupply(_getTotalSupplied());
    }

    function _exchangeRateForSupply(uint256 supply)
        internal
        view
        returns (uint256)
    {
        if (tToken.totalSupply() == 0) {
            return uint256(10)**uint256(int8(EXCHANGE_RATE_DECIMALS));
        }

        return
            supply.mul(uint256(10)**uint256(EXCHANGE_RATE_DECIMALS)).div(
                tToken.totalSupply()
            );
    }

    /**
        @notice It calculates the market state values across all markets.
        @return values that represent the global state across all markets.
     */
    function _getMarketState()
        internal
        view
        returns (
            uint256 totalSupplied,
            uint256 totalBorrowed,
            uint256 totalRepaid,
            uint256 totalOnLoan
        )
    {
        totalSupplied = _getTotalSupplied();
        totalBorrowed = _totalBorrowed;
        totalRepaid = _totalRepaid;
        totalOnLoan = _totalBorrowed.sub(totalRepaid);
    }

    /**
        @notice It calculates the total supply of the lending token across all markets.
        @return the total supply denoted in the lending token.
     */
    function _getTotalSupplied() internal view returns (uint256 totalSupplied) {
        totalSupplied = lendingToken.balanceOf(address(this)).add(
            _totalBorrowed.sub(_totalRepaid)
        );

        CToken _cToken = cToken();
        if (address(_cToken) != address(0)) {
            totalSupplied = totalSupplied.add(
                _cToken.valueInUnderlying(_cToken.balanceOf(address(this)))
            );
        }
    }

    function _withdraw(
        uint256 lendingTokenAmount,
        uint256 tTokenAmount,
        uint256 exchangeRate
    ) internal {
        uint256 lendingTokenBalance = lendingToken.balanceOf(address(this));

        _withdrawFromCompoundIfSupported(
            lendingTokenAmount.sub(lendingTokenBalance)
        );

        uint256 currentLenderInterest =
            _calculateLenderInterestEarned(msg.sender, exchangeRate);
        uint256 totalSuppliedDiff;
        if (lendingTokenAmount > currentLenderInterest) {
            totalSuppliedDiff = lendingTokenAmount.sub(currentLenderInterest);
            _totalInterestEarnedLender[msg.sender] = _totalInterestEarnedLender[
                msg.sender
            ]
                .add(currentLenderInterest);
        } else {
            _totalInterestEarnedLender[msg.sender] = _totalInterestEarnedLender[
                msg.sender
            ]
                .add(lendingTokenAmount);
        }
        _totalSuppliedUnderlyingLender[
            msg.sender
        ] = _totalSuppliedUnderlyingLender[msg.sender].sub(totalSuppliedDiff);

        // Burn tToken tokens.
        tToken.burn(msg.sender, tTokenAmount);

        // Transfers tokens
        tokenTransfer(msg.sender, lendingTokenAmount);

        // Emit event.
        emit TokenWithdrawn(msg.sender, lendingTokenAmount, tTokenAmount);
    }

    function _tTokensFromLendingTokens(
        uint256 lendingTokenAmount,
        uint256 exchangeRate
    ) internal pure returns (uint256) {
        return
            lendingTokenAmount
                .mul(uint256(10)**uint256(EXCHANGE_RATE_DECIMALS))
                .div(exchangeRate);
    }

    function _lendingTokensFromTTokens(
        uint256 tTokenAmount,
        uint256 exchangeRate
    ) internal pure returns (uint256) {
        return
            tTokenAmount.mul(exchangeRate).div(
                uint256(10)**uint256(EXCHANGE_RATE_DECIMALS)
            );
    }

    /**
        @notice It deposits a given amount of tokens to Compound.
        @dev The cToken address must be defined in AssetSettings.
        @dev The underlying token value of the tokens to be deposited must be positive. Because the decimals of
            cTokens and the underlying asset can differ, the deposit of dust tokens may result in no cTokens minted.
        @param amount The amount of underlying tokens to deposit.
        @return The amount of underlying tokens deposited.
     */
    function _depositToCompoundIfSupported(uint256 amount)
        internal
        returns (uint256 difference)
    {
        CToken _cToken = cToken();
        if (address(_cToken) == address(0)) {
            return 0;
        }

        // approve the cToken contract to take lending tokens
        lendingToken.safeApprove(address(_cToken), amount);

        uint256 balanceBefore = lendingToken.balanceOf(address(this));

        // Now mint cTokens, which will take lending tokens
        uint256 mintResult = _cToken.mint(amount);
        require(mintResult == 0, "COMPOUND_DEPOSIT_ERROR");

        uint256 balanceAfter = lendingToken.balanceOf(address(this));
        difference = balanceBefore.sub(balanceAfter);
        require(difference > 0, "DEPOSIT_CTOKEN_DUST");
    }

    /**
        @notice It withdraws a given amount of tokens from Compound.
        @param amount The amount of underlying tokens to withdraw.
        @return The amount of underlying tokens withdrawn.
     */
    function _withdrawFromCompoundIfSupported(uint256 amount)
        internal
        returns (uint256)
    {
        CToken _cToken = cToken();
        if (address(_cToken) == address(0)) {
            return 0;
        }

        uint256 balanceBefore = lendingToken.balanceOf(address(this));

        uint256 redeemResult = _cToken.redeemUnderlying(amount);
        require(redeemResult == 0, "COMPOUND_REDEEM_UNDERLYING_ERROR");

        uint256 balanceAfter = lendingToken.balanceOf(address(this));
        return balanceAfter.sub(balanceBefore);
    }

    function _swapAccumulatedComp() internal {
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cToken);

        compound.claimComp(address(this), cTokens);

        // Amount which goes into the swap is COMP balance of the lending pool.
        uint256 amountIn = comp.balanceOf(address(this));

        // Path of the swap is always COMP -> WETH -> LendingToken.
        address[] memory path = new address[](3);
        path[0] = address(comp);
        path[1] = settings.WETH_ADDRESS();
        path[2] = address(lendingToken);

        comp.safeIncreaseAllowance(ROUTER, amountIn);

        ROUTER.swapExactTokensForToken(
            amountIn,
            ROUTER.getAmountsOut(amountIn, path)[path.length - 1],
            path,
            address(this)
        );
    }

    /**
        @notice It validates whether transaction sender is the loans contract address.
        @dev This function is overriden in some mock contracts for testing purposes.
     */
    function _requireIsLoan() internal view {
        require(
            marketRegistry.loansRegistry(address(this), msg.sender),
            "CALLER_NOT_LOANS_CONTRACT"
        );
    }

    /** Private functions */

    /**
        @notice It transfers an amount of tokens to a specific address.
        @param recipient address which will receive the tokens.
        @param amount of tokens to transfer.
        @dev It throws a require error if 'transfer' invocation fails.
     */
    function tokenTransfer(address recipient, uint256 amount) private {
        uint256 currentBalance = lendingToken.balanceOf(address(this));
        require(currentBalance >= amount, "LENDING_TOKEN_NOT_ENOUGH_BALANCE");
        lendingToken.safeTransfer(recipient, amount);
    }

    /**
        @notice It transfers an amount of tokens from an address to this contract.
        @param from address where the tokens will transfer from.
        @param amount to be transferred.
        @dev It throws a require error if 'transferFrom' invocation fails.
     */
    function tokenTransferFrom(address from, uint256 amount)
        private
        returns (uint256 balanceIncrease)
    {
        uint256 balanceBefore = lendingToken.balanceOf(address(this));
        uint256 allowance = lendingToken.allowance(from, address(this));
        require(allowance >= amount, "LEND_TOKEN_NOT_ENOUGH_ALLOWANCE");
        lendingToken.safeTransferFrom(from, address(this), amount);
        return lendingToken.balanceOf(address(this)).sub(balanceBefore);
    }

    /**
        @notice It mints tToken tokens, and send them to a specific address.
        @param to address which will receive the minted tokens.
        @param amount to be minted.
        @dev This contract must has a Minter Role in tToken (mintable) token.
        @dev It throws a require error if mint invocation fails.
     */
    function tTokenMint(address to, uint256 amount) private {
        bool mintResult = tToken.mint(to, amount);
        require(mintResult, "TTOKEN_MINT_FAILED");
    }

    function _accrueInterest() private {
        address(cToken).call(abi.encodeWithSignature("accrueInterest()"));
    }
}
