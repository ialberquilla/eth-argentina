
"use client";

import Link from "next/link";

const CodeBlock = ({ children }: { children: React.ReactNode }) => (
  <div className="relative group mt-2 mb-4">
    <div className="absolute right-2 top-2 opacity-0 group-hover:opacity-100 transition-opacity">
      <span className="text-xs text-muted-foreground bg-background px-2 py-1 rounded border border-border">
        Copy
      </span>
    </div>
    <pre className="bg-secondary/20 border border-border rounded-lg p-4 overflow-x-auto font-mono text-sm text-foreground">
      {children}
    </pre>
  </div>
);

const ParamTable = ({ params }: { params: { name: string; type: string; desc: string }[] }) => (
  <div className="overflow-x-auto mt-4 mb-8">
    <table className="w-full text-left text-sm border-collapse">
      <thead>
        <tr className="border-b border-border">
          <th className="py-2 px-4 font-semibold text-foreground w-32">Name</th>
          <th className="py-2 px-4 font-semibold text-foreground w-48">Type</th>
          <th className="py-2 px-4 font-semibold text-foreground">Description</th>
        </tr>
      </thead>
      <tbody>
        {params.map((p, i) => (
          <tr key={i} className="border-b border-border/50 hover:bg-secondary/10">
            <td className="py-3 px-4 font-mono text-primary">{p.name}</td>
            <td className="py-3 px-4 font-mono text-muted-foreground">{p.type}</td>
            <td className="py-3 px-4 text-muted-foreground">{p.desc}</td>
          </tr>
        ))}
      </tbody>
    </table>
  </div>
);

