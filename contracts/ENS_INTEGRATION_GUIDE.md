# ENS Integration Guide

## Overview

The AdapterRegistry has been updated to integrate with real ENS contracts on Base Sepolia using Basenames.

## Key Changes

### 1. ENS-Compatible Naming Format

**Old Format (Not ENS compatible):**
```
USDC:BASE_SEPOLIA:clear-swan.base.eth
```

**New Format (ENS compatible):**
```
usdc-basesepolia-clear-swan.base.eth
```

Changes:
- All lowercase
- Dashes (`-`) instead of colons (`:`)
- Removed underscores from chain names

### 2. Real ENS Integration

The `AdapterRegistry` now interacts with actual Basenames (ENS) contracts on Base Sepolia:

- **ENS Registry:** `0x1493b2567056c2181630115660963E13A8E32735`
- **L2 Resolver:** `0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA`

### 3. New Contract Interfaces

Created interfaces for ENS integration:
- `IENSRegistry.sol` - Interface for ENS Registry contract
- `IL2Resolver.sol` - Interface for L2 Resolver contract

### 4. Mock Contracts for Testing

Created mock contracts for local testing:
- `MockENSRegistry.sol` - Mock ENS Registry
- `MockL2Resolver.sol` - Mock L2 Resolver

## Deployment Options

### Option 1: Deploy with Real ENS Integration

Use the new deployment script that registers adapters in actual ENS:

```bash
forge script script/DeployBaseTestnetWithENS.s.sol --rpc-url baseSepolia --broadcast
```

**Important Notes:**
- You must own a domain under `base.eth` to register subdomains
- If you don't own `base.eth`, you should:
  1. Register your own `.base.eth` name (e.g., `myproject.base.eth`)
  2. Update `ADAPTER_DOMAIN` in the script to your owned name
  3. Update the `parentNode` calculation accordingly

**To register a Basename:**
Visit https://www.base.org/names or use the Basenames registration contracts.

### Option 2: Deploy with Legacy Mode (No Real ENS)

For testing without ENS integration, use the original deployment script:

```bash
forge script script/DeployBaseTestnet.s.sol --rpc-url baseSepolia --broadcast
```

This uses dummy ENS addresses and won't actually register in ENS, but allows testing the hook functionality.

## How ENS Registration Works

When you call `adapterRegistry.registerAdapter(adapterAddress, "base.eth")`:

1. **Generate ENS Name:** Creates an ENS-compatible name like `usdc-basesepolia-clear-swan.base.eth`
2. **Calculate Namehash:** Generates the ENS node (namehash) for the name
3. **Register Subdomain:** Calls `ensRegistry.setSubnodeRecord()` to create the subdomain
4. **Set Address Record:** Calls `l2Resolver.setAddr()` to map the ENS name to the adapter address

## Verifying ENS Registration

### On BaseScan

After deployment, you can verify your ENS registrations on BaseScan:

1. Go to https://sepolia.basescan.org
2. Search for the ENS Registry address: `0x1493b2567056c2181630115660963E13A8E32735`
3. Check the transaction history for your subdomain registrations

### Using the Script

Run the GetAdapterENSNames script to see registered adapters:

```bash
forge script script/GetAdapterENSNames.s.sol --rpc-url baseSepolia
```

## Example ENS Names

Based on the adapters deployed at the addresses in the script:

- **USDC Adapter:** `usdc-basesepolia-clear-swan.base.eth`
  - Address: `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF`
  - Node: `0x5bb8a24b05fe4669080d86cd280fdba6ad72390dcb15c11970d46ad8f5223ed3`

- **USDT Adapter:** `usdt-basesepolia-copper-serval.base.eth`
  - Address: `0x5531bc190eC0C74dC8694176Ad849277AbA21a5D`
  - Node: (calculated at runtime)

## Usage in Swap Hook

To use adapters with their ENS names:

```solidity
bytes memory hookData = abi.encode(
    "usdc-basesepolia-clear-swan.base.eth",  // Adapter ENS name
    "recipient.base.eth"                      // Recipient basename or address
);

swapRouter.swap(poolKey, swapParams, hookData);
```

## Basenames Contract Addresses (Base Sepolia)

| Contract | Address |
|----------|---------|
| Registry | `0x1493b2567056c2181630115660963E13A8E32735` |
| BaseRegistrar | `0xa0c70ec36c010b55e3c434d6c6ebeec50c705794` |
| RegistrarController | `0x49ae3cc2e3aa768b1e5654f5d3c6002144a59581` |
| L2Resolver | `0x6533C94869D28fAA8dF77cc63f9e2b2D6Cf77eBA` |
| ReverseRegistrar | `0x876eF94ce0773052a2f81921E70FF25a5e76841f` |
| Price Oracle | `0x2b73408052825e17e0fe464f92de85e8c7723231` |

## Next Steps

1. **Register a Basename** - Get your own `.base.eth` name to use as parent domain
2. **Update Deployment Script** - Configure the script with your domain
3. **Deploy Contracts** - Use `DeployBaseTestnetWithENS.s.sol` to deploy with real ENS
4. **Verify on BaseScan** - Check that your ENS names resolve correctly
5. **Test Swaps** - Use the ENS names in your swap transactions

## Resources

- [Basenames GitHub](https://github.com/base/basenames)
- [Base Documentation](https://docs.base.org/)
- [ENS Documentation](https://docs.ens.domains/)
- [Basename Registration](https://www.base.org/names)
