# Agent Integration Guide - Direct Smart Contract Interaction

This guide shows AI agents how to discover DeFi yield products and invest using direct smart contract calls with a wallet.

## Overview

With this platform, agents can:
1. **Discover** available yield products by querying the AdapterRegistry contract
2. **Execute** swaps that automatically deposit into lending protocols in a single transaction
3. **Hold only USDC** - the platform handles all token conversions and protocol interactions

## Key Benefit: One-Transaction Investment

Traditional flow:
1. Swap tokens (if needed)
2. Approve tokens
3. Call lending protocol deposit
4. Receive yield-bearing tokens

**This platform (single transaction):**
1. Call `swap()` with hookData containing adapter info
2. Automatically receive yield-bearing tokens (e.g., aUSDC from Aave)

## Smart Contract Addresses (Base Sepolia)

```
AdapterRegistry:    0x045B9a7505164B418A309EdCf9A45EB1fE382951
SwapDepositor Hook: 0xa97800be965c982c381E161124A16f5450C080c4
Pool Manager:       0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829
Aave V3 Pool:       0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951

Tokens:
USDC:               0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f
USDT:               0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a

Adapters:
USDC Adapter:       0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF
USDT Adapter:       0x5531bc190eC0C74dC8694176Ad849277AbA21a5D
```

**RPC:** `https://sepolia.base.org`
**Chain ID:** `84532`

## Step 1: Discover Available Products

Query the AdapterRegistry to see available lending adapters:

```javascript
import { createPublicClient, http } from 'viem';
import { baseSepolia } from 'viem/chains';

const client = createPublicClient({
  chain: baseSepolia,
  transport: http('https://sepolia.base.org')
});

// AdapterRegistry ABI (minimal)
const registryABI = [
  {
    "inputs": [{"type": "string", "name": "ensName"}],
    "name": "resolveAdapter",
    "outputs": [{"type": "address"}],
    "stateMutability": "view",
    "type": "function"
  }
];

// Query adapter for USDC
const usdcAdapter = await client.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  abi: registryABI,
  functionName: 'resolveAdapter',
  args: ['USDC:BASE_SEPOLIA:word-word.base.eth']
});

console.log('USDC Adapter:', usdcAdapter);
// Returns: 0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF
```

### Available Adapters

Currently registered adapters on Base Sepolia:

| Asset | ENS Name | Adapter Address | Protocol |
|-------|----------|-----------------|----------|
| USDC | `USDC:BASE_SEPOLIA:word-word.base.eth` | `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF` | Aave V3 |
| USDT | `USDT:BASE_SEPOLIA:word-word.base.eth` | `0x5531bc190eC0C74dC8694176Ad849277AbA21a5D` | Aave V3 |

## Step 2: Query Yield Information

To get current APY and other metrics, query the lending protocol directly:

```javascript
// Aave V3 Pool ABI (minimal)
const aavePoolABI = [
  {
    "inputs": [{"type": "address", "name": "asset"}],
    "name": "getReserveData",
    "outputs": [
      {
        "components": [
          {"type": "uint256", "name": "liquidityRate"},
          {"type": "uint256", "name": "variableBorrowRate"},
          // ... other fields
        ],
        "type": "tuple"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

// Query USDC reserve data from Aave
const reserveData = await client.readContract({
  address: '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951', // Aave Pool
  abi: aavePoolABI,
  functionName: 'getReserveData',
  args: ['0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f'] // USDC
});

// liquidityRate is in ray (27 decimals), APY = rate / 1e27 * 100
const apy = (Number(reserveData.liquidityRate) / 1e27) * 100;
console.log('Current USDC APY:', apy, '%');
```

## Step 3: Execute Swap with Auto-Deposit

Now execute a swap that automatically deposits to the lending protocol:

```javascript
import { createWalletClient, custom, encodePacked, encodeAbiParameters } from 'viem';

const walletClient = createWalletClient({
  chain: baseSepolia,
  transport: custom(window.ethereum) // or your wallet provider
});

// 1. Encode hookData with adapter ENS name and recipient
const hookData = encodeAbiParameters(
  [
    { type: 'string', name: 'adapterEnsName' },
    { type: 'address', name: 'recipient' }
  ],
  [
    'USDC:BASE_SEPOLIA:word-word.base.eth',
    '0xYourRecipientAddress'
  ]
);

// 2. Prepare swap parameters
const poolKey = {
  currency0: '0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f', // USDC
  currency1: '0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a', // USDT (example)
  fee: 3000,
  tickSpacing: 60,
  hooks: '0xa97800be965c982c381E161124A16f5450C080c4' // SwapDepositor
};

const swapParams = {
  zeroForOne: true,
  amountSpecified: -1000000n, // 1 USDC (negative = exact input)
  sqrtPriceLimitX96: 0n // No limit
};

// 3. Call swap function
// Note: You'll need to use the Uniswap V4 SwapRouter contract
// This is a simplified example - actual implementation depends on your setup
const hash = await walletClient.writeContract({
  address: '0x...', // SwapRouter address
  abi: swapRouterABI,
  functionName: 'swap',
  args: [poolKey, swapParams, hookData]
});

console.log('Transaction hash:', hash);
// Wait for confirmation, then recipient receives aUSDC tokens
```

