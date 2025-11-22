// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title BaseConstants
/// @notice Constants for Base mainnet addresses
library BaseConstants {
    // ============ Aave V3 Addresses ============
    address constant AAVE_V3_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;

    // ============ Compound V3 Addresses ============
    address constant COMPOUND_V3_USDC = 0xb125E6687d4313864e53df431d5425969c15Eb2F;

    // ============ Morpho Blue Addresses ============
    address constant MORPHO_BLUE = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb;

    // ============ Uniswap V4 Addresses ============
    // Note: These addresses will need to be updated once Uniswap V4 is deployed on Base
    // For now, we'll use placeholder addresses that can be overridden in tests
    address constant UNISWAP_V4_POOL_MANAGER = address(0); // Will be deployed in test

    // ============ Token Addresses ============
    address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant WETH = 0x4200000000000000000000000000000000000006;
    address constant DAI = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;
    address constant USDbC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA; // USD Base Coin (bridged USDC)

    // ============ Aave aToken Addresses ============
    address constant aUSDC = 0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB;
    address constant aWETH = 0xD4a0e0b9149BCee3C920d2E00b5dE09138fd8bb7;
    address constant aUSDbC = 0x0a1d576f3eFeF75b330424287a95A366e8281D54;

    // ============ ENS / Basenames Addresses ============
    address constant ENS_REGISTRY = 0xB94704422c2a1E396835A571837Aa5AE53285a95;
    address constant L2_RESOLVER = 0xC6d566A56A1aFf6508b41f6c90ff131615583BCD;

    // ============ Helper Accounts ============
    // Well-funded accounts on Base for testing (whale addresses)
    address constant USDC_WHALE = 0x20FE51A9229EEf2cF8Ad9E89d91CAb9312cF3b7A; // Coinbase address with USDC
    address constant USDbC_WHALE = 0x4c80E24119CFB836cdF0a6b53dc23F04F7e652CA; // Large USDbC holder
    address constant WETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // Binance wallet
}
