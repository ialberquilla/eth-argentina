// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import {IUniswapV4Router04} from "hookmate/interfaces/router/IUniswapV4Router04.sol";

contract SwapSimpleScript is Script {
    // Deployed addresses on Base Sepolia
    address constant POOL_MANAGER = 0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829;
    address constant SWAP_ROUTER = 0x71cD4Ea054F9Cb3D3BF6251A00673303411A7DD9; // Hookmate router
    address constant USDC = 0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f;
    address constant USDT = 0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a;
    address constant HOOK = 0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4;
    address constant USDT_ADAPTER = 0x6F0b25e2abca0b60109549b7823392e3312f505c;

    function run() external {
        address deployer = msg.sender;

        console2.log("=== Swap Script Debug ===");
        console2.log("Deployer:", deployer);
        console2.log("USDC:", USDC);
        console2.log("USDT:", USDT);
        console2.log("Hook:", HOOK);
        console2.log("Swap Router:", SWAP_ROUTER);
        console2.log("Pool Manager:", POOL_MANAGER);

        // Check balances
        uint256 usdcBalance = IERC20(USDC).balanceOf(deployer);
        uint256 usdtBalance = IERC20(USDT).balanceOf(deployer);
        console2.log("USDC Balance:", usdcBalance);
        console2.log("USDT Balance:", usdtBalance);

        require(usdcBalance >= 1e6, "Insufficient USDC balance - need at least 1 USDC");

        // Ensure currencies are sorted: USDT < USDC
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(USDT),
            currency1: Currency.wrap(USDC),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(HOOK)
        });

        // Encode hookData: abi.encode(string adapterIdentifier, string recipientIdentifier)
        bytes memory hookData = abi.encode(
            "0x992A8847C28F9cD9251D5382249A4d35523F510A", // New USDT adapter address
            vm.toString(deployer) // Recipient address as string
        );

        console2.log("HookData length:", hookData.length);

        vm.startBroadcast();

        // Approve tokens
        IERC20(USDC).approve(SWAP_ROUTER, type(uint256).max);
        IERC20(USDT).approve(SWAP_ROUTER, type(uint256).max);
        console2.log("Tokens approved");

        // Execute swap
        console2.log("Executing swap: 1 USDC -> USDT");
        // USDC is currency1, USDT is currency0. We are swapping USDC -> USDT, so zeroForOne = false
        IUniswapV4Router04(payable(SWAP_ROUTER)).swapExactTokensForTokens({
            amountIn: 1e6, // 1 USDC
            amountOutMin: 0,
            zeroForOne: false, // USDC (currency1) -> USDT (currency0)
            poolKey: poolKey,
            hookData: hookData,
            receiver: deployer,
            deadline: block.timestamp + 300
        });

        console2.log("Swap executed successfully!");

        vm.stopBroadcast();
    }
}
