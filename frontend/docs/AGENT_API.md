# Agent-Friendly API Documentation

This documentation is designed for AI agents to easily discover, evaluate, and invest in DeFi yield products using a simple USDC-denominated interface.

## Overview

This platform enables agents to:
1. **Discover** available yield-bearing vaults across multiple DeFi protocols
2. **Execute** swaps that automatically deposit into yield positions
3. **Manage** positions with USDC only - no complex token swaps needed

All operations are USDC-denominated, and the platform handles the complexity of:
- Cross-chain operations
- Token approvals
- Lending protocol deposits
- Liquidity pool interactions

## Quick Start for Agents

### Step 1: Discover Available Products

Call the vaults API to see all available yield opportunities:

```bash
GET https://your-domain.com/api/vaults
```

Response:
```json
{
  "success": true,
  "count": 10,
  "vaults": [
    {
      "id": "SV-BASE-001",
      "name": "SV-BASE-001",
      "protocol": "AAVE V3 IDE",
      "network": "Base",
      "asset": "USDC",
      "apy": 4.67,
      "tvl": "$1.2B",
      "riskLevel": "Low",
      "swapDepositorAddress": "0xa97800be965c982c381E161124A16f5450C080c4",
      "adapterAddress": "0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF",
      "adapterEnsName": "USDC:BASE_SEPOLIA:word-word.base.eth"
    }
  ]
}
```

### Step 2: Filter and Select Best Vault

You can filter vaults by various criteria:

```bash
# Get only Base network vaults
GET /api/vaults?network=Base

# Get USDC vaults with minimum 5% APY
GET /api/vaults?asset=USDC&minApy=5

# Get low-risk vaults
GET /api/vaults?riskLevel=Low
```

### Step 3: Execute Swap and Auto-Deposit

Once you've selected a vault, execute a swap that automatically deposits to the yield position:

```bash
POST /api/swap
Content-Type: application/json

{
  "vaultId": "SV-BASE-001",
  "amountIn": "1000000",
  "recipient": "0xYourAddress"
}
```

Response:
```json
{
  "success": true,
  "vaultId": "SV-BASE-001",
  "transactionData": {
    "swapDepositorAddress": "0xa97800be965c982c381E161124A16f5450C080c4",
    "adapterEnsName": "USDC:BASE_SEPOLIA:word-word.base.eth",
    "hookData": "0x...",
    "instructions": "...",
    "estimatedGas": "~250,000 gas",
    "network": "BASE_SEPOLIA"
  },
  "expectedOutput": {
    "asset": "aUSDC",
    "apy": 4.67,
    "protocol": "AAVE V3"
  }
}
```

## API Reference

### GET /api/vaults

Returns a list of available yield vaults/products.

**Query Parameters:**
- `network` (optional): Filter by blockchain network (e.g., "Base", "Ethereum", "Arbitrum")
- `asset` (optional): Filter by asset (e.g., "USDC", "USDT", "DAI")
- `minApy` (optional): Filter by minimum APY (number, e.g., 5.0)
- `riskLevel` (optional): Filter by risk level ("Low", "Medium", "High")

**Response:**
```typescript
{
  success: boolean;
  count: number;
  vaults: Array<{
    id: string;
    name: string;
    protocol: string;
    network: string;
    asset: string;
    apy: number;
    tvl: string;
    riskLevel: "Low" | "Medium" | "High";
    volatility: number;
    total24hVol: string;
    bestLeverage: string;
    bestFixedApy: number;
    depeggingRisk: "Low" | "Medium" | "High";
    currentApy: number;
    yieldStability: number;
    lockupPeriod: string;
    gasCost: string;
    capitalUtilization: number;
    currentCapacity: string;
    maxCapacity: string;
    exploitHistory: string;
    timeSinceLaunch: string;
    smartContractRiskScore: number;
    // Agent-specific fields
    swapDepositorAddress?: string;
    adapterAddress?: string;
    adapterEnsName?: string;
  }>;
}
```

**Example:**
```bash
curl https://your-domain.com/api/vaults?network=Base&minApy=4
```

### GET /api/registry

Returns information about registered adapters in the AdapterRegistry.

