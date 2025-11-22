// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import {SwapDepositor} from "../src/SwapDepositor.sol";
import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";

/// @notice Comprehensive deployment script for Base Sepolia testnet
/// @dev Deploys all required contracts: AdapterRegistry, AaveAdapters, and SwapDepositor Hook
contract DeployBaseTestnetScript is Script {
    // Base Sepolia addresses
    address constant POOL_MANAGER = 0x7Da1D65F8B249183667cdE74C5cbd46dD38AA829;
    address constant AAVE_POOL = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;
    address constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    // Token addresses on Base Sepolia
    address constant USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant USDbC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA; // USD Base Coin

    // ENS domain for adapters
    string constant ADAPTER_DOMAIN = "adapters.eth";

    function run() public {
        // Verify we're on Base Sepolia
        require(block.chainid == 84532, "This script is only for Base Sepolia (chainId: 84532)");

        console2.log("========================================");
        console2.log("Deploying to Base Sepolia Testnet");
        console2.log("Chain ID:", block.chainid);
        console2.log("Deployer:", msg.sender);
        console2.log("========================================\n");

        vm.startBroadcast();

        // ============================================
        // 1. Deploy AdapterRegistry
        // ============================================
        console2.log("1. Deploying AdapterRegistry...");
        AdapterRegistry adapterRegistry = new AdapterRegistry();
        console2.log("   AdapterRegistry deployed at:", address(adapterRegistry));
        console2.log("");

        // ============================================
        // 2. Deploy Aave Adapters
        // ============================================
        console2.log("2. Deploying Aave Adapters...");

        // Deploy USDC Adapter
        console2.log("   Deploying AaveAdapter for USDC...");
        AaveAdapter usdcAdapter = new AaveAdapter(AAVE_POOL, "USDC");
        console2.log("   USDC AaveAdapter deployed at:", address(usdcAdapter));

        // Deploy USDbC Adapter
        console2.log("   Deploying AaveAdapter for USDbC...");
        AaveAdapter usdBcAdapter = new AaveAdapter(AAVE_POOL, "USDbC");
        console2.log("   USDbC AaveAdapter deployed at:", address(usdBcAdapter));
        console2.log("");

        // ============================================
        // 3. Deploy SwapDepositor Hook with CREATE2
        // ============================================
        console2.log("3. Deploying SwapDepositor Hook...");

        // Hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG |
            Hooks.AFTER_SWAP_FLAG |
            Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG
        );

        console2.log("   Mining salt for CREATE2 deployment...");
        console2.log("   Required flags:", flags);

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory constructorArgs = abi.encode(
            IPoolManager(POOL_MANAGER),
            adapterRegistry
        );

        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_FACTORY,
            flags,
            type(SwapDepositor).creationCode,
            constructorArgs
        );

        console2.log("   Mined salt:", vm.toString(salt));
        console2.log("   Expected hook address:", hookAddress);

        // Deploy the hook using CREATE2
        SwapDepositor swapDepositor = new SwapDepositor{salt: salt}(
            IPoolManager(POOL_MANAGER),
            adapterRegistry
        );

        require(
            address(swapDepositor) == hookAddress,
            "DeployBaseTestnet: Hook address mismatch"
        );

        console2.log("   SwapDepositor Hook deployed at:", address(swapDepositor));
        console2.log("");

        // ============================================
        // 4. Register Adapters
        // ============================================
        console2.log("4. Registering Adapters in Registry...");

        console2.log("   Registering USDC adapter...");
        adapterRegistry.registerAdapter(address(usdcAdapter), ADAPTER_DOMAIN);
        console2.log("   USDC adapter registered");

        console2.log("   Registering USDbC adapter...");
        adapterRegistry.registerAdapter(address(usdBcAdapter), ADAPTER_DOMAIN);
        console2.log("   USDbC adapter registered");
        console2.log("");

        vm.stopBroadcast();

        // ============================================
        // 5. Print Deployment Summary
        // ============================================
        console2.log("========================================");
        console2.log("DEPLOYMENT SUMMARY");
        console2.log("========================================");
        console2.log("");
        console2.log("Network: Base Sepolia (Chain ID: 84532)");
        console2.log("Deployer:", msg.sender);
        console2.log("");
        console2.log("--- Core Contracts ---");
        console2.log("AdapterRegistry:", address(adapterRegistry));
        console2.log("SwapDepositor Hook:", address(swapDepositor));
        console2.log("");
        console2.log("--- Aave Adapters ---");
        console2.log("USDC Adapter:", address(usdcAdapter));
        console2.log("USDbC Adapter:", address(usdBcAdapter));
        console2.log("");
        console2.log("--- External Dependencies ---");
        console2.log("Pool Manager:", POOL_MANAGER);
        console2.log("Aave V3 Pool:", AAVE_POOL);
        console2.log("");
        console2.log("--- Next Steps ---");
        console2.log("1. Verify contracts on Basescan (if needed)");
        console2.log("2. Create a Uniswap V4 pool using 01_CreatePoolAndAddLiquidity.s.sol");
        console2.log("3. Perform test swaps using 03_Swap.s.sol");
        console2.log("");
        console2.log("--- Adapter ENS Names ---");
        console2.log("Adapters can be resolved using their ENS names:");
        console2.log("Format: SYMBOL:BASE_SEPOLIA:random-words.adapters.eth");
        console2.log("(Exact names are generated dynamically based on adapter address)");
        console2.log("========================================");
    }
}
