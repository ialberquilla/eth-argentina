// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IL2Resolver} from "../../src/interfaces/IL2Resolver.sol";

/// @title MockL2Resolver
/// @notice Mock L2 Resolver for testing
contract MockL2Resolver is IL2Resolver {
    mapping(bytes32 => address) private addresses;
    mapping(bytes32 => mapping(uint256 => bytes)) private addressesForCoinType;
    mapping(bytes32 => mapping(string => string)) private texts;

    function setAddr(bytes32 node, address a) external override {
        addresses[node] = a;
        emit AddrChanged(node, a);
    }

    function addr(bytes32 node) external view override returns (address) {
        return addresses[node];
    }

    function setAddr(bytes32 node, uint256 coinType, bytes memory a) external override {
        addressesForCoinType[node][coinType] = a;
        emit AddressChanged(node, coinType, a);
    }

    function addr(bytes32 node, uint256 coinType) external view override returns (bytes memory) {
        return addressesForCoinType[node][coinType];
    }

    function setText(bytes32 node, string calldata key, string calldata value) external override {
        texts[node][key] = value;
        emit TextChanged(node, key, key, value);
    }

    function text(bytes32 node, string calldata key) external view override returns (string memory) {
        return texts[node][key];
    }
}
