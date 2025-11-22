// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {console2} from "forge-std/console2.sol";

import {BaseScript} from "./base/BaseScript.sol";

contract SwapScript is BaseScript {
    // USDT Adapter address on Base Sepolia
    address constant USDT_ADAPTER = 0x6F0b25e2abca0b60109549b7823392e3312f505c;

    function run() external {
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 3000,
            tickSpacing: 60,
            hooks: hookContract // This must match the pool
        });

        console2.log("=== Swap Script Debug ===");
        console2.log("Deployer address:", deployerAddress);
        console2.log("Currency0 (USDC):", address(token0));
        console2.log("Currency1 (USDT):", address(token1));
        console2.log("Hook:", address(hookContract));
        console2.log("Swap Router:", address(swapRouter));

        // Check balances before swap
        uint256 usdc_balance = token0.balanceOf(deployerAddress);
        uint256 usdt_balance = token1.balanceOf(deployerAddress);
        console2.log("USDC Balance:", usdc_balance);
        console2.log("USDT Balance:", usdt_balance);

        require(usdc_balance >= 1e6, "Insufficient USDC balance");

        vm.startBroadcast();

        // Encode hookData with adapter address and recipient
        // abi.encode(string adapterIdentifier, string recipientIdentifier)
        bytes memory hookData = abi.encode(
            "0x6f0b25e2abca0b60109549b7823392e3312f505c", // USDT adapter address as string (lowercase)
            vm.toString(deployerAddress) // Recipient address as string
        );

        console2.log("HookData length:", hookData.length);

        // Approve both tokens for testing
        token0.approve(address(swapRouter), type(uint256).max);
        token1.approve(address(swapRouter), type(uint256).max);

        console2.log("Tokens approved");

        // Execute swap: USDC -> USDT
        // Swapping 1 USDC (6 decimals) for USDT
        console2.log("Executing swap...");
        swapRouter.swapExactTokensForTokens({
            amountIn: 1e6, // 1 USDC (6 decimals)
            amountOutMin: 0, // Accept any amount (not recommended for production)
            zeroForOne: true, // USDC (currency0) -> USDT (currency1)
            poolKey: poolKey,
            hookData: hookData,
            receiver: deployerAddress, // Use deployer address instead of address(this)
            deadline: block.timestamp + 300 // 5 minutes
        });

        console2.log("Swap executed successfully!");

        vm.stopBroadcast();
    }
}
