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
import {IBasenameRegistry} from "./interfaces/IBasenameRegistry.sol";
import {IBasenameResolver} from "./interfaces/IBasenameResolver.sol";
import {IAdapterRegistry} from "./interfaces/IAdapterRegistry.sol";
import {ENSNamehash} from "./libraries/ENSNamehash.sol";

contract SwapDepositor is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using ENSNamehash for string;

    /// @notice Basenames Registry contract on Base mainnet
    IBasenameRegistry public constant BASENAME_REGISTRY =
        IBasenameRegistry(0xB94704422c2a1E396835A571837Aa5AE53285a95);

    /// @notice Adapter Registry for resolving lending adapter ENS names
    IAdapterRegistry public immutable adapterRegistry;

    /// @notice Stores swap context for resolving recipients in afterSwap
    /// @dev Maps swapId => SwapContext containing adapter and recipient info
    struct SwapContext {
        address adapter;
        address recipient;
        bool exists;
    }

    mapping(bytes32 => SwapContext) private swapContexts;

    /// @notice Emitted when tokens are deposited to a lending protocol after a swap
    /// @param poolId The pool where the swap occurred
    /// @param adapter The lending adapter used
    /// @param token The token that was deposited
    /// @param amount The amount deposited
    /// @param recipient The address receiving the deposit tokens
    event DepositedToLending(
        PoolId indexed poolId, address indexed adapter, Currency token, uint256 amount, address recipient
    );

    /// @notice Emitted when a basename is resolved in beforeSwap
    /// @param basename The basename that was resolved
    /// @param resolvedAddress The address it resolved to
    event BasenameResolved(string basename, address resolvedAddress);

    /// @notice Emitted when an adapter ENS name is resolved
    /// @param adapterEnsName The adapter ENS name that was resolved
    /// @param resolvedAddress The adapter address it resolved to
    event AdapterResolved(string adapterEnsName, address resolvedAddress);

    constructor(IPoolManager _poolManager, IAdapterRegistry _adapterRegistry) BaseHook(_poolManager) {
        require(address(_adapterRegistry) != address(0), "Invalid adapter registry");
        adapterRegistry = _adapterRegistry;
    }

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

    function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        // Only proceed if hookData is provided
        if (hookData.length > 0) {
            // Decode adapter identifier and recipient identifier (both can be ENS names or addresses)
            (string memory adapterIdentifier, string memory recipientIdentifier) = abi.decode(hookData, (string, string));

            // Only proceed if we have valid identifiers
            if (bytes(adapterIdentifier).length > 0 && bytes(recipientIdentifier).length > 0) {
                address resolvedAdapter;
                address resolvedRecipient;

                // Resolve adapter identifier (address or ENS name)
                if (isAddressString(adapterIdentifier)) {
                    // Parse as address
                    resolvedAdapter = parseAddress(adapterIdentifier);
                } else {
                    // Resolve as adapter ENS name
                    resolvedAdapter = adapterRegistry.resolveAdapter(adapterIdentifier);
                    emit AdapterResolved(adapterIdentifier, resolvedAdapter);
                }

                // Resolve recipient identifier (address or basename)
                if (isAddressString(recipientIdentifier)) {
                    // Parse as address
                    resolvedRecipient = parseAddress(recipientIdentifier);
                } else {
                    // Resolve as basename
                    resolvedRecipient = resolveBasename(recipientIdentifier);
                    emit BasenameResolved(recipientIdentifier, resolvedRecipient);
                }

                require(resolvedAdapter != address(0), "Invalid adapter");
                require(resolvedRecipient != address(0), "Invalid recipient");

                // Create unique swap ID to link beforeSwap and afterSwap
                bytes32 swapId = keccak256(abi.encodePacked(sender, key.toId(), params.zeroForOne, block.number));

                // Store context for afterSwap
                swapContexts[swapId] = SwapContext({
                    adapter: resolvedAdapter,
                    recipient: resolvedRecipient,
                    exists: true
                });
            }
        }

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _afterSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) internal override returns (bytes4, int128) {
        // Only proceed if hookData is provided
        if (hookData.length > 0) {
            // Recreate the same swap ID from beforeSwap
            bytes32 swapId = keccak256(abi.encodePacked(sender, key.toId(), params.zeroForOne, block.number));

            // Retrieve stored swap context
            SwapContext memory context = swapContexts[swapId];

            // Only deposit if we have a valid context
            if (context.exists && context.adapter != address(0) && context.recipient != address(0)) {
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
                    IERC20(tokenAddress).approve(context.adapter, outputAmount);

                    // Call the lending adapter to deposit tokens
                    // This transfers tokens from hook to adapter to lending protocol
                    ILendingAdapter(context.adapter).deposit(outputToken, outputAmount, context.recipient);

                    emit DepositedToLending(key.toId(), context.adapter, outputToken, outputAmount, context.recipient);

                    // Clean up storage
                    delete swapContexts[swapId];

                    // Return POSITIVE delta - this reduces what the swapper receives
                    // We took X tokens, we return +X delta to indicate swapper gets X less
                    // This balances the accounting: pool gave us X, swapper's claim reduced by X
                    return (BaseHook.afterSwap.selector, outputAmountSigned);
                }

                // Clean up storage even if no deposit occurred
                delete swapContexts[swapId];
            }
        }

        return (BaseHook.afterSwap.selector, 0);
    }

    // -----------------------------------------------
    // Helper Functions
    // -----------------------------------------------

    /// @notice Resolves a basename to an Ethereum address
    /// @param basename The basename to resolve (e.g., "alice.base.eth")
    /// @return The resolved Ethereum address
    function resolveBasename(string memory basename) internal view returns (address) {
        // Compute the namehash of the basename
        bytes32 node = basename.namehash();

        // Get the resolver address from the registry
        address resolverAddress = BASENAME_REGISTRY.resolver(node);
        require(resolverAddress != address(0), "Basename has no resolver");

        // Query the resolver for the address
        address resolvedAddress = IBasenameResolver(resolverAddress).addr(node);
        require(resolvedAddress != address(0), "Basename not registered");

        return resolvedAddress;
    }

    /// @notice Checks if a string is formatted as an Ethereum address
    /// @param str The string to check
    /// @return True if the string is an address format (0x + 40 hex chars)
    function isAddressString(string memory str) internal pure returns (bool) {
        bytes memory b = bytes(str);

        // Check length: "0x" + 40 hex characters = 42
        if (b.length != 42) {
            return false;
        }

        // Check if starts with "0x"
        if (b[0] != "0" || b[1] != "x") {
            return false;
        }

        // Check if all characters after "0x" are valid hex
        for (uint256 i = 2; i < 42; i++) {
            bytes1 char = b[i];
            if (
                !(char >= "0" && char <= "9") && // 0-9
                !(char >= "a" && char <= "f") && // a-f
                !(char >= "A" && char <= "F")    // A-F
            ) {
                return false;
            }
        }

        return true;
    }

    /// @notice Parses an address string to an address type
    /// @param str The address string (e.g., "0x1234...5678")
    /// @return The parsed address
    function parseAddress(string memory str) internal pure returns (address) {
        bytes memory b = bytes(str);
        require(b.length == 42, "Invalid address length");

        uint160 addr = 0;

        // Parse hex string to address (skip "0x" prefix)
        for (uint256 i = 2; i < 42; i++) {
            uint160 digit;
            bytes1 char = b[i];

            if (char >= "0" && char <= "9") {
                digit = uint160(uint8(char)) - 48;
            } else if (char >= "a" && char <= "f") {
                digit = uint160(uint8(char)) - 87;
            } else if (char >= "A" && char <= "F") {
                digit = uint160(uint8(char)) - 55;
            } else {
                revert("Invalid hex character");
            }

            addr = addr * 16 + digit;
        }

        return address(addr);
    }
}
