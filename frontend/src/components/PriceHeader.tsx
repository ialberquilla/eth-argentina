"use client";

interface CryptoAsset {
  id: number;
  name: string;
  symbol: string;
  price: number;
  change24h: number;
  marketCap: number;
  volume24h: number;
}

interface PriceHeaderProps {
  selectedCrypto: CryptoAsset | null;
}

export const PriceHeader = ({ selectedCrypto }: PriceHeaderProps) => {
  const formatNumber = (num: number) => {
    if (num >= 1e9) {
      return `$${(num / 1e9).toFixed(2)}B`;
    }
    if (num >= 1e6) {
      return `$${(num / 1e6).toFixed(2)}M`;
    }
    return `$${num.toLocaleString()}`;
  };

  if (!selectedCrypto) {
    return (
      <div className="bg-card rounded-lg p-6 border border-border mb-8 transition-colors">
        <div className="text-center py-8">
          <p className="text-muted-foreground text-sm">
            Select a cryptocurrency from the table below to view details
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-card rounded-lg p-6 border border-border mb-8 hover:border-primary/50 transition-colors">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <div className="flex items-center gap-3 mb-3">
            <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
              <span className="text-lg font-bold text-primary">
                {selectedCrypto.symbol.charAt(0)}
              </span>
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Selected Asset</p>
              <p className="font-semibold text-foreground">{selectedCrypto.name}</p>
              <p className="text-xs text-muted-foreground">{selectedCrypto.symbol}</p>
            </div>
          </div>
        </div>

        <div>
          <p className="text-sm text-muted-foreground mb-1">Current Price</p>
          <p className="text-2xl font-bold text-foreground">
            ${selectedCrypto.price.toLocaleString()}
          </p>
          <div className={`text-sm font-medium ${
            selectedCrypto.change24h >= 0 ? "text-green-500" : "text-red-500"
          }`}>
            {selectedCrypto.change24h >= 0 ? "+" : ""}
            {selectedCrypto.change24h.toFixed(2)}% (24h)
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-muted-foreground mb-1">Market Cap</p>
            <p className="text-lg font-semibold text-foreground">
              {formatNumber(selectedCrypto.marketCap)}
            </p>
          </div>
          <div>
            <p className="text-sm text-muted-foreground mb-1">Volume (24h)</p>
            <p className="text-lg font-semibold text-foreground">
              {formatNumber(selectedCrypto.volume24h)}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
