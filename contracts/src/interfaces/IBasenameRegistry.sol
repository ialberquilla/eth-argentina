// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IBasenameRegistry
/// @notice Interface for the Basenames Registry contract on Base
/// @dev The registry tracks ownership and resolver addresses for .base.eth names
interface IBasenameRegistry {
    /// @notice Get the resolver address for a given ENS node
    /// @param node The namehash of the ENS name
    /// @return The address of the resolver contract
    function resolver(bytes32 node) external view returns (address);
}
