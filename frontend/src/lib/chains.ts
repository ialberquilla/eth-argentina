import { defineChain } from "viem";

/**
 * Arc Testnet - Circle's blockchain testnet
 * https://docs.circle.com/circle-developer-controlled-wallets/arc-testnet
 */
export const arcTestnet = defineChain({
  id: 23244,
  name: "Arc Testnet",
  nativeCurrency: {
    name: "Ether",
    symbol: "ETH",
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ["https://arc-testnet.rpc.caldera.xyz/http"],
    },
  },
  blockExplorers: {
    default: {
      name: "Arc Testnet Explorer",
      url: "https://arc-testnet.calderaexplorer.xyz",
    },
  },
  testnet: true,
});

/**
 * Arc Mainnet - Circle's blockchain mainnet
 * https://docs.circle.com/circle-developer-controlled-wallets/arc-mainnet
 */
export const arcMainnet = defineChain({
  id: 23241,
  name: "Arc",
  nativeCurrency: {
    name: "Ether",
    symbol: "ETH",
    decimals: 18,
  },
  rpcUrls: {
    default: {
      http: ["https://arc.rpc.caldera.xyz/http"],
    },
  },
  blockExplorers: {
    default: {
      name: "Arc Explorer",
      url: "https://arc.calderaexplorer.xyz",
    },
  },
  testnet: false,
});
