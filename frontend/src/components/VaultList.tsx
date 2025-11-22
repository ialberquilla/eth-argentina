"use client";

import { VaultCard, Vault } from "./VaultCard";

const mockVaults: Vault[] = [
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
    avatarColor: "bg-blue-600",
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
    avatarColor: "bg-purple-600",
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
    avatarColor: "bg-green-600",
  },
];

export const VaultList = () => {
  return (
    <div className="bg-card rounded-lg border border-border overflow-hidden">
      {mockVaults.map((vault) => (
        <VaultCard key={vault.id} vault={vault} />
      ))}
    </div>
  );
};
