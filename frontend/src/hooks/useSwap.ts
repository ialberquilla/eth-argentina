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
} from "viem";
import { baseSepolia } from "@/lib/chains";
import {
  CONTRACTS,
  ERC20_ABI,
  SWAP_ROUTER_ABI,
  POOL_CONFIG,
} from "@/lib/contracts";

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
        transport: http("https://sepolia.base.org"),
      });

      const [userAddress] = await walletClient.getAddresses();

      // Parse amount with 6 decimals (USDC/USDT)
      const amountIn = parseUnits(params.amountIn, 6);
      // Set amountOutMin to 0 to disable slippage protection (like the working Solidity script)
      // TODO: Calculate proper amountOutMin based on pool price
      const amountOutMin = BigInt(0);

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

      console.log("Hook data parameters:", {
        adapterIdentifier: params.adapterIdentifier,
        recipientIdentifier: params.recipientAddress,
      });

      // Step 1: Check allowance and approve if needed
      const allowance = (await publicClient.readContract({
        address: params.tokenIn,
        abi: ERC20_ABI,
        functionName: "allowance",
        args: [userAddress, CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER as Address],
      })) as bigint;

      console.log("Current allowance:", allowance.toString(), "Required:", amountIn.toString());

      if (allowance < amountIn) {
        console.log("Approving token for unlimited amount...");
        const approveTx = await walletClient.writeContract({
          address: params.tokenIn,
          abi: ERC20_ABI,
          functionName: "approve",
          args: [CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER as Address, BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")],
          account: userAddress,
          chain: baseSepolia,
        });
        console.log("Token approval tx:", approveTx);

        // Wait for approval transaction to be mined
        console.log("Waiting for approval to be confirmed...");
        await publicClient.waitForTransactionReceipt({ hash: approveTx });
        console.log("Approval confirmed!");
      } else {
        console.log("Sufficient allowance already exists");
      }

      // Step 2: Execute swap
      const deadline = BigInt(Math.floor(Date.now() / 1000) + 60 * 20); // 20 minutes

      console.log("Executing swap...", {
        amountIn: amountIn.toString(),
        amountOutMin: amountOutMin.toString(),
        zeroForOne,
        poolKey: POOL_CONFIG,
        hookData,
        receiver: userAddress,
        deadline: deadline.toString(),
      });

      console.log("Swap parameters breakdown:", {
        swapRouter: CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER,
        amountIn: amountIn.toString(),
        amountOutMin: amountOutMin.toString(),
        zeroForOne,
        "poolKey.currency0": POOL_CONFIG.currency0,
        "poolKey.currency1": POOL_CONFIG.currency1,
        "poolKey.fee": POOL_CONFIG.fee,
        "poolKey.tickSpacing": POOL_CONFIG.tickSpacing,
        "poolKey.hooks": POOL_CONFIG.hooks,
        receiver: userAddress,
        deadline: deadline.toString(),
      });

      try {
        // Estimate gas for the swap transaction
        const gasEstimate = await publicClient.estimateContractGas({
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
        });

        // Add 20% buffer to gas estimate
        const gasLimit = (gasEstimate * BigInt(120)) / BigInt(100);

        console.log("Gas estimate:", gasEstimate.toString(), "Gas limit:", gasLimit.toString());

        const swapTx = await walletClient.writeContract({
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
          chain: baseSepolia,
          gas: gasLimit,
        });

        console.log("Swap transaction sent:", swapTx);
        setTxHash(swapTx);

        return {
          success: true,
          txHash: swapTx,
        };
      } catch (swapError: any) {
        console.error("Swap writeContract error:", swapError);
        console.error("Error details:", {
          message: swapError.message,
          code: swapError.code,
          data: swapError.data,
          cause: swapError.cause,
          metaMessages: swapError.metaMessages,
          shortMessage: swapError.shortMessage,
          details: swapError.details,
        });
        throw swapError;
      }
    } catch (err: any) {
      console.error("Swap error:", err);
      console.error("Full error object:", JSON.stringify(err, null, 2));
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
