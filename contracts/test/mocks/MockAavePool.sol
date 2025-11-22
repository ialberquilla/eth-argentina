// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title MockAavePool
/// @notice Mock implementation of Aave Pool for testing
contract MockAavePool {
    /// @notice Tracks deposits made to the pool
    mapping(address => mapping(address => uint256)) public deposits;

    /// @notice Emitted when tokens are supplied
    event Supply(address indexed asset, uint256 amount, address indexed onBehalfOf, uint16 referralCode);

    /// @notice Mock supply function
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external {
        // Transfer tokens from caller to this pool
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        // Track the deposit
        deposits[asset][onBehalfOf] += amount;

        emit Supply(asset, amount, onBehalfOf, referralCode);
    }

    /// @notice Helper to check deposits for testing
    function getDeposit(address asset, address user) external view returns (uint256) {
        return deposits[asset][user];
    }
}
