// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {ENSNamehash} from "./ENSNamehash.sol";

/// @title AdapterIdGenerator
/// @notice Library for generating standardized adapter identifiers for ENS registration
/// @dev Generates human-readable IDs in the format: SYMBOL:BLOCKCHAIN:WORD-WORD
library AdapterIdGenerator {
    using ENSNamehash for string;

    /// @notice Generates a standardized adapter ID from adapter metadata
    /// @dev Format: SYMBOL:BLOCKCHAIN:WORD-WORD (e.g., "USDC:BASE:swift-fox")
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
    /// @dev Format: SYMBOL:BLOCKCHAIN:WORD-WORD.domain (e.g., "USDC:BASE:swift-fox.base.eth")
    /// @param metadata The adapter metadata containing symbol, chainId, and protocolAddress
    /// @param domain The domain suffix to append (e.g., "base.eth" or "eth")
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
    /// @param domain The ENS domain to use (e.g., "base.eth" or "eth")
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

    /// @notice Generates a human-readable identifier from a contract address
    /// @dev Uses word-based encoding for better readability (e.g., "swift-fox")
    /// @param addr The address to encode
    /// @return addressId The human-readable address identifier
    function getAddressHash(address addr) internal pure returns (string memory) {
        // Hash the address to get deterministic bytes
        bytes32 hash = keccak256(abi.encodePacked(addr));

        // Extract first 4 bytes for word selection
        uint16 adjIndex = uint16(uint8(hash[0])) | (uint16(uint8(hash[1])) << 8);
        uint16 nounIndex = uint16(uint8(hash[2])) | (uint16(uint8(hash[3])) << 8);

        // Get words from dictionaries (modulo to stay within bounds)
        string memory adjective = getAdjective(adjIndex % 64);
        string memory noun = getNoun(nounIndex % 64);

        return string(abi.encodePacked(adjective, "-", noun));
    }

    /// @notice Returns an adjective from a predefined list
    /// @param index The index of the adjective (0-63)
    /// @return The adjective string
    function getAdjective(uint256 index) internal pure returns (string memory) {
        if (index == 0) return "swift";
        if (index == 1) return "bright";
        if (index == 2) return "calm";
        if (index == 3) return "bold";
        if (index == 4) return "wise";
        if (index == 5) return "pure";
        if (index == 6) return "noble";
        if (index == 7) return "brave";
        if (index == 8) return "quick";
        if (index == 9) return "smart";
        if (index == 10) return "proud";
        if (index == 11) return "fresh";
        if (index == 12) return "crisp";
        if (index == 13) return "clear";
        if (index == 14) return "warm";
        if (index == 15) return "cool";
        if (index == 16) return "fair";
        if (index == 17) return "true";
        if (index == 18) return "deep";
        if (index == 19) return "vast";
        if (index == 20) return "rich";
        if (index == 21) return "sage";
        if (index == 22) return "keen";
        if (index == 23) return "wild";
        if (index == 24) return "free";
        if (index == 25) return "lucky";
        if (index == 26) return "happy";
        if (index == 27) return "sunny";
        if (index == 28) return "misty";
        if (index == 29) return "snowy";
        if (index == 30) return "stormy";
        if (index == 31) return "windy";
        if (index == 32) return "lunar";
        if (index == 33) return "solar";
        if (index == 34) return "cosmic";
        if (index == 35) return "magic";
        if (index == 36) return "royal";
        if (index == 37) return "golden";
        if (index == 38) return "silver";
        if (index == 39) return "amber";
        if (index == 40) return "jade";
        if (index == 41) return "ruby";
        if (index == 42) return "pearl";
        if (index == 43) return "onyx";
        if (index == 44) return "steel";
        if (index == 45) return "iron";
        if (index == 46) return "bronze";
        if (index == 47) return "copper";
        if (index == 48) return "nimble";
        if (index == 49) return "agile";
        if (index == 50) return "steady";
        if (index == 51) return "stable";
        if (index == 52) return "mighty";
        if (index == 53) return "gentle";
        if (index == 54) return "subtle";
        if (index == 55) return "grand";
        if (index == 56) return "prime";
        if (index == 57) return "vital";
        if (index == 58) return "vivid";
        if (index == 59) return "sleek";
        if (index == 60) return "smooth";
        if (index == 61) return "rapid";
        if (index == 62) return "fleet";
        return "stellar";
    }

    /// @notice Returns a noun from a predefined list
    /// @param index The index of the noun (0-63)
    /// @return The noun string
    function getNoun(uint256 index) internal pure returns (string memory) {
        if (index == 0) return "fox";
        if (index == 1) return "wolf";
        if (index == 2) return "bear";
        if (index == 3) return "hawk";
        if (index == 4) return "eagle";
        if (index == 5) return "lion";
        if (index == 6) return "tiger";
        if (index == 7) return "dragon";
        if (index == 8) return "phoenix";
        if (index == 9) return "raven";
        if (index == 10) return "owl";
        if (index == 11) return "falcon";
        if (index == 12) return "panther";
        if (index == 13) return "lynx";
        if (index == 14) return "orca";
        if (index == 15) return "shark";
        if (index == 16) return "whale";
        if (index == 17) return "dolphin";
        if (index == 18) return "seal";
        if (index == 19) return "otter";
        if (index == 20) return "moose";
        if (index == 21) return "bison";
        if (index == 22) return "mustang";
        if (index == 23) return "stallion";
        if (index == 24) return "cobra";
        if (index == 25) return "viper";
        if (index == 26) return "python";
        if (index == 27) return "condor";
        if (index == 28) return "osprey";
        if (index == 29) return "kestrel";
        if (index == 30) return "sparrow";
        if (index == 31) return "robin";
        if (index == 32) return "heron";
        if (index == 33) return "crane";
        if (index == 34) return "swan";
        if (index == 35) return "goose";
        if (index == 36) return "duck";
        if (index == 37) return "beaver";
        if (index == 38) return "badger";
        if (index == 39) return "weasel";
        if (index == 40) return "marten";
        if (index == 41) return "ferret";
        if (index == 42) return "mink";
        if (index == 43) return "stoat";
        if (index == 44) return "jackal";
        if (index == 45) return "coyote";
        if (index == 46) return "dingo";
        if (index == 47) return "hyena";
        if (index == 48) return "cheetah";
        if (index == 49) return "leopard";
        if (index == 50) return "jaguar";
        if (index == 51) return "cougar";
        if (index == 52) return "puma";
        if (index == 53) return "ocelot";
        if (index == 54) return "caracal";
        if (index == 55) return "serval";
        if (index == 56) return "gazelle";
        if (index == 57) return "antelope";
        if (index == 58) return "ibex";
        if (index == 59) return "ram";
        if (index == 60) return "elk";
        if (index == 61) return "deer";
        if (index == 62) return "stag";
        return "bison";
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
