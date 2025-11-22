"use client";

import { useState } from "react";
import { DashboardHeader } from "@/components/DashboardHeader";
import { PriceHeader } from "@/components/PriceHeader";
import { PriceChart } from "@/components/PriceChart";
import { CryptoTable, CryptoAsset } from "@/components/CryptoTable";

const Index = () => {
  const [selectedCrypto, setSelectedCrypto] = useState<CryptoAsset | null>(null);

  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <PriceHeader selectedCrypto={selectedCrypto} />
        <PriceChart selectedCrypto={selectedCrypto} />
        <CryptoTable
          selectedCryptoId={selectedCrypto?.id || null}
          onSelectCrypto={setSelectedCrypto}
        />
      </div>
    </div>
  );
};

export default Index;
