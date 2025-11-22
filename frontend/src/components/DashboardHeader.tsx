export const DashboardHeader = () => {
  return (
    <header className="mb-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground">Crypto Dashboard</h1>
          <p className="text-muted-foreground mt-1">Track your favorite cryptocurrencies</p>
        </div>
        <div className="flex items-center gap-4">
          <button className="px-4 py-2 rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors">
            Connect Wallet
          </button>
        </div>
      </div>
    </header>
  );
};
