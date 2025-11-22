"use client";

import { useState } from "react";
import { useCCTPBridge } from "../lib/hooks/useCCTPBridge";
import { getCCTPConfig, isCCTPSupported } from "../lib/cctp-config";

interface ChainOption {
  chainId: number;
  name: string;
  logo?: string;
}

const SUPPORTED_CHAINS: ChainOption[] = [
  { chainId: 23244, name: "Arc Testnet" },
  { chainId: 84532, name: "Base Sepolia" },
  { chainId: 8453, name: "Base" },
];

export default function CrossChainBridge() {
  const { bridgeUSDC, completeBridge, isLoading, error, bridgeStatus } = useCCTPBridge();

  const [amount, setAmount] = useState("");
  const [recipient, setRecipient] = useState("");
  const [sourceChain, setSourceChain] = useState(23244); // Arc Testnet
  const [destinationChain, setDestinationChain] = useState(84532); // Base Sepolia
  const [messageHash, setMessageHash] = useState("");
  const [enableSwap, setEnableSwap] = useState(false);
  const [tokenOut, setTokenOut] = useState("");
  const [minAmountOut, setMinAmountOut] = useState("");

  const handleBridge = async () => {
    if (!amount || !recipient) {
      alert("Please fill in all required fields");
      return;
    }

    const swapParams = enableSwap && tokenOut && minAmountOut
      ? {
          tokenOut,
          minAmountOut,
          deadline: Math.floor(Date.now() / 1000) + 3600, // 1 hour from now
        }
      : undefined;

    const result = await bridgeUSDC({
      amount,
      destinationChainId: destinationChain,
      recipient: recipient || "",
      withSwap: enableSwap,
      swapParams,
    });

    if (result?.messageHash) {
      setMessageHash(result.messageHash);
    }
  };

  const handleCompleteBridge = async () => {
    if (!messageHash) {
      alert("No message hash available");
      return;
    }

    await completeBridge(messageHash, sourceChain, destinationChain);
  };

  return (
    <div className="w-full max-w-2xl mx-auto p-6 bg-white dark:bg-gray-800 rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-6 text-gray-900 dark:text-white">
        Cross-Chain USDC Bridge
      </h2>

      <div className="space-y-6">
        {/* Source Chain Selection */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            From Chain
          </label>
          <select
            value={sourceChain}
            onChange={(e) => setSourceChain(Number(e.target.value))}
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            disabled={isLoading}
          >
            {SUPPORTED_CHAINS.map((chain) => (
              <option key={chain.chainId} value={chain.chainId}>
                {chain.name}
              </option>
            ))}
          </select>
        </div>

        {/* Destination Chain Selection */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            To Chain
          </label>
          <select
            value={destinationChain}
            onChange={(e) => setDestinationChain(Number(e.target.value))}
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            disabled={isLoading}
          >
            {SUPPORTED_CHAINS.filter((c) => c.chainId !== sourceChain).map((chain) => (
              <option key={chain.chainId} value={chain.chainId}>
                {chain.name}
              </option>
            ))}
          </select>
        </div>

        {/* Amount Input */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Amount (USDC)
          </label>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.00"
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            disabled={isLoading}
            step="0.01"
            min="0"
          />
        </div>

        {/* Recipient Address */}
        <div>
          <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Recipient Address (on destination chain)
          </label>
          <input
            type="text"
            value={recipient}
            onChange={(e) => setRecipient(e.target.value)}
            placeholder="0x..."
            className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono text-sm"
            disabled={isLoading}
          />
        </div>

        {/* Enable Swap Toggle */}
        <div className="flex items-center space-x-3">
          <input
            type="checkbox"
            id="enableSwap"
            checked={enableSwap}
            onChange={(e) => setEnableSwap(e.target.checked)}
            className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
            disabled={isLoading}
          />
          <label htmlFor="enableSwap" className="text-sm font-medium text-gray-700 dark:text-gray-300">
            Automatically swap on arrival
          </label>
        </div>

        {/* Swap Parameters (conditional) */}
        {enableSwap && (
          <div className="space-y-4 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <h3 className="text-sm font-semibold text-gray-700 dark:text-gray-300">
              Swap Settings
            </h3>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Output Token Address
              </label>
              <input
                type="text"
                value={tokenOut}
                onChange={(e) => setTokenOut(e.target.value)}
                placeholder="0x... (e.g., WETH)"
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono text-sm"
                disabled={isLoading}
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Minimum Amount Out
              </label>
              <input
                type="number"
                value={minAmountOut}
                onChange={(e) => setMinAmountOut(e.target.value)}
                placeholder="0.00"
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                disabled={isLoading}
                step="0.01"
                min="0"
              />
            </div>
          </div>
        )}

        {/* Status Messages */}
        {bridgeStatus && (
          <div className="p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
            <p className="text-sm text-blue-800 dark:text-blue-200">{bridgeStatus}</p>
          </div>
        )}

        {error && (
          <div className="p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
            <p className="text-sm text-red-800 dark:text-red-200">{error}</p>
          </div>
        )}

        {messageHash && (
          <div className="p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg">
            <p className="text-sm font-medium text-green-800 dark:text-green-200 mb-2">
              Bridge Initiated!
            </p>
            <p className="text-xs text-green-700 dark:text-green-300 font-mono break-all">
              Message Hash: {messageHash}
            </p>
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex space-x-4">
          <button
            onClick={handleBridge}
            disabled={isLoading || !amount || !recipient}
            className="flex-1 px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold rounded-lg transition-colors"
          >
            {isLoading ? "Processing..." : "Bridge USDC"}
          </button>

          {messageHash && (
            <button
              onClick={handleCompleteBridge}
              disabled={isLoading}
              className="flex-1 px-6 py-3 bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold rounded-lg transition-colors"
            >
              Complete Bridge
            </button>
          )}
        </div>

        {/* Info Box */}
        <div className="mt-6 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700">
          <h3 className="text-sm font-semibold text-gray-900 dark:text-white mb-2">
            How it works
          </h3>
          <ol className="text-xs text-gray-600 dark:text-gray-400 space-y-1 list-decimal list-inside">
            <li>USDC is burned on the source chain (Arc)</li>
            <li>Circle's attestation service validates the burn (~15 seconds on testnet)</li>
            <li>USDC is minted on the destination chain (Base)</li>
            <li>If swap is enabled, funds are automatically swapped on arrival</li>
          </ol>
        </div>
      </div>
    </div>
  );
}
