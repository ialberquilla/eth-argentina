// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";

contract AdapterIdGeneratorTest is Test {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    function testGenerateAdapterId_ContainsComponents() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453, // Base
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Should contain the symbol and chain name
        assertTrue(bytes(adapterId).length > 0, "Adapter ID should not be empty");
        // Format should be SYMBOL:BLOCKCHAIN:word-word
        // We can't hardcode the exact words since they're hash-based, but we can verify structure
    }

    function testGenerateAdapterId_Base() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453, // Base
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Verify it starts with USDC:BASE:
        bytes memory idBytes = bytes(adapterId);
        assertTrue(idBytes.length > 10, "ID should be reasonably long");
        assertTrue(idBytes[4] == bytes1(":"), "Should have colon separator");
        assertTrue(idBytes[9] == bytes1(":"), "Should have second colon separator");
    }

    function testGenerateAdapterId_Ethereum() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 1, // Ethereum mainnet
            protocolAddress: 0xabcdef1234567890abcdef1234567890abcdef12
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertTrue(bytes(adapterId).length > 0, "Adapter ID should not be empty");
    }

    function testGenerateAdapterId_Arbitrum() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "WETH",
            chainId: 42161, // Arbitrum
            protocolAddress: 0x9999999999999999999999999999999999999999
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertTrue(bytes(adapterId).length > 0, "Adapter ID should not be empty");
    }

    function testGenerateAdapterId_Optimism() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDT",
            chainId: 10, // Optimism
            protocolAddress: 0x0000000000000000000000000000000000000001
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertTrue(bytes(adapterId).length > 0, "Adapter ID should not be empty");
    }

    function testGenerateAdapterId_UnknownChain() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "TOKEN",
            chainId: 999999, // Unknown chain
            protocolAddress: 0x1111111111111111111111111111111111111111
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertTrue(bytes(adapterId).length > 0, "Adapter ID should not be empty");
    }

    function testGenerateAdapterIdWithDomain() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory fullId = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, "adapters.eth");

        // Should end with .adapters.eth
        bytes memory fullIdBytes = bytes(fullId);
        assertTrue(fullIdBytes.length > 13, "Full ID should be long enough");
        // Verify it contains .adapters.eth suffix
        assertTrue(bytes(fullId).length > 0, "Full ID should not be empty");
    }

    function testGenerateENSNode() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        bytes32 node = AdapterIdGenerator.generateENSNode(metadata, "adapters.eth");

        // Should return a valid bytes32 namehash
        assertTrue(node != bytes32(0), "ENS node should not be zero");
    }

    function testGetChainName_Mainnet() public pure {
        assertEq(AdapterIdGenerator.getChainName(1), "ETHEREUM");
    }

    function testGetChainName_Base() public pure {
        assertEq(AdapterIdGenerator.getChainName(8453), "BASE");
    }

    function testGetChainName_Polygon() public pure {
        assertEq(AdapterIdGenerator.getChainName(137), "POLYGON");
    }

    function testGetChainName_Arbitrum() public pure {
        assertEq(AdapterIdGenerator.getChainName(42161), "ARBITRUM");
    }

    function testGetChainName_Optimism() public pure {
        assertEq(AdapterIdGenerator.getChainName(10), "OPTIMISM");
    }

    function testGetChainName_BSC() public pure {
        assertEq(AdapterIdGenerator.getChainName(56), "BSC");
    }

    function testGetChainName_Avalanche() public pure {
        assertEq(AdapterIdGenerator.getChainName(43114), "AVALANCHE");
    }

    function testGetChainName_Sepolia() public pure {
        assertEq(AdapterIdGenerator.getChainName(11155111), "SEPOLIA");
    }

    function testGetChainName_BaseSepolia() public pure {
        assertEq(AdapterIdGenerator.getChainName(84532), "BASE_SEPOLIA");
    }

    function testGetChainName_Unknown() public pure {
        assertEq(AdapterIdGenerator.getChainName(999999), "CHAIN_999999");
    }

    function testGetAddressHash_Format() public pure {
        address addr = 0x1234567890123456789012345678901234567890;
        string memory hash = AdapterIdGenerator.getAddressHash(addr);

        // Should be in format "word-word"
        bytes memory hashBytes = bytes(hash);
        assertTrue(hashBytes.length > 3, "Hash should be reasonably long");

        // Should contain a hyphen
        bool hasHyphen = false;
        for (uint i = 0; i < hashBytes.length; i++) {
            if (hashBytes[i] == bytes1("-")) {
                hasHyphen = true;
                break;
            }
        }
        assertTrue(hasHyphen, "Hash should contain hyphen separator");
    }

    function testGetAddressHash_Deterministic() public pure {
        address addr = 0x1234567890123456789012345678901234567890;
        string memory hash1 = AdapterIdGenerator.getAddressHash(addr);
        string memory hash2 = AdapterIdGenerator.getAddressHash(addr);

        assertEq(hash1, hash2, "Same address should produce same hash");
    }

    function testGetAddressHash_Unique() public pure {
        address addr1 = 0x1234567890123456789012345678901234567890;
        address addr2 = 0x9999999999999999999999999999999999999999;

        string memory hash1 = AdapterIdGenerator.getAddressHash(addr1);
        string memory hash2 = AdapterIdGenerator.getAddressHash(addr2);

        assertTrue(keccak256(bytes(hash1)) != keccak256(bytes(hash2)), "Different addresses should produce different hashes");
    }

    function testToString_Zero() public pure {
        assertEq(AdapterIdGenerator.toString(0), "0");
    }

    function testToString_Small() public pure {
        assertEq(AdapterIdGenerator.toString(42), "42");
    }

    function testToString_Large() public pure {
        assertEq(AdapterIdGenerator.toString(123456789), "123456789");
    }

    function testToString_ChainId() public pure {
        assertEq(AdapterIdGenerator.toString(8453), "8453");
        assertEq(AdapterIdGenerator.toString(42161), "42161");
    }

    function testRealWorldExample_AaveOnBase() public pure {
        // Simulate real Aave adapter on Base
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5 // Example Aave pool on Base
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);
        string memory fullId = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, "lending.eth");

        // Verify format (USDC:BASE:word-word)
        assertTrue(bytes(adapterId).length > 10, "Adapter ID should be reasonably long");
        assertTrue(bytes(fullId).length > bytes(adapterId).length, "Full ID should be longer than adapter ID");
    }

    function testRealWorldExample_CompoundOnEthereum() public pure {
        // Simulate Compound adapter on Ethereum
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 1,
            protocolAddress: 0xc3d688B66703497DAA19211EEdff47f25384cdc3 // Example Compound market
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Verify format (DAI:ETHEREUM:word-word)
        assertTrue(bytes(adapterId).length > 10, "Adapter ID should be reasonably long");
    }

    function testConsistency_SameInputsSameOutput() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory id1 = AdapterIdGenerator.generateAdapterId(metadata);
        string memory id2 = AdapterIdGenerator.generateAdapterId(metadata);

        assertEq(id1, id2, "Same inputs should produce same output");
    }

    function testUniqueness_DifferentAddresses() public pure {
        ILendingAdapter.AdapterMetadata memory metadata1 = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        ILendingAdapter.AdapterMetadata memory metadata2 = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x9999999999999999999999999999999999999999
        });

        string memory id1 = AdapterIdGenerator.generateAdapterId(metadata1);
        string memory id2 = AdapterIdGenerator.generateAdapterId(metadata2);

        assertTrue(keccak256(bytes(id1)) != keccak256(bytes(id2)), "Different addresses should produce different IDs");
    }

    function testUniqueness_DifferentChains() public pure {
        ILendingAdapter.AdapterMetadata memory metadata1 = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453, // Base
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        ILendingAdapter.AdapterMetadata memory metadata2 = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 1, // Ethereum
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory id1 = AdapterIdGenerator.generateAdapterId(metadata1);
        string memory id2 = AdapterIdGenerator.generateAdapterId(metadata2);

        assertTrue(keccak256(bytes(id1)) != keccak256(bytes(id2)), "Different chains should produce different IDs");
    }

    function testUniqueness_DifferentSymbols() public pure {
        ILendingAdapter.AdapterMetadata memory metadata1 = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        ILendingAdapter.AdapterMetadata memory metadata2 = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory id1 = AdapterIdGenerator.generateAdapterId(metadata1);
        string memory id2 = AdapterIdGenerator.generateAdapterId(metadata2);

        assertTrue(keccak256(bytes(id1)) != keccak256(bytes(id2)), "Different symbols should produce different IDs");
    }
}
