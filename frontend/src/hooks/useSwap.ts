"use client";

import { useState } from "react";
import { useWallets } from "@privy-io/react-auth";
import { parseUnits, type Address } from "viem";
import { ethers } from "ethers";
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
  adapterAddress: Address;
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

      const provider = await wallet.getEthersProvider();
      const signer = provider.getSigner();
      const userAddress = await signer.getAddress();

      // Parse amount with 6 decimals (USDC/USDT)
      const amountIn = parseUnits(params.amountIn, 6);
      const slippage = params.slippageTolerance || 1; // 1% default
      const amountOutMin = (amountIn * BigInt(100 - slippage)) / BigInt(100);

      // Determine swap direction
      const zeroForOne =
        params.tokenIn.toLowerCase() === POOL_CONFIG.currency0.toLowerCase();

      // Encode hook data: abi.encode(string adapterAddress, string recipientAddress)
      const abiCoder = ethers.AbiCoder.defaultAbiCoder();
      const hookData = abiCoder.encode(
        ["string", "string"],
        [params.adapterAddress, params.recipientAddress]
      );

      // Step 1: Approve token
      const tokenContract = new ethers.Contract(
        params.tokenIn,
        ERC20_ABI,
        signer
      );

      const allowance = await tokenContract.allowance(
        userAddress,
        CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER
      );

      if (allowance < amountIn) {
        console.log("Approving token...");
        const approveTx = await tokenContract.approve(
          CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER,
          amountIn
        );
        await approveTx.wait();
        console.log("Token approved");
      }

      // Step 2: Execute swap
      const swapRouter = new ethers.Contract(
        CONTRACTS.BASE_SEPOLIA.SWAP_ROUTER,
        SWAP_ROUTER_ABI,
        signer
      );

      const deadline = Math.floor(Date.now() / 1000) + 60 * 20; // 20 minutes

      console.log("Executing swap...", {
        amountIn: amountIn.toString(),
        amountOutMin: amountOutMin.toString(),
        zeroForOne,
        poolKey: POOL_CONFIG,
        hookData,
        receiver: userAddress,
        deadline,
      });

      const swapTx = await swapRouter.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        zeroForOne,
        POOL_CONFIG,
        hookData,
        userAddress,
        deadline
      );

      console.log("Swap transaction sent:", swapTx.hash);
      setTxHash(swapTx.hash);

      const receipt = await swapTx.wait();
      console.log("Swap completed:", receipt);

      return {
        success: true,
        txHash: swapTx.hash,
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
