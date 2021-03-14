pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

import "../util/CacheLib.sol";

/**
    @notice This interface defines all function to manage the asset settings on the platform.

    @author develop@teller.finance
 */
interface AssetSettingsInterface {
    /**
        @notice This event is emitted when a new asset settings is created.
        @param sender the transaction sender address.
        @param assetAddress the asset address used to create the settings.
        @param cTokenAddress cToken address to configure for the asset.
        @param maxLoanAmount max loan amount to configure for the asset.
     */
    event AssetSettingsCreated(
        address indexed sender,
        address indexed assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount
    );

    /**
        @notice This event is emitted when an asset settings is removed.
        @param sender the transaction sender address.
        @param assetAddress the asset address used to remove the settings.
     */
    event AssetSettingsRemoved(
        address indexed sender,
        address indexed assetAddress
    );

    /**
        @notice This event is emitted when an asset settings (address type) is updated.
        @param assetSettingName asset setting name updated.
        @param sender the transaction sender address.
        @param assetAddress the asset address used to update the asset settings.
        @param oldValue old value used for the asset setting.
        @param newValue the value updated.
     */
    event AssetSettingsAddressUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        address oldValue,
        address newValue
    );

    /**
        @notice This event is emitted when an asset settings (uint256 type) is updated.
        @param assetSettingName asset setting name updated.
        @param sender the transaction sender address.
        @param assetAddress the asset address used to update the asset settings.
        @param oldValue old value used for the asset setting.
        @param newValue the value updated.
     */
    event AssetSettingsUintUpdated(
        bytes32 indexed assetSettingName,
        address indexed sender,
        address indexed assetAddress,
        uint256 oldValue,
        uint256 newValue
    );

    /**
        @notice It creates an asset with the given parameters.
        @param assetAddress asset address used to create the new setting.
        @param cTokenAddress cToken address used to configure the asset setting.
        @param maxLoanAmount the initial max loan amount.
        @param maxTVLAmount the initial max total value locked amount.
        @param maxDebtRatio the initial max debt ratio amount.
    */
    function createAssetSetting(
        address assetAddress,
        address cTokenAddress,
        uint256 maxLoanAmount,
        uint256 maxTVLAmount,
        uint256 maxDebtRatio
    ) external;

    /**
        @notice It updates the cToken address associted with an asset.
        @param assetAddress asset address to configure.
        @param cTokenAddress the new cToken address to configure.
     */
    function updateCTokenAddress(address assetAddress, address cTokenAddress)
        external;

    /**
        @notice It returns the cToken address associted with an asset.
        @param assetAddress asset address to get the associated cToken for.
        @return The associated cToken address
     */
    function getCTokenAddress(address assetAddress)
        external
        view
        returns (address);

    /**
        @notice It updates the yearn vault address associted with an asset.
        @param assetAddress asset address to configure.
        @param yVaultAddress the new yVault address to configure.
     */
    function updateYVaultAddressSetting(
        address assetAddress,
        address yVaultAddress
    ) external;

    /**
        @notice It returns the yearn vault address associted with an asset.
        @param assetAddress asset address to get the associated yearn vault address for.
        @return The address of the yearn vault.
     */
    function getYVaultAddress(address assetAddress)
        external
        view
        returns (address);

    /**
     @notice It updates the aToken address associated with an asset.
     @param assetAddress asset address to configure.
     @param aTokenAddress the new aToken address to configure.
     */
    function updateATokenAddress(address assetAddress, address aTokenAddress)
        external;

    /**
      @notice It returns the aToken address associated with an asset.
      @param assetAddress asset address to get the associated aToken for.
      @return The associated aToken address
      */
    function getATokenAddress(address assetAddress)
        external
        view
        returns (address);

    /**
        @notice It updates the max loan amount for a given asset.
        @param assetAddress asset address used to update the max loan amount.
        @param newMaxLoanAmount the new max loan amount to set.
     */
    function updateMaxLoanAmount(address assetAddress, uint256 newMaxLoanAmount)
        external;

    /**
        @notice Returns the max loan amount for a given asset.
        @param assetAddress asset address to retrieve the max loan amount.
     */
    function getMaxLoanAmount(address assetAddress)
        external
        view
        returns (uint256);

    /**
        @notice Tests whether a given amount is greater than the current max loan amount.
        @param assetAddress asset address used to return the max loan amount setting.
        @param amount the loan amount to check.
        @return true if the given amount is greater than the current max loan amount. Otherwise it returns false.
     */
    function exceedsMaxLoanAmount(address assetAddress, uint256 amount)
        external
        view
        returns (bool);

    /**
        @notice It updates the max total vaule locked amount for a given asset.
        @param assetAddress asset address used to update the max loan amount.
        @param newMaxTVLAmount the new max total vault locked amount to set.
     */
    function updateMaxTVL(address assetAddress, uint256 newMaxTVLAmount)
        external;

    /**
        @notice Returns the max total value locked amount for a given asset.
        @param assetAddress asset address to retrieve the max total value locked amount.
     */
    function getMaxTVLAmount(address assetAddress)
        external
        view
        returns (uint256);

    /**
    @notice It updates the max debt ratio for a given asset.
    @dev The ratio value has 2 decimal places. I.e 100 = 1%
    @param assetAddress asset address used to update the max debt ratio.
    @param newMaxDebtRatio the new max debt ratio to set.
    */
    function updateMaxDebtRatio(address assetAddress, uint256 newMaxDebtRatio)
        external;

    /**
    @notice Returns the max debt ratio for a given asset.
    @dev The ratio value has 2 decimal places. I.e 100 = 1%
    @param assetAddress asset address to retrieve the max debt ratio.
    */
    function getMaxDebtRatio(address assetAddress)
        external
        view
        returns (uint256);

    /**
        @notice It removes a configuration for a given asset on the platform.
        @param assetAddress asset address to remove.
     */
    function removeAsset(address assetAddress) external;

    function initialize() external;
}
