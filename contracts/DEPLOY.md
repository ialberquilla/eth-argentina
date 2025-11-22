# Deployment Guide

## Quick Start - Deploy to Base Sepolia

### Prerequisites

1. **Get Base Sepolia ETH**
   - Visit: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
   - Or use the official Base bridge from Sepolia

2. **Set up your private key**

   Edit `.env` and uncomment the PRIVATE_KEY line:
   ```bash
   PRIVATE_KEY=your_private_key_here
   ```

   **⚠️ SECURITY WARNING**: Never commit your private key to git!

### Deploy Everything

Run the comprehensive deployment script:

```bash
source .env

forge script script/DeployBaseTestnet.s.sol \
  --rpc-url base-sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

This will deploy:
1. ✅ AdapterRegistry
2. ✅ AaveAdapter for USDC
3. ✅ AaveAdapter for USDbC
4. ✅ SwapDepositor Hook (with CREATE2 for correct address flags)
5. ✅ Automatically register both adapters

### What Gets Deployed

The script will output something like:

```
========================================
Deploying to Base Sepolia Testnet
Chain ID: 84532
Deployer: 0x...
========================================

1. Deploying AdapterRegistry...
   AdapterRegistry deployed at: 0x...

2. Deploying Aave Adapters...
   USDC AaveAdapter deployed at: 0x...
   USDbC AaveAdapter deployed at: 0x...

3. Deploying SwapDepositor Hook...
   Expected hook address: 0x...
   SwapDepositor Hook deployed at: 0x...

4. Registering Adapters in Registry...
   USDC adapter registered
   USDbC adapter registered

========================================
DEPLOYMENT SUMMARY
========================================

--- Core Contracts ---
AdapterRegistry: 0x...
SwapDepositor Hook: 0x...

--- Aave Adapters ---
USDC Adapter: 0x...
USDbC Adapter: 0x...

--- Adapter ENS Names ---
Format: SYMBOL:BASE_SEPOLIA:word-word.base.eth
Example: USDC:BASE_SEPOLIA:swift-fox.base.eth
(Exact names are generated dynamically based on adapter address)
========================================
```

### Save the Deployed Addresses

After deployment, update `script/QueryDeployment.s.sol` with your deployed addresses:

```solidity
address constant ADAPTER_REGISTRY = 0x...; // From deployment output
address constant USDC_ADAPTER = 0x...;
address constant USDbC_ADAPTER = 0x...;
address constant SWAP_DEPOSITOR = 0x...;
```

Then query your deployment:

```bash
forge script script/QueryDeployment.s.sol --rpc-url base-sepolia
```

## Alternative: Deploy to Base Mainnet

⚠️ **Make sure you have real ETH for gas fees!**

```bash
forge script script/DeployBaseTestnet.s.sol \
  --rpc-url base \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

**Note:** You'll need to update the script with mainnet addresses:
- Pool Manager
- Aave V3 Pool
- Token addresses

## Verify Contracts

If verification fails during deployment, verify manually:

```bash
# Verify AdapterRegistry
forge verify-contract \
  <ADAPTER_REGISTRY_ADDRESS> \
  src/AdapterRegistry.sol:AdapterRegistry \
  --chain-id 84532 \
  --watch

# Verify AaveAdapter
forge verify-contract \
  <USDC_ADAPTER_ADDRESS> \
  src/adapters/AaveAdapter.sol:AaveAdapter \
  --constructor-args $(cast abi-encode "constructor(address,string)" <AAVE_POOL> "USDC") \
  --chain-id 84532 \
  --watch
```

## Using Keystore (More Secure)

Instead of using private key directly:

```bash
# Create keystore (one time)
cast wallet import deployer --interactive
# Enter your private key when prompted

# Deploy using keystore
forge script script/DeployBaseTestnet.s.sol \
  --rpc-url base-sepolia \
  --account deployer \
  --sender <YOUR_ADDRESS> \
  --broadcast \
  --verify
```

## Next Steps

After deployment:

1. **Create a Uniswap V4 Pool**
   ```bash
   forge script script/01_CreatePoolAndAddLiquidity.s.sol \
     --rpc-url base-sepolia \
     --private-key $PRIVATE_KEY \
     --broadcast
   ```

2. **Test Swaps**
   ```bash
   forge script script/03_Swap.s.sol \
     --rpc-url base-sepolia \
     --private-key $PRIVATE_KEY \
     --broadcast
   ```

3. **Query Adapter ENS Names**
   The adapters are registered with names like:
   - `USDC:BASE_SEPOLIA:prime-antelope.base.eth`
   - `USDbC:BASE_SEPOLIA:swift-fox.base.eth`

   Users can now reference adapters by these ENS names instead of addresses!

## Troubleshooting

### Error: "Insufficient funds"
- Get more Base Sepolia ETH from the faucet

### Error: "Nonce too low"
- Your transaction may have already been sent. Check Basescan.

### Error: "Hook address mismatch"
- The CREATE2 salt mining failed. Try running the script again.

### Contract not verified
- Run the manual verification commands above
- Or add `--verify` flag with your Etherscan API key

## Gas Estimation

Approximate gas costs on Base Sepolia:
- AdapterRegistry: ~500k gas
- AaveAdapter (each): ~1M gas
- SwapDepositor Hook: ~2M gas (includes CREATE2 mining)
- **Total: ~4.5M gas**

On Base Sepolia with negligible gas prices, this is essentially free!

## Security Considerations

1. ✅ Never commit `.env` with private keys
2. ✅ Use keystore for production deployments
3. ✅ Verify all contracts on Basescan
4. ✅ Test thoroughly on testnet before mainnet
5. ✅ Consider using a hardware wallet for mainnet

## Resources

- Base Sepolia Faucet: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- Base Sepolia Explorer: https://sepolia.basescan.org
- Uniswap V4 Docs: https://docs.uniswap.org/contracts/v4/overview
