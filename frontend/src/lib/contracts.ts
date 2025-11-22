/**
 * Contract addresses and ABIs for Uniswap V4 on Base Sepolia
 */

export const CONTRACTS = {
  BASE_SEPOLIA: {
    POOL_MANAGER: "0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829",
    SWAP_ROUTER: "0xC81462Fec8B23319F288047f8A03A57682a35C1A", // Uniswap V4 SwapRouter on Base Sepolia
    USDT: "0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a",
    USDC: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f",
    HOOK: "0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4",
    ADAPTER: "0x6F0b25e2abca0b60109549b7823392e3312f505c",
    AAVE_POOL: "0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951",
  },
} as const;

/**
 * Minimal ABI for ERC20 token approval
 */
export const ERC20_ABI = [
  {
    type: "function",
    name: "approve",
    stateMutability: "nonpayable",
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [{ type: "bool" }],
  },
  {
    type: "function",
    name: "allowance",
    stateMutability: "view",
    inputs: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
    ],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "balanceOf",
    stateMutability: "view",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ type: "uint256" }],
  },
] as const;

/**
 * ABI for Uniswap V4 SwapRouter (IUniswapV4Router04)
 * Based on hookmate router interface
 */
export const SWAP_ROUTER_ABI = [
  {
    type: "function",
    name: "swapExactTokensForTokens",
    stateMutability: "payable",
    inputs: [
      { name: "amountIn", type: "uint256" },
      { name: "amountOutMin", type: "uint256" },
      { name: "zeroForOne", type: "bool" },
      {
        name: "poolKey",
        type: "tuple",
        components: [
          { name: "currency0", type: "address" },
          { name: "currency1", type: "address" },
          { name: "fee", type: "uint24" },
          { name: "tickSpacing", type: "int24" },
          { name: "hooks", type: "address" },
        ],
      },
      { name: "hookData", type: "bytes" },
      { name: "receiver", type: "address" },
      { name: "deadline", type: "uint256" },
    ],
    outputs: [{ name: "amountOut", type: "uint256" }],
  },
] as const;

/**
 * Pool configuration for USDC/USDT pool
 */
export const POOL_CONFIG = {
  currency0: CONTRACTS.BASE_SEPOLIA.USDC,
  currency1: CONTRACTS.BASE_SEPOLIA.USDT,
  fee: 3000, // 0.3%
  tickSpacing: 60,
  hooks: CONTRACTS.BASE_SEPOLIA.HOOK,
} as const;
