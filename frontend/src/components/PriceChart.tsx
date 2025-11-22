"use client";

import { useState, useMemo } from "react";

interface CryptoAsset {
  id: number;
  name: string;
  symbol: string;
  price: number;
  change24h: number;
  marketCap: number;
  volume24h: number;
}

interface PriceChartProps {
  selectedCrypto: CryptoAsset | null;
}

export const PriceChart = ({ selectedCrypto }: PriceChartProps) => {
  const [selectedTimeframe, setSelectedTimeframe] = useState("24h");

  const timeframes = ["24h", "7d", "30d", "1y", "All"];

  // Simulated chart data points - different patterns for different cryptos
  const generateChartData = (cryptoId: number) => {
    const points = 50;
    const data = [];
    const seed = cryptoId * 1000; // Use crypto ID to generate consistent but different patterns
    for (let i = 0; i < points; i++) {
      const x = (i / points) * 100;
      const y = 30 + Math.sin((i + seed) * 0.15) * 15 + Math.sin((i + seed) * 0.05) * 8;
      data.push({ x, y });
    }
    return data;
  };

  const chartData = useMemo(
    () => generateChartData(selectedCrypto?.id || 1),
    [selectedCrypto?.id]
  );

  const pathD = chartData
    .map((point, i) => `${i === 0 ? "M" : "L"} ${point.x} ${point.y}`)
    .join(" ");

  if (!selectedCrypto) {
    return (
      <div className="bg-card rounded-lg p-6 border border-border mb-8 transition-colors">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-foreground">Price Chart</h2>
          <div className="flex gap-2">
            {timeframes.map((timeframe) => (
              <button
                key={timeframe}
                disabled
                className="px-3 py-1 rounded-md text-sm font-medium bg-muted text-muted-foreground opacity-50 cursor-not-allowed transition-colors"
              >
                {timeframe}
              </button>
            ))}
          </div>
        </div>
        <div className="relative h-64 w-full bg-muted/30 rounded-lg overflow-hidden flex items-center justify-center">
          <p className="text-muted-foreground text-sm">
            Select a cryptocurrency to view its price chart
          </p>
        </div>
      </div>
    );
  }

  const priceChange = (selectedCrypto.price * selectedCrypto.change24h) / 100;

  return (
    <div className="bg-card rounded-lg p-6 border border-border mb-8 hover:border-primary/50 transition-colors">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-xl font-semibold text-foreground">
            {selectedCrypto.name} Price Chart
          </h2>
          <p className="text-sm text-muted-foreground">{selectedCrypto.symbol}</p>
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

        <div className="absolute bottom-4 left-4 bg-background/80 backdrop-blur-sm rounded-lg p-3 border border-border">
          <p className="text-xs text-muted-foreground">Current Price</p>
          <p className="text-lg font-bold text-foreground">
            ${selectedCrypto.price.toLocaleString()}
          </p>
          <p className={`text-xs font-medium ${
            selectedCrypto.change24h >= 0 ? "text-green-500" : "text-red-500"
          }`}>
            {priceChange >= 0 ? "+" : ""}${Math.abs(priceChange).toFixed(2)} ({selectedCrypto.change24h >= 0 ? "+" : ""}{selectedCrypto.change24h.toFixed(2)}%)
          </p>
        </div>
      </div>
    </div>
  );
};
