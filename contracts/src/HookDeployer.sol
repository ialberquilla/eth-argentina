// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {SwapDepositor} from "./SwapDepositor.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IAdapterRegistry} from "./interfaces/IAdapterRegistry.sol";

/// @title HookDeployer
/// @notice Dedicated deployer for SwapDepositor hooks using CREATE2
/// @dev This contract exists solely to provide a consistent CREATE2 deployer address
contract HookDeployer {
    /// @notice Deploys a SwapDepositor hook with a specific salt
    /// @param salt The CREATE2 salt
    /// @param poolManager The Uniswap V4 pool manager
    /// @param adapterRegistry The adapter registry
    /// @return hook The deployed SwapDepositor hook
    function deploy(
        bytes32 salt,
        IPoolManager poolManager,
        IAdapterRegistry adapterRegistry
    ) external returns (SwapDepositor hook) {
        hook = new SwapDepositor{salt: salt}(poolManager, adapterRegistry);
    }
}
