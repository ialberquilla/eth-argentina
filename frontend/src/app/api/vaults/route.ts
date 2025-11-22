import { NextResponse } from "next/server";

export interface Vault {
  id: string;
  name: string;
  protocol: string;
  network: string;
  asset: string;
  apy: number;
  tvl: string;
  riskLevel: "Low" | "Medium" | "High";
  volatility: number;
  total24hVol: string;
  bestLeverage: string;
  bestFixedApy: number;
  depeggingRisk: "Low" | "Medium" | "High";
  currentApy: number;
  yieldStability: number;
  lockupPeriod: string;
  gasCost: string;
  capitalUtilization: number;
  currentCapacity: string;
  maxCapacity: string;
  exploitHistory: string;
  timeSinceLaunch: string;
  smartContractRiskScore: number;
  // Agent-specific fields
  swapDepositorAddress?: string;
  adapterAddress?: string;
  adapterEnsName?: string;
}

const vaults: Vault[] = [
  {
    id: "SV-BASE-001",
    name: "SV-BASE-001",
    protocol: "AAVE V3 IDE",
    network: "Base",
    asset: "USDC",
    apy: 4.67,
    tvl: "$1.2B",
    riskLevel: "Low",
    volatility: 0.01,
    total24hVol: "$45.2M",
    bestLeverage: "1.0x",
    bestFixedApy: 4.67,
    depeggingRisk: "Low",
    currentApy: 4.67,
    yieldStability: 0.01,
    lockupPeriod: "None",
    gasCost: "$0.15 USDC",
    capitalUtilization: 87,
    currentCapacity: "$1.2B",
    maxCapacity: "$1.8B",
    exploitHistory: "None",
    timeSinceLaunch: "18 months",
    smartContractRiskScore: 92,
    // Agent integration
    swapDepositorAddress: "0xa97800be965c982c381E161124A16f5450C080c4",
    adapterAddress: "0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF",
    adapterEnsName: "USDC:BASE_SEPOLIA:word-word.base.eth",
  },
  {
    id: "SV-ETH-002",
    name: "SV-ETH-002",
    protocol: "Morpho Blue",
    network: "Ethereum",
    asset: "USDC",
    apy: 8.5,
    tvl: "$650M",
    riskLevel: "Medium",
    volatility: 0.02,
    total24hVol: "$28.5M",
    bestLeverage: "3.5x",
    bestFixedApy: 8.5,
    depeggingRisk: "Low",
    currentApy: 8.5,
    yieldStability: 0.02,
    lockupPeriod: "None",
    gasCost: "$2.50 USDC",
    capitalUtilization: 78,
    currentCapacity: "$650M",
    maxCapacity: "$1.0B",
    exploitHistory: "None",
    timeSinceLaunch: "14 months",
    smartContractRiskScore: 88,
  },
  {
    id: "SV-ARB-003",
    name: "SV-ARB-003",
    protocol: "Compound V3",
    network: "Arbitrum",
    asset: "USDT",
    apy: 3.8,
    tvl: "$890M",
    riskLevel: "Low",
    volatility: 0.02,
    total24hVol: "$38.7M",
    bestLeverage: "1.0x",
    bestFixedApy: 3.8,
    depeggingRisk: "Low",
    currentApy: 3.8,
    yieldStability: 0.015,
    lockupPeriod: "None",
    gasCost: "$0.08 USDC",
    capitalUtilization: 65,
    currentCapacity: "$890M",
    maxCapacity: "$1.5B",
    exploitHistory: "None",
    timeSinceLaunch: "22 months",
    smartContractRiskScore: 95,
  },
  {
    id: "SV-POL-005",
    name: "SV-POL-005",
    protocol: "Curve 3Pool",
    network: "Polygon",
    asset: "USDC/USDT/DAI",
    apy: 3.2,
    tvl: "$1.8B",
    riskLevel: "Low",
    volatility: 0.02,
    total24hVol: "$125.8M",
    bestLeverage: "1.0x",
    bestFixedApy: 3.2,
    depeggingRisk: "Medium",
    currentApy: 3.2,
    yieldStability: 0.015,
    lockupPeriod: "None",
    gasCost: "$0.05 USDC",
    capitalUtilization: 72,
    currentCapacity: "$1.8B",
    maxCapacity: "$2.5B",
    exploitHistory: "None",
    timeSinceLaunch: "36 months",
    smartContractRiskScore: 93,
  },
  {
    id: "SV-ETH-006",
    name: "SV-ETH-006",
    protocol: "Spark Protocol",
    network: "Ethereum",
    asset: "DAI → sDAI",
    apy: 4.5,
    tvl: "$2.7B",
    riskLevel: "Low",
    volatility: 0.01,
    total24hVol: "$18.9M",
    bestLeverage: "1.0x",
    bestFixedApy: 4.5,
    depeggingRisk: "Low",
    currentApy: 4.5,
    yieldStability: 0.01,
    lockupPeriod: "None",
    gasCost: "$2.80 USDC",
    capitalUtilization: 68,
    currentCapacity: "$2.7B",
    maxCapacity: "$4.0B",
    exploitHistory: "None",
    timeSinceLaunch: "16 months",
    smartContractRiskScore: 91,
  },
  {
    id: "SV-OPT-007",
    name: "SV-OPT-007",
    protocol: "Yearn Finance",
    network: "Optimism",
    asset: "USDC",
    apy: 6.1,
    tvl: "$315M",
    riskLevel: "Medium",
    volatility: 0.03,
    total24hVol: "$8.4M",
    bestLeverage: "1.5x",
    bestFixedApy: 6.1,
    depeggingRisk: "Low",
    currentApy: 6.1,
    yieldStability: 0.025,
    lockupPeriod: "None",
    gasCost: "$0.12 USDC",
    capitalUtilization: 81,
    currentCapacity: "$315M",
    maxCapacity: "$500M",
    exploitHistory: "None",
    timeSinceLaunch: "24 months",
    smartContractRiskScore: 87,
  },
  {
    id: "SV-ARB-008",
    name: "SV-ARB-008",
    protocol: "AAVE V3",
    network: "Arbitrum",
    asset: "DAI",
    apy: 4.2,
    tvl: "$820M",
    riskLevel: "Low",
    volatility: 0.02,
    total24hVol: "$31.2M",
    bestLeverage: "1.0x",
    bestFixedApy: 4.2,
    depeggingRisk: "Medium",
    currentApy: 4.2,
    yieldStability: 0.018,
    lockupPeriod: "None",
    gasCost: "$0.09 USDC",
    capitalUtilization: 76,
    currentCapacity: "$820M",
    maxCapacity: "$1.2B",
    exploitHistory: "None",
    timeSinceLaunch: "20 months",
    smartContractRiskScore: 94,
  },
  {
    id: "SV-ETH-009",
    name: "SV-ETH-009",
    protocol: "Ether.fi Cash",
    network: "Ethereum",
    asset: "USDC/USDT",
    apy: 10.2,
    tvl: "$425M",
    riskLevel: "Medium",
    volatility: 0.05,
    total24hVol: "$12.7M",
    bestLeverage: "2.2x",
    bestFixedApy: 10.2,
    depeggingRisk: "Low",
    currentApy: 10.2,
    yieldStability: 0.045,
    lockupPeriod: "7 days",
    gasCost: "$3.20 USDC",
    capitalUtilization: 85,
    currentCapacity: "$425M",
    maxCapacity: "$600M",
    exploitHistory: "None",
    timeSinceLaunch: "8 months",
    smartContractRiskScore: 82,
  },
  {
    id: "SV-BASE-010",
    name: "SV-BASE-010",
    protocol: "Morpho Blue",
    network: "Base",
    asset: "USDC",
    apy: 7.8,
    tvl: "$580M",
    riskLevel: "Medium",
    volatility: 0.02,
    total24hVol: "$24.6M",
    bestLeverage: "2.9x",
    bestFixedApy: 7.8,
    depeggingRisk: "Low",
    currentApy: 7.8,
    yieldStability: 0.022,
    lockupPeriod: "None",
    gasCost: "$0.18 USDC",
    capitalUtilization: 79,
    currentCapacity: "$580M",
    maxCapacity: "$850M",
    exploitHistory: "None",
    timeSinceLaunch: "12 months",
    smartContractRiskScore: 86,
  },
];

