import { NextResponse } from "next/server";

export interface AdapterInfo {
  symbol: string;
  network: string;
  protocol: string;
  adapterAddress: string;
  ensName: string;
  tokenAddress: string;
  aavePoolAddress: string;
}

const adapters: AdapterInfo[] = [
  {
    symbol: "USDC",
    network: "BASE_SEPOLIA",
    protocol: "AAVE_V3",
    adapterAddress: "0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF",
    ensName: "USDC:BASE_SEPOLIA:word-word.base.eth",
    tokenAddress: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f",
    aavePoolAddress: "0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951",
  },
  {
    symbol: "USDT",
    network: "BASE_SEPOLIA",
    protocol: "AAVE_V3",
    adapterAddress: "0x5531bc190eC0C74dC8694176Ad849277AbA21a5D",
    ensName: "USDT:BASE_SEPOLIA:word-word.base.eth",
    tokenAddress: "0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a",
    aavePoolAddress: "0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951",
  },
];

/**
 * GET /api/registry
 *
 * Returns information about registered adapters in the AdapterRegistry.
 * These adapters enable automatic deposit of swap outputs to lending protocols.
 *
 * Query parameters:
 * - symbol: Filter by token symbol (e.g., "USDC")
 * - network: Filter by network (e.g., "BASE_SEPOLIA")
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);

  const symbol = searchParams.get("symbol");
  const network = searchParams.get("network");

  let filteredAdapters = [...adapters];

  if (symbol) {
    filteredAdapters = filteredAdapters.filter(
      (a) => a.symbol.toLowerCase() === symbol.toLowerCase()
    );
  }

  if (network) {
    filteredAdapters = filteredAdapters.filter(
      (a) => a.network.toLowerCase() === network.toLowerCase()
    );
  }

  return NextResponse.json({
    success: true,
    registryAddress: "0x045B9a7505164B418A309EdCf9A45EB1fE382951",
    network: "BASE_SEPOLIA",
    count: filteredAdapters.length,
    adapters: filteredAdapters,
    usage: {
      resolveAdapter: "Call adapterRegistry.resolveAdapter(ensName) to get adapter address",
      swapWithDeposit: "Include ensName in hookData when calling swap to auto-deposit to lending protocol",
    },
  });
}
