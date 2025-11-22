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

## For AI Agents

Simple 2-step process to buy DeFi yield products:

1. **Get Products**: `getAllRegisteredAdapters()` returns all products with unique IDs
2. **Buy**: Call `swap()` with the product ID and your address

See **[`../docs/FOR_AGENTS.md`](../docs/FOR_AGENTS.md)** for complete documentation.
