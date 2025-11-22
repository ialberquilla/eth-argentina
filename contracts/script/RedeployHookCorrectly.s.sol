// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {console} from "forge-std/console.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {BaseScript} from "./base/BaseScript.sol";

import {SwapDepositor} from "../src/SwapDepositor.sol";
import {IAdapterRegistry} from "../src/interfaces/IAdapterRegistry.sol";

/// @notice Redeploys the SwapDepositor.sol Hook contract with the correct PoolManager
contract RedeployHookCorrectly is BaseScript {
    address constant EXISTING_ADAPTER_REGISTRY = 0x7425AAa97230f6D575193667cfd402b0B89C47f2;

    function run() public {
        vm.startBroadcast();

        // Ensure we are using the correct PoolManager from AddressConstants (via BaseScript)
        console.log("Using PoolManager:", address(poolManager));

        // Use existing AdapterRegistry
        IAdapterRegistry adapterRegistry = IAdapterRegistry(EXISTING_ADAPTER_REGISTRY);
        console.log("Using AdapterRegistry:", address(adapterRegistry));

        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG);

        // Mine a salt that will produce a hook address with the correct flags
        bytes memory constructorArgs = abi.encode(poolManager, adapterRegistry);
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_FACTORY, flags, type(SwapDepositor).creationCode, constructorArgs);

        // Deploy the hook using CREATE2
        SwapDepositor swapDepositor = new SwapDepositor{salt: salt}(poolManager, adapterRegistry);
        console.log("New Hook Deployed at:", address(swapDepositor));

        vm.stopBroadcast();

        require(address(swapDepositor) == hookAddress, "DeployHookScript: Hook Address Mismatch");
    }
}
