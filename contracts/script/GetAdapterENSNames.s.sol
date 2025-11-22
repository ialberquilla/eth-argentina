// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";

/// @notice Script to get ENS names for deployed adapters
contract GetAdapterENSNamesScript is Script {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    // Deployed addresses on Base Sepolia
    address constant ADAPTER_REGISTRY = 0x045B9a7505164B418A309EdCf9A45EB1fE382951;
    address constant USDC_ADAPTER = 0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF;
    address constant USDT_ADAPTER = 0x5531bc190eC0C74dC8694176Ad849277AbA21a5D;

    string constant ADAPTER_DOMAIN = "base.eth";

    function run() public view {
        console2.log("========================================");
        console2.log("Adapter ENS Names - Base Sepolia");
        console2.log("========================================\n");

        // Get USDC Adapter ENS name
        console2.log("--- USDC Adapter ---");
        console2.log("Address:", USDC_ADAPTER);

        ILendingAdapter.AdapterMetadata memory usdcMetadata =
            AaveAdapter(USDC_ADAPTER).getAdapterMetadata();

        string memory usdcAdapterId = AdapterIdGenerator.generateAdapterId(usdcMetadata);
        string memory usdcEnsName = AdapterIdGenerator.generateAdapterIdWithDomain(usdcMetadata, ADAPTER_DOMAIN);
        bytes32 usdcNode = AdapterIdGenerator.generateENSNode(usdcMetadata, ADAPTER_DOMAIN);

        console2.log("Symbol:", usdcMetadata.symbol);
        console2.log("Chain ID:", usdcMetadata.chainId);
        console2.log("Adapter ID:", usdcAdapterId);
        console2.log("Full ENS Name:", usdcEnsName);
        console2.log("ENS Node:");
        console2.logBytes32(usdcNode);

        // Verify it's registered
        address resolvedUSDC = AdapterRegistry(ADAPTER_REGISTRY).resolveAdapter(usdcEnsName);
        console2.log("Resolved Address:", resolvedUSDC);
        console2.log("Registration Status:", resolvedUSDC == USDC_ADAPTER ? "VERIFIED" : "NOT REGISTERED");
        console2.log("");

        // Get USDT Adapter ENS name
        console2.log("--- USDT Adapter ---");
        console2.log("Address:", USDT_ADAPTER);

        ILendingAdapter.AdapterMetadata memory usdtMetadata =
            AaveAdapter(USDT_ADAPTER).getAdapterMetadata();

        string memory usdtAdapterId = AdapterIdGenerator.generateAdapterId(usdtMetadata);
        string memory usdtEnsName = AdapterIdGenerator.generateAdapterIdWithDomain(usdtMetadata, ADAPTER_DOMAIN);
        bytes32 usdtNode = AdapterIdGenerator.generateENSNode(usdtMetadata, ADAPTER_DOMAIN);

        console2.log("Symbol:", usdtMetadata.symbol);
        console2.log("Chain ID:", usdtMetadata.chainId);
        console2.log("Adapter ID:", usdtAdapterId);
        console2.log("Full ENS Name:", usdtEnsName);
        console2.log("ENS Node:");
        console2.logBytes32(usdtNode);

        // Verify it's registered
        address resolvedUSDT = AdapterRegistry(ADAPTER_REGISTRY).resolveAdapter(usdtEnsName);
        console2.log("Resolved Address:", resolvedUSDT);
        console2.log("Registration Status:", resolvedUSDT == USDT_ADAPTER ? "VERIFIED" : "NOT REGISTERED");
        console2.log("");

        // Summary
        console2.log("========================================");
        console2.log("USAGE EXAMPLE");
        console2.log("========================================\n");
        console2.log("To use these adapters in your swap:");
        console2.log("");
        console2.log("bytes memory hookData = abi.encode(");
        console2.log("    \"", usdcEnsName, "\",  // Adapter ENS name");
        console2.log("    \"0x1234...\"                    // Recipient address or basename");
        console2.log(");");
        console2.log("");
        console2.log("swapRouter.swap(poolKey, swapParams, hookData);");
        console2.log("========================================");
    }
}
