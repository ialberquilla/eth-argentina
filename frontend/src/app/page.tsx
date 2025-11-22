import { DashboardHeader } from "@/components/DashboardHeader";
import { MorphoBlueProtocol } from "@/components/MorphoBlueProtocol";
import { CryptoTable } from "@/components/CryptoTable";

const Index = () => {
  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <MorphoBlueProtocol />
        <CryptoTable />
      </div>
    </div>
  );
};

export default Index;
