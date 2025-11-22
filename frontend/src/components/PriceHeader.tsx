"use client";

import { useState, useEffect } from "react";

export const PriceHeader = () => {
  const [btcPrice, setBtcPrice] = useState<number | null>(null);
  const [ethPrice, setEthPrice] = useState<number | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulated price data - replace with actual API call
    setBtcPrice(43250.75);
    setEthPrice(2280.45);
    setLoading(false);
  }, []);

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        <div className="bg-card rounded-lg p-6 border border-border animate-pulse">
          <div className="h-4 bg-muted rounded w-20 mb-2"></div>
          <div className="h-8 bg-muted rounded w-32"></div>
        </div>
        <div className="bg-card rounded-lg p-6 border border-border animate-pulse">
          <div className="h-4 bg-muted rounded w-20 mb-2"></div>
          <div className="h-8 bg-muted rounded w-32"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
      <div className="bg-card rounded-lg p-6 border border-border hover:border-primary/50 transition-colors">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground mb-1">Bitcoin (BTC)</p>
            <p className="text-2xl font-bold text-foreground">
              ${btcPrice?.toLocaleString()}
            </p>
          </div>
          <div className="text-green-500 text-sm font-medium">
            +2.45%
          </div>
        </div>
      </div>

      <div className="bg-card rounded-lg p-6 border border-border hover:border-primary/50 transition-colors">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-muted-foreground mb-1">Ethereum (ETH)</p>
            <p className="text-2xl font-bold text-foreground">
              ${ethPrice?.toLocaleString()}
            </p>
          </div>
          <div className="text-green-500 text-sm font-medium">
            +1.82%
          </div>
        </div>
      </div>
    </div>
  );
};
