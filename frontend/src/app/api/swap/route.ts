import { NextResponse } from "next/server";

export interface SwapRequest {
  vaultId: string;
  amountIn: string; // Amount in USDC (in wei or smallest unit)
  recipient: string; // Address or ENS name
}

export interface SwapResponse {
  success: boolean;
  vaultId: string;
  transactionData: {
    swapDepositorAddress: string;
    adapterEnsName: string;
    hookData: string; // Encoded hookData for Uniswap V4
    instructions: string;
    estimatedGas: string;
    network: string;
  };
  expectedOutput: {
    asset: string;
    apy: number;
    protocol: string;
  };
}

/**
 * POST /api/swap
 *
 * Returns transaction data needed to execute a swap with automatic deposit to a lending protocol.
 * This endpoint helps agents construct the proper transaction to swap USDC and automatically
 * receive yield-bearing tokens (e.g., aUSDC from Aave) in a single transaction.
 *
 * Request body:
 * {
 *   "vaultId": "SV-BASE-001",
 *   "amountIn": "1000000", // Amount in USDC wei (1 USDC = 1000000)
 *   "recipient": "0x..." // Address or ENS name
 * }
 */
export async function POST(request: Request) {
  try {
    const body: SwapRequest = await request.json();

    const { vaultId, amountIn, recipient } = body;

    if (!vaultId || !amountIn || !recipient) {
      return NextResponse.json(
        {
          success: false,
          error: "Missing required fields: vaultId, amountIn, recipient",
        },
        { status: 400 }
      );
    }

    // For now, we'll use the Base USDC adapter as the primary example
    const adapterEnsName = "USDC:BASE_SEPOLIA:word-word.base.eth";
    const swapDepositorAddress = "0xa97800be965c982c381E161124A16f5450C080c4";

    // Encode hookData: abi.encode(adapterEnsName, recipient)
    // In a real implementation, you'd use ethers/viem to encode this
    const hookData = `0x${Buffer.concat([
      Buffer.from(adapterEnsName.padEnd(64, "\0")),
      Buffer.from(recipient.replace("0x", ""), "hex"),
    ]).toString("hex")}`;

    const response: SwapResponse = {
      success: true,
      vaultId,
      transactionData: {
        swapDepositorAddress,
        adapterEnsName,
        hookData,
        instructions: `
1. Approve USDC spending for the Uniswap V4 Pool Manager
2. Call swap() on the Uniswap V4 SwapRouter with:
   - poolKey containing the SwapDepositor hook address
   - swapParams with your desired swap amount
   - hookData: ${hookData}
3. The hook will automatically deposit your swap output to Aave
4. You'll receive aUSDC (Aave interest-bearing tokens) at the recipient address
        `.trim(),
        estimatedGas: "~250,000 gas",
        network: "BASE_SEPOLIA",
      },
      expectedOutput: {
        asset: "aUSDC",
        apy: 4.67,
        protocol: "AAVE V3",
      },
    };

    return NextResponse.json(response);
  } catch (error) {
    return NextResponse.json(
      {
        success: false,
        error: "Invalid request body",
      },
      { status: 400 }
    );
  }
}

/**
 * GET /api/swap
 *
 * Returns general information about the swap functionality.
 */
export async function GET() {
  return NextResponse.json({
    success: true,
    description:
      "Swap USDC and automatically deposit to yield-bearing positions in a single transaction",
    contracts: {
      swapDepositor: "0xa97800be965c982c381E161124A16f5450C080c4",
      adapterRegistry: "0x045B9a7505164B418A309EdCf9A45EB1fE382951",
      poolManager: "0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829",
    },
    network: "BASE_SEPOLIA",
    supportedAssets: ["USDC", "USDT"],
    documentation: "/docs/AGENT_API.md",
  });
}
