"use client";

import { useState } from "react";
import { useWallets, useLogin } from "@privy-io/react-auth";

export interface Vault {
  id: string;
  name: string;
  protocol: string;
  network: string;
  asset: string;
  apy: number;
  tvl: string;
  riskLevel: "Low" | "Medium" | "High";
  category: "lending" | "perpetuals" | "rwa";
  volatility: number;
  total24hVol: string;
  bestLeverage: string;
  bestFixedApy: number;
  depeggingRisk: "Low" | "Medium" | "High";
  // Advanced Risk Metrics
  currentApy: number;
  yieldStability: number;
  // Capital Efficiency
  lockupPeriod: string;
  gasCost: string;
  capitalUtilization: number;
  currentCapacity: string;
  maxCapacity: string;
  // Protocol Safety
  exploitHistory: string;
  timeSinceLaunch: string;
  smartContractRiskScore: number;
  avatarColor: string;
  // Contract Addresses (optional, for deployed pools)
  tokenAddress?: string;
  adapterAddress?: string;
  poolManagerAddress?: string;
  hookAddress?: string;
  aavePoolAddress?: string;
  ensName?: string; // ENS name for the adapter (e.g., "usdt-basesepolia-word-word.onetx.base.eth")
}

interface VaultCardProps {
  vault: Vault;
}