export default function DocsPage() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Sidebar / Layout container could go here for full docs site */}
      <div className="max-w-5xl mx-auto p-8 md:p-12">
        
        <div className="mb-12 border-b border-border pb-8">
          <div className="flex items-center gap-2 text-sm text-muted-foreground mb-4">
            <Link href="/" className="hover:text-primary transition-colors">Dashboard</Link>
            <span>/</span>
            <span className="text-foreground">Documentation</span>
          </div>
          
          <h1 className="text-4xl font-bold tracking-tight mb-4">
            OneTx Contract Interfaces
          </h1>
          <p className="text-xl text-muted-foreground max-w-3xl leading-relaxed">
            User-facing methods of the OneTx protocol. Use these interfaces to discover yield adapters and execute single-transaction swaps & deposits.
          </p>
        </div>

        <div className="space-y-16">
          
          {/* Contract Addresses */}
          <section>
            <h2 className="text-2xl font-bold mb-4">Contract Addresses</h2>
            <p className="text-muted-foreground mb-6">
              The core contracts are deployed on <span className="font-semibold text-foreground">Base Sepolia</span>.
            </p>
            
            <div className="grid gap-4 md:grid-cols-2">
              <div className="p-4 border border-border rounded-lg bg-card/30">
                <div className="text-sm font-semibold text-muted-foreground mb-1">SwapDepositor Hook</div>
                <div className="font-mono text-sm text-primary break-all">0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4</div>
              </div>
              <div className="p-4 border border-border rounded-lg bg-card/30">
                <div className="text-sm font-semibold text-muted-foreground mb-1">AdapterRegistry</div>
                <div className="font-mono text-sm text-primary break-all">0x7425AAa97230f6D575193667cfd402b0B89C47f2</div>
              </div>
            </div>
          </section>

          {/* Interfaces Section */}
          <section>
             <div className="flex items-center gap-2 mb-8">
                <h2 className="text-2xl font-bold">Interfaces</h2>
                <span className="px-2 py-0.5 rounded-full bg-blue-500/10 text-blue-400 text-xs font-medium border border-blue-500/20">v1.0.0</span>
             </div>

             {/* Method 1: Swap Router */}
             <div className="mb-16">
                <h3 className="text-xl font-semibold mb-2 group cursor-pointer flex items-center gap-2">
                   <span className="text-primary">swap</span>
                   <span className="text-muted-foreground font-normal text-base">(Trade & Deposit)</span>
                </h3>
                <p className="text-muted-foreground mb-4">
                   Executes a swap on Uniswap V4 and automatically deposits the output token into the specified lending protocol via the hook.
                </p>
                
                <CodeBlock>
{`function swap(
  PoolKey memory key,
  IPoolManager.SwapParams memory params,
  bytes calldata hookData
) external payable returns (BalanceDelta delta);`}
                </CodeBlock>

                <h4 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mt-6">Parameters</h4>
                <ParamTable params={[
                  { name: "key", type: "PoolKey", desc: "The V4 pool key (must include SwapDepositor hook)." },
                  { name: "params", type: "SwapParams", desc: "Standard V4 swap parameters (amount, direction)." },
                  { name: "hookData", type: "bytes", desc: "Encoded (string adapterId, address recipient)." }
                ]} />

                <div className="bg-blue-500/5 border border-blue-500/20 rounded-lg p-4 mt-4">
                   <h4 className="text-sm font-semibold text-blue-400 mb-2">Encoding HookData</h4>
                   <p className="text-sm text-muted-foreground mb-2">
                      The <code className="text-foreground">hookData</code> must be ABI encoded. The hook decodes this to find the target adapter and the final recipient of the aTokens.
                   </p>
                   <pre className="text-xs font-mono text-muted-foreground bg-black/20 p-3 rounded">
                      abi.encode(string("USDC:BASE_SEPOLIA:word.base.eth"), address(recipient))
                   </pre>
                </div>
             </div>

             {/* Method 2: Resolve Adapter */}
             <div className="mb-16">
                <h3 className="text-xl font-semibold mb-2 group cursor-pointer flex items-center gap-2">
                   <span className="text-primary">resolveAdapter</span>
                   <span className="text-muted-foreground font-normal text-base">(Discovery)</span>
                </h3>
                <p className="text-muted-foreground mb-4">
                   Resolves a human-readable Standard ID to its underlying adapter contract address.
                </p>
                
                <CodeBlock>
{`function resolveAdapter(string memory adapterId) external view returns (address);`}
                </CodeBlock>

                <h4 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mt-6">Parameters</h4>
                <ParamTable params={[
                  { name: "adapterId", type: "string", desc: "The ENS-based Standard ID (e.g. USDC:BASE...)." }
                ]} />
                
                <h4 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">Returns</h4>
                <ParamTable params={[
                  { name: "adapter", type: "address", desc: "The address of the ILendingAdapter contract." }
                ]} />
             </div>

             {/* Method 3: Get Adapter Metadata */}
             <div className="mb-16">
                <h3 className="text-xl font-semibold mb-2 group cursor-pointer flex items-center gap-2">
                   <span className="text-primary">getAdapterMetadata</span>
                   <span className="text-muted-foreground font-normal text-base">(Metadata)</span>
                </h3>
                <p className="text-muted-foreground mb-4">
                   Retrieves metadata for a specific adapter, useful for verification before swapping.
                </p>
                
                <CodeBlock>
{`function getAdapterMetadata() external view returns (AdapterMetadata memory);`}
                </CodeBlock>

                <h4 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground mt-6">Returns</h4>
                <ParamTable params={[
                  { name: "metadata", type: "AdapterMetadata", desc: "Struct containing protocol, token, and chainId." }
                ]} />
             </div>

          </section>

          {/* API Endpoint Section */}
          <section className="pt-8 border-t border-border">
             <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold">Data API</h2>
                <span className="text-sm text-muted-foreground">REST / JSON</span>
             </div>
             <p className="text-muted-foreground mb-6">
                For AI agents and off-chain applications, use the unified endpoint to discover all available yield opportunities.
             </p>

             <div className="bg-card border border-border rounded-lg overflow-hidden">
                <div className="flex items-center gap-4 bg-secondary/30 px-4 py-3 border-b border-border">
                   <span className="px-2 py-1 rounded text-xs font-bold bg-green-500/20 text-green-400">GET</span>
                   <code className="text-sm font-mono text-foreground">https://api.onetx.xyz/v1/adapters</code>
                </div>
                <div className="p-6">
                   <h4 className="text-sm font-semibold mb-3 text-foreground">Response Example</h4>
                   <pre className="text-xs font-mono text-muted-foreground leading-relaxed">
{`[
  {
    "id": "USDC:BASE_SEPOLIA:word-word.base.eth",
    "apy": 0.045,
    "tvl": "1250000",
    "risk": "LOW"
  },
  ...
]`}
                   </pre>
                </div>
             </div>
          </section>

        </div>
      </div>
    </div>
  );
}
