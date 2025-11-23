# USDC Bridge Test Script

Test script to bridge USDC from Arc Testnet to Base Sepolia using Circle's CCTP.

## Quick Start

### Prerequisites

1. **Set your private key** in `.env`:
```bash
PRIVATE_KEY=your_private_key_here
```

2. **Get USDC on Arc Testnet**: You need at least 10 USDC
   - USDC Address: `0x3600000000000000000000000000000000000000`
   - Arc Faucet: https://faucet.arc.gelato.digital

## Bridge Flow

### Step 1: Bridge from Arc Testnet

```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --rpc-url https://rpc.arc.gelato.digital \
    --broadcast \
    --legacy \
    -vvv
```

**What this does:**
- Approves the bridge to spend your USDC
- Burns 10 USDC on Arc Testnet via CCTP
- Emits a `MessageSent` event with the message hash
- Shows you the transaction details

**Expected Output:**
```
=================================================
Step 1: Bridging USDC from Arc to Base Sepolia
=================================================
Sender: 0x...
Bridge Contract: 0x2Bd7115Db8FFdcB077C8a146401aBd4A5E982903
Amount: 10 USDC

Current USDC balance: 100 USDC
Approved bridge to spend 10 USDC

=================================================
Bridge Transaction Successful!
=================================================
Nonce: 123456
Recipient on Base Sepolia: 0x...

Message Hash: 0xabcdef...

=================================================
Next Steps:
=================================================
1. Wait ~20 minutes for Circle to generate attestation
2. Get attestation from Circle's API:
   curl https://iris-api-sandbox.circle.com/attestations/0xabcdef...

3. Extract message from transaction logs (see below)
4. Call receiveMessage on Base Sepolia
=================================================
```

### Step 2: Extract Message from Transaction

You need two things:
1. **Message bytes** - from the transaction logs
2. **Attestation** - from Circle's API

#### Get Message Bytes:

Look at your Arc transaction on the explorer and find the `MessageSent` event. The `message` parameter contains the bytes you need.

**Or use cast:**
```bash
cast tx <TX_HASH> --rpc-url https://rpc.arc.gelato.digital | grep -A 20 "MessageSent"
```

### Step 3: Get Attestation from Circle

Wait approximately 20 minutes after your bridge transaction, then:

```bash
curl https://iris-api-sandbox.circle.com/attestations/<MESSAGE_HASH>
```

**Response when ready:**
```json
{
  "status": "complete",
  "attestation": "0x1234567890abcdef..."
}
```

If you get `{"status": "pending_confirmations"}`, wait a bit longer.

### Step 4: Receive USDC on Base Sepolia

Once you have both the message bytes and attestation, call the MessageTransmitter directly:

```bash
cast send 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275 \
    "receiveMessage(bytes,bytes)" \
    <MESSAGE_BYTES> \
    <ATTESTATION> \
    --rpc-url https://sepolia.base.org \
    --private-key $PRIVATE_KEY \
    --legacy
```

**Or use the helper script** (once implemented in the Foundry script):
```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "receiveOnBase(bytes,bytes)" <MESSAGE_BYTES> <ATTESTATION> \
    --rpc-url https://sepolia.base.org \
    --broadcast \
    --legacy
```

### Step 5: Verify Balance

Check your USDC balance on Base Sepolia:

```bash
cast call 0x036CbD53842c5426634e7929541eC2318f3dCF7e \
    "balanceOf(address)(uint256)" \
    <YOUR_ADDRESS> \
    --rpc-url https://sepolia.base.org
```

## Helper Commands

### Check Balances

**Arc Testnet:**
```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBalance()" \
    --rpc-url https://rpc.arc.gelato.digital
```

**Base Sepolia:**
```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBalance()" \
    --rpc-url https://sepolia.base.org
```

### Check Bridge Status

**Arc Bridge:**
```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBridgeStatus()" \
    --rpc-url https://rpc.arc.gelato.digital
```

**Base Bridge:**
```bash
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBridgeStatus()" \
    --rpc-url https://sepolia.base.org
```

## Deployed Contracts

### Arc Testnet (Chain ID: 23244)
- **CCTP Bridge**: `0x2Bd7115Db8FFdcB077C8a146401aBd4A5E982903`
- **USDC**: `0x3600000000000000000000000000000000000000`
- **MessageTransmitter**: `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275`
- **TokenMessenger**: `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA`

### Base Sepolia (Chain ID: 84532)
- **CCTP Bridge**: `0x4c23382b26C3ab153f1479b8be2545AB620eD6F2`
- **USDC**: `0x036CbD53842c5426634e7929541eC2318f3dCF7e`
- **MessageTransmitter**: `0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275`
- **TokenMessenger**: `0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA`

## Configuration

To change the bridge amount, edit `TestCCTPBridge.s.sol`:

```solidity
uint256 constant BRIDGE_AMOUNT = 10_000000; // 10 USDC (6 decimals)
```

## Troubleshooting

**"Insufficient USDC balance"**
- Get testnet USDC from Arc faucet
- Check balance with the helper command above

**"Attestation not ready"**
- Circle attestations take 15-20 minutes
- Keep polling the attestation API

**"Message already received"**
- Each message can only be received once
- Create a new bridge transaction

**"Invalid attestation"**
- Make sure you're using the correct message hash
- Verify the attestation is for the right message

## Full Example

```bash
# 1. Check your balance
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBalance()" \
    --rpc-url https://rpc.arc.gelato.digital

# 2. Bridge from Arc
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --rpc-url https://rpc.arc.gelato.digital \
    --broadcast \
    --legacy \
    -vvv

# Output will show message hash like: 0xabcdef...
# Note the transaction hash

# 3. Extract message from transaction logs
cast tx <TX_HASH> --rpc-url https://rpc.arc.gelato.digital

# 4. Wait 20 minutes, then get attestation
curl https://iris-api-sandbox.circle.com/attestations/0xabcdef...

# 5. Receive on Base Sepolia
cast send 0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275 \
    "receiveMessage(bytes,bytes)" \
    <MESSAGE_BYTES> \
    <ATTESTATION> \
    --rpc-url https://sepolia.base.org \
    --private-key $PRIVATE_KEY \
    --legacy

# 6. Verify balance on Base
forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
    --sig "checkBalance()" \
    --rpc-url https://sepolia.base.org
```

## Resources

- **Circle CCTP Docs**: https://developers.circle.com/stablecoins/docs/cctp-getting-started
- **Attestation API**: https://iris-api-sandbox.circle.com
- **Arc Explorer**: https://arcscan.xyz
- **Base Sepolia Explorer**: https://sepolia.basescan.org
