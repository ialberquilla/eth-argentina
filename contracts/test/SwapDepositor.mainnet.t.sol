// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";

import {EasyPosm} from "./utils/libraries/EasyPosm.sol";

import {SwapDepositor} from "../src/SwapDepositor.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {BaseTest} from "./utils/BaseTest.sol";
import {BaseConstants} from "./utils/BaseConstants.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IAavePool} from "../src/interfaces/IAavePool.sol";

/// @title SwapDepositorMainnetTest
/// @notice Fork tests for SwapDepositor using real Base mainnet contracts
/// @dev This test forks Base mainnet and uses actual Aave V3 contracts
contract SwapDepositorMainnetTest is BaseTest {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    // Mainnet contracts
    IAavePool aavePool = IAavePool(BaseConstants.AAVE_V3_POOL);
    IERC20 usdc = IERC20(BaseConstants.USDC);
    IERC20 usdbc = IERC20(BaseConstants.USDbC);
    IERC20 aUSDC = IERC20(BaseConstants.aUSDC);
    IERC20 aUSDbC = IERC20(BaseConstants.aUSDbC);

    // Test contracts
    Currency currency0;
    Currency currency1;
    PoolKey poolKey;
    SwapDepositor hook;
    AaveAdapter aaveAdapter;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    // Test accounts
    address user = address(0xBEEF);
    address liquidityProvider = address(0xCAFE);

    function setUp() public {
        uint256 forkBlock = vm.envOr("FORK_BLOCK_NUMBER", block.number);
        vm.createSelectFork(vm.rpcUrl("base"), forkBlock);

        console2.log("Forked Base mainnet at block:", block.number);

        // Deploy V4 infrastructure (not yet on Base mainnet)
        deployArtifactsAndLabel();

        // Use real stablecoins from Base
        currency0 = Currency.wrap(address(usdc));
        currency1 = Currency.wrap(address(usdbc));

        // Ensure currency0 < currency1 for Uniswap V4
        if (Currency.unwrap(currency0) > Currency.unwrap(currency1)) {
            (currency0, currency1) = (currency1, currency0);
        }

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG)
                ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        bytes memory constructorArgs = abi.encode(poolManager);
        deployCodeTo("SwapDepositor.sol:SwapDepositor", constructorArgs, flags);
        hook = SwapDepositor(flags);

        console2.log("Deployed SwapDepositor hook at:", address(hook));

        // Deploy AaveAdapter with real Aave pool
        aaveAdapter = new AaveAdapter(BaseConstants.AAVE_V3_POOL);
        console2.log("Deployed AaveAdapter at:", address(aaveAdapter));

        // Create the pool
        poolKey = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = poolKey.toId();
        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        console2.log("Initialized Uniswap V4 pool");

        // Setup liquidity provider with real tokens
        _setupLiquidityProvider();

        // Provide full-range liquidity to the pool
        _addLiquidity();

        // Setup test user with real tokens
        _setupTestUser();
    }

    function _setupLiquidityProvider() internal {
        // Fund liquidity provider from whale addresses
        address usdcWhale = BaseConstants.USDC_WHALE;
        address usdbcWhale = BaseConstants.USDbC_WHALE;

        // Get USDC from whale
        vm.prank(usdcWhale);
        usdc.transfer(liquidityProvider, 1000000e6); // 1M USDC

        // Get USDbC from whale
        vm.prank(usdbcWhale);
        usdbc.transfer(liquidityProvider, 1000000e6); // 1M USDbC

        console2.log("Funded liquidity provider");
        console2.log("  USDC balance:", usdc.balanceOf(liquidityProvider));
        console2.log("  USDbC balance:", usdbc.balanceOf(liquidityProvider));
    }

    function _addLiquidity() internal {
        vm.startPrank(liquidityProvider);

        // Approve tokens
        IERC20(Currency.unwrap(currency0)).approve(address(permit2), type(uint256).max);
        IERC20(Currency.unwrap(currency1)).approve(address(permit2), type(uint256).max);
        permit2.approve(Currency.unwrap(currency0), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(Currency.unwrap(currency1), address(positionManager), type(uint160).max, type(uint48).max);

        // Setup liquidity position
        tickLower = TickMath.minUsableTick(poolKey.tickSpacing);
        tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);

        uint128 liquidityAmount = uint128(vm.envOr("LIQUIDITY_AMOUNT", uint256(10e18)));

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityAmount
        );

        console2.log("Adding liquidity:");
        console2.log("  Amount0:", amount0Expected);
        console2.log("  Amount1:", amount1Expected);

        (tokenId,) = positionManager.mint(
            poolKey,
            tickLower,
            tickUpper,
            liquidityAmount,
            amount0Expected + 1,
            amount1Expected + 1,
            liquidityProvider,
            block.timestamp,
            Constants.ZERO_BYTES
        );

        console2.log("Minted position NFT:", tokenId);

        vm.stopPrank();
    }

    function _setupTestUser() internal {
        // Fund user from whale
        address usdcWhale = BaseConstants.USDC_WHALE;

        vm.prank(usdcWhale);
        usdc.transfer(user, 100000e6); // 100k USDC

        // Approve for swapping
        vm.startPrank(user);
        IERC20(Currency.unwrap(currency0)).approve(address(permit2), type(uint256).max);
        IERC20(Currency.unwrap(currency1)).approve(address(permit2), type(uint256).max);
        permit2.approve(Currency.unwrap(currency0), address(swapRouter), type(uint160).max, type(uint48).max);
        permit2.approve(Currency.unwrap(currency1), address(swapRouter), type(uint160).max, type(uint48).max);
        vm.stopPrank();

        console2.log("Funded test user with USDC:", usdc.balanceOf(user));
    }

    function testMainnetForkSwapWithoutHook() public {
        console2.log("\n=== Testing basic swap without hook ===");

        vm.startPrank(user);

        uint256 amountIn = 1000e6; // 1000 USDC
        IERC20 token0 = IERC20(Currency.unwrap(currency0));
        IERC20 token1 = IERC20(Currency.unwrap(currency1));

        uint256 token0Before = token0.balanceOf(user);
        uint256 token1Before = token1.balanceOf(user);

        console2.log("Before swap:");
        console2.log("  Token0:", token0Before);
        console2.log("  Token1:", token1Before);

        // Perform swap without hookData (no deposit to Aave)
        BalanceDelta swapDelta = swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: true,
            poolKey: poolKey,
            hookData: Constants.ZERO_BYTES,
            receiver: user,
            deadline: block.timestamp + 1
        });

        uint256 token0After = token0.balanceOf(user);
        uint256 token1After = token1.balanceOf(user);

        console2.log("After swap:");
        console2.log("  Token0:", token0After);
        console2.log("  Token1:", token1After);
        console2.log("  Token0 spent:", token0Before - token0After);
        console2.log("  Token1 received:", token1After - token1Before);

        vm.stopPrank();

        // Verify swap executed correctly
        assertEq(token0Before - token0After, amountIn, "Should spend exact token0 amount");
        assertGt(token1After, token1Before, "Should receive token1");
    }

    function testMainnetForkSwapWithAaveDeposit() public {
        console2.log("\n=== Testing swap with Aave deposit ===");

        vm.startPrank(user);

        address recipient = address(0x1234);
        uint256 amountIn = 1000e6; // 1000 tokens

        IERC20 token0 = IERC20(Currency.unwrap(currency0));
        IERC20 token1 = IERC20(Currency.unwrap(currency1));

        uint256 token0Before = token0.balanceOf(user);
        uint256 token1Before = token1.balanceOf(user);
        uint256 aTokenBefore = aUSDbC.balanceOf(recipient);

        console2.log("Before swap:");
        console2.log("  User token0:", token0Before);
        console2.log("  User token1:", token1Before);
        console2.log("  Recipient aToken1:", aTokenBefore);

        // Encode adapter address and recipient in hookData
        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        // Perform swap with Aave deposit
        BalanceDelta swapDelta = swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: true,
            poolKey: poolKey,
            hookData: hookData,
            receiver: user,
            deadline: block.timestamp + 1
        });

        uint256 token0After = token0.balanceOf(user);
        uint256 token1After = token1.balanceOf(user);
        uint256 aTokenAfter = aUSDbC.balanceOf(recipient);

        console2.log("After swap:");
        console2.log("  User token0:", token0After);
        console2.log("  User token1:", token1After);
        console2.log("  Recipient aToken1:", aTokenAfter);
        console2.log("  aToken1 received:", aTokenAfter - aTokenBefore);

        vm.stopPrank();

        // Verify tokens were spent
        assertEq(token0Before - token0After, amountIn, "Should spend exact token0 amount");

        // Verify user didn't receive token1 (went to Aave)
        assertEq(token1After, token1Before, "User should not receive token1 directly");

        // Verify recipient received aTokens from Aave
        assertGt(aTokenAfter, aTokenBefore, "Recipient should receive aTokens from Aave");

        // Verify hook doesn't hold any tokens
        assertEq(token0.balanceOf(address(hook)), 0, "Hook should not hold token0");
        assertEq(token1.balanceOf(address(hook)), 0, "Hook should not hold token1");

        console2.log("✓ Swap successfully deposited to Aave V3 on Base mainnet");
    }

    function testMainnetForkMultipleSwapsWithAaveDeposit() public {
        console2.log("\n=== Testing multiple swaps with Aave deposit ===");

        address recipient = address(0x5678);
        uint256 swapAmount = 500e6; // 500 tokens per swap

        vm.startPrank(user);

        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        uint256 initialATokenBalance = aUSDbC.balanceOf(recipient);
        console2.log("Initial aToken balance:", initialATokenBalance);

        // Perform 3 swaps
        for (uint256 i = 0; i < 3; i++) {
            console2.log("\nSwap", i + 1);

            uint256 aTokenBefore = aUSDbC.balanceOf(recipient);

            swapRouter.swapExactTokensForTokens({
                amountIn: swapAmount,
                amountOutMin: 0,
                zeroForOne: true,
                poolKey: poolKey,
                hookData: hookData,
                receiver: user,
                deadline: block.timestamp + 1
            });

            uint256 aTokenAfter = aUSDbC.balanceOf(recipient);
            console2.log("  aToken increase:", aTokenAfter - aTokenBefore);

            assertGt(aTokenAfter, aTokenBefore, "aToken balance should increase");
        }

        uint256 finalATokenBalance = aUSDbC.balanceOf(recipient);
        console2.log("\nFinal aToken balance:", finalATokenBalance);
        console2.log("Total aToken increase:", finalATokenBalance - initialATokenBalance);

        vm.stopPrank();

        assertGt(finalATokenBalance, initialATokenBalance, "Should accumulate aTokens across swaps");
    }

    function testMainnetForkSwapReverseDirection() public {
        console2.log("\n=== Testing reverse swap with Aave deposit ===");

        // First, get some token1 for the user
        vm.prank(BaseConstants.USDbC_WHALE);
        usdbc.transfer(user, 10000e6); // 10k USDbC

        vm.startPrank(user);

        address recipient = address(0x9ABC);
        uint256 amountIn = 1000e6; // 1000 token1

        IERC20 token0 = IERC20(Currency.unwrap(currency0));
        IERC20 token1 = IERC20(Currency.unwrap(currency1));

        uint256 token0Before = token0.balanceOf(user);
        uint256 token1Before = token1.balanceOf(user);
        uint256 aTokenBefore = aUSDC.balanceOf(recipient);

        console2.log("Before swap:");
        console2.log("  User token0:", token0Before);
        console2.log("  User token1:", token1Before);
        console2.log("  Recipient aToken0:", aTokenBefore);

        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        // Swap token1 -> token0
        swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: false,
            poolKey: poolKey,
            hookData: hookData,
            receiver: user,
            deadline: block.timestamp + 1
        });

        uint256 token0After = token0.balanceOf(user);
        uint256 token1After = token1.balanceOf(user);
        uint256 aTokenAfter = aUSDC.balanceOf(recipient);

        console2.log("After swap:");
        console2.log("  User token0:", token0After);
        console2.log("  User token1:", token1After);
        console2.log("  Recipient aToken0:", aTokenAfter);
        console2.log("  aToken0 received:", aTokenAfter - aTokenBefore);

        vm.stopPrank();

        // Verify swap executed and tokens deposited to Aave
        assertEq(token1Before - token1After, amountIn, "Should spend exact token1 amount");
        assertEq(token0After, token0Before, "User should not receive token0 directly");
        assertGt(aTokenAfter, aTokenBefore, "Recipient should receive aToken0 from Aave");

        console2.log("✓ Reverse swap successfully deposited to Aave");
    }
}
