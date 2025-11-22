# CCTP Implementation Guide

## Overview

This implementation enables **Cross-Chain Transfer Protocol (CCTP)** integration for transferring USDC from **Arc blockchain** to **Base blockchain** with optional automatic swap execution upon arrival.

## Architecture

### Smart Contracts

1. **CCTPBridge.sol** - Main bridge contract for Arc and Base
   - Handles USDC burns on source chain
   - Receives USDC mints on destination chain
   - Supports automatic swap execution on destination

2. **Interfaces**
   - `ITokenMessenger.sol` - Circle's TokenMessenger interface
   - `IMessageTransmitter.sol` - Circle's MessageTransmitter interface

### Frontend Components

1. **CrossChainBridge.tsx** - React UI component
   - User-friendly interface for bridging USDC
   - Support for Arc ↔ Base transfers
   - Optional swap parameters

2. **Hooks**
   - `useCCTPBridge.ts` - React hook for CCTP operations
   - Handles wallet integration via Privy
   - Manages bridge and attestation flow

3. **Configuration**
   - `cctp-config.ts` - CCTP contract addresses and domains
   - `attestation.ts` - Circle attestation service integration

## CCTP Flow

### Arc to Base Bridge Flow

```
1. User initiates bridge on Arc
   ↓
2. CCTPBridge calls depositForBurn()
   - Burns USDC on Arc
   - Emits MessageSent event
   ↓
3. Circle's Attestation Service
   - Monitors burn event
   - Waits for finality (~15s testnet)
   - Issues attestation signature
   ↓
4. Frontend fetches attestation
   - Polls Circle's Iris API
   - Gets attestation signature
   ↓
5. User calls receiveMessage() on Base
   - Submits message + attestation
   - MessageTransmitter validates
   - Mints USDC on Base
   ↓
6. Optional: Automatic swap
   - CCTPBridge receives USDC
   - Executes swap via Uniswap V4
   - Sends output tokens to recipient
```

## Contract Addresses

### Arc Testnet (Chain ID: 23244, Domain: 26)

| Contract | Address |
|----------|---------|
| TokenMessenger | `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA` |
| MessageTransmitter | `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275` |
| TokenMinter | `0xb43db544E2c27092c107639Ad201b3dEfAbcF192` |
| USDC | `0x3600000000000000000000000000000000000000` |

### Base Sepolia (Chain ID: 84532, Domain: 6)

| Contract | Address |
|----------|---------|
| TokenMessenger | `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA` |
| MessageTransmitter | `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275` |
| TokenMinter | `0xb43db544E2c27092c107639Ad201b3dEfAbcF192` |
| USDC | `0x036CbD53842c5426634e7929541eC2318f3dCF7e` |

### Base Mainnet (Chain ID: 8453, Domain: 6)

| Contract | Address |
|----------|---------|
| TokenMessenger | `0x1682Ae6375C4E4A97e4B583BC394c861A46D8962` |
| USDC | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |

## Deployment

### 1. Deploy CCTPBridge on Arc Testnet

```bash
cd contracts

# Set your private key
export PRIVATE_KEY=your_private_key_here

# Deploy on Arc Testnet
forge script script/01_DeployCCTPBridge.s.sol:DeployCCTPBridge \
  --rpc-url https://rpc.arc.gateway.fm \
  --broadcast \
  --verify
```

### 2. Deploy CCTPBridge on Base Sepolia

```bash
# Deploy on Base Sepolia
forge script script/01_DeployCCTPBridge.s.sol:DeployCCTPBridge \
  --rpc-url https://sepolia.base.org \
  --broadcast \
  --verify
```

### 3. Link the Bridges

After deploying both contracts, link them:

```bash
# On Arc Testnet bridge
cast send <ARC_BRIDGE_ADDRESS> \
  "setDestinationBridge(address)" \
  <BASE_BRIDGE_ADDRESS> \
  --rpc-url https://rpc.arc.gateway.fm \
  --private-key $PRIVATE_KEY

# On Base Sepolia bridge (optional, for reverse flow)
cast send <BASE_BRIDGE_ADDRESS> \
  "setDestinationBridge(address)" \
  <ARC_BRIDGE_ADDRESS> \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

## Frontend Integration

### Add Bridge Component to Your App

```tsx
// In your page component (e.g., app/bridge/page.tsx)
import CrossChainBridge from "@/components/CrossChainBridge";

