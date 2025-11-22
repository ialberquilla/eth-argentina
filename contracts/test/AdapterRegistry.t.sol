// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AdapterRegistry} from "../src/AdapterRegistry.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";
import {AdapterIdGenerator} from "../src/libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "../src/interfaces/ILendingAdapter.sol";
import {MockENSRegistry} from "./mocks/MockENSRegistry.sol";
import {MockL2Resolver} from "./mocks/MockL2Resolver.sol";
import {ENSNamehash} from "../src/libraries/ENSNamehash.sol";

contract AdapterRegistryTest is Test {
    using AdapterIdGenerator for ILendingAdapter.AdapterMetadata;
    using ENSNamehash for string;

    AdapterRegistry registry;
    AaveAdapter adapter;
    MockENSRegistry ensRegistry;
    MockL2Resolver l2Resolver;

    string constant DOMAIN = "adapters.eth";
    bytes32 parentNode;

    function setUp() public {
        // Deploy mock ENS contracts
        ensRegistry = new MockENSRegistry();
        l2Resolver = new MockL2Resolver();

        // Calculate parent node
        parentNode = DOMAIN.namehash();

        // Set up the parent node to be owned by this test contract
        ensRegistry.setRecord(parentNode, address(this), address(l2Resolver), 0);

        // Deploy registry with ENS integration
        registry = new AdapterRegistry(
            address(ensRegistry),
            address(l2Resolver),
            parentNode,
            DOMAIN
        );

        // Deploy adapter
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
        vm.expectRevert();
        registry.resolveAdapter("usdc-base-test-test.adapters.eth");
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

    function testGetAllRegisteredAdapters() public {
        // Initially should have no adapters
        assertEq(registry.getRegisteredAdapterCount(), 0, "Should start with 0 adapters");

        // Register first adapter
        registry.registerAdapter(address(adapter), DOMAIN);
        assertEq(registry.getRegisteredAdapterCount(), 1, "Should have 1 adapter");

        // Register second adapter
        AaveAdapter adapter2 = new AaveAdapter(address(0x5678), "DAI");
        registry.registerAdapter(address(adapter2), DOMAIN);
        assertEq(registry.getRegisteredAdapterCount(), 2, "Should have 2 adapters");

        // Get all registered adapters
        AdapterRegistry.AdapterInfo[] memory allAdapters = registry.getAllRegisteredAdapters();
        assertEq(allAdapters.length, 2, "Should return 2 adapters");

        // Verify first adapter info
        assertEq(allAdapters[0].adapterAddress, address(adapter), "First adapter address should match");
        assertEq(allAdapters[0].domain, DOMAIN, "First adapter domain should match");
        assertTrue(bytes(allAdapters[0].adapterId).length > 0, "First adapter ID should not be empty");

        // Verify second adapter info
        assertEq(allAdapters[1].adapterAddress, address(adapter2), "Second adapter address should match");
        assertEq(allAdapters[1].domain, DOMAIN, "Second adapter domain should match");
        assertTrue(bytes(allAdapters[1].adapterId).length > 0, "Second adapter ID should not be empty");
    }

    function testGetAllRegisteredAdaptersEmpty() public {
        AdapterRegistry.AdapterInfo[] memory allAdapters = registry.getAllRegisteredAdapters();
        assertEq(allAdapters.length, 0, "Should return empty array when no adapters registered");
    }
}
