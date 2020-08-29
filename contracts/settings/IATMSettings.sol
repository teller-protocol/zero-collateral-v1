pragma solidity 0.5.17;

import "../interfaces/SettingsInterface.sol";


// Libraries

// Commons

// Interfaces
/**
    @notice It manages the settings for the ATMs.
    @author develop@teller.finance
 */
interface IATMSettings {
    /** Events */

    /**
        @notice This event is emitted when an ATM is paused.
        @param atm paused ATM address.
        @param account address that paused the ATM.
     */
    event ATMPaused(address indexed atm, address indexed account);

    /**
        @notice This event is emitted when an ATM is unpaused.
        @param atm unpaused ATM address.
        @param account address that unpaused the ATM.
     */
    event ATMUnpaused(address indexed account, address indexed atm);

    /**
        @notice This event is emitted when the setting for a Market/ATM is set.
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param atm ATM address to set in the given market.
        @param account address that set the setting.
     */
    event MarketToAtmSet(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed atm,
        address account
    );

    /**
        @notice This event is emitted when the setting for a Market/ATM is updated.
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param oldAtm the old ATM address in the given market.
        @param newAtm the new ATM address in the given market.
        @param account address that updated the setting.
     */
    event MarketToAtmUpdated(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address newAtm,
        address account
    );

    /**
        @notice This event is emitted when the setting for a Market/ATM is removed.
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param oldAtm last ATM address in the given market.
        @param account address that removed the setting.
     */
    event MarketToAtmRemoved(
        address indexed borrowedToken,
        address indexed collateralToken,
        address indexed oldAtm,
        address account
    );

    /**
        @notice This event is emitted when the ATM token template is updated.
        @param sender address that sent the transaction.
        @param oldATMTokenLogic the old ATM token template address.
        @param newATMTokenLogic the new ATM token template address.
     */
    event ATMTokenLogicUpdated(
        address indexed sender,
        address indexed oldATMTokenLogic,
        address indexed newATMTokenLogic
    );

    /**
        @notice This event is emitted when the ATM governance template is updated.
        @param sender address that sent the transaction.
        @param oldATMGovernanceLogic the old ATM governance template address.
        @param newATMGovernanceLogic the new ATM governance template address.
     */
    event ATMGovernanceLogicUpdated(
        address indexed sender,
        address indexed oldATMGovernanceLogic,
        address indexed newATMGovernanceLogic
    );

    /* State Variables */

    /** Modifiers */

    /* Constructor */

    /** External Functions */

    /**
        @notice It represents the protocol Settings contract.
     */
    function settings() external view returns (SettingsInterface);

    /**
        @notice It fetches the current logic implementation address for ATM Tokens.
     */
    function atmTokenLogic() external view returns (address);

    /**
        @notice It fetches the current logic implementation address for ATM Governance.
     */
    function atmGovernanceLogic() external view returns (address);

    /**
        @notice It pauses an given ATM.
        @param atmAddress ATM address to pause.
     */
    function pauseATM(address atmAddress) external;

    /**
        @notice It unpauses an given ATM.
        @param atmAddress ATM address to unpause.
     */
    function unpauseATM(address atmAddress) external;

    /**
        @notice Gets whether an ATM is paused or not.
        @param atmAddress ATM address to test.
        @return true if ATM is paused. Otherwise it returns false.
     */
    function isATMPaused(address atmAddress) external view returns (bool);

    /**
        @notice Sets an ATM for a given market (borrowed token and collateral token).
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param atmAddress ATM address to set.
     */
    function setATMToMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external;

    /**
        @notice It sets a new ATM token template to be used in the proxy (see createATM function).
        @param newATMTokenLogicAddress the new ATM token template address.
     */
    function setATMTokenLogic(address newATMTokenLogicAddress) external;

    /**
        @notice It sets a new ATM governance template to be used in the proxy (see createATM function).
        @param newATMGovernanceLogicAddress the new ATM governance template address.
     */
    function setATMGovernanceLogic(address newATMGovernanceLogicAddress) external;

    /**
        @notice Updates a new ATM for a given market (borrowed token and collateral token).
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param newAtmAddress the new ATM address to update.
     */
    function updateATMToMarket(
        address borrowedToken,
        address collateralToken,
        address newAtmAddress
    ) external;

    /**
        @notice Removes the ATM address for a given market (borrowed token and collateral token).
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
     */
    function removeATMToMarket(address borrowedToken, address collateralToken) external;

    /**
        @notice Gets the ATM configured for a given market (borrowed token and collateral token).
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @return the ATM address configured for a given market.
     */
    function getATMForMarket(address borrowedToken, address collateralToken)
        external
        view
        returns (address);

    /**
        @notice Tests whether an ATM is configured for a given market (borrowed token and collateral token) or not.
        @param borrowedToken borrowed token address.
        @param collateralToken collateral token address.
        @param atmAddress ATM address to test.
        @return true if the ATM is configured for the market. Otherwise it returns false.
     */
    function isATMForMarket(
        address borrowedToken,
        address collateralToken,
        address atmAddress
    ) external view returns (bool);

    /**
        @notice It initializes this ATM Settings instance.
        @param settingsAddress settings address.
     */
    function initialize(address settingsAddress) external;
}