export const VaultCard = ({ vault }: VaultCardProps) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [showSwapModal, setShowSwapModal] = useState(false);
  const [swapAmount, setSwapAmount] = useState("");
  const [arcTxStatus, setArcTxStatus] = useState<"loading" | "completed" | "idle">("idle");
  const [baseSwapStatus, setBaseSwapStatus] = useState<"loading" | "completed" | "idle">("idle");
  const [showSuccess, setShowSuccess] = useState(false);
  const { wallets } = useWallets();
  const { login } = useLogin();

  const getRiskLevelColor = (risk: string) => {
    switch (risk) {
      case "Low":
        return "text-green-500";
      case "Medium":
        return "text-yellow-500";
      case "High":
        return "text-red-500";
      default:
        return "text-muted";
    }
  };

  const handleAllocateCapital = () => {
    if (!wallets || wallets.length === 0) {
      login();
      return;
    }
    setShowSwapModal(true);
  };

  const handleSwap = async () => {
    if (!swapAmount || parseFloat(swapAmount) <= 0) {
      alert("Please enter a valid amount");
      return;
    }

    // Mock behavior - start Arc Tx
    setArcTxStatus("loading");
    setBaseSwapStatus("idle");
    setShowSuccess(false);

    // After 3 seconds, complete Arc Tx and start Base Swap
    setTimeout(() => {
      setArcTxStatus("completed");
      setBaseSwapStatus("loading");

      // After 3 more seconds (6 total), complete Base Swap and show success
      setTimeout(() => {
        setBaseSwapStatus("completed");
        setShowSuccess(true);
      }, 3000);
    }, 3000);
  };

  return (
    <div className="bg-card border-b border-border">
      {/* Main Row */}
      <div className="grid grid-cols-[auto_1fr_auto] gap-4 p-6 items-center hover:bg-card-hover transition-colors">
        {/* Left: Avatar and Vault Info */}
        <div className="flex items-center gap-4 min-w-[300px]">
          <div
            className={`w-12 h-12 rounded-lg flex items-center justify-center text-white font-bold text-lg ${vault.avatarColor}`}
          >
            U
          </div>
          <div>
            <h3 className="text-foreground font-semibold text-base">{vault.name}</h3>
            <p className="text-muted text-sm">
              {vault.protocol} • {vault.network} • {vault.asset}
            </p>
          </div>
        </div>

        {/* Center: Metrics Grid */}
        <div className="grid grid-cols-8 gap-6 text-sm">
          <div className="text-center">
            <div className="text-muted text-xs mb-1">APY</div>
            <div className="text-green-500 font-semibold">{vault.apy.toFixed(2)}%</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">TVL</div>
            <div className="text-foreground font-semibold">{vault.tvl}</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Risk Level</div>
            <div className={`font-semibold ${getRiskLevelColor(vault.riskLevel)}`}>
              {vault.riskLevel}
            </div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Volatility</div>
            <div className="text-foreground font-semibold">{vault.volatility.toFixed(2)}%</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Total 24h Vol</div>
            <div className="text-foreground font-semibold">{vault.total24hVol}</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Best Leverage</div>
            <div className="text-foreground font-semibold">{vault.bestLeverage}</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Best Fixed APY</div>
            <div className="text-green-500 font-semibold">{vault.bestFixedApy.toFixed(2)}%</div>
          </div>
          <div className="text-center">
            <div className="text-muted text-xs mb-1">Depegging Risk</div>
            <div className={`font-semibold ${getRiskLevelColor(vault.depeggingRisk)}`}>
              {vault.depeggingRisk}
            </div>
          </div>
        </div>

        {/* Right: Expand Button and Buy */}
        <div className="flex items-center gap-4">
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="text-muted hover:text-foreground transition-colors p-2"
          >
            <svg
              className={`w-5 h-5 transition-transform ${isExpanded ? "rotate-180" : ""}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          <button
            onClick={handleAllocateCapital}
            className="px-6 py-2 rounded-lg font-medium text-white transition-all bg-gradient-to-r from-green-500 via-blue-500 to-purple-500 hover:opacity-90"
          >
            Buy
          </button>
        </div>
      </div>

      {/* Expanded Section */}
      {isExpanded && (
        <div className="px-6 pb-6 grid grid-cols-3 gap-8">
          {/* Advanced Risk Metrics */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <span className="text-lg">📊</span>
              <h4 className="text-muted text-xs font-semibold uppercase tracking-wider">
                Advanced Risk Metrics
              </h4>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Current APY</span>
                <span className="text-green-500 font-semibold">{vault.currentApy.toFixed(2)}%</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Yield Stability (σ)</span>
                <span className="text-foreground font-semibold">{vault.yieldStability.toFixed(2)}%</span>
              </div>
            </div>
          </div>

          {/* Capital Efficiency */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <span className="text-lg">⚡</span>
              <h4 className="text-muted text-xs font-semibold uppercase tracking-wider">
                Capital Efficiency
              </h4>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Lock-up Period</span>
                <span className="text-green-500 font-semibold">{vault.lockupPeriod}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Gas Cost (Est.)</span>
                <span className="text-foreground font-semibold">{vault.gasCost}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Capital Utilization</span>
                <span className="text-foreground font-semibold">{vault.capitalUtilization}%</span>
              </div>
              <div>
                <div className="flex justify-between items-center mb-2">
                  <span className="text-foreground text-sm">Current Capacity</span>
                  <span className="text-foreground font-semibold">
                    {vault.currentCapacity} → {vault.maxCapacity}
                  </span>
                </div>
                <div className="w-full bg-border rounded-full h-2 overflow-hidden">
                  <div
                    className="h-full bg-gradient-to-r from-green-500 via-blue-500 to-purple-500"
                    style={{ width: `${vault.capitalUtilization}%` }}
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Protocol Safety */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <span className="text-lg">🛡️</span>
              <h4 className="text-muted text-xs font-semibold uppercase tracking-wider">
                Protocol Safety
              </h4>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Exploit History</span>
                <span className="text-green-500 font-semibold">{vault.exploitHistory}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-foreground text-sm">Time Since Launch</span>
                <span className="text-foreground font-semibold">{vault.timeSinceLaunch}</span>
              </div>
              <div className="bg-card-hover rounded-lg p-4 mt-4">
                <div className="flex items-center gap-4">
                  <div className="text-5xl font-bold text-green-500">
                    {vault.smartContractRiskScore}
                  </div>
                  <div>
                    <div className="text-muted text-xs uppercase tracking-wider">Smart Contract</div>
                    <div className="text-muted text-xs uppercase tracking-wider">Risk Score</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Swap Modal */}
      {showSwapModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-card border border-border rounded-lg p-6 max-w-md w-full mx-4">
            <h3 className="text-xl font-bold text-foreground mb-4">
              Swap USDC to {vault.asset}
            </h3>
            <p className="text-muted text-sm mb-4">
              Swap USDC for {vault.asset} and automatically deposit to Aave via {vault.protocol}
            </p>

            <div className="mb-4">
              <label className="block text-sm text-muted mb-2">Amount (USDC)</label>
              <input
                type="number"
                value={swapAmount}
                onChange={(e) => setSwapAmount(e.target.value)}
                placeholder="0.0"
                className="w-full px-4 py-2 bg-background border border-border rounded-lg text-foreground"
                step="0.01"
                min="0"
                disabled={arcTxStatus !== "idle"}
              />
            </div>

            {/* Transaction Progress */}
            {arcTxStatus !== "idle" && (
              <div className="mb-4 space-y-3">
                {/* Arc Tx */}
                <div className="flex items-center gap-3 p-3 bg-background border border-border rounded-lg">
                  {arcTxStatus === "loading" ? (
                    <div className="w-5 h-5 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
                  ) : null}
                  {arcTxStatus === "completed" ? (
                    <a
                      href="https://testnet.arcscan.app/tx/0x9914214a5db159182f63c8400ff455a41dd2c276422cbe10948fc59e3df9dcd3"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="px-4 py-2 rounded-lg font-medium text-white bg-gradient-to-r from-green-500 via-blue-500 to-purple-500 hover:opacity-90"
                    >
                      Arc Tx
                    </a>
                  ) : (
                    <span className="text-foreground text-sm">Arc Tx</span>
                  )}
                </div>

                {/* Base Swap */}
                <div className="flex items-center gap-3 p-3 bg-background border border-border rounded-lg">
                  {baseSwapStatus === "loading" ? (
                    <div className="w-5 h-5 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
                  ) : null}
                  {baseSwapStatus === "completed" ? (
                    <a
                      href="https://sepolia.basescan.org/tx/0x29083f8a9081883d35836ce4c352154be7e0061d7040eaa2ddb4357301c48031"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="px-4 py-2 rounded-lg font-medium text-white bg-gradient-to-r from-green-500 via-blue-500 to-purple-500 hover:opacity-90"
                    >
                      Base Swap
                    </a>
                  ) : (
                    <span className="text-foreground text-sm">Base Swap</span>
                  )}
                </div>

                {/* Success Message */}
                {showSuccess && (
                  <div className="flex items-center justify-center gap-3 p-4 bg-green-500 border-2 border-green-600 rounded-lg">
                    <svg className="w-6 h-6 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                    <span className="text-white font-bold text-lg">Bought!</span>
                  </div>
                )}
              </div>
            )}

            <div className="flex gap-3">
              <button
                onClick={() => {
                  setShowSwapModal(false);
                  setArcTxStatus("idle");
                  setBaseSwapStatus("idle");
                  setShowSuccess(false);
                  setSwapAmount("");
                }}
                className="flex-1 px-4 py-2 rounded-lg font-medium text-muted border border-border hover:bg-card-hover"
                disabled={arcTxStatus === "loading" || baseSwapStatus === "loading"}
              >
                {showSuccess ? "Close" : "Cancel"}
              </button>
              {arcTxStatus === "idle" && (
                <button
                  onClick={handleSwap}
                  className="flex-1 px-4 py-2 rounded-lg font-medium text-white bg-gradient-to-r from-green-500 via-blue-500 to-purple-500 hover:opacity-90 disabled:opacity-50"
                >
                  Buy Instrument
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
