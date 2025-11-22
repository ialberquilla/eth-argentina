"use client";

import { usePrivy } from "@privy-io/react-auth";
import { useState } from "react";

export const DashboardHeader = () => {
  const { ready, authenticated, login, logout, user } = usePrivy();
  const [copied, setCopied] = useState(false);

  // Get user's wallet address or email
  const getDisplayName = () => {
    if (!user) return "";

    // Check for wallet address
    const walletAddress = user.wallet?.address;
    if (walletAddress) {
      return `${walletAddress.slice(0, 6)}...${walletAddress.slice(-4)}`;
    }

    // Check for email
    if (user.email?.address) {
      return user.email.address;
    }

    // Check for social accounts
    if (user.google?.email) return user.google.email;
    if (user.twitter?.username) return `@${user.twitter.username}`;
    if (user.discord?.username) return user.discord.username;
    if (user.github?.username) return user.github.username;

    return "User";
  };

  const handleCopyAddress = async () => {
    const walletAddress = user?.wallet?.address;
    if (!walletAddress) return;

    try {
      await navigator.clipboard.writeText(walletAddress);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error("Failed to copy address:", err);
    }
  };

  const hasWalletAddress = user?.wallet?.address;

  return (
    <header className="mb-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Vault Dashboard</h1>
          <p className="text-muted mt-1">Explore and allocate capital to DeFi vaults</p>
        </div>
        <div className="flex items-center gap-4">
          {authenticated ? (
            <div className="flex items-center gap-3">
              <span className="text-sm text-muted">{getDisplayName()}</span>
              {hasWalletAddress && (
                <button
                  onClick={handleCopyAddress}
                  className="p-2 rounded-lg bg-secondary/20 hover:bg-secondary/40 transition-colors"
                  title="Copy wallet address"
                >
                  {copied ? (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                  ) : (
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      width="16"
                      height="16"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                      <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                    </svg>
                  )}
                </button>
              )}
              <button
                onClick={logout}
                className="px-4 py-2 rounded-lg bg-secondary text-white hover:opacity-80 transition-opacity"
              >
                Disconnect
              </button>
            </div>
          ) : (
            <button
              onClick={login}
              disabled={!ready}
              className="px-4 py-2 rounded-lg bg-primary text-white hover:bg-primary-hover transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Login
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
