This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Features

- **Privy Social Login**: Connect with email, Google, Twitter, Discord, GitHub, Apple, LinkedIn, TikTok, and wallet
- **Arc Blockchain Support**: Full integration with Circle's Arc blockchain (testnet and mainnet)
- **viem Integration**: Latest viem version for blockchain interactions
- **Multi-chain Support**: Arc, Base, Ethereum, Arbitrum, Polygon, and Optimism
- **Agent Integration**: Documentation and examples for AI agents to interact directly with smart contracts

## Getting Started

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Privy

1. Go to [Privy Dashboard](https://dashboard.privy.io/) and create an account
2. Create a new app and copy your App ID
3. Create a `.env.local` file in the frontend directory:

```bash
cp .env.local.example .env.local
```

4. Add your Privy App ID to `.env.local`:

```env
NEXT_PUBLIC_PRIVY_APP_ID=your_actual_privy_app_id
```

### 3. Run the Development Server

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Privy Social Login Configuration

This app supports multiple social login methods through Privy:

- Email
- Wallet (MetaMask, WalletConnect, etc.)
- Google
- Twitter
- Discord
- GitHub
- Apple
- LinkedIn
- TikTok

Users can connect using any of these methods, and Privy will create an embedded wallet for them automatically.

## Arc Blockchain (Circle)

The app is configured to support Circle's Arc blockchain:

- **Arc Testnet** (Chain ID: 23244)
  - RPC: https://arc-testnet.rpc.caldera.xyz/http
  - Explorer: https://arc-testnet.calderaexplorer.xyz

- **Arc Mainnet** (Chain ID: 23241)
  - RPC: https://arc.rpc.caldera.xyz/http
  - Explorer: https://arc.calderaexplorer.xyz

The default chain is set to Arc Testnet. You can modify this in `src/lib/privy-config.ts`.

## Additional Supported Networks

- Base (Coinbase L2)
- Ethereum Mainnet
- Arbitrum One
- Polygon PoS
- Optimism

## Agent Integration

This platform enables AI agents with wallets to discover and invest in DeFi yield products through direct smart contract interaction.

### How Agents Use This Platform

Agents interact directly with smart contracts to:
- **Discover** products by querying the AdapterRegistry contract
- **Check APYs** by querying lending protocols (Aave, Compound, etc.)
- **Execute** swaps that automatically deposit to yield positions in one transaction
- **Hold only USDC** - the platform handles all conversions and deposits

### Quick Start for AI Agents

```javascript
import { createPublicClient, http } from 'viem';
import { baseSepolia } from 'viem/chains';

// 1. Query AdapterRegistry to discover available products
const adapter = await client.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  abi: registryABI,
  functionName: 'resolveAdapter',
  args: ['USDC:BASE_SEPOLIA:word-word.base.eth']
});

// 2. Query Aave to get current APY
const reserveData = await client.readContract({
  address: '0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951',
  abi: aavePoolABI,
  functionName: 'getReserveData',
  args: ['0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f'] // USDC
});

// 3. Execute swap with auto-deposit using hookData
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'address' }],
  ['USDC:BASE_SEPOLIA:word-word.base.eth', recipientAddress]
);
// Call swap on Uniswap V4 with this hookData
```

### Architecture

The platform uses a Uniswap V4 hook architecture:

- **AdapterRegistry** (`0x045B9a7505164B418A309EdCf9A45EB1fE382951`): Query to discover available lending adapters
- **SwapDepositor Hook** (`0xa97800be965c982c381E161124A16f5450C080c4`): Automatically intercepts swap outputs and deposits to lending protocols
- **Lending Adapters**: Protocol-specific adapters for Aave, Compound, etc.

When an agent calls swap with hookData:
1. Uniswap V4 executes the swap
2. SwapDepositor hook intercepts the output tokens
3. Hook resolves the adapter from the registry using the ENS name
4. Adapter deposits tokens to the lending protocol
5. Agent receives yield-bearing tokens (e.g., aUSDC)

All in one transaction.

### Documentation

For complete integration guide with code examples:
- **[Agent Integration Guide](docs/AGENT_GUIDE.md)** - Complete guide with viem, ethers.js, and web3.py examples
- **[Contract Documentation](../contracts/README.md)** - Smart contract details
- **[Deployed Addresses](../contracts/DEPLOYED_ADDRESSES.md)** - Contract addresses and ABIs

### Example: Complete Agent Workflow

```javascript
// 1. Discover available adapters
const adapters = [
  { asset: 'USDC', ensName: 'USDC:BASE_SEPOLIA:word-word.base.eth' },
  { asset: 'USDT', ensName: 'USDT:BASE_SEPOLIA:word-word.base.eth' }
];

// 2. Query APY for each
for (const adapter of adapters) {
  const data = await getReserveData(adapter);
  adapter.apy = calculateAPY(data.liquidityRate);
}

// 3. Select best APY
const best = adapters.sort((a, b) => b.apy - a.apy)[0];

// 4. Execute swap with auto-deposit
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'address' }],
  [best.ensName, myAddress]
);
await swap(poolKey, swapParams, hookData);
// Done! You now hold yield-bearing tokens
```
