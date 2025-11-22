/**
 * Contract addresses and ABIs for Uniswap V4 on Base Sepolia
 */

export const CONTRACTS = {
  BASE_SEPOLIA: {
    POOL_MANAGER: "0x7da1d65f8b249183667cde74c5cbd46dd38aa829",
    SWAP_ROUTER: "0x71cd4ea054f9cb3d3bf6251a00673303411a7dd9", // Hookmate V4 SwapRouter on Base Sepolia
    USDT: "0x0a215d8ba66387dca84b284d18c3b4ec3de6e54a",
    USDC: "0xba50cd2a20f6da35d788639e581bca8d0b5d4d5f",
    HOOK: "0x1d16eade6be2d9037f458d53d0b0fd216fc740c4",
    ADAPTER: "0x6f0b25e2abca0b60109549b7823392e3312f505c",
    AAVE_POOL: "0x6ae43d3271ff6888e7fc43fd7321a503ff738951",
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
