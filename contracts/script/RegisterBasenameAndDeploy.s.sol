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

interface IBaseRegistrar {
    function ownerOf(uint256 id) external view returns (address);
    function reclaim(uint256 id, address owner) external;
}

/// @notice Complete deployment script for Base Sepolia with basename registration
/// @dev This script:
///      1. Helps you register a basename (or uses existing one)
///      2. Deploys all contracts
///      3. Registers adapters with ENS names under your basename
contract RegisterBasenameAndDeployScript is Script {
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
    address constant REGISTRAR_CONTROLLER = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address constant BASE_REGISTRAR = 0xA0c70ec36c010B55E3C434D6c6EbEEC50c705794;

    // === CONFIGURATION ===
    // Set your basename here (the name you registered or will register)
    // Example: "myproject" (will become myproject.base.eth)
    string constant YOUR_BASENAME = "onetx"; // <-- CHANGE THIS!

    function checkAndSyncBasename(
        string memory fullDomain,
        bytes32 basenameNode,
        uint256 tokenId,
        address registrarAddr,
        address registryAddr
    ) internal returns (bool) {
        console2.log("========================================");
        console2.log("STEP 1: Check Basename Registration");
        console2.log("========================================");

        IENSRegistry ensRegistry = IENSRegistry(registryAddr);
        IBaseRegistrar registrar = IBaseRegistrar(registrarAddr);

        // Check Registrar Owner (The true owner of the NFT)
        address registrarOwner = address(0);
        try registrar.ownerOf(tokenId) returns (address owner) {
            registrarOwner = owner;
        } catch {
            console2.log("Name not registered in Registrar.");
        }

        console2.log("Checking ownership of:", fullDomain);
        console2.log("Node Hash:", vm.toString(basenameNode));
        console2.log("Registrar Owner (NFT):", registrarOwner);
        console2.log("Registry Owner (ENS):", ensRegistry.owner(basenameNode));
        console2.log("Your address:", msg.sender);
        console2.log("");

        if (registrarOwner == address(0)) {
            console2.log("WARNING: Basename NOT registered!");
            console2.log("");
            console2.log("You need to register it first:");
            console2.log("1. Go to: https://www.base.org/names");
            console2.log("2. Connect with address:", msg.sender);
            console2.log("3. Register:", fullDomain);
            console2.log("4. Cost: ~$5-10 (testnet might be free)");
            console2.log("");
            console2.log("After registration, run this script again.");
            console2.log("========================================");
            return false;
        }

        if (registrarOwner != msg.sender) {
            console2.log("ERROR: ACCOUNT MISMATCH!");
            console2.log("The basename '%s' is owned by: %s", fullDomain, registrarOwner);
            console2.log("But you are deploying as:      %s", msg.sender);
            console2.log("");
            console2.log("FIX:");
            console2.log("Update your .env file to use the PRIVATE_KEY for %s", registrarOwner);
            console2.log("========================================");
            return false;
        }

        // Check Registry sync status
        if (ensRegistry.owner(basenameNode) != msg.sender) {
            console2.log("WARNING: Registry not synced with Registrar.");
            console2.log("Reclaiming name to update Registry...");

            vm.broadcast();
            registrar.reclaim(tokenId, msg.sender);

            console2.log("Registry synced!");
        }

        console2.log("SUCCESS: You own this basename and Registry is synced!");
        console2.log("You can create unlimited subdomains under it.");
        console2.log("");
        return true;
    }

    function deployContracts(string memory fullDomain, bytes32 basenameNode) internal {
        // ============================================
        // STEP 2: Deploy AdapterRegistry with ENS Integration
        // ============================================
        console2.log("========================================");
        console2.log("STEP 2: Deploy AdapterRegistry");
        console2.log("========================================");
        
        IENSRegistry ensRegistry = IENSRegistry(ENS_REGISTRY);

        console2.log("ENS Registry:", ENS_REGISTRY);
        console2.log("L2 Resolver:", L2_RESOLVER);
        console2.log("Domain:", fullDomain);
        console2.log("Node:", vm.toString(basenameNode));

        AdapterRegistry adapterRegistry = new AdapterRegistry(
            ENS_REGISTRY,
            L2_RESOLVER,
            basenameNode,
            fullDomain
        );
        console2.log("AdapterRegistry deployed at:", address(adapterRegistry));
        console2.log("");

        // Transfer ownership of basename to AdapterRegistry so it can register subdomains
        console2.log("Transferring basename ownership to AdapterRegistry...");
        ensRegistry.setOwner(basenameNode, address(adapterRegistry));
        console2.log("SUCCESS: AdapterRegistry can now register subdomains");
        console2.log("");

        // ============================================
        // STEP 3: Deploy Aave Adapters
        // ============================================
        console2.log("========================================");
        console2.log("STEP 3: Deploy Aave Adapters");
        console2.log("========================================");

        console2.log("Deploying USDC Adapter...");
        AaveAdapter usdcAdapter = new AaveAdapter(AAVE_POOL, "USDC");
        console2.log("USDC Adapter:", address(usdcAdapter));

        console2.log("Deploying USDT Adapter...");
        AaveAdapter usdtAdapter = new AaveAdapter(AAVE_POOL, "USDT");
        console2.log("USDT Adapter:", address(usdtAdapter));
        console2.log("");

        // ============================================
        // STEP 4: Deploy SwapDepositor Hook
        // ============================================
        console2.log("========================================");
        console2.log("STEP 4: Deploy SwapDepositor Hook");
        console2.log("========================================");

        console2.log("Deploying HookDeployer...");
        HookDeployer hookDeployer = new HookDeployer();
        console2.log("HookDeployer:", address(hookDeployer));

        // Hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG |
            Hooks.AFTER_SWAP_FLAG |
            Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG
        );

        console2.log("Mining salt for CREATE2 deployment...");
        bytes memory constructorArgs = abi.encode(
            IPoolManager(POOL_MANAGER),
            adapterRegistry
        );

        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(hookDeployer),
            flags,
            type(SwapDepositor).creationCode,
            constructorArgs
        );

        console2.log("Expected hook address:", hookAddress);
        console2.log("Salt:", vm.toString(salt));

        SwapDepositor swapDepositor = hookDeployer.deploy(
            salt,
            IPoolManager(POOL_MANAGER),
            adapterRegistry
        );

        require(address(swapDepositor) == hookAddress, "Hook address mismatch");
        console2.log("SwapDepositor Hook:", address(swapDepositor));
        console2.log("");

        // ============================================
        // STEP 5: Register Adapters in ENS
        // ============================================
        console2.log("========================================");
        console2.log("STEP 5: Register Adapters in ENS");
        console2.log("========================================");

        console2.log("Registering USDC adapter...");
        adapterRegistry.registerAdapter(address(usdcAdapter), fullDomain);
        console2.log("SUCCESS: USDC adapter registered in ENS");

        console2.log("Registering USDT adapter...");
        adapterRegistry.registerAdapter(address(usdtAdapter), fullDomain);
        console2.log("SUCCESS: USDT adapter registered in ENS");
        console2.log("");

        // ============================================
        // STEP 6: Print Summary
        // ============================================
        console2.log("========================================");
        console2.log("DEPLOYMENT COMPLETE!");
        console2.log("========================================");
        console2.log("");
        console2.log("Network: Base Sepolia");
        console2.log("Deployer:", msg.sender);
        console2.log("");
        console2.log("--- Your Basename ---");
        console2.log("Domain:", fullDomain);
        console2.log("Owner: AdapterRegistry (can create subdomains)");
        console2.log("");
        console2.log("--- Core Contracts ---");
        console2.log("AdapterRegistry:", address(adapterRegistry));
        console2.log("SwapDepositor Hook:", address(swapDepositor));
        console2.log("HookDeployer:", address(hookDeployer));
        console2.log("");
        console2.log("--- Adapters ---");
        console2.log("USDC Adapter:", address(usdcAdapter));
        console2.log("USDT Adapter:", address(usdtAdapter));
        console2.log("");
        console2.log("--- ENS Names Created ---");
        console2.log("USDC: usdc-basesepolia-<words>.", fullDomain);
        console2.log("USDT: usdt-basesepolia-<words>.", fullDomain);
        console2.log("");
        console2.log("--- Next Steps ---");
        console2.log("1. Verify on BaseScan: https://sepolia.basescan.org");
        console2.log("2. Create a pool with script/01_CreatePoolAndAddLiquidity.s.sol");
        console2.log("3. Test swaps with script/03_Swap.s.sol");
        console2.log("");
        console2.log("--- Add More Adapters ---");
        console2.log("To add more adapters in the future:");
        console2.log("1. Deploy new AaveAdapter");
        console2.log("2. Call adapterRegistry.registerAdapter(adapterAddress, \"", fullDomain, "\")");
        console2.log("3. New ENS name created automatically!");
        console2.log("========================================");
    }

    function run() public {
        // Verify we're on Base Sepolia
        require(block.chainid == 84532, "This script is only for Base Sepolia (chainId: 84532)");

        console2.log("========================================");
        console2.log("Base Sepolia Deployment with Basenames");
        console2.log("========================================");
        console2.log("Chain ID:", block.chainid);
        console2.log("Deployer:", msg.sender);
        console2.log("Your basename:", string.concat(YOUR_BASENAME, ".base.eth"));
        console2.log("");

        // Full domain name
        string memory fullDomain = string.concat(YOUR_BASENAME, ".base.eth");
        uint256 tokenId = uint256(keccak256(bytes(YOUR_BASENAME)));

        // Base Sepolia specific parent node for "base.eth"
        // Standard namehash gives 0xff1e... but Base Sepolia actually uses 0x6462...
        bytes32 parentNode = 0x646204f07e7fcd394a508306bf1148a1e13d14287fa33839bf9ad63755f547c6;
        
        // Calculate the correct basename node
        bytes32 basenameNode = keccak256(abi.encodePacked(parentNode, keccak256(bytes(YOUR_BASENAME))));

        // Perform Checks and Sync
        if (!checkAndSyncBasename(fullDomain, basenameNode, tokenId, BASE_REGISTRAR, ENS_REGISTRY)) {
            return;
        }

        vm.startBroadcast();
        deployContracts(fullDomain, basenameNode);
        vm.stopBroadcast();
    }
}
