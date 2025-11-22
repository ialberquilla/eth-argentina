"use client";

import { useState } from "react";

export interface YieldProduct {
  asset: string;
  id: string;
  protocol: string;
  chain: string;
  stablecoin: string;
  apy: string;
  tvl: string;
  riskLevel: string;
  volatility: string;
  total24hVol: string;
  bestLeverage: string;
  bestFixedAPY: string;
  depegRisk: string;
}

const mockYieldData: YieldProduct[] = [
  {
    asset: "USDC",
    id: "SV-BASE-001",
    protocol: "AAVE V3",
    chain: "Base",
    stablecoin: "USDC",
    apy: "4.67%",
    tvl: "$1.2B",
    riskLevel: "Low",
    volatility: "0.01%",
    total24hVol: "$45.2M",
    bestLeverage: "1.0x",
    bestFixedAPY: "4.67%",
    depegRisk: "Low",
  },
  {
    asset: "USDC",
    id: "SV-ETH-002",
    protocol: "Morpho Blue",
    chain: "Ethereum",
    stablecoin: "USDC",
    apy: "8.50%",
    tvl: "$650M",
    riskLevel: "Medium",
    volatility: "0.02%",
    total24hVol: "$28.5M",
    bestLeverage: "3.5x",
    bestFixedAPY: "8.50%",
    depegRisk: "Low",
  },
  {
    asset: "USDT",
    id: "SV-ARB-003",
    protocol: "Compound V3",
    chain: "Arbitrum",
    stablecoin: "USDT",
    apy: "3.80%",
    tvl: "$890M",
    riskLevel: "Low",
    volatility: "0.02%",
    total24hVol: "$38.7M",
    bestLeverage: "1.0x",
    bestFixedAPY: "3.80%",
    depegRisk: "Low",
  },
  {
    asset: "USDC/USDT/DAI",
    id: "SV-POL-005",
    protocol: "Curve 3Pool",
    chain: "Polygon",
    stablecoin: "USDC/USDT/DAI",
    apy: "3.20%",
    tvl: "$1.8B",
    riskLevel: "Low",
    volatility: "0.02%",
    total24hVol: "$125.8M",
    bestLeverage: "1.0x",
    bestFixedAPY: "3.20%",
    depegRisk: "Medium",
  },
  {
    asset: "sDAI",
    id: "SV-ETH-006",
    protocol: "Spark Protocol",
    chain: "Ethereum",
    stablecoin: "DAI → sDAI",
    apy: "4.50%",
    tvl: "$2.7B",
    riskLevel: "Low",
    volatility: "0.01%",
    total24hVol: "$18.9M",
    bestLeverage: "1.0x",
    bestFixedAPY: "4.50%",
    depegRisk: "Low",
  },
  {
    asset: "USDC",
    id: "SV-OPT-007",
    protocol: "Yearn Finance",
    chain: "Optimism",
    stablecoin: "USDC",
    apy: "6.10%",
    tvl: "$315M",
    riskLevel: "Medium",
    volatility: "0.03%",
    total24hVol: "$8.4M",
    bestLeverage: "1.5x",
    bestFixedAPY: "6.10%",
    depegRisk: "Low",
  },
  {
    asset: "DAI",
    id: "SV-ARB-008",
    protocol: "AAVE V3",
    chain: "Arbitrum",
    stablecoin: "DAI",
    apy: "4.20%",
    tvl: "$820M",
    riskLevel: "Low",
    volatility: "0.02%",
    total24hVol: "$31.2M",
    bestLeverage: "1.0x",
    bestFixedAPY: "4.20%",
    depegRisk: "Medium",
  },
  {
    asset: "USDC/USDT",
    id: "SV-ETH-009",
    protocol: "Ether.fi Cash",
    chain: "Ethereum",
    stablecoin: "USDC/USDT",
    apy: "10.20%",
    tvl: "$425M",
    riskLevel: "Medium-High",
    volatility: "0.05%",
    total24hVol: "$12.7M",
    bestLeverage: "2.2x",
    bestFixedAPY: "10.20%",
    depegRisk: "Low",
  },
  {
    asset: "USDC",
    id: "SV-BASE-010",
    protocol: "Morpho Blue",
    chain: "Base",
    stablecoin: "USDC",
    apy: "7.80%",
    tvl: "$580M",
    riskLevel: "Medium",
    volatility: "0.02%",
    total24hVol: "$24.6M",
    bestLeverage: "2.9x",
    bestFixedAPY: "7.80%",
    depegRisk: "Low",
  },
];

interface CryptoTableProps {
  onProductSelect?: (product: YieldProduct) => void;
}

export const CryptoTable = ({ onProductSelect }: CryptoTableProps) => {
  const [products] = useState<YieldProduct[]>(mockYieldData);
  const [selectedProductId, setSelectedProductId] = useState<string | null>(null);

  const handleRowClick = (product: YieldProduct) => {
    setSelectedProductId(product.id);
    if (onProductSelect) {
      onProductSelect(product);
    }
  };

  const getRiskColor = (riskLevel: string) => {
    if (riskLevel.toLowerCase().includes("low")) return "text-green-500";
    if (riskLevel.toLowerCase().includes("high")) return "text-red-500";
    return "text-yellow-500";
  };

  return (
    <div className="bg-card rounded-lg border border-border overflow-hidden">
      <div className="p-6 border-b border-border">
        <h2 className="text-xl font-semibold text-foreground">Yield Products</h2>
        <p className="text-sm text-muted-foreground mt-1">Click on a product to view details</p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Asset</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">ID</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Protocol</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Chain</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Stablecoin</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">APY</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">TVL</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Risk Level</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">Volatility</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">24h Vol</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">Leverage</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Depeg Risk</th>
            </tr>
          </thead>
          <tbody>
            {products.map((product) => (
              <tr
                key={product.id}
                onClick={() => handleRowClick(product)}
                className={`border-t border-border hover:bg-primary/10 transition-colors cursor-pointer ${
                  selectedProductId === product.id ? "bg-primary/20" : ""
                }`}
              >
                <td className="p-4">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                      <span className="text-xs font-bold text-primary">
                        {product.asset.charAt(0)}
                      </span>
                    </div>
                    <span className="font-medium text-foreground">{product.asset}</span>
                  </div>
                </td>
                <td className="p-4 text-sm text-muted-foreground">{product.id}</td>
                <td className="p-4 text-sm text-foreground">{product.protocol}</td>
                <td className="p-4 text-sm text-muted-foreground">{product.chain}</td>
                <td className="p-4 text-sm text-muted-foreground">{product.stablecoin}</td>
                <td className="p-4 text-right font-medium text-green-500">{product.apy}</td>
                <td className="p-4 text-right text-muted-foreground">{product.tvl}</td>
                <td className="p-4 text-sm">
                  <span className={`font-medium ${getRiskColor(product.riskLevel)}`}>
                    {product.riskLevel}
                  </span>
                </td>
                <td className="p-4 text-right text-sm text-muted-foreground">{product.volatility}</td>
                <td className="p-4 text-right text-sm text-muted-foreground">{product.total24hVol}</td>
                <td className="p-4 text-right text-sm font-medium text-primary">{product.bestLeverage}</td>
                <td className="p-4 text-sm">
                  <span className={`font-medium ${getRiskColor(product.depegRisk)}`}>
                    {product.depegRisk}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
