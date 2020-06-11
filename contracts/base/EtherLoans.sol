/*
    Copyright 2020 Fabrx Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

// Contracts
import "./LoansBase.sol";

// Interfaces
import "../interfaces/EtherLoansInterface.sol";

contract EtherLoans is EtherLoansInterface, LoansBase {

    /**
     * @notice Deposit collateral into a loan
     * @param borrower address The address of the loan borrower.
     * @param loanID uint256 The ID of the loan the collateral is for
     */
    function depositCollateral(address borrower, uint256 loanID)
        external
        payable
        loanActiveOrSet(loanID)
        isInitialized()
        whenNotPaused()
        whenLendingPoolNotPaused(address(lendingPool))
    {
        require(
            loans[loanID].loanTerms.borrower == borrower,
            "BORROWER_LOAN_ID_MISMATCH"
        );
        require(msg.value > 0, "CANNOT_DEPOSIT_ZERO");

        uint256 depositAmount = msg.value;

        // update the contract total and the loan collateral total
        _payInCollateral(loanID, depositAmount);

        emit CollateralDeposited(loanID, borrower, depositAmount);
    }

    function setLoanTerms(
        ZeroCollateralCommon.LoanRequest calldata request,
        ZeroCollateralCommon.LoanResponse[] calldata responses
    ) external payable isInitialized() whenNotPaused() isBorrower(request.borrower) {
        uint256 loanID = getAndIncrementLoanID();

        (
            uint256 interestRate,
            uint256 collateralRatio,
            uint256 maxLoanAmount
        ) = loanTermsConsensus.processRequest(request, responses);

        loans[loanID] = createLoan(
            loanID,
            request,
            interestRate,
            collateralRatio,
            maxLoanAmount
        );

        if (msg.value > 0) {
            // Update collateral, totalCollateral, and lastCollateralIn
            _payInCollateral(loanID, msg.value);
        }

        borrowerLoans[request.borrower].push(loanID);

        emit LoanTermsSet(
            loanID,
            request.borrower,
            request.recipient,
            interestRate,
            collateralRatio,
            maxLoanAmount,
            request.duration,
            loans[loanID].termsExpiry
        );
        if (msg.value > 0) {
            emit CollateralDeposited(loanID, request.borrower, msg.value);
        }
    }

    function initialize(
        address priceOracleAddress,
        address lendingPoolAddress,
        address loanTermsConsensusAddress,
        address settingsAddress
    ) external isNotInitialized() {
        _initialize(
            priceOracleAddress,
            lendingPoolAddress,
            loanTermsConsensusAddress,
            settingsAddress
        );
    }

    /** Internal Functions */

    function _payOutCollateral(uint256 loanID, uint256 amount, address payable recipient)
        internal
    {
        totalCollateral = totalCollateral.sub(amount);
        loans[loanID].collateral = loans[loanID].collateral.sub(amount);
        recipient.transfer(amount);
    }

    function _emitCollateralWithdrawnEvent(
        uint256 loanID,
        address payable recipient,
        uint256 amount
    ) internal {
        emit CollateralWithdrawn(loanID, recipient, amount);
    }

    function _emitLoanTakenOutEvent(uint256 loanID, uint256 amountBorrow) internal {
        emit LoanTakenOut(loanID, loans[loanID].loanTerms.borrower, amountBorrow);
    }

    function _emitLoanRepaidEvent(
        uint256 loanID,
        uint256 amountPaid,
        address payer,
        uint256 totalOwed
    ) internal {
        emit LoanRepaid(
            loanID,
            loans[loanID].loanTerms.borrower,
            amountPaid,
            payer,
            totalOwed
        );
    }
    function _emitLoanLiquidatedEvent(uint256 loanID, address liquidator, uint256 collateralOut, uint256 tokensIn)
        internal
    {
        emit LoanLiquidated(
            loanID,
            loans[loanID].loanTerms.borrower,
            liquidator,
            collateralOut,
            tokensIn
        );
    }
}