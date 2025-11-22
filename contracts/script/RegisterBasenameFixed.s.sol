// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

struct RegisterRequest {
    string name;
    address owner;
    uint256 duration;
    address resolver;
    bytes[] data;
    bool reverseRecord;
}

interface IRegistrarController {
    function available(string memory name) external view returns (bool);
    function rentPrice(string memory name, uint256 duration) external view returns (uint256 base, uint256 premium);
    function register(RegisterRequest memory request) external payable;
}

/// @notice Script to register basename using direct contract calls with correct ABI
contract RegisterBasenameFixedScript is Script {
    address constant REGISTRAR_CONTROLLER = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address constant L2_RESOLVER = 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA;
    
    string constant NAME = "onetx";
    uint256 constant DURATION = 365 days;

    function run() public {
        console2.log("========================================");
        console2.log("Registering:", string.concat(NAME, ".base.eth"));
        console2.log("========================================");
        
        IRegistrarController controller = IRegistrarController(REGISTRAR_CONTROLLER);

        // Check availability
        try controller.available(NAME) returns (bool isAvailable) {
            console2.log("Available:", isAvailable);
            require(isAvailable, "Name not available");
        } catch {
             console2.log("Failed to check availability");
             return;
        }

        // Get price
        uint256 totalPrice;
        try controller.rentPrice(NAME, DURATION) returns (uint256 base, uint256 premium) {
            totalPrice = base + premium;
            console2.log("Price:", totalPrice);
        } catch {
            console2.log("Failed to get price");
            return;
        }
        
        console2.log("Balance:", msg.sender.balance);
        require(msg.sender.balance >= totalPrice, "Insufficient balance");

        vm.startBroadcast();

        RegisterRequest memory request = RegisterRequest({
            name: NAME,
            owner: msg.sender,
            duration: DURATION,
            resolver: L2_RESOLVER,
            data: new bytes[](0),
            reverseRecord: true
        });

        console2.log("Registering...");
        
        try controller.register{value: totalPrice}(request) {
            console2.log("========================================");
            console2.log("SUCCESS!");
            console2.log("========================================");
            console2.log("Registered:", string.concat(NAME, ".base.eth"));
            console2.log("Owner:", msg.sender);
        } catch Error(string memory reason) {
            console2.log("Registration failed:", reason);
        } catch (bytes memory lowLevelData) {
            console2.log("Registration failed (low level):");
            console2.logBytes(lowLevelData);
        }

        vm.stopBroadcast();
    }
}