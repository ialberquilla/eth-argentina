/**
 * CCTP (Cross-Chain Transfer Protocol) Configuration
 * Contract addresses and domain IDs for Circle's CCTP on Arc and Base
 */

export interface CCTPConfig {
  tokenMessenger: string;
  messageTransmitter: string;
  tokenMinter: string;
  usdc: string;
  domain: number;
}

export interface CCTPChainConfig {
  [chainId: number]: CCTPConfig;
}

/**
 * CCTP V2 Contract Addresses and Domain IDs
 * Source: https://developers.circle.com/stablecoins/evm-smart-contracts
 */
export const CCTP_CONFIG: CCTPChainConfig = {
  // Arc Testnet (Chain ID: 23244, Domain: 26)
  23244: {
    tokenMessenger: "0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA",
    messageTransmitter: "0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275",
    tokenMinter: "0xb43db544E2c27092c107639Ad201b3dEfAbcF192",
    usdc: "0x3600000000000000000000000000000000000000", // Native USDC on Arc
    domain: 26,
  },

  // Arc Testnet (Chain ID: 5042002, Domain: 26) - Alternative testnet
  5042002: {
    tokenMessenger: "0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA",
    messageTransmitter: "0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275",
    tokenMinter: "0xb43db544E2c27092c107639Ad201b3dEfAbcF192",
    usdc: "0x3600000000000000000000000000000000000000", // Native USDC on Arc
    domain: 26,
  },

  // Arc Mainnet (Chain ID: 23241, Domain: TBD - Update when available)
  23241: {
    tokenMessenger: "0x0000000000000000000000000000000000000000", // Update when available
    messageTransmitter: "0x0000000000000000000000000000000000000000",
    tokenMinter: "0x0000000000000000000000000000000000000000",
    usdc: "0x0000000000000000000000000000000000000000",
    domain: 0, // Update when available
  },

  // Base Sepolia Testnet (Chain ID: 84532, Domain: 6)
  84532: {
    tokenMessenger: "0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA",
    messageTransmitter: "0xE737e5cEBEEBa77EFE34D4aa090756590b1CE275",
    tokenMinter: "0xb43db544E2c27092c107639Ad201b3dEfAbcF192",
    usdc: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
    domain: 6,
  },

  // Base Mainnet (Chain ID: 8453, Domain: 6)
  8453: {
    tokenMessenger: "0x1682Ae6375C4E4A97e4B583BC394c861A46D8962",
    messageTransmitter: "0x0000000000000000000000000000000000000000", // Update when available
    tokenMinter: "0x0000000000000000000000000000000000000000",
    usdc: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", // Native USDC on Base
    domain: 6,
  },
};

/**
 * Circle Attestation API endpoints
 */
export const ATTESTATION_API = {
  testnet: "https://iris-api-sandbox.circle.com",
  mainnet: "https://iris-api.circle.com",
} as const;

/**
 * Get CCTP config for a specific chain
 */
export function getCCTPConfig(chainId: number): CCTPConfig | undefined {
  return CCTP_CONFIG[chainId];
}

/**
 * Get attestation API URL based on chain ID
 */
export function getAttestationAPI(chainId: number): string {
  // Testnet chain IDs: Arc Testnet (23244, 5042002), Base Sepolia (84532)
  const isTestnet = chainId === 23244 || chainId === 5042002 || chainId === 84532;
  return isTestnet ? ATTESTATION_API.testnet : ATTESTATION_API.mainnet;
}

/**
 * Check if CCTP is supported on a chain
 */
export function isCCTPSupported(chainId: number): boolean {
  return chainId in CCTP_CONFIG;
}

/**
 * Get domain ID for a chain
 */
export function getDomainId(chainId: number): number {
  const config = getCCTPConfig(chainId);
  return config?.domain ?? 0;
}