**Query Parameters:**
- `symbol` (optional): Filter by token symbol (e.g., "USDC")
- `network` (optional): Filter by network (e.g., "BASE_SEPOLIA")

**Response:**
```typescript
{
  success: boolean;
  registryAddress: string;
  network: string;
  count: number;
  adapters: Array<{
    symbol: string;
    network: string;
    protocol: string;
    adapterAddress: string;
    ensName: string;
    tokenAddress: string;
    aavePoolAddress: string;
  }>;
  usage: {
    resolveAdapter: string;
    swapWithDeposit: string;
  };
}
```

**Example:**
```bash
curl https://your-domain.com/api/registry?symbol=USDC
```

### POST /api/swap

Returns transaction data needed to execute a swap with automatic deposit.

**Request Body:**
```typescript
{
  vaultId: string;        // Vault ID from /api/vaults
  amountIn: string;       // Amount in USDC wei (1 USDC = 1000000)
  recipient: string;      // Recipient address or ENS name
}
```

**Response:**
```typescript
{
  success: boolean;
  vaultId: string;
  transactionData: {
    swapDepositorAddress: string;
    adapterEnsName: string;
    hookData: string;
    instructions: string;
    estimatedGas: string;
    network: string;
  };
  expectedOutput: {
    asset: string;
    apy: number;
    protocol: string;
  };
}
```

**Example:**
```bash
curl -X POST https://your-domain.com/api/swap \
  -H "Content-Type: application/json" \
  -d '{
    "vaultId": "SV-BASE-001",
    "amountIn": "1000000",
    "recipient": "0x1234567890123456789012345678901234567890"
  }'
```

### GET /api/swap

Returns general information about the swap functionality.

**Response:**
```typescript
{
  success: boolean;
  description: string;
  contracts: {
    swapDepositor: string;
    adapterRegistry: string;
    poolManager: string;
  };
  network: string;
  supportedAssets: string[];
  documentation: string;
}
```

## Smart Contract Integration

### Architecture Overview

The platform uses a Uniswap V4 hook architecture:

1. **AdapterRegistry** (`0x045B9a7505164B418A309EdCf9A45EB1fE382951`)
   - Central registry for adapter lookup
   - Maps ENS-style names to adapter addresses
   - Supports human-readable adapter identifiers

2. **SwapDepositor Hook** (`0xa97800be965c982c381E161124A16f5450C080c4`)
   - Uniswap V4 hook that intercepts swap outputs
   - Automatically deposits to lending protocols
   - Supports ENS/Basename resolution for recipients

3. **Lending Adapters** (e.g., `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF`)
   - Protocol-specific adapters (Aave, Compound, etc.)
   - Handle token deposits and withdrawals
   - Return yield-bearing tokens (aTokens, cTokens, etc.)

### Transaction Flow

```
1. Agent holds USDC
2. Agent calls swap() with hookData containing adapter ENS name
3. Uniswap V4 executes swap (if needed)
4. SwapDepositor hook intercepts output tokens
5. Hook deposits tokens to lending protocol via adapter
6. Agent receives yield-bearing tokens (e.g., aUSDC)
```

### Direct Smart Contract Usage

If you prefer to interact directly with smart contracts:

#### 1. Query Available Adapters

```solidity
// AdapterRegistry interface
interface IAdapterRegistry {
    function resolveAdapter(string memory ensName) external view returns (address);
    function getAdapterNode(string memory ensName) external pure returns (bytes32);
}

// Example: Resolve USDC adapter
address adapter = adapterRegistry.resolveAdapter("USDC:BASE_SEPOLIA:word-word.base.eth");
```

#### 2. Execute Swap with Auto-Deposit

```solidity
// Encode hookData
bytes memory hookData = abi.encode(
    "USDC:BASE_SEPOLIA:word-word.base.eth",  // Adapter ENS name
    recipientAddress                          // Recipient address or ENS name
);

// Execute swap (Uniswap V4 SwapRouter)
swapRouter.swap{value: 0}(
    poolKey,      // Pool key with SwapDepositor hook
    swapParams,   // Swap parameters (amount, direction, etc.)
    testSettings, // Test settings
    hookData      // Hook data with adapter info
);
```

## Example Agent Workflow

Here's a complete example of an agent discovering and investing in a vault:

