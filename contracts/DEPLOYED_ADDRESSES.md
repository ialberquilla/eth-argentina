# Deployed Contracts - Base Sepolia

## Deployment Details

- **Network**: Base Sepolia (Chain ID: 84532)
- **Deployer**: `0x8ff8E6ee2A0d3427160FBa3240E87797036a2BC0`
- **Basename**: `onetx.base.eth`
- **Block**: 34035073
- **Total Gas Used**: 13755280 gas
- **Total Cost**: 0.00001667155066808 ETH

## Core Contracts

### AdapterRegistry
- **Address**: `0x7425AAa97230f6D575193667cfd402b0B89C47f2`
- **Explorer**: https://sepolia.basescan.org/address/0x7425AAa97230f6D575193667cfd402b0B89C47f2
- **Purpose**: Central registry for ENS-based adapter lookup under `onetx.base.eth`
- **Transaction**: `0x6ecddd176670c6b1f7feaf971646733db6981a227182c7d6088dd7c88785494c`

### SwapDepositor Hook
- **Address**: `0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4`
- **Explorer**: https://sepolia.basescan.org/address/0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4
- **Purpose**: Uniswap V4 hook that deposits swap outputs to Aave via adapters
- **Hook Flags**: 196 (BEFORE_SWAP | AFTER_SWAP | AFTER_SWAP_RETURNS_DELTA)
- **Transaction**: `0x2a619fd1d202fcd7929214b8ff9e3ac3647bd74e666a99733fa6529ee12cbf9c`

### HookDeployer
- **Address**: `0x05B7A9c0E73aBCfCA1A6D983fab2E382C77f1B8B`
- **Explorer**: https://sepolia.basescan.org/address/0x05B7A9c0E73aBCfCA1A6D983fab2E382C77f1B8B
- **Purpose**: CREATE2 deployer for hooks with correct address flags
- **Transaction**: `0xe7cf44ffb494729bd7d0a2a4af39c80753cac3031c984d89aaa190c0269e743c`

## Aave V3 Adapters

### USDC Adapter
- **Address**: `0x6a546f500b9BDaF1d08acA6DF955e8919886604a`
- **Explorer**: https://sepolia.basescan.org/address/0x6a546f500b9BDaF1d08acA6DF955e8919886604a
- **Token**: USDC (`0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`)
- **ENS Name**: `usdc-basesepolia-<words>.onetx.base.eth` (dynamically generated)
- **Status**: ✅ Registered in AdapterRegistry
- **Transaction**: `0xca967b779f74c99ee9639a107a3eb194d5fca895bf8e7920b81ff416c5812cfd`

### USDT Adapter
- **Address**: `0x6F0b25e2abca0b60109549b7823392e3312f505c`
- **Explorer**: https://sepolia.basescan.org/address/0x6F0b25e2abca0b60109549b7823392e3312f505c
- **Token**: USDT (`0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`)
- **ENS Name**: `usdt-basesepolia-<words>.onetx.base.eth` (dynamically generated)
- **Status**: ✅ Registered in AdapterRegistry
- **Transaction**: `0x8fab9f3f17b884ecf2ce38648284d71c7d29ecfebf74ed8c6921d589c643b717`

## External Dependencies (Base Sepolia)

### Uniswap V4
- **Pool Manager**: `0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829`

### Uniswap V4 Pool (USDC/USDT)
- **Tokens**: USDC (`0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`), USDT (`0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`)
- **Fee**: 0.30% (3000)
- **Tick Spacing**: 60
- **Hook**: SwapDepositor (`0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4`)
- **Transaction**: `0x1469f6b826ebbbae9665090784bffeaa13ea9d6acd3dde632c46a5e3986ebcbb`
- **Purpose**: Initialized pool and provided 5000 USDC / 5000 USDT liquidity.


### Aave V3
- **Pool**: `0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951`

### Tokens
- **USDC**: `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`
- **USDT**: `0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`

## Adapter ENS Names

The adapters are registered with ENS-style names for easy lookup:

**Format**: `SYMBOL:BASE_SEPOLIA:word-word.base.eth`

To query the exact ENS names for your deployed adapters, use:

```solidity
// Get USDC adapter metadata
ILendingAdapter.AdapterMetadata memory metadata = usdcAdapter.getAdapterMetadata();
string memory ensName = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, "base.eth");
```

Or use the query script:

```bash
forge script script/QueryDeployment.s.sol --rpc-url baseSepolia
```

## How to Use

### 1. Swap with Automatic Aave Deposit

```solidity
// Encode adapter ENS name and recipient
bytes memory hookData = abi.encode(
    "USDC:BASE_SEPOLIA:word-word.base.eth",  // Adapter ENS name
    "0x1234..."                               // Recipient address
);

// Perform swap - output automatically deposited to Aave
swapRouter.swap(poolKey, swapParams, hookData);
```

### 2. Resolve Adapter by ENS Name

```solidity
address adapter = adapterRegistry.resolveAdapter("USDC:BASE_SEPOLIA:word-word.base.eth");
```

### 3. Register a New Adapter

```solidity
AaveAdapter newAdapter = new AaveAdapter(aavePool, "DAI");
adapterRegistry.registerAdapter(address(newAdapter), "base.eth");
```

## Gas Costs (Base Sepolia)

| Contract | Deployment Gas | Cost (ETH) |
|----------|---------------|------------|
| AdapterRegistry | 2,123,276 | 0.006370 |
| USDC Adapter | 631,407 | 0.001894 |
| USDT Adapter | 631,407 | 0.001894 |
| HookDeployer | 1,823,272 | 0.005470 |
| SwapDepositor Hook | 1,457,071 | 0.004372 |
| Register USDC | 106,294 | 0.000319 |
| Register USDT | 110,480 | 0.000331 |
| **Total** | **6,883,207** | **0.0206** |

*Gas price: ~3 gwei*

## Next Steps

1. ✅ All contracts deployed successfully
2. ✅ Both adapters registered in AdapterRegistry
3. ✅ Create a Uniswap V4 pool and provided initial liquidity (using `script/ProvideLiquidityBaseSepolia.s.sol`)
4. ⏳ Perform test swaps (use `03_Swap.s.sol`)
5. ⏳ Verify contracts on Basescan (optional)

## Verification Commands

To verify contracts on Basescan:

```bash
# Set your Basescan API key
export BASESCAN_API_KEY=your_api_key

# Verify AdapterRegistry
forge verify-contract \
  0x045B9a7505164B418A309EdCf9A45EB1fE382951 \
  src/AdapterRegistry.sol:AdapterRegistry \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify USDC Adapter
forge verify-contract \
  0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF \
  src/adapters/AaveAdapter.sol:AaveAdapter \
  --constructor-args $(cast abi-encode "constructor(address,string)" 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951 "USDC") \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify USDT Adapter
forge verify-contract \
  0x5531bc190eC0C74dC8694176Ad849277AbA21a5D \
  src/adapters/AaveAdapter.sol:AaveAdapter \
  --constructor-args $(cast abi-encode "constructor(address,string)" 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951 "USDT") \
  --chain-id 84532 \
  --etherscan-api-key $BASESCAN_API_KEY
```

## Notes

- All contracts are deployed and functional on Base Sepolia
- The SwapDepositor hook has the correct address flags for Uniswap V4
- Both adapters are registered and can be resolved by ENS-style names
- Ready for pool creation and testing!
