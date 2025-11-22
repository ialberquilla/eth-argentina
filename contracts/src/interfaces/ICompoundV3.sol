// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ICompoundV3
/// @notice Minimal interface for Compound V3 (Comet)
/// @dev Only includes the methods needed for depositing
interface ICompoundV3 {
    /// @notice Supply an amount of asset to the protocol
    /// @param asset The address of the asset to supply
    /// @param amount The amount to be supplied
    function supply(address asset, uint256 amount) external;

    /// @notice Supply an amount of asset to the protocol on behalf of another address
    /// @param to The address that will receive the supply balance
    /// @param asset The address of the asset to supply
    /// @param amount The amount to be supplied
    function supplyTo(address to, address asset, uint256 amount) external;
}
