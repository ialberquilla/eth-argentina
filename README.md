# OneTX - DeFi Yield Aggregator

A DeFi yield aggregator platform that enables users and AI agents to discover and invest in yield-bearing positions across multiple protocols using a simple USDC-denominated interface with automatic swaps and deposits in a single transaction.

## 🚀 What is OneTX?

OneTX simplifies DeFi investing by eliminating the complexity of navigating multiple protocols, performing token swaps, and managing approvals. Users can invest in any yield-bearing position with just USDC in **one transaction**.

### Traditional DeFi Investing (5 steps)
1. Buy desired token (multiple swaps, high fees)
2. Approve token for protocol
3. Navigate complex protocol UI
4. Deposit tokens to protocol
5. Receive yield-bearing tokens

### OneTX (1 transaction)
1. Hold USDC
2. Select yield product from aggregated list
3. Execute swap → **Automatically** swap, deposit, and receive yield tokens

All powered by Uniswap V4 hooks that execute deposits atomically during swaps.

## ✨ Key Features

### For Users
- **One-Click Investing**: Invest in any vault with just USDC
- **Yield Aggregation**: Browse and compare opportunities across Aave, Compound, Morpho, and more
- **Automatic Execution**: Token swaps and protocol deposits happen automatically
- **Comprehensive Risk Metrics**: APY, TVL, volatility, depegging risk, smart contract risk scores
- **Cross-Chain USDC Transfers**: Bridge USDC between Arc and Base using Circle's CCTP
- **Social Login**: Connect with email, Google, Twitter, Discord, GitHub, Apple, and more

### For AI Agents
- **Simple API**: Two-step process to discover and invest in products
- **ENS-Based Product IDs**: Human-readable identifiers like `USDT:BASE_SEPOLIA:word-word.base.eth`
- **Direct Contract Access**: No UI required, pure smart contract interactions
- **Complete Documentation**: Visit `/docs` on the frontend for full API guide

## 🏗️ Architecture

### System Overview

```
User/Agent (USDC)
    ↓
Uniswap V4 Swap Router
    ↓
SwapDepositor Hook (intercepts swap output)
    ↓
AdapterRegistry (resolves protocol adapter)
    ↓
Lending Adapter (Aave/Compound/Morpho)
    ↓
User receives yield-bearing tokens (aUSDC/cUSDC/etc.)
```

### Components

#### 1. Frontend (`/frontend`)
Next.js 16 application featuring:
- **Vault Discovery**: Browse and compare yield opportunities
- **Privy Integration**: Social login and embedded wallets
- **Multi-Chain Support**: Base Sepolia, Ethereum, Arbitrum, Polygon, Optimism
- **Agent Documentation**: Complete API guide at `/docs`
- **Cross-Chain Bridge**: USDC bridge UI for Arc ↔ Base transfers

**Tech Stack:**
- Next.js 16 (App Router)
- Privy (Authentication & Wallets)
- viem (Blockchain interactions)
- Tailwind CSS

#### 2. Smart Contracts (`/contracts`)
Foundry-based Solidity contracts:

**Core Contracts:**
- **SwapDepositor Hook**: Uniswap V4 hook that automatically deposits swap outputs to lending protocols
- **AdapterRegistry**: Central registry for discovering and resolving lending protocol adapters via ENS
- **Lending Adapters**: Protocol-specific adapters for Aave, Compound, Morpho, etc.
- **CCTPBridge**: Cross-chain USDC bridge using Circle's CCTP

**Tech Stack:**
- Solidity 0.8.26
- Foundry
- Uniswap V4
- Aave V3
- OpenZeppelin

## 🎯 How It Works

### Swap + Deposit Flow

1. **User initiates swap**: Swap USDC for USDT on Uniswap V4
2. **beforeSwap hook**: SwapDepositor resolves adapter and recipient addresses
3. **Swap executes**: USDC → USDT via pool
4. **afterSwap hook**:
   - Intercepts USDT output
   - Approves adapter to spend tokens
   - Calls adapter's `deposit()` function
