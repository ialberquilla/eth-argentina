// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

/// @notice Interface for Base Registrar Controller
interface IRegistrarController {
    struct RegisterRequest {
        string name;
        address owner;
        uint256 duration;
        bytes32 secret;
        address resolver;
        bytes[] data;
        bool reverseRecord;
        uint16 referrerCode;
    }

    function rentPrice(string memory name, uint256 duration) external view returns (uint256);
    function available(string memory name) external view returns (bool);
    function makeCommitment(RegisterRequest memory request) external pure returns (bytes32);
    function commit(bytes32 commitment) external;
    function register(RegisterRequest calldata request) external payable;
    function MIN_REGISTRATION_DURATION() external view returns (uint256);
}

/// @notice Script to register a basename on Base Sepolia
/// @dev This is a two-step process:
///      1. Run with --sig "step1()" to commit
///      2. Wait 60 seconds
///      3. Run with --sig "step2()" to register
contract RegisterBasenameScript is Script {
    // Base Sepolia Basenames contracts
    address constant REGISTRAR_CONTROLLER = 0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581;
    address constant L2_RESOLVER = 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA;

    // Configuration
    string constant NAME_TO_REGISTER = "onetx"; // Without .base.eth
    uint256 constant DURATION = 365 days; // 1 year
    bytes32 constant SECRET = keccak256("onetx-secret-base-sepolia-2024"); // Change this!

    IRegistrarController controller = IRegistrarController(REGISTRAR_CONTROLLER);

    /// @notice Step 1: Make and submit commitment
    function step1() public {
        console2.log("========================================");
        console2.log("Step 1: Making Commitment");
        console2.log("========================================");
        console2.log("Name:", NAME_TO_REGISTER);
        console2.log("Duration:", DURATION / 1 days, "days");
        console2.log("Registrar Controller:", REGISTRAR_CONTROLLER);
        console2.log("");

        // Check if name is available
        bool isAvailable = controller.available(NAME_TO_REGISTER);
        console2.log("Is name available?", isAvailable);
        
        if (!isAvailable) {
            console2.log("");
            console2.log("ERROR: Name is already registered!");
            console2.log("Choose a different name or check who owns it.");
            return;
        }

        // Get price
        uint256 price = controller.rentPrice(NAME_TO_REGISTER, DURATION);
        console2.log("Registration price:", price, "wei");
        console2.log("Registration price:", price / 1e18, "ETH");
        console2.log("");

        // Create registration request
        IRegistrarController.RegisterRequest memory request = IRegistrarController.RegisterRequest({
            name: NAME_TO_REGISTER,
            owner: msg.sender,
            duration: DURATION,
            secret: SECRET,
            resolver: L2_RESOLVER,
            data: new bytes[](0),
            reverseRecord: false,
            referrerCode: 0
        });

        // Make commitment
        bytes32 commitment = controller.makeCommitment(request);
        console2.log("Commitment hash:");
        console2.logBytes32(commitment);
        console2.log("");

        // Submit commitment
        vm.startBroadcast();
        controller.commit(commitment);
        vm.stopBroadcast();

        console2.log("SUCCESS: Commitment submitted!");
        console2.log("");
        console2.log("========================================");
        console2.log("NEXT STEP:");
        console2.log("========================================");
        console2.log("1. Wait 60 seconds for commitment to age");
        console2.log("2. Run step 2 with:");
        console2.log("   forge script script/RegisterBasename.s.sol \\");
        console2.log("     --sig \"step2()\" \\");
        console2.log("     --rpc-url baseSepolia \\");
        console2.log("     --broadcast \\");
        console2.log("     -vvv");
        console2.log("========================================");
    }

    /// @notice Step 2: Complete registration (run 60+ seconds after step1)
    function step2() public {
        console2.log("========================================");
        console2.log("Step 2: Registering Name");
        console2.log("========================================");
        console2.log("Name:", NAME_TO_REGISTER);
        console2.log("");

        // Check if name is still available
        bool isAvailable = controller.available(NAME_TO_REGISTER);
        if (!isAvailable) {
            console2.log("ERROR: Name is no longer available!");
            console2.log("It may have been registered by someone else.");
            return;
        }

        // Get price
        uint256 price = controller.rentPrice(NAME_TO_REGISTER, DURATION);
        console2.log("Registration price:", price / 1e18, "ETH");
        console2.log("Your balance:", msg.sender.balance / 1e18, "ETH");
        console2.log("");

        if (msg.sender.balance < price) {
            console2.log("ERROR: Insufficient balance!");
            console2.log("You need:", price / 1e18, "ETH");
            console2.log("You have:", msg.sender.balance / 1e18, "ETH");
            console2.log("");
            console2.log("Get Base Sepolia ETH from:");
            console2.log("https://www.coinbase.com/faucets/base-ethereum-goerli-faucet");
            return;
        }

        // Create registration request (must match commitment!)
        IRegistrarController.RegisterRequest memory request = IRegistrarController.RegisterRequest({
            name: NAME_TO_REGISTER,
            owner: msg.sender,
            duration: DURATION,
            secret: SECRET,
            resolver: L2_RESOLVER,
            data: new bytes[](0),
            reverseRecord: false,
            referrerCode: 0
        });

        // Register
        console2.log("Registering basename...");
        vm.startBroadcast();
        controller.register{value: price}(request);
        vm.stopBroadcast();

        console2.log("");
        console2.log("========================================");
        console2.log("SUCCESS!");
        console2.log("========================================");
        console2.log("Registered:", string.concat(NAME_TO_REGISTER, ".base.eth"));
        console2.log("Owner:", msg.sender);
        console2.log("");
        console2.log("You can now deploy with ENS names!");
        console2.log("Run: ./deploy-base-sepolia.sh");
        console2.log("========================================");
    }

    /// @notice All-in-one: Does both steps with a 60 second wait
    /// @dev Warning: This blocks for 60 seconds between steps
    function run() public {
        console2.log("========================================");
        console2.log("Registering Basename on Base Sepolia");
        console2.log("========================================");
        console2.log("Name:", NAME_TO_REGISTER);
        console2.log("Full name:", string.concat(NAME_TO_REGISTER, ".base.eth"));
        console2.log("Owner:", msg.sender);
        console2.log("");

        // Check availability
        bool isAvailable = controller.available(NAME_TO_REGISTER);
        console2.log("Is available?", isAvailable);
        
        if (!isAvailable) {
            console2.log("");
            console2.log("ERROR: Name already registered!");
            console2.log("Either:");
            console2.log("1. Change NAME_TO_REGISTER in script");
            console2.log("2. Or use a different name");
            return;
        }

        // Get price
        uint256 price = controller.rentPrice(NAME_TO_REGISTER, DURATION);
        console2.log("Price:", price / 1e18, "ETH");
        console2.log("Your balance:", msg.sender.balance / 1e18, "ETH");
        console2.log("");

        if (msg.sender.balance < price) {
            console2.log("ERROR: Insufficient balance!");
            console2.log("Get testnet ETH from: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet");
            return;
        }

        // Step 1: Commit
        console2.log("========================================");
        console2.log("Step 1/2: Submitting commitment...");
        console2.log("========================================");

        IRegistrarController.RegisterRequest memory request = IRegistrarController.RegisterRequest({
            name: NAME_TO_REGISTER,
            owner: msg.sender,
            duration: DURATION,
            secret: SECRET,
            resolver: L2_RESOLVER,
            data: new bytes[](0),
            reverseRecord: false,
            referrerCode: 0
        });

        bytes32 commitment = controller.makeCommitment(request);
        
        vm.startBroadcast();
        controller.commit(commitment);
        vm.stopBroadcast();

        console2.log("Commitment submitted!");
        console2.log("");

        // Wait
        console2.log("========================================");
        console2.log("Waiting 60 seconds for commitment...");
        console2.log("========================================");
        vm.sleep(60000); // Wait 60 seconds
        console2.log("Wait complete!");
        console2.log("");

        // Step 2: Register
        console2.log("========================================");
        console2.log("Step 2/2: Registering name...");
        console2.log("========================================");

        vm.startBroadcast();
        controller.register{value: price}(request);
        vm.stopBroadcast();

        console2.log("");
        console2.log("========================================");
        console2.log("SUCCESS!");
        console2.log("========================================");
        console2.log("Registered:", string.concat(NAME_TO_REGISTER, ".base.eth"));
        console2.log("Owner:", msg.sender);
        console2.log("");
        console2.log("Next steps:");
        console2.log("1. Run: ./deploy-base-sepolia.sh");
        console2.log("2. Your adapters will get ENS names automatically!");
        console2.log("========================================");
    }
}
