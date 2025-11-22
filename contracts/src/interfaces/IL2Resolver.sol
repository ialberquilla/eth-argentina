// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IL2Resolver
/// @notice Interface for the L2 Resolver contract used by Basenames
/// @dev The resolver stores address records and other data for ENS names
interface IL2Resolver {
    /// @notice Sets the address for a node
    /// @param node The namehash of the name
    /// @param a The address to set
    function setAddr(bytes32 node, address a) external;

    /// @notice Returns the address associated with an ENS node
    /// @param node The namehash of the name
    /// @return The address associated with the name
    function addr(bytes32 node) external view returns (address);

    /// @notice Sets the address for a specific coin type
    /// @param node The namehash of the name
    /// @param coinType The coin type (e.g., 60 for ETH, 0 for BTC)
    /// @param a The address in bytes format
    function setAddr(bytes32 node, uint256 coinType, bytes memory a) external;

    /// @notice Returns the address for a specific coin type
    /// @param node The namehash of the name
    /// @param coinType The coin type
    /// @return The address in bytes format
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);

    /// @notice Sets a text record for a node
    /// @param node The namehash of the name
    /// @param key The key for the text record
    /// @param value The value to set
    function setText(bytes32 node, string calldata key, string calldata value) external;

    /// @notice Returns a text record for a node
    /// @param node The namehash of the name
    /// @param key The key for the text record
    /// @return The value of the text record
    function text(bytes32 node, string calldata key) external view returns (string memory);

    /// @notice Event emitted when an address is changed
    event AddrChanged(bytes32 indexed node, address a);

    /// @notice Event emitted when an address for a specific coin type is changed
    event AddressChanged(bytes32 indexed node, uint256 coinType, bytes newAddress);

    /// @notice Event emitted when a text record is changed
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key, string value);
}
