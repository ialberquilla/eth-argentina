# Gasless Transactions Setup Guide

This guide explains how to set up and use gasless transactions in the ETH Argentina frontend application.

## Overview

The application now supports **completely gasless transactions** for users. All transaction costs are paid by a backend relayer service, providing a seamless user experience where users never need to worry about gas fees.

## How It Works

1. **User initiates transaction**: User triggers a swap or bridge operation through the UI
2. **Transaction encoding**: Frontend encodes the transaction data
3. **Relayer submission**: Transaction is sent to `/api/relay` endpoint
4. **Gas sponsorship**: Backend relayer signs and submits the transaction, paying for gas
5. **Confirmation**: Transaction hash is returned to the frontend for tracking

## Supported Operations

✅ **Token Approvals** (ERC20 approve)
✅ **Token Swaps** (Uniswap V4 on Base Sepolia)
✅ **CCTP Bridge Initiation** (depositForBurn)
✅ **CCTP Bridge Completion** (receiveMessage)

## Supported Chains

- **Base Sepolia (84532)** - Testnet ✅
- **Base Mainnet (8453)** - Production ✅
- **Arc Testnet (23244)** - Coming soon
- **Arc Mainnet (23241)** - Coming soon

## Setup Instructions

### 1. Generate Relayer Wallet

Create a new wallet specifically for the relayer:

```bash
# Using Node.js (in the frontend directory)
node -e "const { generatePrivateKey } = require('viem/accounts'); console.log(generatePrivateKey())"
```

Or use any wallet generation tool. **IMPORTANT**: This should be a NEW wallet used ONLY for relaying.

### 2. Fund the Relayer Wallet

The relayer needs native tokens to pay for gas:

**For Base Sepolia (Testing):**
- Get the wallet address from your private key
- Request free testnet ETH from: https://faucet.quicknode.com/base/sepolia
- Recommended: ~0.1 ETH for testing

**For Base Mainnet (Production):**
- Fund with real ETH
- Recommended: Start with 0.05-0.1 ETH
- Monitor and refill as needed

### 3. Configure Environment Variables

Create `/frontend/.env.local`:

```env
# Privy App ID (required)
NEXT_PUBLIC_PRIVY_APP_ID=your_privy_app_id

# Relayer Private Key (required for gasless transactions)
RELAYER_PRIVATE_KEY=0x1234... # Your generated private key

# Optional: Biconomy for Arc chain support
NEXT_PUBLIC_BICONOMY_PAYMASTER_URL=https://...
```

### 4. Security Considerations

⚠️ **IMPORTANT SECURITY NOTES:**

1. **Never commit private keys to git**
   - `.env.local` is gitignored by default
   - Use environment variables in production (Vercel, etc.)

2. **Use separate wallets**
   - Relayer wallet should be ONLY for relaying
   - Don't use personal wallets as relayers

3. **Monitor relayer balance**
   - Set up alerts when balance drops below threshold
   - Implement rate limiting to prevent abuse

4. **Production hardening** (recommended):
   - Add authentication to `/api/relay` endpoint
   - Implement user verification (e.g., Privy session tokens)
   - Add transaction value limits
   - Set up gas price caps
   - Implement daily spending limits per user

### 5. Deployment

**Local Development:**
```bash
cd frontend
npm install
npm run dev
```

**Vercel/Production:**
1. Deploy to Vercel
2. Add environment variables in Vercel dashboard:
   - `NEXT_PUBLIC_PRIVY_APP_ID`
   - `RELAYER_PRIVATE_KEY`
3. Redeploy

## Testing Gasless Transactions

1. **Check relayer status:**
   ```bash
   curl http://localhost:3000/api/relay
   ```

   Expected response:
   ```json
   {
     "status": "online",
     "relayerConfigured": true,
     "supportedChains": [84532, 8453]
   }
   ```

2. **Test a swap:**
   - Connect wallet via Privy
   - Navigate to a vault
   - Click "Swap"
   - Enter amount and execute
   - **Notice**: No MetaMask popup for gas approval!

3. **Monitor relayer transactions:**
   - Check wallet address on Base Sepolia explorer
   - View transaction history
   - Monitor gas consumption

## Cost Estimation

Typical gas costs on Base Sepolia:

| Operation | Gas Used | Cost (ETH) @ 0.001 Gwei |
|-----------|----------|-------------------------|
| ERC20 Approve | ~46,000 | ~0.000046 ETH |
| Swap | ~180,000 | ~0.00018 ETH |
| CCTP Deposit | ~100,000 | ~0.0001 ETH |
| CCTP Receive | ~80,000 | ~0.00008 ETH |

**Monthly estimate** (1000 users, 5 transactions each):
- Testnet: ~0.2 ETH
- Mainnet Base: ~$20-50 (depending on gas prices)

## Rate Limiting (TODO)

To prevent abuse, consider adding rate limiting:

```typescript
// Example: Upstash Rate Limit
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, "1 h"), // 10 requests per hour per user
});
```

## Monitoring & Alerts

Set up monitoring for:
- ✅ Relayer wallet balance (alert when < 0.01 ETH)
- ✅ Failed transactions rate
- ✅ Gas price spikes
- ✅ Daily spending totals
- ✅ Unusual transaction patterns

**Recommended tools:**
- Alchemy/Infura webhooks for transaction monitoring
- Tenderly for real-time alerts
- Grafana for metrics dashboard

## Upgrading to ERC-4337 (Future)

For more advanced features, consider upgrading to full ERC-4337 Account Abstraction:

Benefits:
- Batch transactions
- Session keys
- Social recovery
- More flexible gas policies

Providers:
- Alchemy Account Kit
- Biconomy
- Pimlico

## Troubleshooting

**Problem: "Relayer not configured on server"**
- Solution: Ensure `RELAYER_PRIVATE_KEY` is set in environment variables
- Check: `console.log(!!process.env.RELAYER_PRIVATE_KEY)`

**Problem: "Transaction would fail"**
- Solution: Ensure relayer wallet has sufficient native tokens
- Solution: Check contract addresses are correct for the chain

**Problem: "Chain not supported"**
- Solution: Add chain to `SUPPORTED_CHAINS` in `/api/relay/route.ts`

**Problem: High gas costs**
- Solution: Implement rate limiting
- Solution: Add user authentication
- Solution: Set gas price caps

## API Reference

### POST /api/relay

Submit a transaction for gasless execution.

**Request:**
```json
{
  "chainId": 84532,
  "to": "0x...",
  "data": "0x...",
  "value": "0x0",
  "userAddress": "0x..."
}
```

**Response (Success):**
```json
{
  "success": true,
  "txHash": "0x...",
  "blockNumber": "12345",
  "gasUsed": "180000"
}
```

**Response (Error):**
```json
{
  "error": "Transaction would fail",
  "details": "insufficient funds"
}
```

### GET /api/relay

Health check endpoint.

**Response:**
```json
{
  "status": "online",
  "relayerConfigured": true,
  "supportedChains": [84532, 8453]
}
```

## Support

For issues or questions:
1. Check this guide first
2. Review error logs
3. Open an issue on GitHub
4. Contact the development team

---

**Built with ❤️ for ETH Argentina**
