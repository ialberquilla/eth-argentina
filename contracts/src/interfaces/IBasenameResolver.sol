// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IBasenameResolver
/// @notice Interface for the Basenames Resolver contract on Base
/// @dev The resolver maps ENS nodes to addresses and other records
interface IBasenameResolver {
    /// @notice Get the address associated with an ENS node
    /// @param node The namehash of the ENS name
    /// @return The address associated with the name
    function addr(bytes32 node) external view returns (address);
}
