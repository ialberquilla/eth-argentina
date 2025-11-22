// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

interface IL2Resolver {
    function setAddr(bytes32 node, address a) external;
}

interface IReverseRegistrar {
    function setName(string memory name) external returns (bytes32);
}

contract SetBasenameAddr is Script {
    address constant L2_RESOLVER = 0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA;
    address constant REVERSE_REGISTRAR = 0x876eF94ce0773052a2f81921E70FF25a5e76841f;
    bytes32 constant NODE = 0xbfbf4727806a184d751263218441175a9acd64fa434d88111a876d00d5ccf960;
    string constant NAME = "onetx";

    function run() public {
        console2.log("Configuring records for:", string.concat(NAME, ".base.eth"));
        
        vm.startBroadcast();

        // 1. Set Forward Resolution (onetx.base.eth -> User)
        console2.log("Setting forward resolution (name -> address)...");
        IL2Resolver(L2_RESOLVER).setAddr(NODE, msg.sender);

        // 2. Set Reverse Resolution (User -> onetx.base.eth)
        console2.log("Setting reverse resolution (address -> name)...");
        try IReverseRegistrar(REVERSE_REGISTRAR).setName(NAME) {
             console2.log("Reverse record set.");
        } catch {
             console2.log("Failed to set reverse record (might be already set or unauthorized).");
        }

        vm.stopBroadcast();
        
        console2.log("Records updated successfully!");
    }
}
