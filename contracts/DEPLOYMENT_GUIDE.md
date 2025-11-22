# Base Sepolia Testnet Deployment Guide

This guide walks through deploying all contracts for the SwapDepositor Hook on Base Sepolia testnet.

## Prerequisites

1. **Foundry** installed ([installation guide](https://book.getfoundry.sh/getting-started/installation))
2. **Base Sepolia RPC URL** (e.g., from Alchemy, Infura, or public RPC)
3. **Private key** with Base Sepolia ETH for gas
4. **Testnet tokens** for testing (USDC, USDbC)

## Network Information

- **Chain ID**: 84532
- **RPC URL**: `https://sepolia.base.org` (public) or use your own provider
- **Block Explorer**: https://sepolia.basescan.org

## Pre-deployed Contracts (Base Sepolia)

These contracts are already deployed and will be used by our deployment:

| Contract | Address |
|----------|---------|
| Uniswap V4 Pool Manager | `0x7Da1D65F8B249183667cdE74C5cbd46dD38AA829` |
| Uniswap V4 Position Manager | `0xcdbe7b1ed817ef0005ece6a3e576fbae2ea5eafe` |
| Aave V3 Pool | `0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951` |
| USDC Token | `0x036CbD53842c5426634e7929541eC2318f3dCF7e` |
| USDbC Token | `0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA` |

## Deployment Steps

### 1. Set Up Environment

Create a `.env` file in the `contracts` directory:

```bash
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_basescan_api_key_here  # Optional, for verification
```

**Important**: Never commit your `.env` file to version control!

### 2. Get Testnet ETH

Get Base Sepolia ETH from:
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet)
- [Alchemy Faucet](https://sepoliafaucet.com/)

### 3. Run the Deployment Script

From the `contracts` directory:

```bash
# Load environment variables
source .env

# Run the deployment script
forge script script/DeployBaseTestnet.s.sol:DeployBaseTestnetScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

**Note**: Remove `--verify` if you don't want to verify contracts immediately.

### 4. What Gets Deployed

The script deploys the following contracts in order:

1. **AdapterRegistry** - Registry for managing lending protocol adapters
2. **AaveAdapter (USDC)** - Adapter for depositing USDC to Aave V3
3. **AaveAdapter (USDbC)** - Adapter for depositing USDbC to Aave V3
4. **SwapDepositor Hook** - Uniswap V4 hook that auto-deposits to lending protocols
5. **Adapter Registration** - Registers both adapters in the registry with ENS names

### 5. Save Deployment Addresses

The script will output all deployed addresses. Save these for future reference:

```
AdapterRegistry: 0x...
SwapDepositor Hook: 0x...
USDC Adapter: 0x...
USDbC Adapter: 0x...
```

## Post-Deployment Steps

### Create a Pool and Add Liquidity

Before you can perform swaps, you need to create a Uniswap V4 pool:

1. **Update BaseScript.sol** with your token addresses:

```solidity
// In contracts/script/base/BaseScript.sol
IERC20 internal constant token0 = IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e); // USDC
IERC20 internal constant token1 = IERC20(0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA); // USDbC
IHooks constant hookContract = IHooks(0x...); // Your deployed SwapDepositor address
```

2. **Get testnet tokens**:
   - Use Aave V3 faucet: https://staging.aave.com/faucet/
   - Or find other Base Sepolia faucets

3. **Create pool and add liquidity**:

```bash
forge script script/01_CreatePoolAndAddLiquidity.s.sol:CreatePoolAndAddLiquidityScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

### Perform a Test Swap

Once the pool is created:

```bash
forge script script/03_Swap.s.sol:SwapScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

## How It Works

### Adapter ENS Names

Each adapter is registered with an ENS-style name following this format:

```
SYMBOL:BLOCKCHAIN:WORD-WORD.adapters.eth
```

Example:
- `USDC:BASE_SEPOLIA:swift-fox.adapters.eth`
- `USDbC:BASE_SEPOLIA:brave-wolf.adapters.eth`

The "WORD-WORD" portion is deterministically generated from the adapter's address, making each name unique and human-readable.

### Swap Flow

1. User initiates a swap through Uniswap V4
2. SwapDepositor hook's `beforeSwap` executes (optional pre-processing)
3. Swap happens in the pool
4. SwapDepositor hook's `afterSwap` executes:
   - Detects the output token amount
   - Looks up the appropriate lending adapter via ENS name
   - Automatically deposits the output tokens to Aave V3
   - User receives aTokens (interest-bearing tokens)

### Basename Support (Base Mainnet Only)

On Base mainnet, users can specify recipients using Basenames:
- Instead of `0x1234...`, use `alice.base.eth`
- The hook automatically resolves the Basename to an address
- Deposits are made to the resolved address

**Note**: This feature is only available on Base mainnet, not on testnet.

## Troubleshooting

### "Hook Address Mismatch" Error

The hook deployment uses CREATE2 to mine an address with specific flags. If you see this error:
- The mining process failed to find a valid salt
- Try running the script again
- This is rare but can happen

### "Invalid adapter address" Error

Make sure the Aave V3 Pool address is correct for Base Sepolia:
- Current address: `0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951`
- Verify on [Aave docs](https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses)

### "Insufficient funds" Error

You need Base Sepolia ETH for:
- Contract deployment gas fees (~0.01-0.05 ETH)
- Pool creation and liquidity provision (if creating a pool)
- Get more from faucets listed above

### RPC Rate Limiting

If using a public RPC, you might hit rate limits. Solutions:
- Use your own RPC endpoint (Alchemy, Infura, QuickNode)
- Add delays between transactions
- Use `--slow` flag in forge script

## Contract Verification

To verify contracts on Basescan after deployment:

```bash
# Verify AdapterRegistry
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  <ADAPTER_REGISTRY_ADDRESS> \
  src/AdapterRegistry.sol:AdapterRegistry

# Verify USDC Adapter
forge verify-contract \
  --chain-id 84532 \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address,string)" 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951 "USDC") \
  <USDC_ADAPTER_ADDRESS> \
  src/adapters/AaveAdapter.sol:AaveAdapter

# Verify Hook (similar pattern)
```

## Additional Resources

- [Uniswap V4 Documentation](https://docs.uniswap.org/contracts/v4/overview)
- [Aave V3 Documentation](https://docs.aave.com/developers/)
- [Base Documentation](https://docs.base.org/)
- [Foundry Book](https://book.getfoundry.sh/)

## Security Considerations

⚠️ **This is testnet deployment for testing purposes only**

Before deploying to mainnet:
1. Conduct thorough security audits
2. Test extensively on testnet
3. Consider economic attack vectors
4. Review all adapter implementations
5. Ensure proper access controls
6. Test with various token types
7. Verify all external contract addresses

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review contract tests in `contracts/test/`
3. Open an issue in the repository
