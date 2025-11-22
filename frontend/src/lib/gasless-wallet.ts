import { encodeFunctionData, type Address, type Hash } from "viem";

/**
 * Gasless transaction client using backend relayer
 * Transactions are sent through a relayer that pays for gas
 */

export interface RelayTransactionParams {
  to: Address;
  data: `0x${string}`;
  value?: bigint;
  chainId: number;
  userAddress: Address;
}

export interface RelayResponse {
  success: boolean;
  txHash: Hash;
  blockNumber?: string;
  gasUsed?: string;
  error?: string;
}

/**
 * Send a gasless transaction through the relayer API
 * The relayer pays for gas, making the transaction free for users
 */
export async function sendGaslessTransaction(
  params: RelayTransactionParams
): Promise<RelayResponse> {
  try {
    const response = await fetch("/api/relay", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        chainId: params.chainId,
        to: params.to,
        data: params.data,
        value: params.value?.toString() || "0x0",
        userAddress: params.userAddress,
      }),
    });

    const result = await response.json();

    if (!response.ok) {
      throw new Error(result.error || "Relayer request failed");
    }

    return result;
  } catch (error: any) {
    console.error("Gasless transaction failed:", error);
    return {
      success: false,
      txHash: "0x" as Hash,
      error: error.message,
    };
  }
}

/**
 * Write a contract function call using gasless transactions
 */
export async function writeContractGasless(
  params: {
    address: Address;
    abi: any;
    functionName: string;
    args?: any[];
    account: Address;
    chainId: number;
  }
): Promise<Hash> {
  // Encode function data
  const data = encodeFunctionData({
    abi: params.abi,
    functionName: params.functionName,
    args: params.args || [],
  });

  // Send through relayer
  const result = await sendGaslessTransaction({
    to: params.address,
    data,
    value: 0n,
    chainId: params.chainId,
    userAddress: params.account,
  });

  if (!result.success) {
    throw new Error(result.error || "Gasless transaction failed");
  }

  return result.txHash;
}

/**
 * Check if gasless transactions are available
 */
export async function isGaslessAvailable(): Promise<boolean> {
  try {
    const response = await fetch("/api/relay");
    const result = await response.json();
    return result.relayerConfigured;
  } catch (error) {
    console.error("Failed to check gasless availability:", error);
    return false;
  }
}

/**
 * Get user-friendly message about gas sponsorship
 */
export function getGasMessage(isGasless: boolean): string {
  if (isGasless) {
    return "✨ Gas fees are sponsored - you pay nothing!";
  }
  return "Standard transaction (you pay gas fees)";
}
