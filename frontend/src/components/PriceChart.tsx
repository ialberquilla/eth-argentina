"use client";

import { useState, useEffect } from "react";
import { YieldProduct } from "./CryptoTable";

interface PriceChartProps {
  selectedProduct?: YieldProduct;
}

export const PriceChart = ({ selectedProduct }: PriceChartProps) => {
  const [selectedTimeframe, setSelectedTimeframe] = useState("24h");
  const [chartData, setChartData] = useState<{ x: number; y: number }[]>([]);

  const timeframes = ["24h", "7d", "30d", "1y", "All"];

  // Generate chart data based on selected product
  useEffect(() => {
    if (!selectedProduct) {
      // Default chart when no product is selected
      const defaultData = generateChartData(4.5, 0.5);
      setChartData(defaultData);
      return;
    }

    // Extract APY value and generate trend based on volatility
    const apyValue = parseFloat(selectedProduct.apy.replace("%", ""));
    const volatilityValue = parseFloat(selectedProduct.volatility.replace("%", ""));

    const data = generateChartData(apyValue, volatilityValue);
    setChartData(data);
  }, [selectedProduct, selectedTimeframe]);

  // Generate chart data points with some variation
  const generateChartData = (baseAPY: number, volatility: number) => {
    const points = 50;
    const data = [];

    for (let i = 0; i < points; i++) {
      const x = (i / points) * 100;
      // Create a trend line with some noise based on volatility
      const noise = (Math.sin(i * 0.3) + Math.random() - 0.5) * volatility * 100;
      const y = 50 - ((baseAPY + noise) / 20) * 40; // Invert Y axis for SVG
      data.push({ x, y: Math.max(10, Math.min(90, y)) });
    }

    return data;
  };

  const pathD = chartData
    .map((point, i) => `${i === 0 ? "M" : "L"} ${point.x} ${point.y}`)
    .join(" ");

  const parseValue = (value: string) => {
    return value.replace(/[$,%]/g, "");
  };

  return (
    <div className="bg-card rounded-lg p-6 border border-border mb-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-xl font-semibold text-foreground">
            {selectedProduct ? `${selectedProduct.protocol} - ${selectedProduct.asset}` : "Yield Performance"}
          </h2>
          {selectedProduct && (
            <p className="text-sm text-muted-foreground mt-1">
              {selectedProduct.chain} • {selectedProduct.stablecoin}
            </p>
          )}
        </div>
        <div className="flex gap-2">
          {timeframes.map((timeframe) => (
            <button
              key={timeframe}
              onClick={() => setSelectedTimeframe(timeframe)}
              className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
                selectedTimeframe === timeframe
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted text-muted-foreground hover:bg-muted/80"
              }`}
            >
              {timeframe}
            </button>
          ))}
        </div>
      </div>

      {selectedProduct ? (
        <>
          {/* Metrics Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            <div className="bg-muted/30 rounded-lg p-4">
              <p className="text-xs text-muted-foreground mb-1">APY</p>
              <p className="text-2xl font-bold text-green-500">{selectedProduct.apy}</p>
            </div>
            <div className="bg-muted/30 rounded-lg p-4">
              <p className="text-xs text-muted-foreground mb-1">TVL</p>
              <p className="text-2xl font-bold text-foreground">{selectedProduct.tvl}</p>
            </div>
            <div className="bg-muted/30 rounded-lg p-4">
              <p className="text-xs text-muted-foreground mb-1">24h Volume</p>
              <p className="text-2xl font-bold text-foreground">{selectedProduct.total24hVol}</p>
            </div>
            <div className="bg-muted/30 rounded-lg p-4">
              <p className="text-xs text-muted-foreground mb-1">Leverage</p>
              <p className="text-2xl font-bold text-primary">{selectedProduct.bestLeverage}</p>
            </div>
          </div>

          {/* Chart */}
          <div className="relative h-64 w-full bg-muted/30 rounded-lg overflow-hidden">
            <svg
              viewBox="0 0 100 100"
              preserveAspectRatio="none"
              className="w-full h-full"
            >
              <defs>
                <linearGradient id="chartGradient" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stopColor="hsl(var(--primary))" stopOpacity="0.3" />
                  <stop offset="100%" stopColor="hsl(var(--primary))" stopOpacity="0" />
                </linearGradient>
              </defs>

              <path
                d={`${pathD} L 100 100 L 0 100 Z`}
                fill="url(#chartGradient)"
              />

              <path
                d={pathD}
                fill="none"
                stroke="hsl(var(--primary))"
                strokeWidth="0.5"
                vectorEffect="non-scaling-stroke"
              />
            </svg>

            <div className="absolute top-4 right-4 bg-background/80 backdrop-blur-sm rounded-lg p-3 border border-border">
              <p className="text-xs text-muted-foreground">Volatility</p>
              <p className="text-lg font-bold text-foreground">{selectedProduct.volatility}</p>
            </div>

            <div className="absolute bottom-4 left-4 bg-background/80 backdrop-blur-sm rounded-lg p-3 border border-border">
              <p className="text-xs text-muted-foreground">Risk Level</p>
              <p className={`text-sm font-bold ${
                selectedProduct.riskLevel.toLowerCase().includes("low") ? "text-green-500" :
                selectedProduct.riskLevel.toLowerCase().includes("high") ? "text-red-500" :
                "text-yellow-500"
              }`}>
                {selectedProduct.riskLevel}
              </p>
              <p className="text-xs text-muted-foreground mt-1">Depeg: {selectedProduct.depegRisk}</p>
            </div>
          </div>

          {/* Additional Info */}
          <div className="mt-4 p-4 bg-muted/20 rounded-lg">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-muted-foreground">Product ID:</span>
                <span className="ml-2 font-medium text-foreground">{selectedProduct.id}</span>
              </div>
              <div>
                <span className="text-muted-foreground">Fixed APY:</span>
                <span className="ml-2 font-medium text-foreground">{selectedProduct.bestFixedAPY}</span>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="flex items-center justify-center h-64 bg-muted/30 rounded-lg">
          <div className="text-center">
            <p className="text-muted-foreground text-lg mb-2">No Product Selected</p>
            <p className="text-sm text-muted-foreground">Click on a product in the table below to view its details</p>
          </div>
        </div>
      )}
    </div>
  );
};
