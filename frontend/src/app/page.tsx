"use client";

import { DashboardHeader } from "@/components/DashboardHeader";
import { VaultList } from "@/components/VaultList";

const Index = () => {
  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <VaultList />
      </div>
    </div>
  );
};

export default Index;
