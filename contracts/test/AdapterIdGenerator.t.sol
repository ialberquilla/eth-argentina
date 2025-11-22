// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";

contract AdapterIdGeneratorTest is Test {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    function testGenerateAdapterId_Base() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453, // Base
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Expected format: "USDC:BASE:0x12345678"
        assertEq(adapterId, "USDC:BASE:0x12345678");
    }

    function testGenerateAdapterId_Ethereum() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 1, // Ethereum mainnet
            protocolAddress: 0xabcdef1234567890abcdef1234567890abcdef12
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertEq(adapterId, "DAI:ETHEREUM:0xabcdef12");
    }

    function testGenerateAdapterId_Arbitrum() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "WETH",
            chainId: 42161, // Arbitrum
            protocolAddress: 0x9999999999999999999999999999999999999999
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertEq(adapterId, "WETH:ARBITRUM:0x99999999");
    }

    function testGenerateAdapterId_Optimism() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDT",
            chainId: 10, // Optimism
            protocolAddress: 0x0000000000000000000000000000000000000001
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertEq(adapterId, "USDT:OPTIMISM:0x00000000");
    }

    function testGenerateAdapterId_UnknownChain() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "TOKEN",
            chainId: 999999, // Unknown chain
            protocolAddress: 0x1111111111111111111111111111111111111111
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        // Should use default format: CHAIN_{chainId}
        assertEq(adapterId, "TOKEN:CHAIN_999999:0x11111111");
    }

    function testGenerateAdapterIdWithDomain() public pure {
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453,
            protocolAddress: 0x1234567890123456789012345678901234567890
        });

        string memory fullId = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, "adapters.eth");

        assertEq(fullId, "USDC:BASE:0x12345678.adapters.eth");
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

    function testGetAddressHash() public pure {
        address addr = 0x1234567890123456789012345678901234567890;
        string memory hash = AdapterIdGenerator.getAddressHash(addr);

        assertEq(hash, "0x12345678");
    }

    function testGetAddressHash_AllZeros() public pure {
        address addr = 0x0000000000000000000000000000000000000000;
        string memory hash = AdapterIdGenerator.getAddressHash(addr);

        assertEq(hash, "0x00000000");
    }

    function testGetAddressHash_AllFs() public pure {
        address addr = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        string memory hash = AdapterIdGenerator.getAddressHash(addr);

        assertEq(hash, "0xffffffff");
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

        assertEq(adapterId, "USDC:BASE:0xa238dd80");
        assertEq(fullId, "USDC:BASE:0xa238dd80.lending.eth");
    }

    function testRealWorldExample_CompoundOnEthereum() public pure {
        // Simulate Compound adapter on Ethereum
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 1,
            protocolAddress: 0xc3d688B66703497DAA19211EEdff47f25384cdc3 // Example Compound market
        });

        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);

        assertEq(adapterId, "DAI:ETHEREUM:0xc3d688b6");
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
