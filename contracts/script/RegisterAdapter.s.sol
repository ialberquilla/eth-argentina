// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";

/// @notice Example script showing how to generate standardized adapter IDs for ENS registration
/// @dev This demonstrates the usage of AdapterIdGenerator library
contract RegisterAdapterScript is Script {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    function run() public {
        // Example 1: Generate ID for an existing Aave adapter
        console2.log("\n=== Example 1: Generating ID for Aave USDC Adapter on Base ===");

        // Simulate getting metadata from a deployed adapter
        ILendingAdapter.AdapterMetadata memory metadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDC",
            chainId: 8453, // Base mainnet
            protocolAddress: 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5 // Aave Pool on Base
        });

        // Generate the standardized adapter ID
        string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);
        console2.log("Adapter ID:", adapterId);
        // Output: "USDC:BASE:0xa238dd80"

        // Generate full ENS name
        string memory ensName = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, "adapters.eth");
        console2.log("ENS Name:", ensName);
        // Output: "USDC:BASE:0xa238dd80.adapters.eth"

        // Generate ENS namehash for registration
        bytes32 ensNode = AdapterIdGenerator.generateENSNode(metadata, "adapters.eth");
        console2.log("ENS Node (namehash):");
        console2.logBytes32(ensNode);

        console2.log("\n=== Example 2: Multiple adapters for different chains ===");

        // Ethereum mainnet
        ILendingAdapter.AdapterMetadata memory ethMetadata = ILendingAdapter.AdapterMetadata({
            symbol: "DAI",
            chainId: 1,
            protocolAddress: 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2 // Aave V3 Pool on Ethereum
        });
        console2.log("Ethereum:", AdapterIdGenerator.generateAdapterId(ethMetadata));

        // Arbitrum
        ILendingAdapter.AdapterMetadata memory arbMetadata = ILendingAdapter.AdapterMetadata({
            symbol: "WETH",
            chainId: 42161,
            protocolAddress: 0x794a61358D6845594F94dc1DB02A252b5b4814aD // Aave V3 Pool on Arbitrum
        });
        console2.log("Arbitrum:", AdapterIdGenerator.generateAdapterId(arbMetadata));

        // Optimism
        ILendingAdapter.AdapterMetadata memory opMetadata = ILendingAdapter.AdapterMetadata({
            symbol: "USDT",
            chainId: 10,
            protocolAddress: 0x794a61358D6845594F94dc1DB02A252b5b4814aD // Aave V3 Pool on Optimism
        });
        console2.log("Optimism:", AdapterIdGenerator.generateAdapterId(opMetadata));

        console2.log("\n=== Example 3: Usage with deployed adapter contract ===");

        // If you have a deployed adapter, you can query it directly
        // address adapterAddress = 0x...; // Your deployed adapter
        // ILendingAdapter adapter = ILendingAdapter(adapterAddress);
        // ILendingAdapter.AdapterMetadata memory deployedMetadata = adapter.getAdapterMetadata();
        // string memory deployedAdapterId = AdapterIdGenerator.generateAdapterId(deployedMetadata);
        // console2.log("Deployed Adapter ID:", deployedAdapterId);

        console2.log("\n=== How to use this for ENS registration ===");
        console2.log("1. Deploy your adapter contract");
        console2.log("2. Call getAdapterMetadata() to get the metadata");
        console2.log("3. Use AdapterIdGenerator.generateENSNode() to get the namehash");
        console2.log("4. Register the namehash in your ENS registry");
        console2.log("5. Set the resolver to point to your adapter contract address");
        console2.log("\nThis ensures all adapters follow a consistent naming convention:");
        console2.log("SYMBOL:BLOCKCHAIN:ADDRESS_HASH.domain");
        console2.log("Example: USDC:BASE:0xa238dd80.adapters.eth");
    }
}
