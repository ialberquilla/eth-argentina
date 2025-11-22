'use client';

import { useState } from 'react';
import { RegisterProductModal } from './RegisterProductModal';

export const DashboardHeader = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <header className="mb-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Vault Dashboard</h1>
            <p className="text-muted mt-1">Explore and allocate capital to DeFi vaults</p>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => setIsModalOpen(true)}
              className="px-4 py-2 rounded-lg bg-gradient-to-r from-primary via-blue-500 to-secondary text-white font-medium hover:opacity-90 transition-opacity"
            >
              Register New Product
            </button>
            <button className="px-4 py-2 rounded-lg bg-primary text-white hover:bg-primary-hover transition-colors">
              Connect Wallet
            </button>
          </div>
        </div>
      </header>

      <RegisterProductModal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)} />
    </>
  );
};
