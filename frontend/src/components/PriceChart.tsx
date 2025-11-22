"use client";

import { useState } from "react";

export const PriceChart = () => {
  const [selectedTimeframe, setSelectedTimeframe] = useState("24h");

  const timeframes = ["24h", "7d", "30d", "1y", "All"];

  // Simulated chart data points
  const generateChartData = () => {
    const points = 50;
    const data = [];
    for (let i = 0; i < points; i++) {
      const x = (i / points) * 100;
      const y = 30 + Math.sin(i * 0.2) * 15 + Math.random() * 10;
      data.push({ x, y });
    }
    return data;
  };

  const chartData = generateChartData();
  const pathD = chartData
    .map((point, i) => `${i === 0 ? "M" : "L"} ${point.x} ${point.y}`)
    .join(" ");

  return (
    <div className="bg-card rounded-lg p-6 border border-border mb-8">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-semibold text-foreground">Price Chart</h2>
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
          <p className="text-lg font-bold text-foreground">$43,250.75</p>
          <p className="text-xs text-green-500">+$1,045.23 (2.45%)</p>
        </div>
      </div>
    </div>
  );
};
