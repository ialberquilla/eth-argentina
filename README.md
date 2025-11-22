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
- **Direct Contract Interaction**: Query AdapterRegistry and call swap with your wallet
- **Single Transaction**: Swap and deposit atomically via Uniswap V4 hooks
- **USDC Only**: No complex token management
- **On-Chain Discovery**: Query contracts to discover products and APYs
- **Complete Documentation**: See [`frontend/docs/AGENT_GUIDE.md`](frontend/docs/AGENT_GUIDE.md)

## Quick Start for AI Agents

```javascript
import { createPublicClient, http } from 'viem';
import { baseSepolia } from 'viem/chains';

const client = createPublicClient({
  chain: baseSepolia,
  transport: http('https://sepolia.base.org')
});

// 1. Discover available adapters from registry
const adapter = await client.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951', // AdapterRegistry
  abi: registryABI,
  functionName: 'resolveAdapter',
  args: ['USDC:BASE_SEPOLIA:word-word.base.eth']
});

// 2. Query APY from Aave
const reserveData = await client.readContract({
  address: '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951', // Aave Pool
  abi: aavePoolABI,
  functionName: 'getReserveData',
  args: ['0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f'] // USDC
});

// 3. Execute swap with auto-deposit
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'address' }],
  ['USDC:BASE_SEPOLIA:word-word.base.eth', yourAddress]
);
// Call swap on Uniswap V4 with this hookData
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
2. Query AdapterRegistry to discover products
3. Call Uniswap V4 `swap()` with hookData containing adapter ENS name
4. Receive yield-bearing tokens automatically

All token swaps, approvals, and protocol deposits happen in a single transaction via Uniswap V4 hooks.

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
- **[Agent Integration Guide](frontend/docs/AGENT_GUIDE.md)** - Complete guide for direct contract interaction
- **[Contract Interfaces](frontend/docs/AGENT_GUIDE.md#contract-interfaces)** - ABIs and function signatures
- **[Example Workflows](frontend/docs/AGENT_GUIDE.md#complete-example-agent-workflow)** - JavaScript and Python examples

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
