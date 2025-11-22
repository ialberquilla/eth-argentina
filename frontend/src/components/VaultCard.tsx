
"use client";

import { useState } from "react";
import { useSwapDepositor } from "../hooks/useSwapDepositor";

export interface Vault {
  id: string;
  name: string;
  protocol: string;
  network: string;
  asset: string;
  apy: number;
  tvl: string;
  riskLevel: "Low" | "Medium" | "High";
  adapterAddress: string; 
  avatarColor: string;
}

interface VaultCardProps {
  vault: Vault;
}

export const VaultCard = ({ vault }: VaultCardProps) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [amount, setAmount] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { swapAndDeposit } = useSwapDepositor();

  const handleDeposit = async () => {
    if (!amount) return;
    try {
      setIsLoading(true);
      const hash = await swapAndDeposit(amount, vault.adapterAddress);
      alert(`Transaction Sent! Hash: ${hash}`);
      setAmount("");
    } catch (e) {
      console.error(e);
      alert("Error: " + (e as Error).message);
    } finally {
      setIsLoading(false);
    }
  };

  const getRiskLevelColor = (risk: string) => {
    switch (risk) {
      case "Low": return "text-green-500";
      case "Medium": return "text-yellow-500";
      case "High": return "text-red-500";
      default: return "text-muted";
    }
  };

  return (
    <div className="bg-card/50 backdrop-blur-md border border-border rounded-xl overflow-hidden hover:border-primary/50 transition-all duration-300">
      {/* Main Row */}
      <div className="grid grid-cols-[auto_1fr_auto] gap-4 p-6 items-center cursor-pointer" onClick={() => setIsExpanded(!isExpanded)}>
        {/* Left: Avatar and Vault Info */}
        <div className="flex items-center gap-4 min-w-[200px]">
          <div className={`w-12 h-12 rounded-full flex items-center justify-center text-white font-bold text-xl shadow-lg ${vault.avatarColor}`}>
            {vault.asset[0]}
          </div>
          <div>
            <h3 className="text-foreground font-bold text-lg tracking-tight">{vault.name}</h3>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <span className="bg-secondary px-2 py-0.5 rounded text-xs">{vault.protocol}</span>
              <span>•</span>
              <span>{vault.network}</span>
            </div>
          </div>
        </div>

        {/* Center: Metrics Grid */}
        <div className="grid grid-cols-4 gap-8 text-sm ml-8">
          <div>
            <div className="text-muted-foreground text-xs uppercase tracking-wider mb-1">APY</div>
            <div className="text-green-400 font-bold text-lg">{vault.apy.toFixed(2)}%</div>
          </div>
          <div>
            <div className="text-muted-foreground text-xs uppercase tracking-wider mb-1">TVL</div>
            <div className="text-foreground font-semibold">{vault.tvl}</div>
          </div>
          <div>
            <div className="text-muted-foreground text-xs uppercase tracking-wider mb-1">Risk</div>
            <div className={`font-semibold ${getRiskLevelColor(vault.riskLevel)}`}>{vault.riskLevel}</div>
          </div>
          <div>
             <div className="text-muted-foreground text-xs uppercase tracking-wider mb-1">Asset</div>
             <div className="text-foreground font-semibold">{vault.asset}</div>
          </div>
        </div>

        {/* Right: Arrow */}
        <div className="pr-4">
            <svg
              className={`w-6 h-6 text-muted-foreground transition-transform duration-300 ${isExpanded ? "rotate-180" : ""}`}
              fill="none" stroke="currentColor" viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
        </div>
      </div>

      {/* Expanded Section */}
      {isExpanded && (
        <div className="px-6 pb-6 pt-2 border-t border-border/50 bg-card/30">
           <div className="flex flex-col md:flex-row gap-8 mt-4">
              
              {/* Left: Details */}
              <div className="flex-1 space-y-4">
                  <h4 className="font-semibold text-foreground">Vault Strategy</h4>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                      This vault automatically swaps your <strong>USDC</strong> for <strong>{vault.asset}</strong> and deposits it into {vault.protocol} to earn yield. 
                      The entire process happens in a single transaction using the SwapDepositor hook.
                  </p>
                  <div className="flex gap-4 mt-4">
                      <div className="bg-secondary/50 p-3 rounded-lg flex-1">
                          <div className="text-xs text-muted-foreground">Earn (Est.)</div>
                          <div className="text-green-400 font-mono font-semibold">+{vault.apy.toFixed(2)}% APY</div>
                      </div>
                      <div className="bg-secondary/50 p-3 rounded-lg flex-1">
                          <div className="text-xs text-muted-foreground">Protection</div>
                          <div className="text-foreground font-mono font-semibold">Auto-Compounding</div>
                      </div>
                  </div>
              </div>

              {/* Right: Action */}
              <div className="w-full md:w-[350px] bg-background/50 p-5 rounded-xl border border-border shadow-sm">
                  <h4 className="font-semibold text-foreground mb-4">Deposit USDC</h4>
                  <div className="space-y-4">
                      <div className="relative">
                          <input 
                              type="number" 
                              placeholder="0.00" 
                              value={amount}
                              onChange={(e) => setAmount(e.target.value)}
                              className="w-full bg-background border border-input rounded-lg px-4 py-3 text-lg focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all"
                          />
                          <span className="absolute right-4 top-1/2 -translate-y-1/2 text-muted-foreground font-medium">USDC</span>
                      </div>
                      
                      <div className="text-xs text-muted-foreground flex justify-between px-1">
                          <span>Balance: 0.00 USDC</span>
                          <span>Max</span>
                      </div>

                      <button 
                          onClick={handleDeposit}
                          disabled={isLoading || !amount}
                          className="w-full py-3.5 rounded-lg font-bold text-white transition-all bg-gradient-to-r from-blue-600 to-purple-600 hover:opacity-90 hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-primary/20"
                      >
                          {isLoading ? "Processing..." : "Deposit & Earn"}
                      </button>
                      <p className="text-[10px] text-center text-muted-foreground">
                          Powered by Uniswap V4 & Aave V3
                      </p>
                  </div>
              </div>

           </div>
        </div>
      )}
    </div>
  );
};
