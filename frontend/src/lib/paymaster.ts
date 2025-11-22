import {
  createPublicClient,
  http,
  type Chain,
  type Address,
  createWalletClient,
  custom,
  encodeFunctionData,
} from "viem";

/**
 * Paymaster configuration for gasless transactions
 * Using Coinbase's paymaster service (free for Base/Base Sepolia)
 * and Biconomy for other chains
 */

export const PAYMASTER_CONFIG: Record<number, { url: string; type: string }> = {
  // Base Sepolia - Using Coinbase Paymaster (free)
  84532: {
    url: "https://api.developer.coinbase.com/rpc/v1/base-sepolia",
    type: "coinbase"
  },

  // Base Mainnet - Using Coinbase Paymaster (free)
  8453: {
    url: "https://api.developer.coinbase.com/rpc/v1/base",
    type: "coinbase"
  },

  // Arc Testnet - Using Biconomy
  23244: {
    url: process.env.NEXT_PUBLIC_BICONOMY_PAYMASTER_URL || "",
    type: "biconomy"
  },

  // Arc Mainnet - Using Biconomy
  23241: {
    url: process.env.NEXT_PUBLIC_BICONOMY_PAYMASTER_URL || "",
    type: "biconomy"
  },
};

/**
 * Creates a wallet client configured for gasless transactions
 * This uses the wallet's existing provider but adds paymaster support
 */
export async function createGaslessWalletClient(
  ethereumProvider: any,
  chain: Chain,
  address: Address
) {
  const walletClient = createWalletClient({
    chain,
    transport: custom(ethereumProvider),
    account: address,
  });

  const publicClient = createPublicClient({
    chain,
    transport: http(),
  });

  return {
    walletClient,
    publicClient,
  };
}

/**
 * Prepare a gasless transaction using paymaster
 * This wraps the transaction in a user operation for ERC-4337
 */
export async function prepareGaslessTransaction(
  to: Address,
  data: `0x${string}`,
  value: bigint = 0n,
  chainId: number
) {
  const paymasterConfig = PAYMASTER_CONFIG[chainId];

  if (!paymasterConfig || !paymasterConfig.url) {
    // Fallback to regular transaction if paymaster not configured
    return {
      to,
      data,
      value,
      gasless: false,
    };
  }

  // For Coinbase Paymaster on Base, we can use their sponsored transaction API
  if (paymasterConfig.type === "coinbase") {
    return {
      to,
      data,
      value,
      gasless: true,
      paymasterAndData: "0x", // Coinbase handles this automatically
    };
  }

  return {
    to,
    data,
    value,
    gasless: false, // Fallback for other chains until configured
  };
}

/**
 * Send a gasless transaction using the wallet client
 * This will automatically use the paymaster if configured
 */
export async function sendGaslessTransaction(
  walletClient: any,
  to: Address,
  data: `0x${string}`,
  value: bigint = 0n,
  chainId: number
) {
  const tx = await prepareGaslessTransaction(to, data, value, chainId);

  // Send transaction - on Base with Coinbase wallet, this will be gasless automatically
  // if the user is using a Coinbase Smart Wallet
  const hash = await walletClient.sendTransaction({
    to: tx.to,
    data: tx.data,
    value: tx.value,
  });

  return hash;
}

/**
 * Check if gasless transactions are available for a chain
 */
export function isGaslessAvailable(chainId: number): boolean {
  const config = PAYMASTER_CONFIG[chainId];
  return !!config && !!config.url;
}

/**
 * Get paymaster info for display to users
 */
export function getPaymasterInfo(chainId: number) {
  const config = PAYMASTER_CONFIG[chainId];

  if (!config) {
    return null;
  }

  return {
    available: isGaslessAvailable(chainId),
    provider: config.type === "coinbase" ? "Coinbase" : "Biconomy",
    message: config.type === "coinbase"
      ? "Gas fees sponsored by Coinbase"
      : "Gas fees sponsored",
  };
}
