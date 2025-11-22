// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "@openzeppelin/uniswap-hooks/src/base/BaseHook.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager, SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {ILendingAdapter} from "./interfaces/ILendingAdapter.sol";

contract SwapDepositor is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    /// @notice Emitted when tokens are deposited to a lending protocol after a swap
    /// @param poolId The pool where the swap occurred
    /// @param adapter The lending adapter used
    /// @param token The token that was deposited
    /// @param amount The amount deposited
    /// @param recipient The address receiving the deposit tokens
    event DepositedToLending(
        PoolId indexed poolId, address indexed adapter, Currency token, uint256 amount, address recipient
    );

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: true, // Enable to claim swap output
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------

    function _beforeSwap(address, PoolKey calldata, SwapParams calldata, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _afterSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal override returns (bytes4, int128) {
        // Only proceed if hookData is provided
        if (hookData.length > 0) {
            // Decode adapter address and recipient from hookData
            (address adapterAddress, address recipient) = abi.decode(hookData, (address, address));

            // Only deposit if we have a valid adapter
            if (adapterAddress != address(0) && recipient != address(0)) {
                // Determine output token and amount based on swap direction
                Currency outputToken;
                int128 outputAmountSigned;

                if (params.zeroForOne) {
                    // Swapping token0 for token1, so output is token1
                    outputToken = key.currency1;
                    outputAmountSigned = delta.amount1();
                } else {
                    // Swapping token1 for token0, so output is token0
                    outputToken = key.currency0;
                    outputAmountSigned = delta.amount0();
                }

                uint256 outputAmount = uint256(int256(outputAmountSigned));

                if (outputAmount > 0) {
                    address tokenAddress = Currency.unwrap(outputToken);

                    // Take the output tokens from pool manager to this hook
                    poolManager.take(outputToken, address(this), outputAmount);

                    // Approve the adapter to spend the tokens
                    IERC20(tokenAddress).approve(adapterAddress, outputAmount);

                    // Call the lending adapter to deposit tokens
                    // This transfers tokens from hook to adapter to lending protocol
                    ILendingAdapter(adapterAddress).deposit(outputToken, outputAmount, recipient);

                    emit DepositedToLending(key.toId(), adapterAddress, outputToken, outputAmount, recipient);

                    // Return POSITIVE delta - this reduces what the swapper receives
                    // We took X tokens, we return +X delta to indicate swapper gets X less
                    // This balances the accounting: pool gave us X, swapper's claim reduced by X
                    return (BaseHook.afterSwap.selector, outputAmountSigned);
                }
            }
        }

        return (BaseHook.afterSwap.selector, 0);
    }
}