export default function BridgePage() {
  return (
    <div className="min-h-screen p-8">
      <CrossChainBridge />
    </div>
  );
}
```

### Usage

1. **Connect Wallet**: User connects via Privy (supports Arc and Base)
2. **Select Chains**: Choose Arc as source, Base as destination
3. **Enter Amount**: Input USDC amount to bridge
4. **Set Recipient**: Enter destination address (can be same or different)
5. **Optional Swap**: Enable automatic swap and configure parameters
6. **Bridge**: Click "Bridge USDC" to initiate
7. **Wait**: Frontend polls for attestation (~15 seconds on testnet)
8. **Complete**: Click "Complete Bridge" to receive USDC on Base

## Testing

### Manual Testing on Testnets

1. **Get Testnet USDC**
   - Arc Testnet: Use Arc faucet
   - Base Sepolia: Use Circle's testnet faucet

2. **Bridge USDC from Arc to Base**

```bash
# 1. Approve USDC on Arc Testnet
cast send 0x3600000000000000000000000000000000000000 \
  "approve(address,uint256)" \
  <ARC_BRIDGE_ADDRESS> \
  1000000 \
  --rpc-url https://rpc.arc.gateway.fm \
  --private-key $PRIVATE_KEY

# 2. Bridge 1 USDC (1000000 = 1 USDC with 6 decimals)
cast send <ARC_BRIDGE_ADDRESS> \
  "bridgeUSDC(uint256,address)" \
  1000000 \
  <YOUR_ADDRESS> \
  --rpc-url https://rpc.arc.gateway.fm \
  --private-key $PRIVATE_KEY
```

3. **Fetch Attestation**

```bash
# Get transaction hash from previous step
TX_HASH=<your_tx_hash>

# Extract message hash from logs (this is simplified - use frontend helper)
# Then fetch attestation from Circle
curl https://iris-api-sandbox.circle.com/v1/attestations/<MESSAGE_HASH>
```

4. **Complete Bridge on Base**

```bash
# Call receiveMessage with message and attestation
cast send <BASE_MESSAGE_TRANSMITTER> \
  "receiveMessage(bytes,bytes)" \
  <MESSAGE_BYTES> \
  <ATTESTATION> \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

### Automated Testing

Create test file `contracts/test/CCTPBridge.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {CCTPBridge} from "../src/CCTPBridge.sol";

contract CCTPBridgeTest is Test {
    CCTPBridge bridge;

    function setUp() public {
        // Deploy with Arc Testnet parameters
        bridge = new CCTPBridge(
            0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA, // tokenMessenger
            0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275, // messageTransmitter
            0x3600000000000000000000000000000000000000, // usdc
            6 // Base Sepolia domain
        );
    }

    function testDeployment() public view {
        assertEq(bridge.destinationDomain(), 6);
    }

    // Add more tests for bridging, receiving, swaps, etc.
}
```

Run tests:

```bash
forge test -vvv
```

## Security Considerations

1. **Access Control**: In production, add `Ownable` or role-based access control
2. **Attestation Validation**: Always verify attestation from Circle's API
3. **Slippage Protection**: Use `minAmountOut` for swaps
4. **Recipient Validation**: Ensure recipient address is valid on destination chain
5. **Amount Validation**: Check for zero amounts and reasonable limits

## API Integration for AI Agents

AI agents can interact with the bridge programmatically:

```typescript
// Example: Bridge USDC from Arc to Base
import { useCCTPBridge } from './lib/hooks/useCCTPBridge';

const { bridgeUSDC } = useCCTPBridge();

await bridgeUSDC({
  amount: "100", // 100 USDC
  destinationChainId: 84532, // Base Sepolia
  recipient: "0xRecipientAddress",
  withSwap: true,
  swapParams: {
    tokenOut: "0xWETH_ADDRESS",
    minAmountOut: "0.05",
    deadline: Math.floor(Date.now() / 1000) + 3600
  }
});
```

## Resources

- [Circle CCTP Documentation](https://developers.circle.com/cctp)
- [Arc Network Documentation](https://docs.arc.network)
- [Base Documentation](https://docs.base.org)
- [CCTP Technical Guide](https://developers.circle.com/cctp/technical-guide)
- [Circle Attestation API](https://developers.circle.com/stablecoins/evm-smart-contracts)

## Support

For issues or questions:
- Open an issue in the GitHub repository
- Check Circle's developer Discord
- Review Arc blockchain documentation

## License

MIT
