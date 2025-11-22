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
    IERC20 weth = IERC20(BaseConstants.WETH);
    IERC20 aUSDC = IERC20(BaseConstants.aUSDC);

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
        // Create fork at a recent block
        // Note: You can override this by setting FORK_BLOCK_NUMBER env var
        uint256 forkBlock = vm.envOr("FORK_BLOCK_NUMBER", uint256(22000000));
        vm.createSelectFork(vm.rpcUrl("base"), forkBlock);

        console2.log("Forked Base mainnet at block:", block.number);

        // Deploy V4 infrastructure (not yet on Base mainnet)
        deployArtifactsAndLabel();

        // Use real USDC and WETH from Base
        currency0 = Currency.wrap(address(usdc));
        currency1 = Currency.wrap(address(weth));

        // Ensure currency0 < currency1 for Uniswap V4
        if (Currency.unwrap(currency0) > Currency.unwrap(currency1)) {
            (currency0, currency1) = (currency1, currency0);
        }

        console2.log("Currency0 (USDC):", Currency.unwrap(currency0));
        console2.log("Currency1 (WETH):", Currency.unwrap(currency1));

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
        address wethWhale = BaseConstants.WETH_WHALE;

        // Get USDC from whale
        vm.prank(usdcWhale);
        usdc.transfer(liquidityProvider, 1000000e6); // 1M USDC

        // Get WETH from whale
        vm.prank(wethWhale);
        weth.transfer(liquidityProvider, 100e18); // 100 WETH

        console2.log("Funded liquidity provider");
        console2.log("  USDC balance:", usdc.balanceOf(liquidityProvider));
        console2.log("  WETH balance:", weth.balanceOf(liquidityProvider));
    }

    function _addLiquidity() internal {
        vm.startPrank(liquidityProvider);

        // Approve tokens
        usdc.approve(address(permit2), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        permit2.approve(address(usdc), address(positionManager), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(positionManager), type(uint160).max, type(uint48).max);

        // Setup liquidity position
        tickLower = TickMath.minUsableTick(poolKey.tickSpacing);
        tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);

        uint128 liquidityAmount = 10e18; // Smaller amount for testing

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityAmount
        );

        console2.log("Adding liquidity:");
        console2.log("  Amount0 (USDC):", amount0Expected);
        console2.log("  Amount1 (WETH):", amount1Expected);

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
        usdc.approve(address(permit2), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        permit2.approve(address(usdc), address(swapRouter), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(swapRouter), type(uint160).max, type(uint48).max);
        vm.stopPrank();

        console2.log("Funded test user with USDC:", usdc.balanceOf(user));
    }

    function testMainnetForkSwapWithoutHook() public {
        console2.log("\n=== Testing basic swap without hook ===");

        vm.startPrank(user);

        uint256 amountIn = 1000e6; // 1000 USDC
        uint256 usdcBefore = usdc.balanceOf(user);
        uint256 wethBefore = weth.balanceOf(user);

        console2.log("Before swap:");
        console2.log("  USDC:", usdcBefore);
        console2.log("  WETH:", wethBefore);

        // Perform swap without hookData (no deposit to Aave)
        BalanceDelta swapDelta = swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: true, // USDC -> WETH
            poolKey: poolKey,
            hookData: Constants.ZERO_BYTES,
            receiver: user,
            deadline: block.timestamp + 1
        });

        uint256 usdcAfter = usdc.balanceOf(user);
        uint256 wethAfter = weth.balanceOf(user);

        console2.log("After swap:");
        console2.log("  USDC:", usdcAfter);
        console2.log("  WETH:", wethAfter);
        console2.log("  USDC spent:", usdcBefore - usdcAfter);
        console2.log("  WETH received:", wethAfter - wethBefore);

        vm.stopPrank();

        // Verify swap executed correctly
        assertEq(usdcBefore - usdcAfter, amountIn, "Should spend exact USDC amount");
        assertGt(wethAfter, wethBefore, "Should receive WETH");
    }

    function testMainnetForkSwapWithAaveDeposit() public {
        console2.log("\n=== Testing swap with Aave deposit ===");

        vm.startPrank(user);

        address recipient = address(0x1234);
        uint256 amountIn = 1000e6; // 1000 USDC

        uint256 usdcBefore = usdc.balanceOf(user);
        uint256 wethBefore = weth.balanceOf(user);
        uint256 aTokenBefore = aUSDC.balanceOf(recipient); // Check WETH aTokens

        console2.log("Before swap:");
        console2.log("  User USDC:", usdcBefore);
        console2.log("  User WETH:", wethBefore);
        console2.log("  Recipient aWETH:", aTokenBefore);

        // Encode adapter address and recipient in hookData
        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        // Perform swap with Aave deposit
        BalanceDelta swapDelta = swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: true, // USDC -> WETH
            poolKey: poolKey,
            hookData: hookData,
            receiver: user, // User is receiver, but tokens go to Aave
            deadline: block.timestamp + 1
        });

        uint256 usdcAfter = usdc.balanceOf(user);
        uint256 wethAfter = weth.balanceOf(user);
        uint256 aTokenAfter = aUSDC.balanceOf(recipient);

        console2.log("After swap:");
        console2.log("  User USDC:", usdcAfter);
        console2.log("  User WETH:", wethAfter);
        console2.log("  Recipient aWETH:", aTokenAfter);
        console2.log("  aWETH received:", aTokenAfter - aTokenBefore);

        vm.stopPrank();

        // Verify tokens were spent
        assertEq(usdcBefore - usdcAfter, amountIn, "Should spend exact USDC amount");

        // Verify user didn't receive WETH (went to Aave)
        assertEq(wethAfter, wethBefore, "User should not receive WETH directly");

        // Verify recipient received aTokens from Aave
        assertGt(aTokenAfter, aTokenBefore, "Recipient should receive aTokens from Aave");

        // Verify hook doesn't hold any tokens
        assertEq(weth.balanceOf(address(hook)), 0, "Hook should not hold WETH");
        assertEq(usdc.balanceOf(address(hook)), 0, "Hook should not hold USDC");

        console2.log("✓ Swap successfully deposited to Aave V3 on Base mainnet");
    }

    function testMainnetForkMultipleSwapsWithAaveDeposit() public {
        console2.log("\n=== Testing multiple swaps with Aave deposit ===");

        address recipient = address(0x5678);
        uint256 swapAmount = 500e6; // 500 USDC per swap

        vm.startPrank(user);

        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        uint256 initialATokenBalance = aUSDC.balanceOf(recipient);
        console2.log("Initial aToken balance:", initialATokenBalance);

        // Perform 3 swaps
        for (uint256 i = 0; i < 3; i++) {
            console2.log("\nSwap", i + 1);

            uint256 aTokenBefore = aUSDC.balanceOf(recipient);

            swapRouter.swapExactTokensForTokens({
                amountIn: swapAmount,
                amountOutMin: 0,
                zeroForOne: true,
                poolKey: poolKey,
                hookData: hookData,
                receiver: user,
                deadline: block.timestamp + 1
            });

            uint256 aTokenAfter = aUSDC.balanceOf(recipient);
            console2.log("  aToken increase:", aTokenAfter - aTokenBefore);

            assertGt(aTokenAfter, aTokenBefore, "aToken balance should increase");
        }

        uint256 finalATokenBalance = aUSDC.balanceOf(recipient);
        console2.log("\nFinal aToken balance:", finalATokenBalance);
        console2.log("Total aToken increase:", finalATokenBalance - initialATokenBalance);

        vm.stopPrank();

        assertGt(finalATokenBalance, initialATokenBalance, "Should accumulate aTokens across swaps");
    }

    function testMainnetForkSwapReverseDirection() public {
        console2.log("\n=== Testing reverse swap (WETH -> USDC) with Aave deposit ===");

        // First, get some WETH for the user
        vm.prank(BaseConstants.WETH_WHALE);
        weth.transfer(user, 1e18); // 1 WETH

        vm.startPrank(user);

        address recipient = address(0x9ABC);
        uint256 amountIn = 0.1e18; // 0.1 WETH

        uint256 wethBefore = weth.balanceOf(user);
        uint256 usdcBefore = usdc.balanceOf(user);
        uint256 aTokenBefore = aUSDC.balanceOf(recipient);

        console2.log("Before swap:");
        console2.log("  User WETH:", wethBefore);
        console2.log("  User USDC:", usdcBefore);
        console2.log("  Recipient aUSDC:", aTokenBefore);

        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        // Swap WETH -> USDC
        swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: false, // WETH -> USDC
            poolKey: poolKey,
            hookData: hookData,
            receiver: user,
            deadline: block.timestamp + 1
        });

        uint256 wethAfter = weth.balanceOf(user);
        uint256 usdcAfter = usdc.balanceOf(user);
        uint256 aTokenAfter = aUSDC.balanceOf(recipient);

        console2.log("After swap:");
        console2.log("  User WETH:", wethAfter);
        console2.log("  User USDC:", usdcAfter);
        console2.log("  Recipient aUSDC:", aTokenAfter);
        console2.log("  aUSDC received:", aTokenAfter - aTokenBefore);

        vm.stopPrank();

        // Verify swap executed and tokens deposited to Aave
        assertEq(wethBefore - wethAfter, amountIn, "Should spend exact WETH amount");
        assertEq(usdcAfter, usdcBefore, "User should not receive USDC directly");
        assertGt(aTokenAfter, aTokenBefore, "Recipient should receive aUSDC from Aave");

        console2.log("✓ Reverse swap successfully deposited to Aave");
    }
}
