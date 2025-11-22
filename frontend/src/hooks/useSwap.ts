"use client";

import { useState } from "react";
import { useWallets } from "@privy-io/react-auth";
import {
  parseUnits,
  encodeAbiParameters,
  createWalletClient,
  createPublicClient,
  custom,
  http,
  type Address,
  encodeFunctionData,
} from "viem";
import { baseSepolia } from "@/lib/chains";
import {
  CONTRACTS,
  ERC20_ABI,
  SWAP_ROUTER_ABI,
  POOL_CONFIG,
} from "@/lib/contracts";
import { writeContractGasless } from "@/lib/gasless-wallet";

export interface SwapParams {
  tokenIn: Address;
  tokenOut: Address;
  amountIn: string;
  adapterIdentifier: string; // ENS name or adapter address as string
  recipientAddress: Address;
  slippageTolerance?: number;
}

export function useSwap() {
  const { wallets } = useWallets();
  const [isSwapping, setIsSwapping] = useState(false);
  const [txHash, setTxHash] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const executeSwap = async (params: SwapParams) => {
    setIsSwapping(true);
    setError(null);
    setTxHash(null);

    try {
      const wallet = wallets[0];
      if (!wallet) {
        throw new Error("No wallet connected");
      }

      await wallet.switchChain(84532); // Base Sepolia

      const ethereumProvider = await wallet.getEthereumProvider();
      const walletClient = createWalletClient({
        chain: baseSepolia,
        transport: custom(ethereumProvider),
      });

      const publicClient = createPublicClient({
        chain: baseSepolia,
        transport: http(),
      });

      const [userAddress] = await walletClient.getAddresses();

      // Parse amount with 6 decimals (USDC/USDT)
      const amountIn = parseUnits(params.amountIn, 6);
      const slippage = params.slippageTolerance || 1; // 1% default
      const amountOutMin = (amountIn * BigInt(100 - slippage)) / BigInt(100);

      // Determine swap direction
      const zeroForOne =
        params.tokenIn.toLowerCase() === POOL_CONFIG.currency0.toLowerCase();

      // Encode hook data: abi.encode(string adapterIdentifier, string recipientIdentifier)
      // adapterIdentifier is the adapter address as a string
      // recipientIdentifier is the user's wallet address as string
      const hookData = encodeAbiParameters(
        [{ type: "string" }, { type: "string" }],
        [params.adapterIdentifier, params.recipientAddress]
      );

      // Step 1: Check allowance and approve if needed
      const allowance = (await publicClient.readContract({
        address: params.tokenIn,
        abi: ERC20_ABI,
        functionName: "allowance",
        args: [userAddress, CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER as Address],
      })) as bigint;

      console.log("Current allowance:", allowance.toString(), "Required:", amountIn.toString());

      if (allowance < amountIn) {
        console.log("Approving token for unlimited amount (gasless)...");
        const approveTx = await writeContractGasless({
          address: params.tokenIn,
          abi: ERC20_ABI,
          functionName: "approve",
          args: [CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER as Address, BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")],
          account: userAddress,
          chainId: 84532, // Base Sepolia
        });
        console.log("Token approval tx (gasless):", approveTx);

        // Wait for approval transaction to be mined
        console.log("Waiting for approval to be confirmed...");
        await publicClient.waitForTransactionReceipt({ hash: approveTx });
        console.log("Approval confirmed!");
      } else {
        console.log("Sufficient allowance already exists");
      }

      // Step 2: Execute swap
      const deadline = BigInt(Math.floor(Date.now() / 1000) + 60 * 20); // 20 minutes

      console.log("Executing swap (gasless)...", {
        amountIn: amountIn.toString(),
        amountOutMin: amountOutMin.toString(),
        zeroForOne,
        poolKey: POOL_CONFIG,
        hookData,
        receiver: userAddress,
        deadline: deadline.toString(),
      });

      const swapTx = await writeContractGasless({
        address: CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER as Address,
        abi: SWAP_ROUTER_ABI,
        functionName: "swapExactTokensForTokens",
        args: [
          amountIn,
          amountOutMin,
          zeroForOne,
          POOL_CONFIG,
          hookData,
          userAddress,
          deadline,
        ],
        account: userAddress,
        chainId: 84532, // Base Sepolia
      });

      console.log("Swap transaction sent (gasless):", swapTx);
      setTxHash(swapTx);

      return {
        success: true,
        txHash: swapTx,
      };
    } catch (err: any) {
      console.error("Swap error:", err);
      setError(err.message || "Swap failed");
      return {
        success: false,
        error: err.message,
      };
    } finally {
      setIsSwapping(false);
    }
  };

  return {
    executeSwap,
    isSwapping,
    txHash,
    error,
  };
}
