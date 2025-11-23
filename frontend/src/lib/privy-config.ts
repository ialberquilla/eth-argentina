import type { PrivyClientConfig } from "@privy-io/react-auth";
import { base, mainnet, arbitrum, polygon, optimism } from "viem/chains";
import { baseSepolia } from "./chains";

/**
 * Privy configuration for social login and blockchain support
 * Note: Arc chains removed as they're not supported by Coinbase Smart Wallet
 */
export const privyConfig: PrivyClientConfig = {
  // Appearance customization
  appearance: {
    theme: "dark",
    accentColor: "#10b981",
    logo: undefined,
  },

  // Embedded wallet configuration
  embeddedWallets: {
    ethereum: {
      createOnLogin: "users-without-wallets",
    },
  },

  // Login methods - all social login options enabled
  loginMethods: [
    "email",
    "wallet",
    "google",
    "twitter",
    "discord",
    "github",
    "apple",
    "linkedin",
    "tiktok",
  ],

  // Supported chains - only chains supported by Coinbase Smart Wallet
  supportedChains: [
    baseSepolia,     // Base Sepolia Testnet
    base,            // Base (Coinbase L2)
    mainnet,         // Ethereum Mainnet
    arbitrum,        // Arbitrum One
    polygon,         // Polygon PoS
    optimism,        // Optimism
  ],

  // Default chain for wallet connection
  defaultChain: baseSepolia,
};
