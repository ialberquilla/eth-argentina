// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IENSRegistry} from "../../src/interfaces/IENSRegistry.sol";

/// @title MockENSRegistry
/// @notice Mock ENS Registry for testing
contract MockENSRegistry is IENSRegistry {
    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32 => Record) public records;

    function owner(bytes32 node) external view override returns (address) {
        return records[node].owner;
    }

    function resolver(bytes32 node) external view override returns (address) {
        return records[node].resolver;
    }

    function ttl(bytes32 node) external view override returns (uint64) {
        return records[node].ttl;
    }

    function setRecord(bytes32 node, address owner_, address resolver_, uint64 ttl_) external override {
        records[node] = Record(owner_, resolver_, ttl_);
        emit NewOwner(node, bytes32(0), owner_);
        emit NewResolver(node, resolver_);
        emit NewTTL(node, ttl_);
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner_) external override returns (bytes32) {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        records[subnode].owner = owner_;
        emit NewOwner(node, label, owner_);
        return subnode;
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner_, address resolver_, uint64 ttl_)
        external
        override
    {
        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        records[subnode] = Record(owner_, resolver_, ttl_);
        emit NewOwner(node, label, owner_);
        emit NewResolver(subnode, resolver_);
        emit NewTTL(subnode, ttl_);
    }

    function setOwner(bytes32 node, address owner_) external override {
        records[node].owner = owner_;
        emit Transfer(node, owner_);
    }

    function setResolver(bytes32 node, address resolver_) external override {
        records[node].resolver = resolver_;
        emit NewResolver(node, resolver_);
    }

    function setTTL(bytes32 node, uint64 ttl_) external override {
        records[node].ttl = ttl_;
        emit NewTTL(node, ttl_);
    }
}
