"use client";

import { usePrivy } from "@privy-io/react-auth";

export const DashboardHeader = () => {
  const { ready, authenticated, login, logout, user } = usePrivy();

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
