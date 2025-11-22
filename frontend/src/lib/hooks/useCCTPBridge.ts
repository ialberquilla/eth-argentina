"use client";

import { useState } from "react";
import {
  useWallets,
  usePrivy,
} from "@privy-io/react-auth";
import {
  createWalletClient,
  custom,
  parseUnits,
  formatUnits,
  Hash,
  keccak256,
  encodeAbiParameters,
  parseAbiParameters,
} from "viem";
import { getCCTPConfig, getDomainId } from "../cctp-config";
import { getAttestation } from "../attestation";
import { writeContractGasless } from "../gasless-wallet";

// CCTP TokenMessenger ABI (depositForBurn and depositForBurnWithCaller)
const TOKEN_MESSENGER_ABI = [
  {
    inputs: [
      { name: "amount", type: "uint256" },
      { name: "destinationDomain", type: "uint32" },
      { name: "mintRecipient", type: "bytes32" },
      { name: "burnToken", type: "address" },
    ],
    name: "depositForBurn",
    outputs: [{ name: "nonce", type: "uint64" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { name: "amount", type: "uint256" },
      { name: "destinationDomain", type: "uint32" },
      { name: "mintRecipient", type: "bytes32" },
      { name: "burnToken", type: "address" },
      { name: "destinationCaller", type: "bytes32" },
    ],
    name: "depositForBurnWithCaller",
    outputs: [{ name: "nonce", type: "uint64" }],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

// CCTP MessageTransmitter ABI (receiveMessage)
const MESSAGE_TRANSMITTER_ABI = [
  {
    inputs: [
      { name: "message", type: "bytes" },
      { name: "attestation", type: "bytes" },
    ],
    name: "receiveMessage",
    outputs: [{ name: "success", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    anonymous: false,
    inputs: [
      { indexed: false, name: "message", type: "bytes" },
    ],
    name: "MessageSent",
    type: "event",
  },
] as const;

// ERC20 USDC ABI
const USDC_ABI = [
  {
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    name: "approve",
    outputs: [{ name: "", type: "bool" }],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { name: "account", type: "address" },
    ],
    name: "balanceOf",
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
    ],
    name: "allowance",
    outputs: [{ name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
] as const;

export interface BridgeParams {
  amount: string; // Amount in USDC (e.g., "100" for 100 USDC)
  destinationChainId: number;
  recipient: string;
  withSwap?: boolean;
  swapParams?: {
    tokenOut: string;
    minAmountOut: string;
    deadline: number;
  };
}

export interface BridgeResult {
  txHash: Hash;
  nonce: bigint;
  messageHash?: string;
}

export function useCCTPBridge() {
  const { wallets } = useWallets();
  const { authenticated } = usePrivy();
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [bridgeStatus, setBridgeStatus] = useState<string>("");

  /**
   * Bridge USDC from Arc to Base (or other supported chains)
   */
  const bridgeUSDC = async (params: BridgeParams): Promise<BridgeResult | null> => {
    if (!authenticated || wallets.length === 0) {
      setError("Please connect your wallet");
      return null;
    }

    try {
      setIsLoading(true);
      setError(null);
      setBridgeStatus("Initializing bridge...");

      const wallet = wallets[0];
      const provider = await wallet.getEthereumProvider();
      const walletClient = createWalletClient({
        account: wallet.address as `0x${string}`,
        transport: custom(provider),
      });

      // Get current chain ID
      const chainId = await provider.request({ method: "eth_chainId" }) as string;
      const sourceChainId = parseInt(chainId, 16);

      // Get CCTP config for source and destination chains
      const sourceConfig = getCCTPConfig(sourceChainId);
      const destConfig = getCCTPConfig(params.destinationChainId);

      if (!sourceConfig) {
        throw new Error(`CCTP not supported on source chain ${sourceChainId}`);
      }

      if (!destConfig) {
        throw new Error(`CCTP not supported on destination chain ${params.destinationChainId}`);
      }

      const destinationDomain = getDomainId(params.destinationChainId);
      const amount = parseUnits(params.amount, 6); // USDC has 6 decimals

      setBridgeStatus("Checking USDC allowance...");

      // Check and approve USDC if needed
      const allowance = await provider.request({
        method: "eth_call",
        params: [
          {
            to: sourceConfig.usdc,
            data: encodeAbiParameters(
              parseAbiParameters("address,address"),
              [wallet.address as `0x${string}`, sourceConfig.tokenMessenger as `0x${string}`]
            ),
          },
        ],
      }) as bigint;

      if (allowance < amount) {
        setBridgeStatus("Approving USDC (gasless)...");
        const approveTx = await writeContractGasless({
          address: sourceConfig.usdc as `0x${string}`,
          abi: USDC_ABI,
          functionName: "approve",
          args: [sourceConfig.tokenMessenger as `0x${string}`, amount],
          account: wallet.address as `0x${string}`,
          chainId: sourceChainId,
        });

        setBridgeStatus("Waiting for approval confirmation...");
        // Wait for approval transaction
        await provider.request({
          method: "eth_getTransactionReceipt",
          params: [approveTx],
        });
      }

      setBridgeStatus("Initiating CCTP bridge...");

      // Convert recipient address to bytes32
      const mintRecipient = `0x${params.recipient.slice(2).padStart(64, "0")}` as `0x${string}`;

      // Call depositForBurn (gasless)
      const txHash = await writeContractGasless({
        address: sourceConfig.tokenMessenger as `0x${string}`,
        abi: TOKEN_MESSENGER_ABI,
        functionName: "depositForBurn",
        args: [
          amount,
          destinationDomain,
          mintRecipient,
          sourceConfig.usdc as `0x${string}`,
        ],
        account: wallet.address as `0x${string}`,
        chainId: sourceChainId,
      });

      setBridgeStatus("Waiting for transaction confirmation...");

      // Get transaction receipt
      const receipt = await provider.request({
        method: "eth_getTransactionReceipt",
        params: [txHash],
      }) as any;

      // Extract message hash from logs
      let messageHash: string | undefined;
      if (receipt.logs) {
        // Find MessageSent event in logs
        const messageSentLog = receipt.logs.find((log: any) =>
          log.address.toLowerCase() === sourceConfig.messageTransmitter.toLowerCase()
        );

        if (messageSentLog) {
          // The message is in the log data
          messageHash = keccak256(messageSentLog.data as `0x${string}`);
        }
      }

      setBridgeStatus("Bridge initiated successfully!");
      setIsLoading(false);

      return {
        txHash,
        nonce: BigInt(0), // Would need to parse from receipt
        messageHash,
      };
    } catch (err: any) {
      console.error("Bridge error:", err);
      setError(err.message || "Failed to bridge USDC");
      setBridgeStatus("");
      setIsLoading(false);
      return null;
    }
  };

  /**
   * Complete the bridge on destination chain by submitting attestation
   */
  const completeBridge = async (
    messageHash: string,
    sourceChainId: number,
    destinationChainId: number
  ): Promise<Hash | null> => {
    if (!authenticated || wallets.length === 0) {
      setError("Please connect your wallet");
      return null;
    }

    try {
      setIsLoading(true);
      setError(null);
      setBridgeStatus("Fetching attestation from Circle...");

      // Get attestation from Circle's API
      const attestation = await getAttestation(messageHash, sourceChainId);

      setBridgeStatus("Switching to destination chain...");

      const wallet = wallets[0];
      const provider = await wallet.getEthereumProvider();

      // Switch to destination chain
      await provider.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: `0x${destinationChainId.toString(16)}` }],
      });

      const walletClient = createWalletClient({
        account: wallet.address as `0x${string}`,
        transport: custom(provider),
      });

      const destConfig = getCCTPConfig(destinationChainId);
      if (!destConfig) {
        throw new Error(`CCTP not supported on destination chain ${destinationChainId}`);
      }

      setBridgeStatus("Completing bridge on destination chain (gasless)...");

      // Call receiveMessage on destination chain (gasless)
      const txHash = await writeContractGasless({
        address: destConfig.messageTransmitter as `0x${string}`,
        abi: MESSAGE_TRANSMITTER_ABI,
        functionName: "receiveMessage",
        args: [messageHash as `0x${string}`, attestation as `0x${string}`],
        account: wallet.address as `0x${string}`,
        chainId: destinationChainId,
      });

      setBridgeStatus("Bridge completed successfully!");
      setIsLoading(false);

      return txHash;
    } catch (err: any) {
      console.error("Complete bridge error:", err);
      setError(err.message || "Failed to complete bridge");
      setBridgeStatus("");
      setIsLoading(false);
      return null;
    }
  };

  return {
    bridgeUSDC,
    completeBridge,
    isLoading,
    error,
    bridgeStatus,
  };
}