5. **Adapter deposits**: Deposits USDT to Aave on behalf of recipient
6. **User receives**: aUSDT tokens (yield-bearing)

### ENS Resolution

The system supports both direct addresses and ENS names:

**Adapter Identifier**: `"0x992A8847C28F9cD9251D5382249A4d35523F510A"` OR `"usdt-basesepolia-word-word.onetx.base.eth"`

**Recipient Identifier**: `"0x1234..."` OR `"alice.base.eth"`

## 📦 Deployed Contracts

### Base Sepolia Testnet (Chain ID: 84532)

| Contract | Address | Purpose |
|----------|---------|---------|
| **AdapterRegistry** | [`0x7425AAa97230f6D575193667cfd402b0B89C47f2`](https://sepolia.basescan.org/address/0x7425AAa97230f6D575193667cfd402b0B89C47f2) | Central registry for adapter lookup |
| **SwapDepositor Hook** | [`0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4`](https://sepolia.basescan.org/address/0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4) | Uniswap V4 hook for auto-deposits |
| **USDT Adapter** | [`0x992A8847C28F9cD9251D5382249A4d35523F510A`](https://sepolia.basescan.org/address/0x992A8847C28F9cD9251D5382249A4d35523F510A) | Aave V3 adapter for USDT |
| **Mock Aave Pool** | [`0x6645D1d54aA2450e048cbdca38e032cfe8DA7845`](https://sepolia.basescan.org/address/0x6645D1d54aA2450e048cbdca38e032cfe8DA7845) | Mock Aave pool for testing |

**Uniswap V4:**
- Pool Manager: `0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829`
- Swap Router: `0x71cD4Ea054F9Cb3D3BF6251A00673303411A7DD9`

**Test Tokens:**
- USDC: `0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f`
- USDT: `0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a`

### Arc Testnet (Chain ID: 5042002)

| Contract | Address | Purpose |
|----------|---------|---------|
| **CCTP Helper** | `0xC5567a5E3370d4DBfB0540025078e283e36A363d` | Bridge USDC via CCTP |
| **USDC** | `0x3600000000000000000000000000000000000000` | Native gas token |
| **TokenMessenger** | `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA` | Circle CCTP messenger |
| **MessageTransmitter** | `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275` | Circle CCTP transmitter |

See [`contracts/DEPLOYED_ADDRESSES.md`](contracts/DEPLOYED_ADDRESSES.md) for complete details.

## 🤖 For AI Agents

### Quick Start Guide

AI agents with wallets can interact directly with the smart contracts:

```javascript
// Step 1: Get all available yield products
const adapterRegistry = "0x7425AAa97230f6D575193667cfd402b0B89C47f2";
const products = await contract.call(
  adapterRegistry,
  'getAllRegisteredAdapters'
);
// Returns: [{ adapterId: "USDT:BASE_SEPOLIA:...", adapterAddress: "0x...", ... }]

// Step 2: Encode hook data with product ID and your address
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'string' }],
  [
    "0x992A8847C28F9cD9251D5382249A4d35523F510A", // Adapter address
    "0xYourAddress"                                  // Your wallet
  ]
);

// Step 3: Execute swap (USDC -> USDT) with auto-deposit
const poolKey = {
  currency0: "0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a", // USDT
  currency1: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f", // USDC
  fee: 3000,
  tickSpacing: 60,
  hooks: "0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4"
};

await swapRouter.swapExactTokensForTokens(
  1000000,        // 1 USDC
  0,              // Min out (adjust for slippage)
  false,          // zeroForOne (USDC -> USDT)
  poolKey,
  hookData,
  yourAddress,
  deadline
);

// Done! You receive aUSDT tokens automatically
```

**Complete Documentation**: Visit `/docs` on the frontend for detailed examples, ABIs, and error handling.

## 🌉 Cross-Chain USDC Bridge (CCTP)

OneTX supports Circle's Cross-Chain Transfer Protocol for native USDC transfers between Arc and Base.

### Features
- **Native USDC**: Burn & mint mechanism (no wrapped tokens!)
- **Fast Finality**: ~15 seconds on testnet
- **Optional Auto-Swap**: Execute swaps automatically on destination chain

### Quick Example

```typescript
// Bridge 100 USDC from Arc to Base
await bridgeUSDC({
  amount: "100",
  destinationChainId: 84532, // Base Sepolia
  recipient: "0xYourAddress",
  withSwap: true,              // Optional
  swapParams: {
    tokenOut: "0xUSDT_ADDRESS",
    minAmountOut: "99",
    deadline: Date.now() + 3600
  }
});
```

### Bridge Flow
1. User burns USDC on Arc via TokenMessenger
2. Circle's attestation service monitors burn event
3. After finality (~15s), attestation signature is issued
4. User calls `receiveMessage()` on Base with message + attestation
5. USDC is minted on Base
6. (Optional) Automatic swap executes via Uniswap V4

See [`CCTP_IMPLEMENTATION.md`](CCTP_IMPLEMENTATION.md) for complete bridge documentation.

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- pnpm/npm/yarn
- Foundry (for contracts)
- Git

### Frontend Setup

```bash
cd frontend
pnpm install

# Configure Privy
cp .env.local.example .env.local
# Add your Privy App ID to .env.local

# Run development server
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000)

### Smart Contracts Setup

```bash
cd contracts
forge install
forge build
forge test
```

### Run a Test Swap

```bash
cd contracts
source .env

# Execute swap that automatically deposits to Aave
forge script script/03_Swap_Simple.s.sol \
  --rpc-url baseSepolia \
  --broadcast \
  -vvv
```

## 📚 Documentation

- **Frontend README**: [`frontend/README.md`](frontend/README.md) - Next.js setup and configuration
- **Contracts README**: [`contracts/README.md`](contracts/README.md) - Smart contract documentation
- **CCTP Guide**: [`CCTP_IMPLEMENTATION.md`](CCTP_IMPLEMENTATION.md) - Cross-chain bridge guide
- **Deployed Addresses**: [`contracts/DEPLOYED_ADDRESSES.md`](contracts/DEPLOYED_ADDRESSES.md) - All contract addresses
- **AI Agent Docs**: Visit `/docs` on the frontend for complete API guide

## 🛠️ Technology Stack

### Frontend
- Next.js 16 (App Router)
- Privy (Social login & embedded wallets)
- viem (Ethereum interactions)
- Tailwind CSS
- TypeScript

### Smart Contracts
- Solidity 0.8.26
- Foundry (Development & testing)
- Uniswap V4 (Hooks & swaps)
- Aave V3 (Lending protocol)
- Circle CCTP (Cross-chain transfers)
- OpenZeppelin (Security & standards)

### Supported Networks
- **Base Sepolia** (Primary testnet)
- **Arc Testnet** (Circle's blockchain)
- Ethereum Mainnet
- Arbitrum One
- Polygon PoS
- Optimism

## 🔒 Security

- ✅ Comprehensive test coverage with Foundry
- ✅ Adapter registry for trusted protocol integrations
- ✅ Risk metrics for each vault (volatility, smart contract risk, depegging risk)
- ✅ Slippage protection on swaps
- ✅ Tested on Base Sepolia before mainnet deployment

**Note**: This is testnet software. Always verify contracts and test thoroughly before mainnet use.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

MIT License - see LICENSE file for details

## 📞 Contact & Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/your-repo/issues)
- **Documentation**: Visit `/docs` on the frontend
- **Contracts**: See [`contracts/DEPLOYED_ADDRESSES.md`](contracts/DEPLOYED_ADDRESSES.md)

---

Built with ❤️ for ETH Argentina Hackathon
