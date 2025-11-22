
"use client";

import { usePrivy } from "@privy-io/react-auth";
import Link from "next/link";

export const DashboardHeader = () => {
  const { ready, authenticated, login, logout, user } = usePrivy();

  const getDisplayName = () => {
    if (!user) return "";
    const walletAddress = user.wallet?.address;
    if (walletAddress) return `${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`;
    if (user.email?.address) return user.email.address;
    return "User";
  };

  return (
    <header className="mb-10">
      <div className="flex items-center justify-between">
        <div>
          <div className="flex items-center gap-3 mb-2">
             <div className="w-10 h-10 bg-gradient-to-br from-blue-600 to-purple-600 rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-primary/20">
                1
             </div>
             <h1 className="text-3xl font-bold text-foreground tracking-tight">OneTx</h1>
          </div>
          <p className="text-muted-foreground">
            Single-transaction yield access via Uniswap V4 hooks
          </p>
        </div>

        <div className="flex items-center gap-6">
          <Link href="/docs" className="text-sm font-medium text-muted-foreground hover:text-primary transition-colors">
             Developers
          </Link>

          {authenticated ? (
            <div className="flex items-center gap-3 bg-card border border-border rounded-full pl-4 pr-2 py-1.5 shadow-sm">
              <div className="flex items-center gap-2">
                 <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                 <span className="text-sm font-medium text-foreground">{getDisplayName()}</span>
              </div>
              <button 
                onClick={logout}
                className="px-4 py-1.5 rounded-full bg-secondary/80 text-foreground text-sm hover:bg-secondary transition-colors"
              >
                Disconnect
              </button>
            </div>
          ) : (
            <button 
              onClick={login}
              disabled={!ready}
              className="px-6 py-2.5 rounded-full bg-foreground text-background font-medium hover:opacity-90 transition-all shadow-lg disabled:opacity-50"
            >
              Connect Wallet
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
