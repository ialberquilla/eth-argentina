"use client";

export default function DocsPage() {
  return (
    <div className="min-h-screen bg-background p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-8">For AI Agents</h1>

        <div className="space-y-8">
          {/* Step 1 */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">Step 1: Get All Products</h2>
            <p className="text-muted-foreground mb-4">
              Call <code className="bg-muted px-2 py-1 rounded">getAllRegisteredAdapters()</code> on the AdapterRegistry to get all available products.
            </p>

            <div className="bg-muted p-4 rounded-lg mb-4">
              <p className="text-sm text-muted-foreground mb-2">Contract Address (Base Sepolia):</p>
              <code className="text-sm">0x045B9a7505164B418A309EdCf9A45EB1fE382951</code>
            </div>

            <div className="bg-black p-4 rounded-lg overflow-x-auto">
              <pre className="text-sm text-green-400">
{`const products = await contract.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  abi: [{
    name: 'getAllRegisteredAdapters',
    outputs: [{
      components: [
        { name: 'adapterAddress', type: 'address' },
        { name: 'ensNode', type: 'bytes32' },
        { name: 'domain', type: 'string' },
        { name: 'adapterId', type: 'string' }
      ],
      type: 'tuple[]'
    }],
    stateMutability: 'view',
    type: 'function'
  }],
  functionName: 'getAllRegisteredAdapters'
});`}
              </pre>
            </div>

            <div className="mt-4 bg-muted p-4 rounded-lg">
              <p className="text-sm font-semibold mb-2">Returns:</p>
              <pre className="text-sm overflow-x-auto">
{`[
  {
    adapterId: "USDC:BASE_SEPOLIA:word-word.base.eth",
    adapterAddress: "0x3903D3A1d5F18925ac9c76F2dC52d1447B1AbfCF",
    ensNode: "0x...",
    domain: "base.eth"
  },
  {
    adapterId: "USDT:BASE_SEPOLIA:word-word.base.eth",
    adapterAddress: "0x5531bc190eC0C74dC8694176Ad849277AbA21a5D",
    ensNode: "0x...",
    domain: "base.eth"
  }
]`}
              </pre>
            </div>
          </section>

          {/* Step 2 */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">Step 2: Buy a Product</h2>
            <p className="text-muted-foreground mb-4">
              Call Uniswap V4 <code className="bg-muted px-2 py-1 rounded">swap()</code> with hookData containing the product's adapterId.
            </p>

            <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-lg p-4 mb-4">
              <p className="text-sm font-semibold mb-2">You need:</p>
              <ul className="list-disc list-inside text-sm space-y-1">
                <li>USDC in your wallet</li>
                <li>The <code className="bg-muted px-1 rounded">adapterId</code> from step 1</li>
                <li>Your recipient address</li>
              </ul>
            </div>

            <div className="bg-black p-4 rounded-lg overflow-x-auto">
              <pre className="text-sm text-green-400">
{`import { encodeAbiParameters } from 'viem';

// Encode hookData with adapterId and your address
const hookData = encodeAbiParameters(
  [
    { type: 'string', name: 'adapterIdentifier' },
    { type: 'string', name: 'recipientIdentifier' }
  ],
  [
    'USDC:BASE_SEPOLIA:word-word.base.eth',  // adapterId from step 1
    '0xYourAddress'                           // your address
  ]
);

// Call swap on Uniswap V4
// (You'll need to set up poolKey and swapParams)
await walletClient.writeContract({
  address: SWAP_ROUTER_ADDRESS,
  abi: swapRouterABI,
  functionName: 'swap',
  args: [poolKey, swapParams, hookData]
});

// Done! You now hold yield-bearing tokens (e.g., aUSDC from Aave)`}
              </pre>
            </div>
          </section>

          {/* What Happens */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">What Happens</h2>
            <p className="text-muted-foreground mb-4">
              The SwapDepositor hook automatically:
            </p>
            <ol className="list-decimal list-inside space-y-2 text-muted-foreground">
              <li>Takes your swap output tokens</li>
              <li>Deposits them to the lending protocol (Aave, Compound, etc.)</li>
              <li>Sends you the yield-bearing tokens</li>
            </ol>
            <p className="mt-4 text-sm font-semibold">
              All in one transaction ✨
            </p>
          </section>

          {/* Complete Example */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">Complete Example</h2>
            <div className="bg-black p-4 rounded-lg overflow-x-auto">
              <pre className="text-sm text-green-400">
{`import { createPublicClient, createWalletClient, http, encodeAbiParameters } from 'viem';
import { baseSepolia } from 'viem/chains';

// 1. Get all products
const publicClient = createPublicClient({
  chain: baseSepolia,
  transport: http('https://sepolia.base.org')
});

const products = await publicClient.readContract({
  address: '0x045B9a7505164B418A309EdCf9A45EB1fE382951',
  abi: registryABI,
  functionName: 'getAllRegisteredAdapters'
});

console.log('Available products:', products);

// 2. Select a product (e.g., first one)
const selectedProduct = products[0];
console.log('Selected:', selectedProduct.adapterId);

// 3. Prepare hookData
const hookData = encodeAbiParameters(
  [{ type: 'string' }, { type: 'string' }],
  [selectedProduct.adapterId, myAddress]
);

// 4. Execute swap
const walletClient = createWalletClient({
  chain: baseSepolia,
  transport: custom(window.ethereum)
});

await walletClient.writeContract({
  address: SWAP_ROUTER_ADDRESS,
  abi: swapRouterABI,
  functionName: 'swap',
  args: [poolKey, swapParams, hookData]
});

// Done! Check your wallet for yield-bearing tokens`}
              </pre>
            </div>
          </section>

          {/* Contract Addresses */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">Contract Addresses (Base Sepolia)</h2>
            <div className="space-y-3 font-mono text-sm">
              <div className="grid grid-cols-[200px_1fr] gap-4">
                <span className="text-muted-foreground">AdapterRegistry:</span>
                <code>0x045B9a7505164B418A309EdCf9A45EB1fE382951</code>
              </div>
              <div className="grid grid-cols-[200px_1fr] gap-4">
                <span className="text-muted-foreground">SwapDepositor:</span>
                <code>0xa97800be965c982c381E161124A16f5450C080c4</code>
              </div>
              <div className="grid grid-cols-[200px_1fr] gap-4">
                <span className="text-muted-foreground">Pool Manager:</span>
                <code>0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829</code>
              </div>
            </div>
          </section>

          {/* What You Get */}
          <section className="bg-card border border-border rounded-lg p-6">
            <h2 className="text-2xl font-bold mb-4">What You Get</h2>
            <p className="text-muted-foreground mb-4">
              When you buy a product, you receive <span className="font-semibold text-foreground">yield-bearing tokens</span>:
            </p>
            <ul className="space-y-2 text-muted-foreground">
              <li>• USDC product → <code className="bg-muted px-2 py-1 rounded">aUSDC</code> (Aave interest-bearing USDC)</li>
              <li>• USDT product → <code className="bg-muted px-2 py-1 rounded">aUSDT</code> (Aave interest-bearing USDT)</li>
            </ul>
            <p className="mt-4 text-sm text-muted-foreground">
              These tokens automatically earn yield. Your balance grows over time.
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}
