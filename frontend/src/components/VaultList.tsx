
"use client";

import { Vault, VaultCard } from "./VaultCard";
import { CONTRACTS } from "../lib/constants";

const MOCK_VAULTS: Vault[] = [
  {
    id: "1",
    name: "USDT Yield Aggregator",
    protocol: "Aave V3",
    network: "Base Sepolia",
    asset: "USDT",
    apy: 4.5,
    tvl: "$1.2M",
    riskLevel: "Low",
    adapterAddress: CONTRACTS.TOKENS.USDT ? "0x6F0b25e2abca0b60109549b7823392e3312f505c" : "", // Hardcoded for now to match deployment
    avatarColor: "bg-green-500",
  },
  {
    id: "2",
    name: "USDC Core Lending",
    protocol: "Aave V3",
    network: "Base Sepolia",
    asset: "USDC",
    apy: 3.8,
    tvl: "$4.5M",
    riskLevel: "Low",
    adapterAddress: "0x6a546f500b9BDaF1d08acA6DF955e8919886604a",
    avatarColor: "bg-blue-500",
  },
];

export const VaultList = () => {
  return (
    <div className="space-y-6 mt-8">
      <div className="flex justify-between items-center mb-6">
         <h2 className="text-xl font-bold text-foreground">Available Vaults</h2>
         <div className="text-sm text-muted-foreground">
            {MOCK_VAULTS.length} strategies found
         </div>
      </div>
      <div className="grid gap-4">
        {MOCK_VAULTS.map((vault) => (
          <VaultCard key={vault.id} vault={vault} />
        ))}
      </div>
    </div>
  );
};
