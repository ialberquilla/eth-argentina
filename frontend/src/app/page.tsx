"use client";

import { useState } from "react";
import { DashboardHeader } from "@/components/DashboardHeader";
import { VaultList } from "@/components/VaultList";
import { CategoryMenu, Category } from "@/components/CategoryMenu";

const Index = () => {
  const [selectedCategory, setSelectedCategory] = useState<Category>("all");

  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <CategoryMenu
          selectedCategory={selectedCategory}
          onCategoryChange={setSelectedCategory}
        />
        <VaultList category={selectedCategory} />
      </div>
    </div>
  );
};

export default Index;
