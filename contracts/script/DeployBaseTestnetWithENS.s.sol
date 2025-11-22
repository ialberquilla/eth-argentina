// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SwapDepositor} from "../src/SwapDepositor.sol";
import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {HookDeployer} from "../src/HookDeployer.sol";
import {ENSNamehash} from "../src/libraries/ENSNamehash.sol";
import {IENSRegistry} from "../src/interfaces/IENSRegistry.sol";

/// @notice Comprehensive deployment script for Base Sepolia testnet with real ENS integration
/// @dev Deploys all required contracts and registers adapters in Base's ENS (Basenames)
contract DeployBaseTestnetWithENSScript is Script {
    using ENSNamehash for string;

    // Base Sepolia addresses
    address constant POOL_MANAGER = 0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829;
    address constant AAVE_POOL = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;

    // Token addresses on Base Sepolia
    address constant USDC = 0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f;
    address constant USDT = 0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a;

    // Basenames (ENS) contract addresses on Base Sepolia
    address constant ENS_REGISTRY = 0x1493b2567056c2181630115660963E13A8E32735;
    address constant L2_RESOLVER = 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA;

    // ENS domain configuration
    string constant ADAPTER_DOMAIN = "onetx.base.eth";

    function run() public {
        // Verify we're on Base Sepolia
        require(block.chainid == 84532, "This script is only for Base Sepolia (chainId: 84532)");

        console2.log("========================================");
        console2.log("Deploying to Base Sepolia Testnet");
        console2.log("With Real ENS Integration (Basenames)");
        console2.log("Chain ID:", block.chainid);
        console2.log("Deployer:", msg.sender);
        console2.log("========================================\n");

        // Calculate the parent node for base.eth
        bytes32 parentNode = ADAPTER_DOMAIN.namehash();
        console2.log("Parent Node (%s):", ADAPTER_DOMAIN);
        console2.logBytes32(parentNode);
        console2.log("");

        console2.log("IMPORTANT:");
        console2.log("This deployment will attempt to register subdomains under %s.", ADAPTER_DOMAIN);
        console2.log("The deployer MUST own %s.", ADAPTER_DOMAIN);
        console2.log("Ownership of %s will be transferred to the AdapterRegistry to allow subdomain creation.", ADAPTER_DOMAIN);
        console2.log("");

        vm.startBroadcast();

        // ============================================
        // 1. Deploy AdapterRegistry with ENS Integration
        // ============================================
        console2.log("1. Deploying AdapterRegistry with ENS integration...");
        console2.log("   ENS Registry:", ENS_REGISTRY);
        console2.log("   L2 Resolver:", L2_RESOLVER);
        console2.log("   Parent Node:");
        console2.logBytes32(parentNode);
        console2.log("   Domain:", ADAPTER_DOMAIN);

        AdapterRegistry adapterRegistry = new AdapterRegistry(
            ENS_REGISTRY,
            L2_RESOLVER,
            parentNode,
            ADAPTER_DOMAIN
        );
        console2.log("   AdapterRegistry deployed at:", address(adapterRegistry));
        console2.log("");

        // Transfer ownership of the parent node to the AdapterRegistry
        // This allows the registry to create subdomains (e.g. usdc.onetx.base.eth)
        console2.log("   Transferring ownership of %s to AdapterRegistry...", ADAPTER_DOMAIN);
        try IENSRegistry(ENS_REGISTRY).setOwner(parentNode, address(adapterRegistry)) {
             console2.log("   Ownership transferred successfully.");
        } catch Error(string memory reason) {
             console2.log("   FAILED to transfer ownership: %s", reason);
             console2.log("   Ensure deployer (%s) owns %s", msg.sender, ADAPTER_DOMAIN);
        }
        console2.log("");

        // ============================================
        // 2. Deploy Aave Adapters
        // ============================================
        console2.log("2. Deploying Aave Adapters...");

        // Deploy USDC Adapter
        console2.log("   Deploying AaveAdapter for USDC...");
        AaveAdapter usdcAdapter = new AaveAdapter(AAVE_POOL, "USDC");
        console2.log("   USDC AaveAdapter deployed at:", address(usdcAdapter));

        // Deploy USDT Adapter
        console2.log("   Deploying AaveAdapter for USDT...");
        AaveAdapter usdtAdapter = new AaveAdapter(AAVE_POOL, "USDT");
        console2.log("   USDT AaveAdapter deployed at:", address(usdtAdapter));
        console2.log("");

        // ============================================
        // 3. Deploy HookDeployer and SwapDepositor Hook
        // ============================================
        console2.log("3. Deploying Hook infrastructure...");

        // Deploy the HookDeployer contract
        console2.log("   Deploying HookDeployer...");
        HookDeployer hookDeployer = new HookDeployer();
        console2.log("   HookDeployer deployed at:", address(hookDeployer));

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

        // Use the HookDeployer address as the CREATE2 factory
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(hookDeployer),
            flags,
            type(SwapDepositor).creationCode,
            constructorArgs
        );

        console2.log("   Mined salt:", vm.toString(salt));
        console2.log("   Expected hook address:", hookAddress);

        // Deploy the hook using the HookDeployer
        SwapDepositor swapDepositor = hookDeployer.deploy(
            salt,
            IPoolManager(POOL_MANAGER),
            adapterRegistry
        );

        console2.log("   SwapDepositor Hook deployed at:", address(swapDepositor));

        // Verify the address matches
        require(
            address(swapDepositor) == hookAddress,
            "DeployBaseTestnet: Hook address mismatch"
        );
        console2.log("   Hook address matches expected address!");
        console2.log("");

        // ============================================
        // 4. Register Adapters in ENS
        // ============================================
        console2.log("4. Registering Adapters in ENS (Basenames)...");
        console2.log("");

        console2.log("   Registering USDC adapter in ENS...");
        try adapterRegistry.registerAdapter(address(usdcAdapter), ADAPTER_DOMAIN) {
            console2.log("   USDC adapter registered successfully in ENS!");
        } catch Error(string memory reason) {
            console2.log("   WARNING: Failed to register USDC adapter:");
            console2.log("   ", reason);
            console2.log("   This likely means you don't have permission to create subdomains under", ADAPTER_DOMAIN);
        } catch {
            console2.log("   WARNING: Failed to register USDC adapter (unknown error)");
        }
        console2.log("");

        console2.log("   Registering USDT adapter in ENS...");
        try adapterRegistry.registerAdapter(address(usdtAdapter), ADAPTER_DOMAIN) {
            console2.log("   USDT adapter registered successfully in ENS!");
        } catch Error(string memory reason) {
            console2.log("   WARNING: Failed to register USDT adapter:");
            console2.log("   ", reason);
        } catch {
            console2.log("   WARNING: Failed to register USDT adapter (unknown error)");
        }
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
        console2.log("USDT Adapter:", address(usdtAdapter));
        console2.log("");
        console2.log("--- ENS Configuration ---");
        console2.log("ENS Registry:", ENS_REGISTRY);
        console2.log("L2 Resolver:", L2_RESOLVER);
        console2.log("Domain:", ADAPTER_DOMAIN);
        console2.log("");
        console2.log("--- External Dependencies ---");
        console2.log("Pool Manager:", POOL_MANAGER);
        console2.log("Aave V3 Pool:", AAVE_POOL);
        console2.log("");
        console2.log("--- Next Steps ---");
        console2.log("1. Run GetAdapterENSNames script to see the registered ENS names");
        console2.log("2. Verify ENS registration on BaseScan");
        console2.log("3. Create a Uniswap V4 pool using 01_CreatePoolAndAddLiquidity.s.sol");
        console2.log("4. Perform test swaps using 03_Swap.s.sol");
        console2.log("========================================");
    }
}