/**
 * GET /api/vaults
 *
 * Returns a list of available yield vaults/products.
 * Supports filtering by network, asset, and minimum APY.
 *
 * Query parameters:
 * - network: Filter by blockchain network (e.g., "Base", "Ethereum")
 * - asset: Filter by asset (e.g., "USDC", "USDT")
 * - minApy: Filter by minimum APY (number)
 * - riskLevel: Filter by risk level ("Low", "Medium", "High")
 */
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);

  const network = searchParams.get("network");
  const asset = searchParams.get("asset");
  const minApy = searchParams.get("minApy");
  const riskLevel = searchParams.get("riskLevel");

  let filteredVaults = [...vaults];

  if (network) {
    filteredVaults = filteredVaults.filter(
      (v) => v.network.toLowerCase() === network.toLowerCase()
    );
  }

  if (asset) {
    filteredVaults = filteredVaults.filter((v) =>
      v.asset.toLowerCase().includes(asset.toLowerCase())
    );
  }

  if (minApy) {
    const minApyNum = parseFloat(minApy);
    filteredVaults = filteredVaults.filter((v) => v.apy >= minApyNum);
  }

  if (riskLevel) {
    filteredVaults = filteredVaults.filter(
      (v) => v.riskLevel.toLowerCase() === riskLevel.toLowerCase()
    );
  }

  return NextResponse.json({
    success: true,
    count: filteredVaults.length,
    vaults: filteredVaults,
  });
}
