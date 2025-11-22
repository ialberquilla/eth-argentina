// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";

contract AdapterRegistryTest is Test {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;

    AdapterRegistry registry;
    AaveAdapter adapter;

    string constant DOMAIN = "adapters.eth";

    function setUp() public {
        registry = new AdapterRegistry();
        adapter = new AaveAdapter(address(0x1234), "USDC");
    }

    function testRegisterAdapter() public {
        registry.registerAdapter(address(adapter), DOMAIN);

        // Generate expected ENS name
        ILendingAdapter.AdapterMetadata memory metadata = adapter.getAdapterMetadata();
        string memory expectedEnsName = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, DOMAIN);

        // Verify adapter can be resolved
        address resolvedAdapter = registry.resolveAdapter(expectedEnsName);
        assertEq(resolvedAdapter, address(adapter), "Should resolve to correct adapter");
    }

    function testGetAdapterNode() public {
        registry.registerAdapter(address(adapter), DOMAIN);

        bytes32 node = registry.getAdapterNode(address(adapter), DOMAIN);
        assertTrue(node != bytes32(0), "Node should not be zero");
    }

    function testResolveUnregisteredAdapter() public {
        vm.expectRevert("Adapter not registered");
        registry.resolveAdapter("USDC:BASE:test-test.adapters.eth");
    }

    function testRegisterMultipleAdapters() public {
        AaveAdapter adapter2 = new AaveAdapter(address(0x5678), "DAI");

        registry.registerAdapter(address(adapter), DOMAIN);
        registry.registerAdapter(address(adapter2), DOMAIN);

        ILendingAdapter.AdapterMetadata memory metadata1 = adapter.getAdapterMetadata();
        ILendingAdapter.AdapterMetadata memory metadata2 = adapter2.getAdapterMetadata();

        string memory ensName1 = AdapterIdGenerator.generateAdapterIdWithDomain(metadata1, DOMAIN);
        string memory ensName2 = AdapterIdGenerator.generateAdapterIdWithDomain(metadata2, DOMAIN);

        assertEq(registry.resolveAdapter(ensName1), address(adapter));
        assertEq(registry.resolveAdapter(ensName2), address(adapter2));
    }
}
