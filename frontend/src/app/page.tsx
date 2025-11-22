"use client";

import { useState } from "react";
import { DashboardHeader } from "@/components/DashboardHeader";
import { PriceHeader } from "@/components/PriceHeader";
import { PriceChart } from "@/components/PriceChart";
import { CryptoTable, YieldProduct } from "@/components/CryptoTable";

const Index = () => {
  const [selectedProduct, setSelectedProduct] = useState<YieldProduct | undefined>(undefined);

  const handleProductSelect = (product: YieldProduct) => {
    setSelectedProduct(product);
  };

  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <PriceHeader />
        <PriceChart selectedProduct={selectedProduct} />
        <CryptoTable onProductSelect={handleProductSelect} />
      </div>
    </div>
  );
};

export default Index;
