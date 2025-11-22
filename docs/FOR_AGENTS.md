# For AI Agents: How to Buy DeFi Yield Products

Simple 2-step process to discover and buy yield-bearing positions with USDC.

## Step 1: Get All Products

Call `getAllRegisteredAdapters()` on the AdapterRegistry to get all available products.

**Contract:** `0x045B9a7505164B418A309EdCf9A45EB1fE382951` (Base Sepolia)

```javascript
const products = await contract.call('getAllRegisteredAdapters');

// Returns array of:
// [
//   {
//     adapterId: "USDC:BASE_SEPOLIA:word-word.base.eth",  // ← Unique ID
//     adapterAddress: "0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF",
//     ensNode: "0x...",
//     domain: "base.eth"
//   },
//   ...
// ]
```

Each product has:
- **adapterId**: Unique identifier (use this to buy)
- **adapterAddress**: Contract address of the lending adapter
- **ensNode**: ENS namehash
- **domain**: ENS domain

## Step 2: Buy a Product

Call Uniswap V4 `swap()` with hookData containing the product's `adapterId`.

**You need:**
- USDC in your wallet
- The `adapterId` from step 1
- Your recipient address

```javascript
// Encode hookData
const hookData = encodeAbiParameters(
  [
    { type: 'string', name: 'adapterIdentifier' },
    { type: 'string', name: 'recipientIdentifier' }
  ],
  [
    'USDC:BASE_SEPOLIA:word-word.base.eth',  // adapterId from step 1
    '0xYourAddress'                           // where to receive tokens
  ]
);

// Call swap on Uniswap V4
await swap(poolKey, swapParams, hookData);

// Done! You now hold yield-bearing tokens (e.g., aUSDC from Aave)
```

## That's It

The hook automatically:
1. Takes your swap output
2. Deposits it to the lending protocol (Aave, Compound, etc.)
3. Sends you the yield-bearing tokens

All in one transaction.

---

## Example: Complete Flow

```javascript
import { createPublicClient, createWalletClient, http } from 'viem';
import { baseSepolia } from 'viem/chains';

// 1. Get all products
const publicClient = createPublicClient({
  chain: baseSepolia,
  transport: http('https://sepolia.base.org')
});

const products = await publicClient.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  abi: [{
    name: 'getAllRegisteredAdapters',
    outputs: [{
      components: [
        { name: 'adapterAddress', type: 'address' },
        { name: 'ensNode', type: 'bytes32' },
        { name: 'domain', type: 'string' },
        { name: 'adapterId', type: 'string' }
      ],
      type: 'tuple[]'
    }],
    stateMutability: 'view',
    type: 'function'
  }],
  functionName: 'getAllRegisteredAdapters'
});

console.log('Available products:', products);
// [
//   { adapterId: "USDC:BASE_SEPOLIA:word-word.base.eth", ... },
//   { adapterId: "USDT:BASE_SEPOLIA:word-word.base.eth", ... }
// ]

// 2. Select a product and buy
const selectedProduct = products[0]; // USDC product

const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'string' }],
  [selectedProduct.adapterId, myAddress]
);

// 3. Execute swap (you need Uniswap V4 swap router setup)
// The swap will automatically deposit to Aave and you get aUSDC
```

## Contract Addresses (Base Sepolia)

```
AdapterRegistry:  0x045B9a7505164B418A309EdCf9A45EB1fE382951
SwapDepositor:    0xa97800be965c982c381E161124A16f5450C080c4
Pool Manager:     0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829
```

## What You Get

When you buy a product, you receive **yield-bearing tokens**:
- USDC product → aUSDC (Aave interest-bearing USDC)
- USDT product → aUSDT (Aave interest-bearing USDT)

These tokens automatically earn yield. Your balance grows over time.

## Requirements

- Hold USDC on Base Sepolia
- Approve USDC for Uniswap V4 Pool Manager
- Call swap with the hookData

No manual deposits, no complex flows. Just swap and receive yield tokens.
