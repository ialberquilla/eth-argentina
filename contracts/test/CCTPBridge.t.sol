// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {CCTPBridge} from "../src/CCTPBridge.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

/**
 * @title CCTPBridgeTest
 * @notice Test suite for CCTPBridge contract
 * @dev Tests basic functionality - full integration tests require testnet deployment
 */
contract CCTPBridgeTest is Test {
    CCTPBridge public bridge;

    // Arc Testnet CCTP addresses
    address constant TOKEN_MESSENGER = 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA;
    address constant MESSAGE_TRANSMITTER = 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275;
    address constant USDC = 0x3600000000000000000000000000000000000000;
    uint32 constant DESTINATION_DOMAIN = 6; // Base Sepolia

    // Test addresses
    address constant ALICE = address(0x1);
    address constant BOB = address(0x2);
    address constant DESTINATION_BRIDGE = address(0x3);

    function setUp() public {
        // Deploy CCTPBridge
        bridge = new CCTPBridge(
            TOKEN_MESSENGER,
            MESSAGE_TRANSMITTER,
            USDC,
            DESTINATION_DOMAIN
        );

        vm.label(address(bridge), "CCTPBridge");
        vm.label(ALICE, "Alice");
        vm.label(BOB, "Bob");
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOYMENT TESTS
    //////////////////////////////////////////////////////////////*/

    function test_Deployment() public view {
        assertEq(address(bridge.tokenMessenger()), TOKEN_MESSENGER);
        assertEq(address(bridge.messageTransmitter()), MESSAGE_TRANSMITTER);
        assertEq(address(bridge.usdc()), USDC);
        assertEq(bridge.destinationDomain(), DESTINATION_DOMAIN);
    }

    function test_SetDestinationBridge() public {
        bridge.setDestinationBridge(DESTINATION_BRIDGE);
        assertEq(bridge.destinationBridge(), DESTINATION_BRIDGE);
    }

    /*//////////////////////////////////////////////////////////////
                        BRIDGE VALIDATION TESTS
    //////////////////////////////////////////////////////////////*/

    function test_RevertWhen_BridgeAmountIsZero() public {
        vm.expectRevert(CCTPBridge.InvalidAmount.selector);
        bridge.bridgeUSDC(0, BOB);
    }

    function test_RevertWhen_RecipientIsZeroAddress() public {
        vm.expectRevert(CCTPBridge.InvalidRecipient.selector);
        bridge.bridgeUSDC(1000000, address(0));
    }

    function test_RevertWhen_BridgeAndSwapWithoutDestinationBridge() public {
        bytes memory swapParams = abi.encode(
            address(0x123), // tokenOut
            1000000, // minAmountOut
            block.timestamp + 3600 // deadline
        );

        vm.expectRevert(CCTPBridge.DestinationBridgeNotSet.selector);
        bridge.bridgeAndSwap(1000000, BOB, swapParams);
    }

    /*//////////////////////////////////////////////////////////////
                            HELPER TESTS
    //////////////////////////////////////////////////////////////*/

    function test_RecoverTokens() public {
        // This test would need to set up token balances
        // For now, just testing the interface exists
        assertTrue(address(bridge).code.length > 0);
    }

    /*//////////////////////////////////////////////////////////////
                        INTEGRATION TEST SETUP
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Test helper for full integration testing on testnet
     * @dev This should be run on Arc Testnet fork with actual USDC
     */
    function testFork_BridgeUSDC() public {
        // Skip if not on fork
        if (block.chainid != 23244) {
            console.log("Skipping fork test - not on Arc Testnet");
            return;
        }

        uint256 amount = 1_000000; // 1 USDC (6 decimals)

        // Setup: Get USDC for Alice (would need actual faucet in real test)
        vm.startPrank(ALICE);

        // Check USDC balance
        uint256 balanceBefore = IERC20(USDC).balanceOf(ALICE);
        console.log("Alice USDC balance:", balanceBefore);

        if (balanceBefore >= amount) {
            // Approve bridge to spend USDC
            IERC20(USDC).approve(address(bridge), amount);

            // Bridge USDC
            uint64 nonce = bridge.bridgeUSDC(amount, BOB);

            console.log("Bridge nonce:", nonce);
            assertGt(nonce, 0, "Nonce should be greater than 0");

            // Check balance decreased
            uint256 balanceAfter = IERC20(USDC).balanceOf(ALICE);
            assertEq(balanceAfter, balanceBefore - amount, "Balance should decrease");
        } else {
            console.log("Insufficient USDC for test - get testnet USDC first");
        }

        vm.stopPrank();
    }

    /**
     * @notice Test helper for bridge and swap functionality
     * @dev Requires destination bridge to be set
     */
    function testFork_BridgeAndSwap() public {
        // Skip if not on fork
        if (block.chainid != 23244) {
            console.log("Skipping fork test - not on Arc Testnet");
            return;
        }

        uint256 amount = 1_000000; // 1 USDC

        // Set destination bridge
        bridge.setDestinationBridge(DESTINATION_BRIDGE);

        // Setup swap params
        address tokenOut = address(0x4200000000000000000000000000000000000006); // WETH on Base
        bytes memory swapParams = abi.encode(
            tokenOut,
            950000, // minAmountOut (0.95 USDC worth, accounting for slippage)
            block.timestamp + 3600
        );

        vm.startPrank(ALICE);

        uint256 balanceBefore = IERC20(USDC).balanceOf(ALICE);

        if (balanceBefore >= amount) {
            // Approve bridge
            IERC20(USDC).approve(address(bridge), amount);

            // Bridge and swap
            uint64 nonce = bridge.bridgeAndSwap(amount, BOB, swapParams);

            console.log("Bridge and swap nonce:", nonce);
            assertGt(nonce, 0, "Nonce should be greater than 0");
        } else {
            console.log("Insufficient USDC for test");
        }

        vm.stopPrank();
    }
}
