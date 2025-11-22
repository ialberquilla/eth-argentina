# DeFi Yield Aggregator - Agent-Friendly Platform

A DeFi yield aggregator platform that enables users and AI agents to discover and invest in yield-bearing positions across multiple protocols using a simple USDC-denominated interface.

## Overview

This platform simplifies DeFi investing by:
- Aggregating yield opportunities from Aave, Compound, Morpho, and other protocols
- Enabling one-click investments via Uniswap V4 hooks
- Providing comprehensive risk metrics and analytics
- Offering an agent-friendly API for programmatic access

## Architecture

The platform consists of two main components:

### 1. Frontend (`/frontend`)
Next.js 16 application with:
- User-friendly vault discovery and comparison
- Privy social login integration
- Multi-chain support (Arc, Base, Ethereum, Arbitrum, Polygon, Optimism)
- RESTful API for AI agents

### 2. Smart Contracts (`/contracts`)
Foundry-based Solidity contracts:
- **AdapterRegistry**: Central registry for lending protocol adapters
- **SwapDepositor Hook**: Uniswap V4 hook for automatic yield deposits
- **Lending Adapters**: Protocol-specific adapters (Aave, Compound, etc.)

## Key Features

### For Users
- Browse and compare yield opportunities across multiple protocols
- Invest in any vault with just USDC
- Automatic token swaps and protocol deposits
- Comprehensive risk metrics and analytics

### For AI Agents
- **Simple API**: Discover vaults via `/api/vaults`
- **Single Transaction**: Swap and deposit atomically
- **USDC Only**: No complex token management
- **Risk Metrics**: Automated risk assessment for decision-making
- **Complete Documentation**: See [`frontend/docs/AGENT_API.md`](frontend/docs/AGENT_API.md)

## Quick Start for AI Agents

```bash
# 1. Discover available vaults
curl https://your-domain.com/api/vaults?network=Base&minApy=4

# 2. Get adapter registry information
curl https://your-domain.com/api/registry?symbol=USDC

# 3. Execute swap with auto-deposit
curl -X POST https://your-domain.com/api/swap \
  -H "Content-Type: application/json" \
  -d '{
    "vaultId": "SV-BASE-001",
    "amountIn": "1000000",
    "recipient": "0xYourAddress"
  }'
```

## How It Works

### Traditional DeFi Investing
1. Buy desired token (multiple swaps, high fees)
2. Approve token for protocol
3. Navigate protocol UI
4. Deposit to protocol
5. Receive yield-bearing tokens

### This Platform
1. Hold USDC
2. Call `/api/swap` with vault ID
3. Receive yield-bearing tokens automatically

All token swaps, approvals, and protocol deposits happen in a single transaction via Uniswap V4 hooks.

## Smart Contract Architecture

```
User/Agent (USDC)
    “
Uniswap V4 Swap
    “
SwapDepositor Hook
    “
AdapterRegistry (resolves protocol adapter)
    “
Lending Adapter (Aave/Compound/etc.)
    “
User receives yield-bearing tokens (aUSDC/cUSDC/etc.)
```

## Deployed Contracts (Base Sepolia)

- **AdapterRegistry**: `0x045B9a7505164B418A309EdCf9A45EB1fE382951`
- **SwapDepositor**: `0xa97800be965c982c381E161124A16f5450C080c4`
- **USDC Adapter**: `0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF`
- **USDT Adapter**: `0x5531bc190eC0C74dC8694176Ad849277AbA21a5D`

See [`contracts/DEPLOYED_ADDRESSES.md`](contracts/DEPLOYED_ADDRESSES.md) for complete deployment details.

## Documentation

### For AI Agents
- **[Agent API Guide](frontend/docs/AGENT_API.md)** - Complete API documentation with examples
- **[API Reference](frontend/docs/AGENT_API.md#api-reference)** - Endpoint specifications
- **[Example Workflows](frontend/docs/AGENT_API.md#example-agent-workflow)** - Python examples

### For Developers
- **[Frontend README](frontend/README.md)** - Next.js app setup and configuration
- **[Contract README](contracts/README.md)** - Smart contract documentation
- **[Deployment Guide](contracts/DEPLOYMENT_GUIDE.md)** - How to deploy contracts
- **[Adapter Registration](contracts/ADAPTER_REGISTRATION.md)** - Register new adapters

## Getting Started

### Frontend Development

```bash
cd frontend
npm install
cp .env.local.example .env.local
# Add your Privy App ID to .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### Contract Development

```bash
cd contracts
forge install
forge build
forge test
```

## API Endpoints

### GET /api/vaults
List available yield vaults with filtering options.

**Query Parameters:**
- `network`: Filter by blockchain (e.g., "Base")
- `asset`: Filter by asset (e.g., "USDC")
- `minApy`: Minimum APY threshold
- `riskLevel`: Filter by risk ("Low", "Medium", "High")

### GET /api/registry
Get registered lending protocol adapters.

**Query Parameters:**
- `symbol`: Filter by token symbol
- `network`: Filter by network

### POST /api/swap
Get transaction data for swap with automatic deposit.

**Body:**
```json
{
  "vaultId": "SV-BASE-001",
  "amountIn": "1000000",
  "recipient": "0xAddress"
}
```

## Technology Stack

### Frontend
- Next.js 16 (App Router)
- Privy (Social login & wallet management)
- viem (Ethereum interactions)
- Tailwind CSS

### Contracts
- Solidity 0.8.26
- Foundry
- Uniswap V4
- Aave V3
- OpenZeppelin

### Supported Networks
- Arc (Circle)
- Base
- Ethereum
- Arbitrum
- Polygon
- Optimism

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests.

## Security

- All smart contracts are tested with Foundry
- Adapters are registered in a central registry
- Comprehensive risk metrics provided for each vault
- Test on Base Sepolia before mainnet deployment

## License

[Add your license here]

## Contact

[Add contact information or links]
