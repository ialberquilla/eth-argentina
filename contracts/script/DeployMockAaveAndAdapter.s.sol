// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {MockAavePool} from "../test/mocks/MockAavePool.sol";
import {AaveAdapter} from "../src/adapters/AaveAdapter.sol";

contract DeployMockAaveAndAdapter is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Deploy Mock Aave Pool
        MockAavePool mockPool = new MockAavePool();
        console.log("Mock Aave Pool Deployed at:", address(mockPool));

        // 2. Deploy AaveAdapter for USDT (we only really need this one for the swap)
        // USDT Address on Base Sepolia: 0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a
        AaveAdapter adapter = new AaveAdapter(address(mockPool), "USDT");
        console.log("New USDT Adapter Deployed at:", address(adapter));

        vm.stopBroadcast();
    }
}
