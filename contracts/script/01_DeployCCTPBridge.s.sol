// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CCTPBridge} from "../src/CCTPBridge.sol";

/**
 * @title DeployCCTPBridge
 * @notice Deployment script for CCTPBridge contract
 * @dev Usage:
 *   Arc Testnet to Base Sepolia:
 *     forge script script/01_DeployCCTPBridge.s.sol:DeployCCTPBridge --rpc-url arc-testnet --broadcast --verify
 *   Base Sepolia (for receiving):
 *     forge script script/01_DeployCCTPBridge.s.sol:DeployCCTPBridge --rpc-url base-sepolia --broadcast --verify
 */
contract DeployCCTPBridge is Script {
    // Arc Testnet CCTP addresses (Domain: 26)
    address constant ARC_TESTNET_TOKEN_MESSENGER = 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA;
    address constant ARC_TESTNET_MESSAGE_TRANSMITTER = 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275;
    address constant ARC_TESTNET_USDC = 0x3600000000000000000000000000000000000000;
    uint32 constant BASE_SEPOLIA_DOMAIN = 6;

    // Base Sepolia CCTP addresses (Domain: 6)
    address constant BASE_SEPOLIA_TOKEN_MESSENGER = 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA;
    address constant BASE_SEPOLIA_MESSAGE_TRANSMITTER = 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275;
    address constant BASE_SEPOLIA_USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    uint32 constant ARC_TESTNET_DOMAIN = 26;

    // Base Mainnet CCTP addresses (Domain: 6)
    address constant BASE_MAINNET_TOKEN_MESSENGER = 0x1682Ae6375C4E4A97e4B583BC394c861A46D8962;
    address constant BASE_MAINNET_MESSAGE_TRANSMITTER = 0x0000000000000000000000000000000000000000; // Update
    address constant BASE_MAINNET_USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 chainId = block.chainid;

        console.log("Deploying CCTPBridge on chain:", chainId);

        vm.startBroadcast(deployerPrivateKey);

        CCTPBridge bridge;

        if (chainId == 23244) {
            // Arc Testnet - Deploy bridge for Arc -> Base Sepolia
            console.log("Deploying Arc Testnet -> Base Sepolia bridge");
            bridge = new CCTPBridge(
                ARC_TESTNET_TOKEN_MESSENGER,
                ARC_TESTNET_MESSAGE_TRANSMITTER,
                ARC_TESTNET_USDC,
                BASE_SEPOLIA_DOMAIN
            );
        } else if (chainId == 84532) {
            // Base Sepolia - Deploy bridge for receiving from Arc
            console.log("Deploying Base Sepolia bridge (receiver)");
            bridge = new CCTPBridge(
                BASE_SEPOLIA_TOKEN_MESSENGER,
                BASE_SEPOLIA_MESSAGE_TRANSMITTER,
                BASE_SEPOLIA_USDC,
                ARC_TESTNET_DOMAIN
            );
        } else if (chainId == 8453) {
            // Base Mainnet
            console.log("Deploying Base Mainnet bridge");
            bridge = new CCTPBridge(
                BASE_MAINNET_TOKEN_MESSENGER,
                BASE_MAINNET_MESSAGE_TRANSMITTER,
                BASE_MAINNET_USDC,
                ARC_TESTNET_DOMAIN // or Arc Mainnet domain when available
            );
        } else {
            revert("Unsupported chain");
        }

        vm.stopBroadcast();

        console.log("CCTPBridge deployed at:", address(bridge));
        console.log("");
        console.log("=== Deployment Summary ===");
        console.log("Chain ID:", chainId);
        console.log("Bridge Address:", address(bridge));
        console.log("TokenMessenger:", address(bridge.tokenMessenger()));
        console.log("MessageTransmitter:", address(bridge.messageTransmitter()));
        console.log("USDC:", address(bridge.usdc()));
        console.log("Destination Domain:", bridge.destinationDomain());
        console.log("");
        console.log("Next steps:");
        console.log("1. Verify the contract on block explorer");
        console.log("2. If this is the source bridge, set the destination bridge address:");
        console.log("   bridge.setDestinationBridge(<destination_bridge_address>)");
        console.log("3. Update frontend config with deployed addresses");
    }
}
