// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAdapterRegistry} from "./interfaces/IAdapterRegistry.sol";
import {ILendingAdapter} from "./interfaces/ILendingAdapter.sol";
import {AdapterIdGenerator} from "./libraries/AdapterIdGenerator.sol";
import {ENSNamehash} from "./libraries/ENSNamehash.sol";

/// @title AdapterRegistry
/// @notice Registry for lending adapters using ENS-based naming
/// @dev This is a simple in-memory registry for testing. In production, this would interact with actual ENS contracts
contract AdapterRegistry is IAdapterRegistry {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;
    using ENSNamehash for string;

    /// @notice Maps ENS nodes to adapter addresses
    mapping(bytes32 => address) private adaptersByNode;

    /// @notice Maps adapter addresses to their ENS nodes for a given domain
    mapping(address => mapping(string => bytes32)) private nodesByAdapter;

    /// @notice Registers a lending adapter with ENS
    /// @param adapter The adapter contract to register
    /// @param domain The ENS domain to use (e.g., "base.eth")
    function registerAdapter(address adapter, string calldata domain) external override {
        require(adapter != address(0), "Invalid adapter address");
        require(bytes(domain).length > 0, "Invalid domain");

        // Get metadata from the adapter
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter(adapter).getAdapterMetadata();

        // Generate the full ENS name
        string memory adapterId = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, domain);

        // Generate the ENS node (namehash)
        bytes32 node = AdapterIdGenerator.generateENSNode(metadata, domain);

        // Register the adapter
        adaptersByNode[node] = adapter;
        nodesByAdapter[adapter][domain] = node;

        emit AdapterRegistered(adapterId, adapter, node);
    }

    /// @notice Resolves an adapter ENS name to its contract address
    /// @param adapterEnsName The full ENS name (e.g., "USDC:BASE:swift-fox.base.eth")
    /// @return The adapter contract address
    function resolveAdapter(string calldata adapterEnsName) external view override returns (address) {
        bytes32 node = adapterEnsName.namehash();
        address adapter = adaptersByNode[node];
        require(adapter != address(0), "Adapter not registered");
        return adapter;
    }

    /// @notice Gets the ENS node for a given adapter address
    /// @param adapter The adapter contract address
    /// @param domain The ENS domain
    /// @return The ENS namehash
    function getAdapterNode(address adapter, string calldata domain) external view override returns (bytes32) {
        bytes32 node = nodesByAdapter[adapter][domain];
        require(node != bytes32(0), "Adapter not registered for this domain");
        return node;
    }
}
