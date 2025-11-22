// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {ENSNamehash} from "./ENSNamehash.sol";

/// @title AdapterIdGenerator
/// @notice Library for generating standardized adapter identifiers for ENS registration
/// @dev Generates human-readable IDs in the format: SYMBOL:BLOCKCHAIN:ADDRESS_HASH
library AdapterIdGenerator {
    using ENSNamehash for string;

    /// @notice Generates a standardized adapter ID from adapter metadata
    /// @dev Format: SYMBOL:BLOCKCHAIN:ADDRESS_HASH (e.g., "USDC:BASE:0x1234abcd")
    /// @param metadata The adapter metadata containing symbol, chainId, and protocolAddress
    /// @return adapterId The standardized human-readable adapter ID
    function generateAdapterId(ILendingAdapter.AdapterMetadata memory metadata)
        internal
        pure
        returns (string memory)
    {
        string memory chainName = getChainName(metadata.chainId);
        string memory addressHash = getAddressHash(metadata.protocolAddress);

        return string(
            abi.encodePacked(
                metadata.symbol,
                ":",
                chainName,
                ":",
                addressHash
            )
        );
    }

    /// @notice Generates a standardized adapter ID with a custom domain suffix
    /// @dev Format: SYMBOL:BLOCKCHAIN:ADDRESS_HASH.domain (e.g., "USDC:BASE:0x1234abcd.adapters.eth")
    /// @param metadata The adapter metadata containing symbol, chainId, and protocolAddress
    /// @param domain The domain suffix to append (e.g., "adapters.eth")
    /// @return fullId The full adapter ID with domain
    function generateAdapterIdWithDomain(
        ILendingAdapter.AdapterMetadata memory metadata,
        string memory domain
    ) internal pure returns (string memory) {
        string memory adapterId = generateAdapterId(metadata);
        return string(abi.encodePacked(adapterId, ".", domain));
    }

    /// @notice Generates an ENS namehash for the adapter ID
    /// @dev Useful for registering the adapter in ENS
    /// @param metadata The adapter metadata
    /// @param domain The ENS domain to use (e.g., "adapters.eth")
    /// @return node The ENS namehash (bytes32)
    function generateENSNode(
        ILendingAdapter.AdapterMetadata memory metadata,
        string memory domain
    ) internal pure returns (bytes32) {
        string memory fullId = generateAdapterIdWithDomain(metadata, domain);
        return fullId.namehash();
    }

    /// @notice Converts a chainId to a human-readable blockchain name
    /// @param chainId The chain ID to convert
    /// @return chainName The uppercase blockchain name
    function getChainName(uint256 chainId) internal pure returns (string memory) {
        if (chainId == 1) return "ETHEREUM";
        if (chainId == 8453) return "BASE";
        if (chainId == 10) return "OPTIMISM";
        if (chainId == 42161) return "ARBITRUM";
        if (chainId == 137) return "POLYGON";
        if (chainId == 56) return "BSC";
        if (chainId == 43114) return "AVALANCHE";
        if (chainId == 250) return "FANTOM";
        if (chainId == 100) return "GNOSIS";
        if (chainId == 42220) return "CELO";
        if (chainId == 1284) return "MOONBEAM";
        if (chainId == 1285) return "MOONRIVER";
        if (chainId == 25) return "CRONOS";
        if (chainId == 1313161554) return "AURORA";
        if (chainId == 42262) return "OASIS";
        if (chainId == 1101) return "POLYGONZKEVM";
        if (chainId == 324) return "ZKSYNC";
        if (chainId == 59144) return "LINEA";
        if (chainId == 534352) return "SCROLL";
        if (chainId == 81457) return "BLAST";
        if (chainId == 5000) return "MANTLE";

        // Testnets
        if (chainId == 11155111) return "SEPOLIA";
        if (chainId == 84532) return "BASE_SEPOLIA";
        if (chainId == 421614) return "ARBITRUM_SEPOLIA";
        if (chainId == 11155420) return "OPTIMISM_SEPOLIA";
        if (chainId == 80002) return "AMOY";

        // Default: return "CHAIN_{chainId}"
        return string(abi.encodePacked("CHAIN_", toString(chainId)));
    }

    /// @notice Extracts a human-friendly hash from a contract address
    /// @dev Returns the first 10 characters (including 0x prefix) of the address
    /// @param addr The address to hash
    /// @return addressHash The shortened address hash (e.g., "0x1234abcd")
    function getAddressHash(address addr) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory addrBytes = abi.encodePacked(addr);
        bytes memory result = new bytes(10); // "0x" + 8 chars

        result[0] = "0";
        result[1] = "x";

        // Take first 4 bytes of the address (8 hex characters)
        for (uint256 i = 0; i < 4; i++) {
            result[2 + i * 2] = alphabet[uint8(addrBytes[i] >> 4)];
            result[3 + i * 2] = alphabet[uint8(addrBytes[i] & 0x0f)];
        }

        return string(result);
    }

    /// @notice Converts a uint256 to a string
    /// @param value The number to convert
    /// @return The string representation
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
