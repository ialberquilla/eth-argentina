/**
 * Contract addresses and ABIs for Uniswap V4 on Base Sepolia
 */

export const CONTRACTS = {
  ARC_TESTNET: {
    CCTP_BRIDGE: "0x2Bd7115Db8FFdcB077C8a146401aBd4A5E982903",
  },
  BASE_SEPOLIA: {
    POOL_MANAGER: "0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829",
    SWAP_ROUTER: "0x71cD4Ea054F9Cb3D3BF6251A00673303411A7DD9", // Hookmate V4 SwapRouter on Base Sepolia
    USDT: "0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a",
    USDC: "0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f",
    HOOK: "0xd1b0f8F27aad2292765E2Ca645e7eF1A692980c4",
    ADAPTER: "0x992A8847C28F9cD9251D5382249A4d35523F510A",
    AAVE_POOL: "0x6645D1d54aA2450e048cbdca38e032cfe8da7845",
    CCTP_BRIDGE: "0x4c23382b26C3ab153f1479b8be2545AB620eD6F2",
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
  currency0: CONTRACTS.BASE_SEPOLIA.USDT,
  currency1: CONTRACTS.BASE_SEPOLIA.USDC,
  fee: 3000, // 0.3%
  tickSpacing: 60,
  hooks: CONTRACTS.BASE_SEPOLIA.HOOK,
} as const;
