# Deployed Contracts - Base Sepolia (Updated)

## Deployment Details

- **Network**: Base Sepolia (Chain ID: 84532)
- **Deployer**: `0x8ff8E6ee2A0d3427160FBa3240E87797036a2BC0` (Initial) / User (Updates)
- **Basename**: `onetx.base.eth`

## Core Contracts

### AdapterRegistry
- **Address**: `0x7425AAa97230f6D575193667cfd402b0B89C47f2`
- **Explorer**: https://sepolia.basescan.org/address/0x7425AAa97230f6D575193667cfd402b0B89C47f2
- **Purpose**: Central registry for ENS-based adapter lookup under `onetx.base.eth`

### SwapDepositor Hook (Redeployed)
- **Address**: `0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4`
- **Explorer**: https://sepolia.basescan.org/address/0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4
- **Purpose**: Uniswap V4 hook that deposits swap outputs to Aave via adapters
- **Hook Flags**: 196 (BEFORE_SWAP | AFTER_SWAP | AFTER_SWAP_RETURNS_DELTA)
- **Note**: Redeployed to use correct PoolManager and AdapterRegistry.

### HookDeployer
- **Address**: `0x05B7A9c0E73aBCfCA1A6D983fab2E382C77f1B8B`
- **Explorer**: https://sepolia.basescan.org/address/0x05B7A9c0E73aBCfCA1A6D983fab2E382C77f1B8B

## Aave V3 Adapters & Mock Pool

### Mock Aave V3 Pool
- **Address**: `0x6645D1d54aA2450e048cbdca38e032cfe8DA7845`
- **Purpose**: Mock Aave V3 Pool for testing on Base Sepolia.

### USDC Adapter
- **Address**: `0x6a546f500b9BDaF1d08acA6DF955e8919886604a` (Old - points to non-existent Aave Pool)
- **Status**: ⚠️ Points to invalid Aave Pool. Use USDT Adapter for testing.

### USDT Adapter (Redeployed)
- **Address**: `0x992A8847C28F9cD9251D5382249A4d35523F510A`
- **Token**: USDT (`0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`)
- **Aave Pool**: `0x6645D1d54aA2450e048cbdca38e032cfe8DA7845` (Mock)
- **Status**: ✅ Functional with Mock Pool. NOT Registered in AdapterRegistry yet.

## External Dependencies (Base Sepolia)

### Uniswap V4
- **Pool Manager**: `0x05E73354cFDd6745C338b50BcFDfA3Aa6fA03408`
- **Swap Router**: `0x71cD4Ea054F9Cb3D3BF6251A00673303411A7DD9`

### Uniswap V4 Pool (USDC/USDT)
- **Tokens**: USDC (`0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`), USDT (`0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`)
- **Fee**: 0.30% (3000)
- **Tick Spacing**: 60
- **Hook**: SwapDepositor (`0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4`)
- **Purpose**: Initialized pool for testing swap -> deposit flow.

### Tokens
- **USDC**: `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`
- **USDT**: `0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`

## How to Use

### 1. Swap with Automatic Aave Deposit

```solidity
// Encode adapter address directly (since it's not registered)
bytes memory hookData = abi.encode(
    "0x992A8847C28F9cD9251D5382249A4d35523F510A",  // New USDT Adapter Address
    "0x1234..."                                   // Recipient address
);

// Perform swap - output automatically deposited to Mock Aave Pool
swapRouter.swap(poolKey, swapParams, hookData);
```