# Deployed Contracts

## Networks

- **Base Sepolia** (Chain ID: 84532)
- **Arc Testnet** (Chain ID: 5042002)

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

## Arc Testnet CCTP Bridge

### CCTP Helper Contract
- **Address**: `0xC5567a5E3370d4DBfB0540025078e283e36A363d`
- **Purpose**: Helper contract for bridging USDC from Arc Testnet to Base Sepolia via Circle's CCTP
- **Function**: `bridgeWithPreapproval((uint256,uint256,uint256,bytes32,bytes32,address,address,uint32,uint32))`

### Arc Testnet USDC
- **Address**: `0x3600000000000000000000000000000000000000`
- **Decimals**: 6 (ERC-20 interface) / 18 (native gas token)
- **Note**: USDC is the native gas token on Arc. The ERC-20 interface at this address mirrors native balance.

### CCTP Contracts (Arc Testnet)
- **TokenMessenger**: `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA`
- **MessageTransmitter**: `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275`
- **TokenMinter**: `0xb43db544E2c27092c107639Ad201b3dEfAbcF192`
- **Domain**: 26

### Example Bridge Transaction
- **Transaction Hash**: `0x9914214a5db159182f63c8400ff455a41dd2c276422cbe10948fc59e3df9dcd3`
- **Explorer**: https://testnet.arcscan.app/tx/0x9914214a5db159182f63c8400ff455a41dd2c276422cbe10948fc59e3df9dcd3
- **Amount**: 1 USDC (1,000,000 with 6 decimals)
- **Source**: Arc Testnet
- **Destination**: Base Sepolia (Domain 6)
- **Recipient**: `0x8ff8E6ee2A0d3427160FBa3240E87797036a2BC0`
- **Nonce**: 6

### How to Bridge USDC from Arc to Base Sepolia

1. **Approve the helper contract to spend USDC:**
```bash
cast send 0x3600000000000000000000000000000000000000 \
  "approve(address,uint256)" \
  0xC5567a5E3370d4DBfB0540025078e283e36A363d \
  1000000 \
  --rpc-url https://rpc.testnet.arc.network \
  --private-key $PRIVATE_KEY \
  --legacy
```

2. **Call the helper contract to bridge:**
```bash
# Bridge 1 USDC to Base Sepolia
cast send 0xC5567a5E3370d4DBfB0540025078e283e36A363d \
  0xd0d4229a00000000000000000000000000000000000000000000000000000000000f4240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ff8e6ee2a0d3427160fba3240e87797036a2bc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003600000000000000000000000000000000000000000000000000000000000000c5567a5e3370d4dbfb0540025078e283e36a363d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006 \
  --rpc-url https://rpc.testnet.arc.network \
  --private-key $PRIVATE_KEY \
  --legacy \
  --gas-limit 400000
```

3. **Wait ~20 minutes for Circle's attestation**

4. **Get attestation from Circle's API:**
```bash
# Extract message hash from transaction logs
curl https://iris-api-sandbox.circle.com/attestations/{messageHash}
```

5. **Receive USDC on Base Sepolia:**
```bash
# Use the attestation to call receiveMessage on Base Sepolia's MessageTransmitter
# MessageTransmitter address on Base Sepolia: 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275
```

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