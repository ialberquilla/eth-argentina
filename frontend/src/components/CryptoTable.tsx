"use client";

import { useState } from "react";

interface CryptoAsset {
  id: number;
  name: string;
  symbol: string;
  price: number;
  change24h: number;
  marketCap: number;
  volume24h: number;
}

const mockCryptoData: CryptoAsset[] = [
  {
    id: 1,
    name: "Bitcoin",
    symbol: "BTC",
    price: 43250.75,
    change24h: 2.45,
    marketCap: 846000000000,
    volume24h: 28500000000,
  },
  {
    id: 2,
    name: "Ethereum",
    symbol: "ETH",
    price: 2280.45,
    change24h: 1.82,
    marketCap: 274000000000,
    volume24h: 15200000000,
  },
  {
    id: 3,
    name: "Binance Coin",
    symbol: "BNB",
    price: 312.56,
    change24h: -0.45,
    marketCap: 48000000000,
    volume24h: 1800000000,
  },
  {
    id: 4,
    name: "Solana",
    symbol: "SOL",
    price: 98.34,
    change24h: 5.23,
    marketCap: 42000000000,
    volume24h: 2100000000,
  },
  {
    id: 5,
    name: "Cardano",
    symbol: "ADA",
    price: 0.52,
    change24h: -1.15,
    marketCap: 18000000000,
    volume24h: 450000000,
  },
];

export const CryptoTable = () => {
  const [cryptos] = useState<CryptoAsset[]>(mockCryptoData);

  const formatNumber = (num: number) => {
    if (num >= 1e9) {
      return `$${(num / 1e9).toFixed(2)}B`;
    }
    if (num >= 1e6) {
      return `$${(num / 1e6).toFixed(2)}M`;
    }
    return `$${num.toLocaleString()}`;
  };

  return (
    <div className="bg-card rounded-lg border border-border overflow-hidden">
      <div className="p-6 border-b border-border">
        <h2 className="text-xl font-semibold text-foreground">Top Cryptocurrencies</h2>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-muted/50">
            <tr>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">#</th>
              <th className="text-left p-4 text-sm font-medium text-muted-foreground">Name</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">Price</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">24h %</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">Market Cap</th>
              <th className="text-right p-4 text-sm font-medium text-muted-foreground">Volume (24h)</th>
            </tr>
          </thead>
          <tbody>
            {cryptos.map((crypto) => (
              <tr
                key={crypto.id}
                className="border-t border-border hover:bg-muted/30 transition-colors cursor-pointer"
              >
                <td className="p-4 text-sm text-muted-foreground">{crypto.id}</td>
                <td className="p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                      <span className="text-xs font-bold text-primary">
                        {crypto.symbol.charAt(0)}
                      </span>
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{crypto.name}</p>
                      <p className="text-xs text-muted-foreground">{crypto.symbol}</p>
                    </div>
                  </div>
                </td>
                <td className="p-4 text-right font-medium text-foreground">
                  ${crypto.price.toLocaleString()}
                </td>
                <td className="p-4 text-right">
                  <span
                    className={`font-medium ${
                      crypto.change24h >= 0 ? "text-green-500" : "text-red-500"
                    }`}
                  >
                    {crypto.change24h >= 0 ? "+" : ""}
                    {crypto.change24h.toFixed(2)}%
                  </span>
                </td>
                <td className="p-4 text-right text-muted-foreground">
                  {formatNumber(crypto.marketCap)}
                </td>
                <td className="p-4 text-right text-muted-foreground">
                  {formatNumber(crypto.volume24h)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
