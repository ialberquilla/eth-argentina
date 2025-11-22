// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILendingAdapter} from "./ILendingAdapter.sol";

/// @title IAdapterRegistry
/// @notice Interface for the adapter registry that manages ENS-based adapter registration
interface IAdapterRegistry {
    /// @notice Emitted when an adapter is registered
    /// @param adapterId The ENS name of the adapter (e.g., "USDC:BASE:swift-fox.adapters.eth")
    /// @param adapterAddress The address of the registered adapter
    /// @param ensNode The ENS namehash of the adapter ID
    event AdapterRegistered(string adapterId, address indexed adapterAddress, bytes32 indexed ensNode);

    /// @notice Registers a lending adapter with ENS
    /// @param adapter The adapter contract to register
    /// @param domain The ENS domain to use (e.g., "adapters.eth")
    /// @dev Generates the adapter ID from the adapter's metadata and registers it in ENS
    function registerAdapter(address adapter, string calldata domain) external;

    /// @notice Resolves an adapter ENS name to its contract address
    /// @param adapterEnsName The full ENS name (e.g., "USDC:BASE:swift-fox.adapters.eth")
    /// @return The adapter contract address
    function resolveAdapter(string calldata adapterEnsName) external view returns (address);

    /// @notice Gets the ENS node for a given adapter address
    /// @param adapter The adapter contract address
    /// @param domain The ENS domain
    /// @return The ENS namehash
    function getAdapterNode(address adapter, string calldata domain) external view returns (bytes32);
}
