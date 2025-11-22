export const CHAIN_ID = 84532;

export const CONTRACTS = {
  SWAP_DEPOSITOR_HOOK: '0x1d16EAde6bE2D9037f458D53d0B0fD216FC740C4',
  ADAPTER_REGISTRY: '0x7425AAa97230f6D575193667cfd402b0B89C47f2',
  SWAP_ROUTER: '0x71cD4Ea054F9Cb3D3BF6251A00673303411A7DD9',
  POOL_MANAGER: '0x7Da1D65F8B249183667cdE74C5CBD46dD38AA829',
  TOKENS: {
    USDC: '0xba50Cd2A20f6DA35D788639E581bca8d0B5d4D5f',
    USDT: '0x0a215D8ba66387DCA84B284D18c3B4ec3de6E54a',
  },
};

// Pool Key for USDT/USDC (Sorted: USDT < USDC)
// Currency0 = USDT
// Currency1 = USDC
export const POOL_KEY = {
  currency0: CONTRACTS.TOKENS.USDT,
  currency1: CONTRACTS.TOKENS.USDC,
  fee: 3000,
  tickSpacing: 60,
  hooks: CONTRACTS.SWAP_DEPOSITOR_HOOK,
};

// If user has USDC (Currency1) and wants to get USDT (Currency0) -> 1 -> 0
// zeroForOne = false (Wait, 0->1 is zeroForOne. 1->0 is oneForZero = false? No. zeroForOne=false means 1 -> 0)
// Yes. zeroForOne=true (0->1). zeroForOne=false (1->0).
