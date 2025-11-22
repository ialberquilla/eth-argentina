# How to Deploy with Your Own Basename

## Problem
You cannot register subdomains under `base.eth` because you don't own it. Only the owner can create subdomains.

## Solution: Use Your Own Basename

### Step 1: Register a Basename
Go to https://www.base.org/names and register your own name, for example:
- `myproject.base.eth`
- `defi.base.eth`
- `yourname.base.eth`

Cost: ~$5-10 per year

### Step 2: Update Deployment Script

Edit `script/DeployBaseTestnetWithENS.s.sol`:

```solidity
// Change this line:
string constant ADAPTER_DOMAIN = "base.eth";

// To your registered basename:
string constant ADAPTER_DOMAIN = "myproject.base.eth";
```

### Step 3: Deploy

```bash
forge script script/DeployBaseTestnetWithENS.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  --private-key $PRIVATE_KEY
```

Now your adapters will register as:
- `usdc-basesepolia-clear-swan.myproject.base.eth`
- `usdt-basesepolia-copper-serval.myproject.base.eth`

## Alternative: Deploy Without ENS

The deployment script has try-catch blocks, so it will still deploy successfully even if ENS registration fails.

Edit `script/DeployBaseTestnetWithENS.s.sol` to skip ENS registration:

```solidity
// Comment out the registration attempts (lines 160-181)
// The contracts will deploy but won't register in ENS
// You can still use the system, just reference adapters by address
```

## Option 3: Add a Permissioned Registration Function

If you want others to register adapters under your domain, add this to `AdapterRegistry.sol`:

```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}

function setOwner(address newOwner) external onlyOwner {
    owner = newOwner;
}

// Only owner can call this, owner can transfer base.eth ownership to registry
function registerAdapterAsOwner(address adapter, string calldata _domain) external onlyOwner {
    registerAdapter(adapter, _domain);
}
```

But you still need to own the basename first!
