# ENS Deployment Options

## Current Situation

The AdapterRegistry uses real ENS/Basenames contracts. You have 3 options:

### ✅ Option 1: Use Your Own Basename (RECOMMENDED for production)

**What you need:**
1. Register a basename at https://www.base.org/names (e.g., "myproject.base.eth")
2. Update ADAPTER_DOMAIN in deployment script to your basename
3. Deploy - you'll be able to register subdomains under YOUR name

**Pros:**
- Real ENS integration
- You control the namespace
- Professional looking names

**Cons:**
- Costs ~$5-10/year
- Takes 5 minutes to register

**Steps:**
```bash
# 1. Register "myproject.base.eth" at base.org/names
# 2. Edit script/DeployBaseTestnetWithENS.s.sol
#    Change: string constant ADAPTER_DOMAIN = "myproject.base.eth";
# 3. Deploy
forge script script/DeployBaseTestnetWithENS.s.sol --rpc-url baseSepolia --broadcast
```

---

### ✅ Option 2: Deploy Without ENS Registration

**What happens:**
- Contracts deploy successfully
- ENS registration fails (caught by try-catch)
- System works, but you reference adapters by address instead of names

**Pros:**
- Free
- Works immediately
- No ENS needed

**Cons:**
- No human-readable names
- Must use adapter addresses directly

**Already implemented** - just deploy as-is and ignore the ENS registration warnings

---

### ✅ Option 3: Testing Only (Fork Tests)

**For fork tests only:**
- We impersonate the base.eth owner
- Transfer ownership to AdapterRegistry
- Register adapters

**This ONLY works in tests** - you cannot do this in real deployment

---

## What The Tests Do vs Real Deployment

### Fork Tests (test-fork.sh)
```solidity
// We can impersonate ANY address in tests
vm.prank(baseEthOwner);
ensRegistry.setOwner(parentNode, address(adapterRegistry));
// Now registry owns base.eth temporarily and can register
```

### Real Deployment
```solidity
// This will FAIL with Unauthorized() unless you own base.eth
adapterRegistry.registerAdapter(address(adapter), "base.eth");
```

---

## Recommendation

**For testing:** Use fork tests (they work perfectly)

**For production deployment:**
1. **Best:** Register your own basename → Use Option 1
2. **Quick:** Skip ENS → Use Option 2
3. **Cannot:** Use "base.eth" unless you own it
