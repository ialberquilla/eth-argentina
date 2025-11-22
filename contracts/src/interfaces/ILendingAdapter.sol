// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/// @title ILendingAdapter
/// @notice Interface for lending protocol adapters
/// @dev All lending adapters must implement this interface to standardize deposits
interface ILendingAdapter {
    /// @notice Deposits tokens into the lending protocol
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    /// @param onBehalfOf The address that will receive the aTokens/deposit tokens
    function deposit(Currency token, uint256 amount, address onBehalfOf) external;
}
