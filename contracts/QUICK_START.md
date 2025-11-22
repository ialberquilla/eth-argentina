# Quick Start: Deploy on Base Sepolia with ENS Names

## TL;DR

```bash
# 1. Register a basename at https://www.base.org/names
#    Example: "ethargentina2024.base.eth"

# 2. Update the script (optional - defaults to "ethargentina2024")
#    Edit: script/RegisterBasenameAndDeploy.s.sol line 41

# 3. Deploy everything
./deploy-base-sepolia.sh
```

Done! Your adapters now have ENS names like:
- `usdc-basesepolia-xxx.ethargentina2024.base.eth` ✅
- `usdt-basesepolia-xxx.ethargentina2024.base.eth` ✅

---

## What This Does

1. **Checks** if you own the basename
2. **Deploys** AdapterRegistry, adapters, and hook
3. **Creates** ENS names for all adapters automatically
4. **Prints** all deployed addresses

---

## Prerequisites

1. **Get Base Sepolia ETH:**
   - https://www.coinbase.com/faucets/base-ethereum-goerli-faucet

2. **Register a basename:**
   - Go to: https://www.base.org/names
   - Register: `yourname.base.eth` (FREE on testnet)
   - Use same wallet as your PRIVATE_KEY

3. **Set up .env:**
   ```bash
   PRIVATE_KEY=0x...
   BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
   ```

---

## Run Deployment

### Option 1: Use the Shell Script (Easiest)

```bash
./deploy-base-sepolia.sh
```

**What it does:**
1. Checks if you own the basename
2. Waits for your confirmation
3. Deploys everything
4. Shows you all addresses

### Option 2: Manual Forge Commands

**Check ownership first:**
```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  -vvv
```

**If you own it, deploy:**
```bash
forge script script/RegisterBasenameAndDeploy.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  --verify \
  -vvv
```

---

## After Deployment

You'll see:

```
========================================
DEPLOYMENT COMPLETE!
========================================

--- Your Basename ---
Domain: ethargentina2024.base.eth

--- Core Contracts ---
AdapterRegistry: 0xABC...
SwapDepositor Hook: 0xDEF...

--- Adapters ---
USDC Adapter: 0x123...
USDT Adapter: 0x456...

--- ENS Names Created ---
USDC: usdc-basesepolia-<words>.ethargentina2024.base.eth
USDT: usdt-basesepolia-<words>.ethargentina2024.base.eth
```

**Verify on BaseScan:**
- https://sepolia.basescan.org

---

## Customize Basename

Edit `script/RegisterBasenameAndDeploy.s.sol` line 41:

```solidity
// Change this:
string constant YOUR_BASENAME = "ethargentina2024";

// To your name:
string constant YOUR_BASENAME = "myproject";
```

Then your adapters become:
- `usdc-basesepolia-xxx.myproject.base.eth`

---

## Add More Adapters Later

Deploy a new adapter and register it:

```solidity
// Deploy
AaveAdapter daiAdapter = new AaveAdapter(AAVE_POOL, "DAI");

// Register (creates ENS name automatically)
adapterRegistry.registerAdapter(
    address(daiAdapter),
    "ethargentina2024.base.eth"
);

// Result: dai-basesepolia-xxx.ethargentina2024.base.eth ✅
```

**Unlimited adapters, all with ENS names, all FREE!**

---

## Troubleshooting

**"Basename NOT registered"**
→ Register at https://www.base.org/names first

**"You don't own this basename"**
→ Use the wallet that registered it, or change YOUR_BASENAME

**"Insufficient funds"**
→ Get Base Sepolia ETH from faucet

---

## Summary

| Step | Command | Result |
|------|---------|--------|
| 1. Register basename | https://www.base.org/names | You own `yourname.base.eth` |
| 2. Deploy | `./deploy-base-sepolia.sh` | All contracts deployed |
| 3. Result | ✅ | Adapters have ENS names |

**One basename = unlimited adapter names!**
