pragma solidity 0.5.17;

// Contracts
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
import "../../base/BaseUpgradeable.sol";
import "../../base/TInitializable.sol";

// Libraries
import "@openzeppelin/contracts-ethereum-package/contracts/utils/Address.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "../openzeppelin/SignedSafeMath.sol";

// Interfaces
import "./IChainlinkAggregator.sol";

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
    @notice This contract is used to fetch and calculate prices and values from one token to another through Chainlink Aggregators.
    @dev It tries to find an aggregator using the token addresses supplied. If unable, it uses ETH as a pass through asset to construct a path conversion.

    @author develop@teller.finance
 */
contract ChainlinkAggregator is IChainlinkAggregator, TInitializable, BaseUpgradeable {
    using Address for address;
    using AddressLib for address;
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    /* State Variables */

    uint256 internal constant TEN = 10;

    mapping(address => mapping(address => address)) internal aggregators;

    /* External Functions */

    /**
        @notice It grabs the Chainlink Aggregator contract address for the token pair if it is supported.
        @param src Source token address.
        @param dst Destination token address.
        @return AggregatorV2V3Interface The Chainlink Aggregator address.
        @return bool whether or not the values from the Aggregator should be considered inverted.
     */
    function aggregatorFor(address src, address dst) external view returns (AggregatorV2V3Interface, bool) {
        return _aggregatorFor(src, dst);
    }

    /**
        @notice It calculates the value of a token amount into another.
        @param src Source token address.
        @param dst Destination token address.
        @param srcAmount Amount of the source token to convert into the destination token.
        @return uint256 Value of the source token amount in destination tokens.
     */
    function valueFor(address src, address dst, uint256 srcAmount) external view returns (uint256) {
        return _valueFor(src, dst, srcAmount);
    }

    /**
        @notice It returns the price of the token pair as given from the Chainlink Aggregator.
        @dev It tries to use ETH as a pass through asset if the direct pair is not supported.
        @param src Source token address.
        @param dst Destination token address.
        @return uint256 The latest answer as given from Chainlink.
     */
    function latestAnswerFor(address src, address dst) external view returns (int256) {
        return _priceFor(src, dst);
    }

    /**
        @notice It allows for additional Chainlink Aggregators to be supported.
        @param src Source token address.
        @param dst Destination token address.
     */
    function add(address src, address dst, address aggregator) external onlyPauser {
        require(aggregators[src][dst] == address(0));
        require(src.isContract() || src == settings().ETH_ADDRESS(), "TOKEN_A_NOT_CONTRACT");
        require(dst.isContract() || dst == settings().ETH_ADDRESS(), "TOKEN_B_NOT_CONTRACT");
        require(aggregator.isContract(), "AGGREGATOR_NOT_CONTRACT");
        aggregators[src][dst] = aggregator;
    }

    /**
        @notice It initializes this ChainlinkAggregator instance.
        @param settingsAddress the settings contract address.
     */
    function initialize(address settingsAddress) external isNotInitialized() {
        require(settingsAddress.isContract(), "SETTINGS_MUST_BE_A_CONTRACT");

        _initialize();

        _setSettings(settingsAddress);
    }

    /* Internal Functions */

    /**
        @notice It gets the number of decimals for a given token.
        @param addr Token address to get decimals for.
        @return uint8 Number of decimals the given token.
     */
    function _decimalsFor(address addr) internal view returns (uint8) {
        return addr == settings().ETH_ADDRESS() ? 18 : ERC20Detailed(addr).decimals();
    }

    /**
        @notice It grabs the Chainlink Aggregator contract address for the token pair if it is supported.
        @param src Source token address.
        @param dst Destination token address.
        @return AggregatorV2V3Interface The Chainlink Aggregator address.
        @return bool whether or not the values from the Aggregator should be considered inverted.
     */
    function _aggregatorFor(address src, address dst) internal view returns (AggregatorV2V3Interface aggregator, bool inverse) {
        if (src == settings().WETH_ADDRESS()) {
            src = settings().ETH_ADDRESS();
        }
        if (dst == settings().WETH_ADDRESS()) {
            dst = settings().ETH_ADDRESS();
        }

        inverse = aggregators[src][dst] == address(0);
        aggregator = AggregatorV2V3Interface(inverse ? aggregators[dst][src] : aggregators[src][dst]);
    }

    /**
        @notice It calculates the value of a token amount into another.
        @param src Source token address.
        @param dst Destination token address.
        @param srcAmount Amount of the source token to convert into the destination token.
        @return uint256 Value of the source token amount in destination tokens.
     */
    function _valueFor(address src, address dst, uint256 srcAmount) internal view returns (uint256) {
        return srcAmount * uint256(_priceFor(src, dst)) / uint256(TEN**_decimalsFor(src));
    }

    /**
        @notice It returns the price of the token pair as given from the Chainlink Aggregator.
        @dev It tries to use ETH as a pass through asset if the direct pair is not supported.
        @param src Source token address.
        @param dst Destination token address.
        @return uint256 The latest answer as given from Chainlink.
     */
    function _priceFor(address src, address dst) internal view returns (int256) {
        (AggregatorV2V3Interface agg, bool inverse) = _aggregatorFor(src, dst);
        uint8 srcDecimals = _decimalsFor(src);
        uint8 dstDecimals = _decimalsFor(dst);
        int256 srcFactor = int256(TEN**srcDecimals);
        int256 dstFactor = int256(TEN**dstDecimals);
        if (address(agg) != address(0)) {
            int256 price = agg.latestAnswer();
            if (inverse) {
                return srcFactor * dstFactor / price;
            }
            return price;
        } else {
            address eth = settings().ETH_ADDRESS();
            dst.requireNotEqualTo(eth, "CANNOT_CALCULATE_VALUE");

            int256 price1 = _priceFor(src, eth);
            int256 price2 = _priceFor(dst, eth);

            return price1 * dstFactor / price2;
        }
    }
}