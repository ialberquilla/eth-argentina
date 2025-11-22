"use client";

import { useState } from "react";
import { DashboardHeader } from "@/components/DashboardHeader";
import { CategoryMenu, Category } from "@/components/CategoryMenu";

export default function DocsPage() {
  const [selectedCategory] = useState<Category>("all");

  const codeExample = `import { createPublicClient, createWalletClient, http, encodeAbiParameters } from 'viem';
import { baseSepolia } from 'viem/chains';

// Step 1: Discover all available products
const products = await publicClient.readContract({
  address: '0x7425AAa97230f6D575193667cfd402b0B89C47f2',
  abi: registryABI,
  functionName: 'getAllRegisteredAdapters'
});

// Step 2: Trade and earn yield automatically
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'string' }],
  [products[0].adapterId, myAddress]
);

await walletClient.writeContract({
  address: SWAP_ROUTER_ADDRESS,
  abi: swapRouterABI,
  functionName: 'swap',
  args: [poolKey, swapParams, hookData]
});

// Done! You now hold yield-bearing tokens`;

  const functionSignature1 = `function getAllRegisteredAdapters()
  external view
  returns (AdapterInfo[] memory)`;

  const functionSignature2 = `function swap(
  PoolKey calldata key,
  IPoolManager.SwapParams calldata params,
  bytes calldata hookData
) external returns (BalanceDelta)`;

  return (
    <div className="min-h-screen bg-background p-6 md:p-8">
      <div className="max-w-[1600px] mx-auto">
        <DashboardHeader />
        <CategoryMenu
          selectedCategory={selectedCategory}
          onCategoryChange={() => {}}
        />
        <div className="max-w-5xl mx-auto mt-6">
          <div className="mb-8">
            <h1 className="text-4xl font-bold mb-3">OneTx Contract Interfaces</h1>
            <p className="text-lg text-muted-foreground">
              Discover and trade yield-bearing assets with just two simple functions
            </p>
          </div>

          <div className="space-y-8">
            {/* Overview */}
            <section className="bg-card border border-border rounded-lg p-6">
              <p className="text-muted-foreground">
                The OneTx protocol makes it incredibly easy to discover and trade yield-bearing assets.
                With just two functions, you can browse all available products and execute trades that automatically
                earn yield for you. All in one transaction.
              </p>
            </section>

            {/* Contract Address */}
            <section className="bg-card border border-border rounded-lg p-6">
              <h2 className="text-2xl font-bold mb-4">Contract Address</h2>
              <p className="text-muted-foreground mb-3">
                The <code className="bg-muted px-2 py-1 rounded">AdapterRegistry</code> contract is deployed at{" "}
                <a
                  href="https://sepolia.basescan.org/address/0x7425AAa97230f6D575193667cfd402b0B89C47f2"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline font-mono"
                >
                  0x7425AAa97230f6D575193667cfd402b0B89C47f2
                </a>
              </p>
              <p className="text-sm text-muted-foreground">on the Base Sepolia testnet.</p>
            </section>

            {/* Interfaces */}
            <section className="bg-card border border-border rounded-lg p-6">
              <h2 className="text-2xl font-bold mb-6">Interfaces</h2>

              {/* getAllRegisteredAdapters */}
              <div className="mb-8">
                <h3 className="text-xl font-semibold mb-3">getAllRegisteredAdapters</h3>
                <p className="text-muted-foreground mb-4">
                  Discover all available yield-bearing assets. Returns a list of all registered adapters with their details.
                </p>

                <div className="bg-muted/50 border border-border rounded-lg p-4 mb-4">
                  <pre className="text-sm font-mono overflow-x-auto whitespace-pre">
                    {functionSignature1}
                  </pre>
                </div>

                <div className="mb-6">
                  <h4 className="font-semibold mb-3">Returns</h4>
                  <div className="border border-border rounded-lg overflow-hidden">
                    <table className="w-full text-sm">
                      <thead className="bg-muted/50 border-b border-border">
                        <tr>
                          <th className="text-left p-3 font-semibold">Name</th>
                          <th className="text-left p-3 font-semibold">Type</th>
                          <th className="text-left p-3 font-semibold">Description</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr className="border-b border-border">
                          <td className="p-3 font-mono">adapters</td>
                          <td className="p-3 font-mono text-muted-foreground">AdapterInfo[]</td>
                          <td className="p-3 text-muted-foreground">Array of all registered adapters</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <div className="bg-muted/30 border border-border rounded-lg p-4">
                  <p className="text-sm font-semibold mb-2">AdapterInfo structure:</p>
                  <div className="space-y-2 text-sm font-mono">
                    <div className="grid grid-cols-2 gap-2">
                      <span className="text-muted-foreground">adapterAddress:</span>
                      <span>address</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <span className="text-muted-foreground">ensNode:</span>
                      <span>bytes32</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <span className="text-muted-foreground">domain:</span>
                      <span>string</span>
                    </div>
                    <div className="grid grid-cols-2 gap-2">
                      <span className="text-muted-foreground">adapterId:</span>
                      <span>string</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* swap */}
              <div>
                <h3 className="text-xl font-semibold mb-3">swap</h3>
                <p className="text-muted-foreground mb-4">
                  Execute a trade and automatically receive yield-bearing tokens. The swap deposits your output
                  tokens into the lending protocol and returns yield-bearing tokens to you.
                </p>

                <div className="bg-muted/50 border border-border rounded-lg p-4 mb-4">
                  <pre className="text-sm font-mono overflow-x-auto whitespace-pre">
                    {functionSignature2}
                  </pre>
                </div>

                <div className="mb-6">
                  <h4 className="font-semibold mb-3">Parameters</h4>
                  <div className="border border-border rounded-lg overflow-hidden">
                    <table className="w-full text-sm">
                      <thead className="bg-muted/50 border-b border-border">
                        <tr>
                          <th className="text-left p-3 font-semibold">Name</th>
                          <th className="text-left p-3 font-semibold">Type</th>
                          <th className="text-left p-3 font-semibold">Description</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr className="border-b border-border">
                          <td className="p-3 font-mono">key</td>
                          <td className="p-3 font-mono text-muted-foreground">PoolKey</td>
                          <td className="p-3 text-muted-foreground">The pool to swap against</td>
                        </tr>
                        <tr className="border-b border-border">
                          <td className="p-3 font-mono">params</td>
                          <td className="p-3 font-mono text-muted-foreground">SwapParams</td>
                          <td className="p-3 text-muted-foreground">The swap parameters (amount, limits)</td>
                        </tr>
                        <tr>
                          <td className="p-3 font-mono">hookData</td>
                          <td className="p-3 font-mono text-muted-foreground">bytes</td>
                          <td className="p-3 text-muted-foreground">Encoded adapterId and recipient address</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>

                <div className="mb-6">
                  <h4 className="font-semibold mb-3">Returns</h4>
                  <div className="border border-border rounded-lg overflow-hidden">
                    <table className="w-full text-sm">
                      <thead className="bg-muted/50 border-b border-border">
                        <tr>
                          <th className="text-left p-3 font-semibold">Name</th>
                          <th className="text-left p-3 font-semibold">Type</th>
                          <th className="text-left p-3 font-semibold">Description</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td className="p-3 font-mono">delta</td>
                          <td className="p-3 font-mono text-muted-foreground">BalanceDelta</td>
                          <td className="p-3 text-muted-foreground">The balance changes from the swap</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </section>

            {/* Quick Start */}
            <section className="bg-card border border-border rounded-lg p-6">
              <h2 className="text-2xl font-bold mb-4">Quick Start Example</h2>
              <p className="text-muted-foreground mb-4">
                Here's how simple it is to discover and trade yield-bearing assets:
              </p>

              <div className="bg-black p-4 rounded-lg overflow-x-auto mb-4">
                <pre className="text-sm text-green-400 whitespace-pre">
                  {codeExample}
                </pre>
              </div>

              <div className="bg-blue-500/10 border border-blue-500/20 rounded-lg p-4">
                <p className="text-sm font-semibold mb-2">That's it!</p>
                <p className="text-sm text-muted-foreground">
                  One function to discover products, one function to trade. The protocol handles everything else:
                  depositing to lending protocols, minting yield-bearing tokens, and sending them to you.
                </p>
              </div>
            </section>

            {/* Contract Addresses */}
            <section className="bg-card border border-border rounded-lg p-6">
              <h2 className="text-2xl font-bold mb-4">Other Contract Addresses</h2>
              <p className="text-sm text-muted-foreground mb-4">Base Sepolia testnet:</p>
              <div className="space-y-3 font-mono text-sm">
                <div className="grid grid-cols-2 gap-4">
                  <span className="text-muted-foreground">SwapDepositor Hook:</span>
                  <code>0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4</code>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <span className="text-muted-foreground">Pool Manager:</span>
                  <code>0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829</code>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <span className="text-muted-foreground">USDT Adapter:</span>
                  <code>0x6F0b25e2abca0b60109549b7823392e3312f505c</code>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <span className="text-muted-foreground">USDC Adapter:</span>
                  <code>0x6a546f500b9BDaF1d08acA6DF955e8919886604a</code>
                </div>
              </div>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
}