## Complete Example: Agent Workflow

Here's a complete example showing how an agent would discover and invest:

```javascript
import { createPublicClient, createWalletClient, http, custom, encodeAbiParameters } from 'viem';
import { baseSepolia } from 'viem/chains';

async function agentInvestment() {
  // Setup clients
  const publicClient = createPublicClient({
    chain: baseSepolia,
    transport: http('https://sepolia.base.org')
  });

  const walletClient = createWalletClient({
    chain: baseSepolia,
    transport: custom(window.ethereum)
  });

  // Step 1: Discover available adapters
  const adapters = [
    {
      asset: 'USDC',
      ensName: 'USDC:BASE_SEPOLIA:word-word.base.eth',
      tokenAddress: '0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f'
    },
    {
      asset: 'USDT',
      ensName: 'USDT:BASE_SEPOLIA:word-word.base.eth',
      tokenAddress: '0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a'
    }
  ];

  // Step 2: Query APY for each adapter
  const aavePoolAddress = '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951';

  for (const adapter of adapters) {
    const reserveData = await publicClient.readContract({
      address: aavePoolAddress,
      abi: [{
        inputs: [{ type: 'address', name: 'asset' }],
        name: 'getReserveData',
        outputs: [{ type: 'tuple', components: [{ type: 'uint256', name: 'liquidityRate' }] }],
        stateMutability: 'view',
        type: 'function'
      }],
      functionName: 'getReserveData',
      args: [adapter.tokenAddress]
    });

    adapter.apy = (Number(reserveData.liquidityRate) / 1e27) * 100;
    console.log(`${adapter.asset} APY: ${adapter.apy}%`);
  }

  // Step 3: Select best adapter (highest APY)
  const bestAdapter = adapters.reduce((best, current) =>
    current.apy > best.apy ? current : best
  );

  console.log(`Selected: ${bestAdapter.asset} with ${bestAdapter.apy}% APY`);

  // Step 4: Prepare and execute swap
  const recipientAddress = await walletClient.getAddresses()[0];

  const hookData = encodeAbiParameters(
    [
      { type: 'string', name: 'adapterEnsName' },
      { type: 'address', name: 'recipient' }
    ],
    [bestAdapter.ensName, recipientAddress]
  );

  // Execute swap (implementation depends on your Uniswap V4 setup)
  console.log('Hook data ready:', hookData);
  console.log('Ready to execute swap with auto-deposit to', bestAdapter.asset);

  return {
    adapter: bestAdapter,
    hookData,
    recipient: recipientAddress
  };
}

// Run the agent
agentInvestment();
```

## Contract Interfaces

### AdapterRegistry

```solidity
interface IAdapterRegistry {
    /// @notice Resolve an adapter address from its ENS-style name
    /// @param ensName The ENS name (e.g., "USDC:BASE_SEPOLIA:word-word.base.eth")
    /// @return The adapter contract address
    function resolveAdapter(string memory ensName) external view returns (address);

    /// @notice Get the ENS node hash for an adapter name
    function getAdapterNode(string memory ensName) external pure returns (bytes32);
}
```

### SwapDepositor Hook

The SwapDepositor is a Uniswap V4 hook. You interact with it through Uniswap V4's swap function:

```solidity
// When calling swap on Uniswap V4, pass hookData containing:
bytes memory hookData = abi.encode(
    string adapterEnsName,  // "USDC:BASE_SEPOLIA:word-word.base.eth"
    address recipient       // Where to send yield-bearing tokens
);
```

The hook automatically:
1. Resolves the adapter from the registry using the ENS name
2. Intercepts your swap output tokens
3. Deposits them to the lending protocol
4. Sends yield-bearing tokens (e.g., aUSDC) to the recipient

### Lending Adapter

```solidity
interface ILendingAdapter {
    /// @notice Deposit tokens and receive yield-bearing tokens
    /// @param amount Amount of underlying tokens to deposit
    /// @param onBehalfOf Address to receive the yield-bearing tokens
    function deposit(uint256 amount, address onBehalfOf) external;

    /// @notice Get adapter metadata
    function getAdapterMetadata() external view returns (
        address underlyingAsset,
        string memory symbol,
        BlockchainIdentifier blockchain,
        ProtocolIdentifier protocol
    );
}
```

## Product Discovery Details

### Available Products

The platform currently supports Aave V3 on Base Sepolia. Here's what's available:

