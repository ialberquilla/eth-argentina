// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

/// @notice Correct interface from the actual contract ABI
interface IRegistrarController {
    struct RegisterRequest {
        string name;
        address owner;
        uint256 duration;
        address resolver;
        bytes[] data;
        bool reverseRecord;
    }

    function available(string memory name) external view returns (bool);
    function registerPrice(string memory name, uint256 duration) external view returns (uint256);
    function register(RegisterRequest calldata request) external payable;
}

/// @notice Script to register basename using the CORRECT struct
contract RegisterBasenameCorrectScript is Script {
    address constant REGISTRAR_CONTROLLER = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address constant L2_RESOLVER = 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA;
    
    string constant NAME = "onetx";
    uint256 constant DURATION = 365 days;

    function run() public {
        IRegistrarController controller = IRegistrarController(REGISTRAR_CONTROLLER);

        console2.log("========================================");
        console2.log("Registering Basename on Base Sepolia");
        console2.log("========================================");
        console2.log("Name:", string.concat(NAME, ".base.eth"));
        console2.log("Owner:", msg.sender);
        console2.log("");

        // Check availability
        bool isAvailable = controller.available(NAME);
        console2.log("Is available?", isAvailable);
        
        if (!isAvailable) {
            console2.log("");
            console2.log("ERROR: Name already registered!");
            console2.log("Choose a different name.");
            return;
        }

        // Get price
        uint256 price = controller.registerPrice(NAME, DURATION);
        console2.log("Registration price:", price);
        console2.log("Price in ETH:", price / 1e18);
        console2.log("Your balance:", msg.sender.balance / 1e18, "ETH");
        console2.log("");

        if (msg.sender.balance < price) {
            console2.log("ERROR: Insufficient balance!");
            console2.log("You need:", price / 1e18, "ETH");
            console2.log("You have:", msg.sender.balance / 1e18, "ETH");
            console2.log("");
            console2.log("Get testnet ETH from:");
            console2.log("https://www.coinbase.com/faucets/base-ethereum-goerli-faucet");
            return;
        }

        // Create registration request with CORRECT struct
        IRegistrarController.RegisterRequest memory request = IRegistrarController.RegisterRequest({
            name: NAME,
            owner: msg.sender,
            duration: DURATION,
            resolver: L2_RESOLVER,
            data: new bytes[](0),
            reverseRecord: false
        });

        console2.log("Registering...");
        console2.log("");

        vm.startBroadcast();
        
        controller.register{value: price}(request);
        
        vm.stopBroadcast();

        console2.log("========================================");
        console2.log("SUCCESS!");
        console2.log("========================================");
        console2.log("Registered:", string.concat(NAME, ".base.eth"));
        console2.log("Owner:", msg.sender);
        console2.log("");
        console2.log("Next steps:");
        console2.log("1. Verify ownership:");
        console2.log("   forge script script/RegisterBasenameAndDeploy.s.sol --rpc-url baseSepolia -vv");
        console2.log("");
        console2.log("2. Deploy everything with ENS names:");
        console2.log("   ./deploy-base-sepolia.sh");
        console2.log("");
        console2.log("Your adapters will get names like:");
        console2.log("  - usdc-basesepolia-xxx.onetx.base.eth");
        console2.log("  - usdt-basesepolia-xxx.onetx.base.eth");
        console2.log("========================================");
    }
}
