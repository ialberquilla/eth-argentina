# Deployed Contracts - Base Sepolia

## Deployment Details

- **Network**: Base Sepolia (Chain ID: 84532)
- **Deployer**: `0x8ff8E6ee2A0d3427160FBa3240E87797036a2BC0`
- **Block**: 34029730
- **Total Gas Used**: 6,883,207 gas
- **Total Cost**: 0.0206 ETH

## Core Contracts

### AdapterRegistry
- **Address**: `0x045B9a7505164B418A309EdCf9A45EB1fE382951`
- **Explorer**: https://sepolia.basescan.org/address/0x045B9a7505164B418A309EdCf9A45EB1fE382951
- **Purpose**: Central registry for ENS-based adapter lookup
- **Transaction**: `0xd2fc507d4ea8293aae0b4baccdaedd8af0e07c051c77a7845017fe449b32240f`

### SwapDepositor Hook
- **Address**: `0xa97800be965c982c381E161124A16f5450C080c4`
- **Explorer**: https://sepolia.basescan.org/address/0xa97800be965c982c381E161124A16f5450C080c4
- **Purpose**: Uniswap V4 hook that deposits swap outputs to Aave via adapters
- **Hook Flags**: 196 (BEFORE_SWAP | AFTER_SWAP | AFTER_SWAP_RETURNS_DELTA)
- **Transaction**: `0xebab35bf39795cbb679cadaf1b6a0ffcf02592d0a4c6799ea7276075160c6f7b`

### HookDeployer
- **Address**: `0xd283FF0d24414d16A79acE67dF0665471F9Cd38c`
- **Explorer**: https://sepolia.basescan.org/address/0xd283FF0d24414d16A79acE67dF0665471F9Cd38c
- **Purpose**: CREATE2 deployer for hooks with correct address flags
- **Transaction**: `0xe8c99849ce378f14018f2ca05b1be38505f439e0c895a5ab2079f48a8567f3d8`

## Aave V3 Adapters

### USDC Adapter
- **Address**: `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF`
- **Explorer**: https://sepolia.basescan.org/address/0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF
- **Token**: USDC (`0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`)
- **ENS Name**: `USDC:BASE_SEPOLIA:word-word.base.eth` (dynamically generated)
- **Status**: ✅ Registered in AdapterRegistry
- **Transaction**: `0x630181bc41b1643e27b35356306927f6b2ba808a969b0a5da9ac47591e3c1958`

### USDT Adapter
- **Address**: `0x5531bc190eC0C74dC8694176Ad849277AbA21a5D`
- **Explorer**: https://sepolia.basescan.org/address/0x5531bc190eC0C74dC8694176Ad849277AbA21a5D
- **Token**: USDT (`0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`)
- **ENS Name**: `USDT:BASE_SEPOLIA:word-word.base.eth` (dynamically generated)
- **Status**: ✅ Registered in AdapterRegistry
- **Transaction**: `0xb1992ea5e0894f328aaed1050179aba28def18b13c35465d8472feb3720bec2d`

## External Dependencies (Base Sepolia)

### Uniswap V4
- **Pool Manager**: `0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829`

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
3. ⏳ Create a Uniswap V4 pool (use `01_CreatePoolAndAddLiquidity.s.sol`)
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
