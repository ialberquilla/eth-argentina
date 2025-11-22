// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {SwapDepositor} from "../src/SwapDepositor.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";

/// @notice Query script to get information about deployed contracts
/// @dev Use this to get adapter ENS names and verify deployments
contract QueryDeploymentScript is Script {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    // Update these addresses after deployment
    address constant ADAPTER_REGISTRY = address(0); // TODO: Update with deployed address
    address constant USDC_ADAPTER = address(0);     // TODO: Update with deployed address
    address constant USDbC_ADAPTER = address(0);    // TODO: Update with deployed address
    address constant SWAP_DEPOSITOR = address(0);   // TODO: Update with deployed address

    string constant ADAPTER_DOMAIN = "adapters.eth";

    function run() public view {
        console2.log("========================================");
        console2.log("Deployment Query Tool");
        console2.log("========================================\n");

        // Check if addresses are configured
        if (ADAPTER_REGISTRY == address(0)) {
            console2.log("ERROR: Please update the contract addresses in this script first!");
            console2.log("Update the following constants:");
            console2.log("  - ADAPTER_REGISTRY");
            console2.log("  - USDC_ADAPTER");
            console2.log("  - USDbC_ADAPTER");
            console2.log("  - SWAP_DEPOSITOR");
            return;
        }

        AdapterRegistry registry = AdapterRegistry(ADAPTER_REGISTRY);

        // Query USDC Adapter
        if (USDC_ADAPTER != address(0)) {
            console2.log("--- USDC Adapter ---");
            queryAdapter(registry, USDC_ADAPTER, "USDC");
            console2.log("");
        }

        // Query USDbC Adapter
        if (USDbC_ADAPTER != address(0)) {
            console2.log("--- USDbC Adapter ---");
            queryAdapter(registry, USDbC_ADAPTER, "USDbC");
            console2.log("");
        }

        // Query SwapDepositor
        if (SWAP_DEPOSITOR != address(0)) {
            console2.log("--- SwapDepositor Hook ---");
            SwapDepositor hook = SwapDepositor(SWAP_DEPOSITOR);
            console2.log("Hook Address:", address(hook));
            console2.log("Pool Manager:", address(hook.poolManager()));
            console2.log("Adapter Registry:", address(hook.adapterRegistry()));
            console2.log("");
        }

        console2.log("========================================");
    }

    function queryAdapter(
        AdapterRegistry registry,
        address adapterAddress,
        string memory expectedSymbol
    ) internal view {
        AaveAdapter adapter = AaveAdapter(adapterAddress);

        console2.log("Adapter Address:", adapterAddress);
        console2.log("Token Symbol:", adapter.symbol());
        console2.log("Aave Pool:", address(adapter.aavePool()));

        // Get adapter metadata
        ILendingAdapter.AdapterMetadata memory metadata = adapter.getAdapterMetadata();
        console2.log("Chain ID:", metadata.chainId);

        // Generate ENS name
        string memory ensName = AdapterIdGenerator.generateAdapterIdWithDomain(
            metadata,
            ADAPTER_DOMAIN
        );
        console2.log("ENS Name:", ensName);

        // Get ENS node
        bytes32 node = registry.getAdapterNode(adapterAddress, ADAPTER_DOMAIN);
        console2.log("ENS Node:", vm.toString(node));

        // Verify resolution
        address resolvedAddress = registry.resolveAdapter(ensName);
        console2.log("Resolves to:", resolvedAddress);
        console2.log("Resolution Valid:", resolvedAddress == adapterAddress ? "YES" : "NO");
    }
}
