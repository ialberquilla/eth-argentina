# Deployment Scripts

This directory contains Foundry scripts for deploying and interacting with the SwapDepositor Hook on Base Sepolia testnet.

## Script Overview

### Deployment Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `DeployBaseTestnet.s.sol` | **Main deployment script** - Deploys all contracts (AdapterRegistry, AaveAdapters, SwapDepositor Hook) | Use this first for fresh deployments to Base Sepolia |
| `00_DeployHook.s.sol` | Original hook deployment (AdapterRegistry + Hook only) | Alternative minimal deployment without adapters |
| `RegisterAdapter.s.sol` | Example adapter registration | Reference for registering additional adapters |

### Pool Management Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `01_CreatePoolAndAddLiquidity.s.sol` | Creates a Uniswap V4 pool and adds initial liquidity | After deploying contracts, before swapping |
| `02_AddLiquidity.s.sol` | Adds more liquidity to an existing pool | When you need to increase pool liquidity |
| `03_Swap.s.sol` | Executes a swap through the pool | Testing the hook functionality |

### Utility Scripts

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `QueryDeployment.s.sol` | Queries deployed contracts for info (ENS names, addresses, etc.) | After deployment to verify everything is working |

## Recommended Deployment Flow

### Step 1: Deploy All Contracts

```bash
forge script script/DeployBaseTestnet.s.sol:DeployBaseTestnetScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

This deploys:
- ✅ AdapterRegistry
- ✅ AaveAdapter for USDC
- ✅ AaveAdapter for USDbC
- ✅ SwapDepositor Hook (using CREATE2)
- ✅ Registers all adapters

**Save the output addresses!**

### Step 2: Update Configuration

Edit `base/BaseScript.sol` with your deployed addresses:

```solidity
// Line 25-27
IERC20 internal constant token0 = IERC20(0x036CbD53842c5426634e7929541eC2318f3dCF7e); // USDC
IERC20 internal constant token1 = IERC20(0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA); // USDbC
IHooks constant hookContract = IHooks(0x...); // Your SwapDepositor address from Step 1
```

### Step 3: Create Pool and Add Liquidity

Get testnet tokens first from [Aave Faucet](https://staging.aave.com/faucet/), then:

```bash
forge script script/01_CreatePoolAndAddLiquidity.s.sol:CreatePoolAndAddLiquidityScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

### Step 4: Test with a Swap

```bash
forge script script/03_Swap.s.sol:SwapScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

This swap will automatically deposit the output tokens to Aave V3 via the hook!

### Step 5: Query Deployment (Optional)

Update addresses in `QueryDeployment.s.sol`, then:

```bash
forge script script/QueryDeployment.s.sol:QueryDeploymentScript \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  -vvvv
```

## Base Scripts

The `base/` directory contains shared utilities:

- **BaseScript.sol** - Base configuration with network addresses and token configuration
- **LiquidityHelpers.sol** - Helper functions for liquidity operations

## Environment Setup

Create a `.env` file in the `contracts` directory:

```bash
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
PRIVATE_KEY=your_private_key_here
ETHERSCAN_API_KEY=your_basescan_api_key  # Optional for verification
```

Load it before running scripts:

```bash
source .env
```

## Script Flags Explained

| Flag | Purpose |
|------|---------|
| `--rpc-url` | RPC endpoint for the network |
| `--private-key` | Deployer private key (or use `--ledger`, `--keystore`) |
| `--broadcast` | Actually send transactions (omit for dry-run) |
| `--verify` | Verify contracts on Basescan |
| `-vvvv` | Maximum verbosity (useful for debugging) |
| `--slow` | Add delay between transactions (helps with rate limits) |

## Common Issues

### "Hook Address Mismatch"

The CREATE2 mining process couldn't find a valid salt. This is rare - just try again.

### "Insufficient Funds"

You need Base Sepolia ETH. Get it from:
- https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
- https://sepoliafaucet.com/

### "Adapter not registered"

Make sure you ran `DeployBaseTestnet.s.sol` which registers adapters automatically, or manually register using `RegisterAdapter.s.sol`.

## Adding More Adapters

To add support for additional tokens:

1. Deploy a new AaveAdapter:
```solidity
AaveAdapter daiAdapter = new AaveAdapter(AAVE_POOL, "DAI");
```

2. Register it:
```solidity
adapterRegistry.registerAdapter(address(daiAdapter), "adapters.eth");
```

## Verification

To verify contracts on Basescan after deployment:

```bash
# AdapterRegistry (no constructor args)
forge verify-contract \
  --chain-id 84532 \
  <ADDRESS> \
  src/AdapterRegistry.sol:AdapterRegistry

# AaveAdapter (with constructor args)
forge verify-contract \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor(address,string)" 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951 "USDC") \
  <ADDRESS> \
  src/adapters/AaveAdapter.sol:AaveAdapter
```

## Next Steps

- See `../DEPLOYMENT_GUIDE.md` for comprehensive deployment documentation
- Review tests in `../test/` to understand contract behavior
- Check `../README.md` for project overview

## Need Help?

- Review the main deployment guide: `../DEPLOYMENT_GUIDE.md`
- Check contract documentation in `../src/`
- Open an issue in the repository
