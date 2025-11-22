// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ENSNamehash
/// @notice Library for computing ENS namehashes according to EIP-137
/// @dev Implements the namehash algorithm for converting human-readable names to bytes32 node identifiers
library ENSNamehash {
    /// @notice Computes the ENS namehash of a domain name
    /// @dev Follows EIP-137: namehash is recursively defined as:
    ///      namehash('') = 0x0000000000000000000000000000000000000000000000000000000000000000
    ///      namehash(label.parent) = keccak256(namehash(parent) + keccak256(label))
    /// @param name The domain name to hash (e.g., "vitalik.base.eth")
    /// @return node The bytes32 namehash of the domain
    function namehash(string memory name) internal pure returns (bytes32 node) {
        node = 0x0000000000000000000000000000000000000000000000000000000000000000;

        // Handle empty string
        if (bytes(name).length == 0) {
            return node;
        }

        // Split the name by '.' and process each label
        // We need to process from right to left (e.g., eth -> base -> vitalik)
        uint256 len = bytes(name).length;
        uint256 labelStart = len;

        // Process from right to left
        for (uint256 i = len; i > 0; i--) {
            if (bytes(name)[i - 1] == "." || i == 1) {
                uint256 start = (i == 1) ? 0 : i;
                uint256 labelLen = labelStart - start;

                // Extract label
                bytes memory label = new bytes(labelLen);
                for (uint256 j = 0; j < labelLen; j++) {
                    label[j] = bytes(name)[start + j];
                }

                // Compute namehash: keccak256(node + keccak256(label))
                node = keccak256(abi.encodePacked(node, keccak256(label)));

                // Move to next label
                labelStart = i - 1;
            }
        }

        return node;
    }

    /// @notice Computes the labelhash (keccak256 of a single label)
    /// @param label The label to hash
    /// @return The keccak256 hash of the label
    function labelhash(string memory label) internal pure returns (bytes32) {
        return keccak256(bytes(label));
    }
}
