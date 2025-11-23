import type { PrivyClientConfig } from "@privy-io/react-auth";
import { base, mainnet, arbitrum, polygon, optimism } from "viem/chains";
import { arcTestnet, arcTestnetAlt, arcMainnet, baseSepolia } from "./chains";

/**
 * Privy configuration for social login and blockchain support
 * Includes Arc (Circle blockchain) support with viem
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

  // Supported chains - includes Arc (Circle), Base, Ethereum, and other major networks
  supportedChains: [
    baseSepolia,     // Base Sepolia Testnet
    arcTestnet,      // Arc Testnet (Circle blockchain - Caldera)
    arcTestnetAlt,   // Arc Testnet (Alternative deployment)
    arcMainnet,      // Arc Mainnet (Circle blockchain)
    base,            // Base (Coinbase L2)
    mainnet,         // Ethereum Mainnet
    arbitrum,        // Arbitrum One
    polygon,         // Polygon PoS
    optimism,        // Optimism
  ],

  // Default chain for wallet connection
  defaultChain: baseSepolia,
};