| Product | Protocol | Network | Asset | Adapter Address | Expected APY Range |
|---------|----------|---------|-------|-----------------|-------------------|
| Aave USDC | Aave V3 | Base Sepolia | USDC | 0x3903...fCF | 3-6% |
| Aave USDT | Aave V3 | Base Sepolia | USDT | 0x5531...a5D | 3-6% |

### How to Add More Products

To discover new products as they're added:

1. Listen for `AdapterRegistered` events on the AdapterRegistry contract
2. Query the registry periodically for new adapter ENS names
3. Check Aave V3 for newly supported assets

```javascript
// Listen for new adapters
publicClient.watchEvent({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  event: {
    type: 'event',
    name: 'AdapterRegistered',
    inputs: [
      { type: 'address', name: 'adapter', indexed: true },
      { type: 'bytes32', name: 'node', indexed: true }
    ]
  },
  onLogs: logs => {
    console.log('New adapter registered:', logs);
  }
});
```

## Gas Estimation

Typical gas costs on Base Sepolia:

- Swap only: ~150,000 gas
- Swap + deposit via hook: ~250,000 gas
- Total cost: ~$0.15-0.25 USDC equivalent

The hook adds minimal overhead (~100k gas) for automatic deposit.

## Security Considerations

1. **Verify Adapter Addresses**: Always verify adapter addresses match the registry before sending large amounts
2. **Check Allowances**: Ensure USDC approval for the Pool Manager before swapping
3. **Test First**: Use small amounts on testnet before mainnet
4. **Monitor Recipient**: Confirm yield-bearing tokens arrive at the expected address

## Error Handling

Common errors and solutions:

| Error | Cause | Solution |
|-------|-------|----------|
| `AdapterNotFound` | Invalid ENS name | Check adapter exists in registry |
| `InsufficientAllowance` | Token not approved | Approve tokens for Pool Manager |
| `InvalidRecipient` | Zero address | Provide valid recipient address |
| `SlippageTooHigh` | Price moved | Adjust sqrtPriceLimitX96 |

## Python Example (using web3.py)

```python
from web3 import Web3
from eth_abi import encode

# Connect to Base Sepolia
w3 = Web3(Web3.HTTPProvider('https://sepolia.base.org'))

# Contract addresses
REGISTRY_ADDRESS = '0x045B9a7505164B418A309EdCf9A45EB1fE382951'
AAVE_POOL_ADDRESS = '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951'
USDC_ADDRESS = '0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f'

# Step 1: Query adapter
registry = w3.eth.contract(
    address=REGISTRY_ADDRESS,
    abi=[{
        'inputs': [{'type': 'string', 'name': 'ensName'}],
        'name': 'resolveAdapter',
        'outputs': [{'type': 'address'}],
        'stateMutability': 'view',
        'type': 'function'
    }]
)

usdc_adapter = registry.functions.resolveAdapter(
    'USDC:BASE_SEPOLIA:word-word.base.eth'
).call()
print(f"USDC Adapter: {usdc_adapter}")

# Step 2: Query APY
aave_pool = w3.eth.contract(
    address=AAVE_POOL_ADDRESS,
    abi=[{
        'inputs': [{'type': 'address', 'name': 'asset'}],
        'name': 'getReserveData',
        'outputs': [{'type': 'tuple', 'components': [
            {'type': 'uint256', 'name': 'liquidityRate'}
        ]}],
        'stateMutability': 'view',
        'type': 'function'
    }]
)

reserve_data = aave_pool.functions.getReserveData(USDC_ADDRESS).call()
apy = (reserve_data[0] / 1e27) * 100
print(f"USDC APY: {apy}%")

# Step 3: Prepare hookData
from eth_abi import encode

hook_data = encode(
    ['string', 'address'],
    ['USDC:BASE_SEPOLIA:word-word.base.eth', '0xYourAddress']
)
print(f"Hook data: 0x{hook_data.hex()}")

# Use this hookData when calling swap on Uniswap V4
```

## Next Steps

1. **Set up wallet connection** with viem or ethers.js
2. **Query the AdapterRegistry** to discover available adapters
3. **Check APYs** from lending protocols (Aave, Compound, etc.)
4. **Approve USDC** for the Uniswap V4 Pool Manager
5. **Execute swap** with hookData to auto-deposit and receive yield tokens

## Resources

- **Contract Source Code**: `/contracts/src/`
- **Deployment Addresses**: `/contracts/DEPLOYED_ADDRESSES.md`
- **Adapter Registration Spec**: `/contracts/ADAPTER_REGISTRATION.md`
- **Base Sepolia Faucet**: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
- **Uniswap V4 Docs**: https://docs.uniswap.org/contracts/v4/overview

## Support

For questions or issues:
- Review contract source code in `/contracts/src/`
- Check deployment guide in `/contracts/DEPLOYMENT_GUIDE.md`
- Test transactions on Base Sepolia block explorer: https://sepolia.basescan.org
