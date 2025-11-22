import { NextRequest, NextResponse } from "next/server";
import {
  createWalletClient,
  createPublicClient,
  http,
  type Address,
  type Chain,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { baseSepolia, arcTestnet, arcMainnet } from "@/lib/chains";
import { base } from "viem/chains";

/**
 * Transaction Relayer API
 * This endpoint receives transaction requests from the frontend and
 * submits them on-chain while paying for gas, enabling gasless UX
 */

// Relayer private key from environment variable
const RELAYER_PRIVATE_KEY = process.env.RELAYER_PRIVATE_KEY as `0x${string}`;

if (!RELAYER_PRIVATE_KEY) {
  console.warn("⚠️  RELAYER_PRIVATE_KEY not configured - gasless transactions will not work");
}

// Supported chains for relaying
const SUPPORTED_CHAINS: Record<number, Chain> = {
  84532: baseSepolia,  // Base Sepolia Testnet
  8453: base,          // Base Mainnet
  23244: arcTestnet,   // Arc Testnet
  23241: arcMainnet,   // Arc Mainnet
};

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { chainId, to, data, value = "0x0", userAddress } = body;

    // Validate required fields
    if (!chainId || !to || !data) {
      return NextResponse.json(
        { error: "Missing required fields: chainId, to, data" },
        { status: 400 }
      );
    }

    // Check if chain is supported
    const chain = SUPPORTED_CHAINS[chainId];
    if (!chain) {
      return NextResponse.json(
        { error: `Chain ${chainId} not supported for gasless transactions` },
        { status: 400 }
      );
    }

    // Check if relayer is configured
    if (!RELAYER_PRIVATE_KEY) {
      return NextResponse.json(
        { error: "Relayer not configured on server" },
        { status: 500 }
      );
    }

    // Create relayer account
    const relayerAccount = privateKeyToAccount(RELAYER_PRIVATE_KEY);

    // Create clients
    const publicClient = createPublicClient({
      chain,
      transport: http(),
    });

    const walletClient = createWalletClient({
      account: relayerAccount,
      chain,
      transport: http(),
    });

    // Estimate gas to ensure transaction will succeed
    try {
      await publicClient.estimateGas({
        account: relayerAccount.address,
        to: to as Address,
        data: data as `0x${string}`,
        value: BigInt(value),
      });
    } catch (error: any) {
      console.error("Gas estimation failed:", error);
      return NextResponse.json(
        { error: "Transaction would fail", details: error.message },
        { status: 400 }
      );
    }

    // Send transaction
    const txHash = await walletClient.sendTransaction({
      to: to as Address,
      data: data as `0x${string}`,
      value: BigInt(value),
    });

    console.log(`✅ Relayed transaction for user ${userAddress}: ${txHash}`);

    // Wait for confirmation
    const receipt = await publicClient.waitForTransactionReceipt({
      hash: txHash,
      confirmations: 1,
    });

    return NextResponse.json({
      success: true,
      txHash,
      blockNumber: receipt.blockNumber.toString(),
      gasUsed: receipt.gasUsed.toString(),
    });
  } catch (error: any) {
    console.error("Relay error:", error);
    return NextResponse.json(
      { error: "Failed to relay transaction", details: error.message },
      { status: 500 }
    );
  }
}

// Health check endpoint
export async function GET() {
  const isConfigured = !!RELAYER_PRIVATE_KEY;

  return NextResponse.json({
    status: "online",
    relayerConfigured: isConfigured,
    supportedChains: Object.keys(SUPPORTED_CHAINS).map(Number),
  });
}
