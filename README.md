# DeFi Yield Aggregator - Agent-Friendly Platform

A DeFi yield aggregator platform that enables users and AI agents to discover and invest in yield-bearing positions across multiple protocols using a simple USDC-denominated interface.

## Overview

This platform simplifies DeFi investing by:
- Aggregating yield opportunities from Aave, Compound, Morpho, and other protocols
- Enabling one-click investments via Uniswap V4 hooks
- Providing comprehensive risk metrics and analytics
- Offering direct smart contract access for AI agents with wallets

## Architecture

The platform consists of two main components:

### 1. Frontend (`/frontend`)
Next.js 16 application with:
- User-friendly vault discovery and comparison
- Privy social login integration
- Multi-chain support (Arc, Base, Ethereum, Arbitrum, Polygon, Optimism)
- Documentation for AI agent integration

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
- **Get Products**: Call `getAllRegisteredAdapters()` to see all available yield products
- **Buy with USDC**: Call `swap()` with the product's unique ID to buy
- **One Transaction**: Automatically receive yield-bearing tokens
- **Complete Documentation**: See [`docs/FOR_AGENTS.md`](docs/FOR_AGENTS.md)

## Quick Start for AI Agents

```javascript
// Step 1: Get all available products
const products = await contract.call('getAllRegisteredAdapters');
// Returns: [{ adapterId: "USDC:BASE_SEPOLIA:word-word.base.eth", ... }, ...]

// Step 2: Buy a product with USDC
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'string' }],
  [products[0].adapterId, yourAddress]  // adapterId + your address
);

await swap(poolKey, swapParams, hookData);
// Done! You receive yield-bearing tokens (e.g., aUSDC)
```

See full documentation: [`docs/FOR_AGENTS.md`](docs/FOR_AGENTS.md)

## How It Works

### Traditional DeFi Investing
1. Buy desired token (multiple swaps, high fees)
2. Approve token for protocol
3. Navigate protocol UI
4. Deposit to protocol
5. Receive yield-bearing tokens

### This Platform
1. Hold USDC
2. Call `getAllRegisteredAdapters()` to get products with unique IDs
3. Call `swap()` with the product's unique ID
4. Receive yield-bearing tokens automatically

All in one transaction via Uniswap V4 hooks.

## Smart Contract Architecture

```
User/Agent (USDC)
    �
Uniswap V4 Swap
    �
SwapDepositor Hook
    �
AdapterRegistry (resolves protocol adapter)
    �
Lending Adapter (Aave/Compound/etc.)
    �
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
- **[For Agents](docs/FOR_AGENTS.md)** - Simple 2-step guide: get products, buy with USDC

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
