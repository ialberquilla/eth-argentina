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
    address constant ADAPTER_REGISTRY = 0x7425AAa97230f6D575193667cfd402b0B89C47f2;
    address constant USDC_ADAPTER = 0x6a546f500b9BDaF1d08acA6DF955e8919886604a;
    address constant USDT_ADAPTER = 0x6F0b25e2abca0b60109549b7823392e3312f505c;

    string constant ADAPTER_DOMAIN = "onetx.base.eth";

    function run() public view {
        console2.log("========================================");
        console2.log("Adapter ENS Names - Base Sepolia");
        console2.log("New ENS-Compatible Format");
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
        console2.log("    \"", usdcEnsName, "\",");
        console2.log("    \"your-recipient.base.eth\"  // Or address");
        console2.log(");");
        console2.log("");
        console2.log("swapRouter.swap(poolKey, swapParams, hookData);");
        console2.log("");
        console2.log("--- ENS NAMING FORMAT ---");
        console2.log("New format: symbol-chain-identifier.base.eth");
        console2.log("Example: usdc-basesepolia-clear-swan.base.eth");
        console2.log("(All lowercase, dashes instead of colons)");
        console2.log("========================================");
    }
}
