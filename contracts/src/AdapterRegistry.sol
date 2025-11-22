// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAdapterRegistry} from "./interfaces/IAdapterRegistry.sol";
import {ILendingAdapter} from "./interfaces/ILendingAdapter.sol";
import {IENSRegistry} from "./interfaces/IENSRegistry.sol";
import {IL2Resolver} from "./interfaces/IL2Resolver.sol";
import {AdapterIdGenerator} from "./libraries/AdapterIdGenerator.sol";
import {ENSNamehash} from "./libraries/ENSNamehash.sol";

/// @title AdapterRegistry
/// @notice Registry for lending adapters using ENS-based naming
/// @dev Integrates with real ENS/Basenames contracts on Base
contract AdapterRegistry is IAdapterRegistry {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;
    using ENSNamehash for string;

    /// @notice Information about a registered adapter
    struct AdapterInfo {
        address adapterAddress;
        bytes32 ensNode;
        string domain;
        string adapterId;
    }

    /// @notice The ENS Registry contract
    IENSRegistry public immutable ensRegistry;

    /// @notice The L2 Resolver contract
    IL2Resolver public immutable l2Resolver;

    /// @notice The parent node under which adapters are registered
    bytes32 public immutable parentNode;

    /// @notice The domain being used (e.g., "base.eth")
    string public domain;

    /// @notice Array of all registered adapters
    AdapterInfo[] private registeredAdapters;

    /// @notice Maps adapter addresses to their ENS nodes for a given domain
    mapping(address => mapping(string => bytes32)) private nodesByAdapter;

    /// @notice Constructor
    /// @param _ensRegistry The ENS Registry contract address
    /// @param _l2Resolver The L2 Resolver contract address
    /// @param _parentNode The parent node under which to register adapters
    /// @param _domain The domain being used (e.g., "base.eth")
    constructor(address _ensRegistry, address _l2Resolver, bytes32 _parentNode, string memory _domain) {
        require(_ensRegistry != address(0), "Invalid ENS registry");
        require(_l2Resolver != address(0), "Invalid L2 resolver");
        require(_parentNode != bytes32(0), "Invalid parent node");
        require(bytes(_domain).length > 0, "Invalid domain");

        ensRegistry = IENSRegistry(_ensRegistry);
        l2Resolver = IL2Resolver(_l2Resolver);
        parentNode = _parentNode;
        domain = _domain;
    }

    /// @notice Registers a lending adapter with ENS
    /// @param adapter The adapter contract to register
    /// @param _domain The ENS domain to use (must match the configured domain)
    function registerAdapter(address adapter, string calldata _domain) external override {
        require(adapter != address(0), "Invalid adapter address");
        require(keccak256(bytes(_domain)) == keccak256(bytes(domain)), "Domain mismatch");

        // Get metadata from the adapter
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter(adapter).getAdapterMetadata();

        // Generate the adapter ID (subdomain label)
        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Generate the full ENS name
        string memory fullEnsName = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, domain);

        // Generate the label hash for the subdomain
        bytes32 labelHash = keccak256(bytes(adapterId));

        // Calculate the ENS node hash directly from the parent node and label hash
        // This ensures consistency with the actual node created in the registry
        bytes32 node = keccak256(abi.encodePacked(parentNode, labelHash));

        // Register subdomain in ENS Registry (creates the subdomain under parentNode)
        ensRegistry.setSubnodeRecord(
            parentNode,
            labelHash,
            address(this), // This contract owns the subdomain
            address(l2Resolver),
            0 // TTL
        );

        // Set the address record in the resolver
        l2Resolver.setAddr(node, adapter);

        // Store the mapping for lookup
        nodesByAdapter[adapter][domain] = node;

        // Add to registry array
        registeredAdapters.push(
            AdapterInfo({
                adapterAddress: adapter,
                ensNode: node,
                domain: domain,
                adapterId: fullEnsName
            })
        );

        emit AdapterRegistered(fullEnsName, adapter, node);
    }

    /// @notice Resolves an adapter ENS name to its contract address
    /// @param adapterEnsName The full ENS name (e.g., "usdc-basesepolia-swift-fox.base.eth")
    /// @return The adapter contract address
    function resolveAdapter(string calldata adapterEnsName) external view override returns (address) {
        bytes32 node = adapterEnsName.namehash();

        // Get the resolver for this node
        address resolverAddress = ensRegistry.resolver(node);
        require(resolverAddress != address(0), "No resolver found");

        // Query the resolver for the address
        address adapter = IL2Resolver(resolverAddress).addr(node);
        require(adapter != address(0), "Adapter not registered");

        return adapter;
    }

    /// @notice Gets the ENS node for a given adapter address
    /// @param adapter The adapter contract address
    /// @param _domain The ENS domain
    /// @return The ENS namehash
    function getAdapterNode(address adapter, string calldata _domain) external view override returns (bytes32) {
        bytes32 node = nodesByAdapter[adapter][_domain];
        require(node != bytes32(0), "Adapter not registered for this domain");
        return node;
    }

    /// @notice Gets all registered adapters
    /// @return An array of all registered adapter information
    function getAllRegisteredAdapters() external view returns (AdapterInfo[] memory) {
        return registeredAdapters;
    }

    /// @notice Gets the total number of registered adapters
    /// @return The count of registered adapters
    function getRegisteredAdapterCount() external view returns (uint256) {
        return registeredAdapters.length;
    }
}
