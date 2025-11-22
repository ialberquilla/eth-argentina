// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

/// @notice Simple script to register a basename using web interface
contract RegisterBasenameSimpleScript is Script {
    string constant NAME_TO_REGISTER = "onetx";

    function run() public view {
        console2.log("========================================");
        console2.log("Register Basename: Manual Instructions");
        console2.log("========================================");
        console2.log("");
        console2.log("Name to register:", string.concat(NAME_TO_REGISTER, ".base.eth"));
        console2.log("Your address:", msg.sender);
        console2.log("");
        console2.log("========================================");
        console2.log("STEPS:");
        console2.log("========================================");
        console2.log("");
        console2.log("1. Go to: https://www.base.org/names");
        console2.log("");
        console2.log("2. Connect wallet with address:");
        console2.log("   ", msg.sender);
        console2.log("");
        console2.log("3. Search for and register:");
        console2.log("   ", string.concat(NAME_TO_REGISTER, ".base.eth"));
        console2.log("");
        console2.log("4. Cost on Base Sepolia testnet:");
        console2.log("   Should be FREE or very cheap");
        console2.log("");
        console2.log("5. After registration, verify with:");
        console2.log("   forge script script/RegisterBasenameAndDeploy.s.sol \\");
        console2.log("     --rpc-url baseSepolia -vv");
        console2.log("");
        console2.log("6. Then deploy everything:");
        console2.log("   ./deploy-base-sepolia.sh");
        console2.log("");
        console2.log("========================================");
        console2.log("Alternative: Use Basescan");
        console2.log("========================================");
        console2.log("");
        console2.log("1. Go to the Registrar Controller:");
        console2.log("   https://sepolia.basescan.org/address/0x49aE3cC2e3AA768B1e5654f5D3C6002144A59581#writeContract");
        console2.log("");
        console2.log("2. Connect your wallet");
        console2.log("");
        console2.log("3. Use the 'register' function with:");
        console2.log("   - name: ", NAME_TO_REGISTER);
        console2.log("   - owner:", msg.sender);
        console2.log("   - duration: 31536000 (1 year)");
        console2.log("   - resolver: 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA");
        console2.log("");
        console2.log("========================================");
    }
}
