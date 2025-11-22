import { DashboardHeader } from "@/components/DashboardHeader";
import { PriceHeader } from "@/components/PriceHeader";
import { PriceChart } from "@/components/PriceChart";
import { CryptoTable } from "@/components/CryptoTable";

const Index = () => {
  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <PriceHeader />
        <PriceChart />
        <CryptoTable />
      </div>
    </div>
  );
};

export default Index;
