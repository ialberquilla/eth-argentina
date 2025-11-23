// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {CCTPBridge} from "../src/CCTPBridge.sol";

/**
 * @title LinkBridges
 * @notice Script to link Arc and Base CCTP bridges
 */
contract LinkBridges is Script {
    // Bridge addresses
    address constant ARC_BRIDGE = 0x2Bd7115Db8FFdcB077C8a146401aBd4A5E982903;
    address constant BASE_BRIDGE = 0x4c23382b26C3ab153f1479b8be2545AB620eD6F2;

    function run() public {
        if (block.chainid == 5042002) {
            linkArcBridge();
        } else if (block.chainid == 84532) {
            linkBaseBridge();
        } else {
            console.log("Unknown chain ID:", block.chainid);
        }
    }

    function linkArcBridge() public {
        console.log("=================================================");
        console.log("Linking Arc Bridge to Base Bridge");
        console.log("=================================================");

        CCTPBridge bridge = CCTPBridge(ARC_BRIDGE);

        console.log("Arc Bridge:", ARC_BRIDGE);
        console.log("Current destination bridge:", bridge.destinationBridge());
        console.log("Setting destination to:", BASE_BRIDGE);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        bridge.setDestinationBridge(BASE_BRIDGE);
        vm.stopBroadcast();

        console.log("New destination bridge:", bridge.destinationBridge());
        console.log("=================================================");
    }

    function linkBaseBridge() public {
        console.log("=================================================");
        console.log("Linking Base Bridge to Arc Bridge");
        console.log("=================================================");

        CCTPBridge bridge = CCTPBridge(BASE_BRIDGE);

        console.log("Base Bridge:", BASE_BRIDGE);
        console.log("Current destination bridge:", bridge.destinationBridge());
        console.log("Setting destination to:", ARC_BRIDGE);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        bridge.setDestinationBridge(ARC_BRIDGE);
        vm.stopBroadcast();

        console.log("New destination bridge:", bridge.destinationBridge());
        console.log("=================================================");
    }

    function checkBridges() public view {
        console.log("=================================================");
        console.log("Bridge Configuration Check");
        console.log("=================================================");

        if (block.chainid == 5042002) {
            CCTPBridge bridge = CCTPBridge(ARC_BRIDGE);
            console.log("Chain: Arc Testnet");
            console.log("Bridge:", ARC_BRIDGE);
            console.log("Destination Domain:", bridge.destinationDomain());
            console.log("Destination Bridge:", bridge.destinationBridge());
        } else if (block.chainid == 84532) {
            CCTPBridge bridge = CCTPBridge(BASE_BRIDGE);
            console.log("Chain: Base Sepolia");
            console.log("Bridge:", BASE_BRIDGE);
            console.log("Destination Domain:", bridge.destinationDomain());
            console.log("Destination Bridge:", bridge.destinationBridge());
        }

        console.log("=================================================");
    }
}
