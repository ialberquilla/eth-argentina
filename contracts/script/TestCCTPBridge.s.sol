// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {CCTPBridge} from "../src/CCTPBridge.sol";
import {ITokenMessenger} from "../src/interfaces/ITokenMessenger.sol";
import {IMessageTransmitter} from "../src/interfaces/IMessageTransmitter.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

/**
 * @title TestCCTPBridge
 * @notice Script to test USDC bridging from Arc Testnet to Base Sepolia
 * @dev This script handles the complete bridge flow:
 *      1. Bridge USDC from Arc to Base Sepolia
 *      2. Get attestation from Circle's API (manual step)
 *      3. Receive USDC on Base Sepolia
 */
contract TestCCTPBridge is Script {
    // ============ Arc Testnet Configuration ============
    address constant ARC_BRIDGE = 0x2Bd7115Db8FFdcB077C8a146401aBd4A5E982903;
    address constant ARC_USDC = 0x3600000000000000000000000000000000000000;
    address constant ARC_MESSAGE_TRANSMITTER = 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275;
    uint256 constant ARC_CHAIN_ID = 5042002;

    // ============ Base Sepolia Configuration ============
    address constant BASE_BRIDGE = 0x4c23382b26C3ab153f1479b8be2545AB620eD6F2;
    address constant BASE_USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant BASE_MESSAGE_TRANSMITTER = 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275;
    uint256 constant BASE_CHAIN_ID = 84532;

    // ============ Circle CCTP Configuration ============
    string constant ATTESTATION_API = "https://iris-api-sandbox.circle.com";

    // ============ Test Parameters ============
    uint256 constant BRIDGE_AMOUNT = 1_000000; // 1 USDC (6 decimals)

    /**
     * @notice Main entry point - routes to appropriate function based on chain
     */
    function run() public {
        if (block.chainid == ARC_CHAIN_ID) {
            bridgeFromArc();
        } else if (block.chainid == BASE_CHAIN_ID) {
            console.log("For receiving on Base Sepolia, use receiveOnBase()");
            console.log("You need to:");
            console.log("1. Get the attestation from Circle's API");
            console.log("2. Call this script with the attestation data");
        } else {
            console.log("Unknown chain ID:", block.chainid);
            console.log("Expected Arc Testnet (5042002) or Base Sepolia (84532)");
        }
    }

    /**
     * @notice Step 1: Bridge USDC from Arc Testnet to Base Sepolia
     */
    function bridgeFromArc() public {
        require(block.chainid == ARC_CHAIN_ID, "Must be on Arc Testnet");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=================================================");
        console.log("Step 1: Bridging USDC from Arc to Base Sepolia");
        console.log("=================================================");
        console.log("Sender:", deployer);
        console.log("Bridge Contract:", ARC_BRIDGE);
        console.log("Amount:", BRIDGE_AMOUNT / 1e6, "USDC");
        console.log("");

        // Check USDC balance
        uint256 balance = IERC20(ARC_USDC).balanceOf(deployer);
        console.log("Current USDC balance:", balance / 1e6, "USDC");
        require(balance >= BRIDGE_AMOUNT, "Insufficient USDC balance");

        vm.startBroadcast(deployerPrivateKey);

        // Approve bridge to spend USDC
        IERC20(ARC_USDC).approve(ARC_BRIDGE, BRIDGE_AMOUNT);
        console.log("Approved bridge to spend", BRIDGE_AMOUNT / 1e6, "USDC");

        // Bridge USDC to deployer address on Base Sepolia
        CCTPBridge bridge = CCTPBridge(ARC_BRIDGE);
        uint64 nonce = bridge.bridgeUSDC(BRIDGE_AMOUNT, deployer);

        vm.stopBroadcast();

        console.log("");
        console.log("=================================================");
        console.log("Bridge Transaction Successful!");
        console.log("=================================================");
        console.log("Nonce:", nonce);
        console.log("Recipient on Base Sepolia:", deployer);
        console.log("");

        // Get the message hash for attestation
        bytes32 messageHash = getMessageHash(nonce);
        console.log("Message Hash:", vm.toString(messageHash));
        console.log("");

        console.log("=================================================");
        console.log("Next Steps:");
        console.log("=================================================");
        console.log("1. Wait ~20 minutes for Circle to generate attestation");
        console.log("2. Get attestation from Circle's API:");
        console.log("   curl https://iris-api-sandbox.circle.com/attestations/", vm.toString(messageHash));
        console.log("");
        console.log("3. Switch to Base Sepolia and run:");
        console.log("   forge script script/TestCCTPBridge.s.sol --sig 'receiveOnBase(bytes)' <ATTESTATION> \\");
        console.log("     --rpc-url base-sepolia --broadcast");
        console.log("=================================================");
    }

    /**
     * @notice Step 2: Receive USDC on Base Sepolia after getting attestation
     * @param attestation The attestation signature from Circle's API
     */
    function receiveOnBase(bytes memory attestation) public {
        require(block.chainid == BASE_CHAIN_ID, "Must be on Base Sepolia");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=================================================");
        console.log("Step 2: Receiving USDC on Base Sepolia");
        console.log("=================================================");
        console.log("Recipient:", deployer);
        console.log("");

        // Check balance before
        uint256 balanceBefore = IERC20(BASE_USDC).balanceOf(deployer);
        console.log("USDC balance before:", balanceBefore / 1e6, "USDC");

        // Note: You'll need to provide the message bytes from the Arc transaction
        // This is a placeholder - in production, you'd need to:
        // 1. Get the message bytes from the Arc transaction logs
        // 2. Combine them with the attestation
        // 3. Call receiveMessage on the MessageTransmitter

        console.log("");
        console.log("=================================================");
        console.log("Implementation Note:");
        console.log("=================================================");
        console.log("To complete the receive:");
        console.log("1. Extract the message from Arc transaction logs");
        console.log("2. Call MessageTransmitter.receiveMessage(message, attestation)");
        console.log("3. USDC will be minted to the recipient address");
        console.log("=================================================");
    }

    /**
     * @notice Helper function to calculate message hash
     * @dev This is used to query Circle's attestation API
     */
    function getMessageHash(uint64 nonce) internal view returns (bytes32) {
        IMessageTransmitter transmitter = IMessageTransmitter(ARC_MESSAGE_TRANSMITTER);

        // The message hash is emitted in the MessageSent event
        // For testing, we can construct it manually or extract from logs
        // Circle uses: keccak256(abi.encodePacked(version, sourceDomain, destinationDomain, nonce, sender, recipient, destinationCaller, messageBody))

        // This is a simplified version - in production, extract from transaction logs
        console.log("Note: Extract actual message hash from transaction logs");
        console.log("Look for MessageSent event in the transaction receipt");

        return bytes32(0); // Placeholder
    }

    /**
     * @notice Helper function to check bridge status
     */
    function checkBridgeStatus() public view {
        console.log("=================================================");
        console.log("Bridge Status Check");
        console.log("=================================================");

        if (block.chainid == ARC_CHAIN_ID) {
            console.log("Chain: Arc Testnet");
            console.log("Bridge:", ARC_BRIDGE);
            console.log("USDC:", ARC_USDC);

            CCTPBridge bridge = CCTPBridge(ARC_BRIDGE);
            console.log("Destination Domain:", bridge.destinationDomain());
            console.log("Destination Bridge:", bridge.destinationBridge());
        } else if (block.chainid == BASE_CHAIN_ID) {
            console.log("Chain: Base Sepolia");
            console.log("Bridge:", BASE_BRIDGE);
            console.log("USDC:", BASE_USDC);

            CCTPBridge bridge = CCTPBridge(BASE_BRIDGE);
            console.log("Destination Domain:", bridge.destinationDomain());
            console.log("Destination Bridge:", bridge.destinationBridge());
        }

        console.log("=================================================");
    }

    /**
     * @notice Check USDC balance
     */
    function checkBalance() public view {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("=================================================");
        console.log("Balance Check");
        console.log("=================================================");
        console.log("Address:", deployer);

        if (block.chainid == ARC_CHAIN_ID) {
            console.log("Chain: Arc Testnet");
            uint256 balance = IERC20(ARC_USDC).balanceOf(deployer);
            console.log("USDC Balance:", balance / 1e6, "USDC");
        } else if (block.chainid == BASE_CHAIN_ID) {
            console.log("Chain: Base Sepolia");
            uint256 balance = IERC20(BASE_USDC).balanceOf(deployer);
            console.log("USDC Balance:", balance / 1e6, "USDC");
        }

        console.log("=================================================");
    }
}
