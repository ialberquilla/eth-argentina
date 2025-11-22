# YES! Here's How It Works

## One-Time Cost = Unlimited Names

### Step 1: Register ONE Basename (~$5-10/year)

Go to https://www.base.org/names and register:
```
myproject.base.eth  (or whatever name you want)
```

**Cost:** $5-10/year (one-time registration)

### Step 2: Update Deployment Script (One Line)

Edit `script/DeployBaseTestnetWithENS.s.sol` line 35:

```solidity
// Change this:
string constant ADAPTER_DOMAIN = "base.eth";

// To this:
string constant ADAPTER_DOMAIN = "myproject.base.eth";
```

### Step 3: Deploy

```bash
forge script script/DeployBaseTestnetWithENS.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  --private-key $PRIVATE_KEY
```

### Step 4: Your Code Automatically Creates Names

The AdapterRegistry will now create:

```
✅ usdc-basesepolia-clear-swan.myproject.base.eth
✅ usdt-basesepolia-copper-serval.myproject.base.eth
✅ dai-basesepolia-swift-fox.myproject.base.eth
✅ weth-basesepolia-brave-tiger.myproject.base.eth
... and so on, UNLIMITED, FREE!
```

## What You Get

```
ONE registration ($5-10/year):
  myproject.base.eth
  
UNLIMITED subdomains (FREE):
  ├── usdc-basesepolia-xxx.myproject.base.eth
  ├── usdt-basesepolia-xxx.myproject.base.eth
  ├── dai-basesepolia-xxx.myproject.base.eth
  ├── weth-basesepolia-xxx.myproject.base.eth
  ├── aave-basesepolia-xxx.myproject.base.eth
  ├── compound-basesepolia-xxx.myproject.base.eth
  └── ... (create as many as you want!)
```

## Your Code Already Does This!

The AdapterRegistry.sol already has the logic:

```solidity
// Line 72-75 - generates the subdomain name
string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);
// Returns: "usdc-basesepolia-clear-swan"

// Line 75 - adds your domain
string memory fullEnsName = AdapterIdGenerator.generateAdapterIdWithDomain(metadata, domain);
// Returns: "usdc-basesepolia-clear-swan.myproject.base.eth"

// Line 84-90 - registers it in ENS
ensRegistry.setSubnodeRecord(
    parentNode,        // myproject.base.eth (YOU OWN THIS!)
    labelHash,         // usdc-basesepolia-clear-swan
    address(this),
    address(l2Resolver),
    0
);
// ✅ Works because YOU own myproject.base.eth
```

## Every Time You Deploy a New Adapter

```solidity
// Deploy new adapter
AaveAdapter newAdapter = new AaveAdapter(aavePool, "LINK");

// Register it - creates: link-basesepolia-xxx.myproject.base.eth
adapterRegistry.registerAdapter(address(newAdapter), "myproject.base.eth");

// FREE! Automatic! Works!
```

## Summary

| Action | Cost | Result |
|--------|------|--------|
| Register `myproject.base.eth` | $5-10/year | You own it |
| Create `usdc-xxx.myproject.base.eth` | FREE | Auto-created by your code |
| Create `usdt-xxx.myproject.base.eth` | FREE | Auto-created by your code |
| Create `dai-xxx.myproject.base.eth` | FREE | Auto-created by your code |
| Create 1000 more subdomains | FREE | Auto-created by your code |

**Pay once, create unlimited names!**

## Next Steps

1. **Go register:** https://www.base.org/names
2. **Change one line:** `ADAPTER_DOMAIN = "yourname.base.eth"`
3. **Deploy:** Your code handles everything else automatically!

The AdapterRegistry will create a unique ENS name for every adapter you register, forever, for free.
