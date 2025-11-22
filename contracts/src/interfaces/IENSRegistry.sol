// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IENSRegistry
/// @notice Interface for the ENS Registry contract
/// @dev The registry maps ENS names (represented as namehashes) to owners
interface IENSRegistry {
    /// @notice Returns the owner of a node
    /// @param node The namehash of the name
    /// @return The address of the owner
    function owner(bytes32 node) external view returns (address);

    /// @notice Returns the resolver for a node
    /// @param node The namehash of the name
    /// @return The address of the resolver
    function resolver(bytes32 node) external view returns (address);

    /// @notice Returns the time-to-live (TTL) of a node
    /// @param node The namehash of the name
    /// @return The TTL in seconds
    function ttl(bytes32 node) external view returns (uint64);

    /// @notice Sets the record for a node
    /// @param node The namehash of the name
    /// @param owner_ The address of the new owner
    /// @param resolver_ The address of the resolver
    /// @param ttl_ The TTL in seconds
    function setRecord(bytes32 node, address owner_, address resolver_, uint64 ttl_) external;

    /// @notice Sets a subnode owner
    /// @param node The parent node
    /// @param label The hash of the label
    /// @param owner_ The address of the new owner
    /// @return The namehash of the newly created subnode
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner_) external returns (bytes32);

    /// @notice Sets a subnode record
    /// @param node The parent node
    /// @param label The hash of the label
    /// @param owner_ The address of the new owner
    /// @param resolver_ The address of the resolver
    /// @param ttl_ The TTL in seconds
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner_, address resolver_, uint64 ttl_) external;

    /// @notice Sets the owner of a node
    /// @param node The namehash of the name
    /// @param owner_ The address of the new owner
    function setOwner(bytes32 node, address owner_) external;

    /// @notice Sets the resolver for a node
    /// @param node The namehash of the name
    /// @param resolver_ The address of the resolver
    function setResolver(bytes32 node, address resolver_) external;

    /// @notice Sets the TTL for a node
    /// @param node The namehash of the name
    /// @param ttl_ The TTL in seconds
    function setTTL(bytes32 node, uint64 ttl_) external;

    /// @notice Event emitted when a new owner is set for a node
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    /// @notice Event emitted when a transfer of ownership occurs
    event Transfer(bytes32 indexed node, address owner);

    /// @notice Event emitted when a new resolver is set
    event NewResolver(bytes32 indexed node, address resolver);

    /// @notice Event emitted when a new TTL is set
    event NewTTL(bytes32 indexed node, uint64 ttl);
}