```python
import requests
import json

# Step 1: Discover available vaults
vaults_response = requests.get("https://your-domain.com/api/vaults", params={
    "network": "Base",
    "asset": "USDC",
    "minApy": 4,
    "riskLevel": "Low"
})

vaults = vaults_response.json()["vaults"]

# Step 2: Select best vault by APY
best_vault = max(vaults, key=lambda v: v["apy"])
print(f"Selected vault: {best_vault['id']} with APY: {best_vault['apy']}%")

# Step 3: Get swap transaction data
swap_response = requests.post("https://your-domain.com/api/swap", json={
    "vaultId": best_vault["id"],
    "amountIn": "1000000",  # 1 USDC
    "recipient": "0xYourAddress"
})

swap_data = swap_response.json()

# Step 4: Execute transaction (using web3 library)
# The hookData and instructions are provided in swap_data
print(f"Hook data: {swap_data['transactionData']['hookData']}")
print(f"Instructions: {swap_data['transactionData']['instructions']}")
print(f"Expected output: {swap_data['expectedOutput']}")

# Step 5: Submit transaction to blockchain
# (Implementation depends on your web3 library)
```

## Key Benefits for Agents

### 1. Single Currency (USDC)
- Hold only USDC to access all vaults
- No need to manage multiple token types
- Simplified accounting and portfolio management

### 2. One Transaction
- Swap and deposit happen atomically
- No need for multiple transaction approvals
- Reduced gas costs and complexity

### 3. Automatic Protocol Integration
- Platform handles Aave, Compound, Morpho, etc.
- No need to learn each protocol's interface
- Consistent API across all protocols

### 4. Risk Assessment
- Comprehensive risk metrics for each vault
- Smart contract risk scores
- Historical exploit data
- Volatility and yield stability metrics

### 5. Cross-Chain Support
- Access vaults on Base, Ethereum, Arbitrum, Polygon, Optimism
- Unified interface across all chains
- Consistent transaction patterns

## Network Information

### Base Sepolia (Testnet)

**Contract Addresses:**
- AdapterRegistry: `0x045B9a7505164B418A309EdCf9A45EB1fE382951`
- SwapDepositor: `0xa97800be965c982c381E161124A16f5450C080c4`
- Uniswap V4 Pool Manager: `0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829`
- Aave V3 Pool: `0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951`
- USDC: `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`
- USDT: `0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`

**Adapters:**
- USDC Adapter: `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF`
- USDT Adapter: `0x5531bc190eC0C74dC8694176Ad849277AbA21a5D`

**RPC Endpoint:** `https://sepolia.base.org`
**Chain ID:** `84532`
**Block Explorer:** `https://sepolia.basescan.org`

## Error Handling

The API uses standard HTTP status codes:

- `200 OK`: Request successful
- `400 Bad Request`: Invalid request parameters
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

Error responses include descriptive messages:

```json
{
  "success": false,
  "error": "Missing required fields: vaultId, amountIn, recipient"
}
```

## Rate Limiting

Currently, there are no rate limits on the API. However, agents should:
- Cache vault data locally
- Implement exponential backoff for retries
- Use batch requests when possible

## Security Considerations

1. **Contract Verification**: All smart contracts are verified on Basescan
2. **Audit Status**: Check individual vault audit reports
3. **Risk Metrics**: Use provided risk scores and exploit history
4. **Test First**: Use Base Sepolia testnet before mainnet
5. **Amount Limits**: Start with small amounts to test the flow

## Support

- **Documentation**: `/docs/AGENT_API.md` (this file)
- **Contract Docs**: `/contracts/README.md`
- **Deployment Info**: `/contracts/DEPLOYED_ADDRESSES.md`
- **GitHub Issues**: [Repository Issues Page]

## Changelog

### Version 1.0.0 (Current)
- Initial release
- Support for Base Sepolia testnet
- USDC and USDT vaults
- Aave V3 integration
- Basic risk metrics

### Planned Features
- Mainnet deployment
- Additional protocols (Compound V3, Morpho, Curve)
- Advanced risk analytics
- Portfolio management endpoints
- Withdrawal/unstaking APIs
- Real-time APY updates
- Historical performance data
