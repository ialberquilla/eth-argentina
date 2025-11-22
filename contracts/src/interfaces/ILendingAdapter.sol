// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/// @title ILendingAdapter
/// @notice Interface for lending protocol adapters
/// @dev All lending adapters must implement this interface to standardize deposits
interface ILendingAdapter {
    /// @notice Metadata for the lending adapter
    /// @param symbol The token symbol this adapter is configured for (e.g., "USDC", "DAI")
    /// @param chainId The chain ID where this adapter is deployed
    /// @param protocolAddress The address of the underlying lending protocol contract
    struct AdapterMetadata {
        string symbol;
        uint256 chainId;
        address protocolAddress;
    }

    /// @notice Returns the metadata for this lending adapter
    /// @dev This should be used to generate standardized names for adapters
    /// @return metadata The adapter metadata containing symbol, chainId, and protocolAddress
    function getAdapterMetadata() external view returns (AdapterMetadata memory metadata);

    /// @notice Deposits tokens into the lending protocol
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    /// @param onBehalfOf The address that will receive the aTokens/deposit tokens
    function deposit(Currency token, uint256 amount, address onBehalfOf) external;
}
