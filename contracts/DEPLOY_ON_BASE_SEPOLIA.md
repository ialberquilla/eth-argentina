# Complete Guide: Deploy on Base Sepolia with ENS Names

## Overview

This guide will help you:
1. Register a basename on Base Sepolia
2. Deploy all contracts
3. Create ENS names for all adapters automatically

## Prerequisites

- Private key with Base Sepolia ETH (get from https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
- Set in `.env`:
  ```bash
  PRIVATE_KEY=your_private_key_here
  BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
  ```

---

## Step 1: Register Your Basename

### Option A: Register on Base Sepolia Testnet

**Free testnet registration:**

1. Go to: https://www.base.org/names (or Base Sepolia testnet version)
2. Connect your wallet (same address as PRIVATE_KEY)
3. Register a name like: `ethargentina2024.base.eth` or `myproject.base.eth`
4. **Cost:** FREE on testnet (or very cheap)

**Note:** The script defaults to `ethargentina2024.base.eth` - you can change this!

### Option B: Use the Script Default

The script is configured for: `ethargentina2024.base.eth`

To change it, edit `script/RegisterBasenameAndDeploy.s.sol` line 41:
```solidity
string constant YOUR_BASENAME = "ethargentina2024"; // <-- CHANGE THIS!
```

---

## Step 2: Check If You Own the Basename

Run the script in **check mode** (no deployment):

```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  -vvv
```

**What it does:**
- Checks if `ethargentina2024.base.eth` is registered
- Checks if YOU own it
- Gives you instructions if not

**Possible outcomes:**

### ✅ You own it
```
SUCCESS: You own this basename!
You can create unlimited subdomains under it.
```
→ **Proceed to Step 3!**

### ❌ Not registered
```
WARNING: Basename NOT registered!

You need to register it first:
1. Go to: https://www.base.org/names
2. Connect with address: 0xYourAddress
3. Register: ethargentina2024.base.eth
```
→ **Register it, then run again**

### ❌ Someone else owns it
```
WARNING: You don't own this basename!
Owner: 0xOtherAddress
You: 0xYourAddress

Options:
1. Use the address that owns it
2. Register a different basename
3. Transfer ownership to your address
```
→ **Choose a different name or use correct address**

---

## Step 3: Deploy Everything with ENS Names

Once you own the basename, deploy:

```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  --verify \
  -vvv
```

**What happens:**

1. ✅ Checks you own the basename
2. 🚀 Deploys AdapterRegistry
3. 🔄 Transfers basename ownership to AdapterRegistry
4. 🚀 Deploys USDC and USDT adapters
5. 🚀 Deploys SwapDepositor hook
6. 📝 Registers adapters in ENS with names like:
   - `usdc-basesepolia-clear-swan.ethargentina2024.base.eth`
   - `usdt-basesepolia-copper-serval.ethargentina2024.base.eth`

---

## Step 4: Verify Deployment

The script prints everything at the end:

```
========================================
DEPLOYMENT COMPLETE!
========================================

--- Your Basename ---
Domain: ethargentina2024.base.eth
Owner: AdapterRegistry (can create subdomains)

--- Core Contracts ---
AdapterRegistry: 0x...
SwapDepositor Hook: 0x...

--- Adapters ---
USDC Adapter: 0x...
USDT Adapter: 0x...

--- ENS Names Created ---
USDC: usdc-basesepolia-<words>.ethargentina2024.base.eth
USDT: usdt-basesepolia-<words>.ethargentina2024.base.eth
```

**Check on BaseScan:**
- https://sepolia.basescan.org/address/[YourAdapterRegistryAddress]

---

## Step 5: Add More Adapters (Future)

To add more adapters later:

### Deploy New Adapter
```solidity
AaveAdapter daiAdapter = new AaveAdapter(AAVE_POOL, "DAI");
```

### Register with ENS Name
```solidity
adapterRegistry.registerAdapter(
    address(daiAdapter), 
    "ethargentina2024.base.eth"
);
```

**Result:**
- New ENS name created automatically: `dai-basesepolia-xxx.ethargentina2024.base.eth`
- No additional cost!
- Unlimited adapters!

---

## Quick Reference

### Register Basename
```bash
# Go to: https://www.base.org/names
# Register: yourname.base.eth
# Cost: FREE (testnet) or ~$5-10 (mainnet)
```

### Check Ownership
```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  -vvv
```

### Deploy Everything
```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  --verify \
  -vvv
```

### Verify on BaseScan
```
https://sepolia.basescan.org
```

---

## Troubleshooting

### "Basename NOT registered"
→ Register at https://www.base.org/names

### "You don't own this basename"
→ Change `YOUR_BASENAME` in script or use correct wallet

### "Insufficient funds"
→ Get Base Sepolia ETH from faucet

### "Hook address mismatch"
→ This is normal, just a sanity check - it should pass

---

## What You Get

**One basename registration ($0-10):**
```
ethargentina2024.base.eth
```

**Unlimited adapter names (FREE):**
```
├── usdc-basesepolia-xxx.ethargentina2024.base.eth
├── usdt-basesepolia-xxx.ethargentina2024.base.eth
├── dai-basesepolia-xxx.ethargentina2024.base.eth
├── weth-basesepolia-xxx.ethargentina2024.base.eth
└── ... (as many as you want!)
```

**All created automatically by your code!**
