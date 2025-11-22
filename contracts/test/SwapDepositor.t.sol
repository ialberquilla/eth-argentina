// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

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
import {MockAavePool} from "./mocks/MockAavePool.sol";
import {BaseTest} from "./utils/BaseTest.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SwapDepositorTest is BaseTest {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    Currency currency0;
    Currency currency1;

    PoolKey poolKey;

    SwapDepositor hook;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    function setUp() public {
        // Deploys all required artifacts.
        deployArtifactsAndLabel();

        (currency0, currency1) = deployCurrencyPair();

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG)
                ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );
        bytes memory constructorArgs = abi.encode(poolManager); // Add all the necessary constructor arguments from the hook
        deployCodeTo("SwapDepositor.sol:SwapDepositor", constructorArgs, flags);
        hook = SwapDepositor(flags);

        // Create the pool
        poolKey = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = poolKey.toId();
        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        // Provide full-range liquidity to the pool
        tickLower = TickMath.minUsableTick(poolKey.tickSpacing);
        tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);

        uint128 liquidityAmount = 100e18;

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityAmount
        );

        (tokenId,) = positionManager.mint(
            poolKey,
            tickLower,
            tickUpper,
            liquidityAmount,
            amount0Expected + 1,
            amount1Expected + 1,
            address(this),
            block.timestamp,
            Constants.ZERO_BYTES
        );
    }

    function testSwapDepositorHooks() public {
        // Perform a test swap //
        uint256 amountIn = 1e18;
        BalanceDelta swapDelta = swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0, // Very bad, but we want to allow for unlimited price impact
            zeroForOne: true,
            poolKey: poolKey,
            hookData: Constants.ZERO_BYTES,
            receiver: address(this),
            deadline: block.timestamp + 1
        });
        // ------------------- //

        // Verify swap executed correctly
        assertEq(int256(swapDelta.amount0()), -int256(amountIn));
        assertGt(uint256(int256(swapDelta.amount1())), 0, "Should receive output tokens");
    }

    function testSwapWithAaveDeposit() public {
        // Deploy mock Aave pool
        MockAavePool mockAavePool = new MockAavePool();

        // Deploy Aave adapter
        AaveAdapter aaveAdapter = new AaveAdapter(address(mockAavePool));

        // Setup swap parameters
        uint256 amountIn = 1e18;
        address recipient = address(0x1234);

        // Encode adapter address and recipient in hookData
        // This tells the hook to automatically deposit to Aave after the swap
        bytes memory hookData = abi.encode(address(aaveAdapter), recipient);

        // Store balances before swap
        address token1Address = Currency.unwrap(currency1);
        uint256 swapperBalanceBefore = IERC20(token1Address).balanceOf(address(this));

        // Perform the swap with hookData
        // The hook will automatically intercept output and deposit to Aave
        swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: true,
            poolKey: poolKey,
            hookData: hookData, // Adapter info in hookData
            receiver: address(this), // Swapper is the receiver (but won't get tokens due to hook)
            deadline: block.timestamp + 1
        });

        // Verify tokens were AUTOMATICALLY deposited to Aave on behalf of recipient
        uint256 deposited = mockAavePool.getDeposit(token1Address, recipient);
        assertGt(deposited, 0, "Tokens should be deposited to Aave");

        // Verify hook doesn't hold tokens (they went straight to Aave)
        assertEq(IERC20(token1Address).balanceOf(address(hook)), 0, "Hook should have no tokens");

        // Verify swapper didn't receive tokens (they went to Aave instead)
        uint256 swapperBalanceAfter = IERC20(token1Address).balanceOf(address(this));
        assertEq(swapperBalanceAfter, swapperBalanceBefore, "Swapper should not have received any tokens");
    }
}
