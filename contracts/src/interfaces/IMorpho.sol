// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IMorpho
/// @notice Minimal interface for Morpho Blue
/// @dev Only includes the methods needed for depositing
interface IMorpho {
    /// @notice Market parameters for Morpho Blue
    struct MarketParams {
        address loanToken;
        address collateralToken;
        address oracle;
        address irm;
        uint256 lltv;
    }

    /// @notice Supply assets to a market
    /// @param marketParams The market parameters
    /// @param assets The amount of assets to supply
    /// @param shares The amount of shares to mint (0 for assets-based supply)
    /// @param onBehalfOf The address that will receive the supply position
    /// @param data Additional data for callbacks
    /// @return assetsSupplied The amount of assets supplied
    /// @return sharesSupplied The amount of shares minted
    function supply(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalfOf,
        bytes memory data
    ) external returns (uint256 assetsSupplied, uint256 sharesSupplied);
}
