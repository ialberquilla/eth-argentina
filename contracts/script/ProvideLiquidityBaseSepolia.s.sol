// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

interface IERC20Metadata is IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
}

contract ProvideLiquidityBaseSepolia is Script {
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    // --- Addresses ---
    address constant POOL_MANAGER_ADDR = 0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829;
    address constant POSITION_MANAGER_ADDR = 0x4B2C77d209D3405F41a037Ec6c77F7F5b8e2ca80;
    address constant PERMIT2_ADDR = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant USDC_ADDR = 0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f;
    address constant USDT_ADDR = 0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a;
    address constant HOOK_ADDR = 0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4;

    // --- Configuration ---
    uint24 constant LP_FEE = 3000;
    int24 constant TICK_SPACING = 60;
    int24 constant TICK_RANGE = 1000; 

    IPoolManager poolManager = IPoolManager(POOL_MANAGER_ADDR);
    IPositionManager positionManager = IPositionManager(POSITION_MANAGER_ADDR);
    IPermit2 permit2 = IPermit2(PERMIT2_ADDR);

    function run() external {
        require(block.chainid == 84532, "Wrong chain, expected Base Sepolia (84532)");
        
        vm.startBroadcast();

        (Currency currency0, Currency currency1) = _getSortedCurrencies();
        
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: LP_FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(HOOK_ADDR)
        });

        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(poolKey.toId());
        bool isInitialized = sqrtPriceX96 != 0;
        
        bytes[] memory multicallParams;

        // Block to limit stack depth
        {
            uint160 startingPrice = isInitialized ? sqrtPriceX96 : 79228162514264337593543950336;
            
            uint256 amount0Raw = 5000 * (10 ** IERC20Metadata(Currency.unwrap(currency0)).decimals());
            uint256 amount1Raw = 5000 * (10 ** IERC20Metadata(Currency.unwrap(currency1)).decimals());

            int24 tickLower; 
            int24 tickUpper;
            {
                 int24 currentTick = TickMath.getTickAtSqrtPrice(startingPrice);
                 tickLower = truncateTickSpacing((currentTick - TICK_RANGE * TICK_SPACING), TICK_SPACING);
                 tickUpper = truncateTickSpacing((currentTick + TICK_RANGE * TICK_SPACING), TICK_SPACING);
            }

            uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
                startingPrice,
                TickMath.getSqrtPriceAtTick(tickLower),
                TickMath.getSqrtPriceAtTick(tickUpper),
                amount0Raw,
                amount1Raw
            );

            console2.log("Providing Liquidity:", liquidity);

            // Slippage: 1%
            uint256 amount0Max = amount0Raw + (amount0Raw / 100);
            uint256 amount1Max = amount1Raw + (amount1Raw / 100);

            bytes memory actions = abi.encodePacked(
                uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR), uint8(Actions.SWEEP), uint8(Actions.SWEEP)
            );
            
            bytes[] memory mintParams = new bytes[](4);
            mintParams[0] = abi.encode(poolKey, tickLower, tickUpper, liquidity, amount0Max, amount1Max, msg.sender, new bytes(0));
            mintParams[1] = abi.encode(currency0, currency1);
            mintParams[2] = abi.encode(currency0, msg.sender);
            mintParams[3] = abi.encode(currency1, msg.sender);

            if (!isInitialized) {
                console2.log("Initializing Pool...");
                multicallParams = new bytes[](2);
                multicallParams[0] = abi.encodeWithSelector(positionManager.initializePool.selector, poolKey, startingPrice, new bytes(0));
                multicallParams[1] = abi.encodeWithSelector(positionManager.modifyLiquidities.selector, abi.encode(actions, mintParams), block.timestamp + 3600);
            } else {
                console2.log("Adding to existing pool...");
                multicallParams = new bytes[](1);
                multicallParams[0] = abi.encodeWithSelector(positionManager.modifyLiquidities.selector, abi.encode(actions, mintParams), block.timestamp + 3600);
            }
        }

        tokenApprovals(Currency.unwrap(currency0), Currency.unwrap(currency1));
        positionManager.multicall(multicallParams);
        
        console2.log("Success!");
        vm.stopBroadcast();
    }

    function _getSortedCurrencies() internal view returns (Currency, Currency) {
        address t0 = USDC_ADDR;
        address t1 = USDT_ADDR;
        if (t0 > t1) (t0, t1) = (t1, t0);
        return (Currency.wrap(t0), Currency.wrap(t1));
    }

    function tokenApprovals(address token0, address token1) internal {
        IERC20(token0).approve(address(permit2), type(uint256).max);
        permit2.approve(address(token0), address(positionManager), type(uint160).max, type(uint48).max);

        IERC20(token1).approve(address(permit2), type(uint256).max);
        permit2.approve(address(token1), address(positionManager), type(uint160).max, type(uint48).max);
    }

    function truncateTickSpacing(int24 tick, int24 tickSpacing) internal pure returns (int24) {
        return ((tick / tickSpacing) * tickSpacing);
    }
}