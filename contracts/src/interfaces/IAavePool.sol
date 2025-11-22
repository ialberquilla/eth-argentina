// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IAavePool
/// @notice Minimal interface for Aave v3 Pool
/// @dev Only includes the methods needed for depositing
interface IAavePool {
    /// @notice Supplies an amount of underlying asset into the reserve, receiving in return overlying aTokens
    /// @param asset The address of the underlying asset to supply
    /// @param amount The amount to be supplied
    /// @param onBehalfOf The address that will receive the aTokens
    /// @param referralCode Code used to register the integrator originating the operation, for potential rewards
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
}
