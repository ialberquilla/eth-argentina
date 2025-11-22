import { useWallets } from '@privy-io/react-auth';
import { createWalletClient, custom, encodeAbiParameters, parseAbiParameters, parseUnits } from 'viem';
import { baseSepolia } from 'viem/chains';
import { CONTRACTS, POOL_KEY } from '../lib/constants';
import { ERC20_ABI, SWAP_ROUTER_ABI } from '../lib/abis';

export const useSwapDepositor = () => {
  const { wallets } = useWallets();
  const wallet = wallets[0]; // Assume first wallet

  const swapAndDeposit = async (amountIn: string, adapterAddress: string) => {
    if (!wallet) throw new Error('No wallet connected');
    
    await wallet.switchChain(baseSepolia.id);
    const provider = await wallet.getEthereumProvider();
    const client = createWalletClient({
      chain: baseSepolia,
      transport: custom(provider),
    });

    const [address] = await client.getAddresses();

    // 1. Approve Router to spend USDC
    const amount = parseUnits(amountIn, 6); // USDC is 6 decimals
    
    console.log('Approving USDC...');
    await client.writeContract({
      address: CONTRACTS.TOKENS.USDC as `0x${string}`,
      abi: ERC20_ABI,
      functionName: 'approve',
      args: [CONTRACTS.SWAP_ROUTER as `0x${string}`, amount],
      account: address,
    });

    // 2. Prepare Swap Params
    // We are swapping USDC (1) -> USDT (0)
    // zeroForOne = false
    
    console.log('Encoding Hook Data...');
    const hookData = encodeAbiParameters(
      parseAbiParameters('string, string'),
      [adapterAddress, address] // adapter is passed as address string, recipient is self
    );

    // 3. Call Router
    console.log('Swapping...');
    const hash = await client.writeContract({
      address: CONTRACTS.SWAP_ROUTER as `0x${string}`,
      abi: SWAP_ROUTER_ABI,
      functionName: 'swap',
      args: [
        {
            currency0: POOL_KEY.currency0 as `0x${string}`,
            currency1: POOL_KEY.currency1 as `0x${string}`,
            fee: POOL_KEY.fee,
            tickSpacing: POOL_KEY.tickSpacing,
            hooks: POOL_KEY.hooks as `0x${string}`,
        },
        {
            zeroForOne: false, // USDC -> USDT
            amountSpecified: -amount, // Exact Input (negative for V4)
            sqrtPriceLimitX96: 0n, // No limit
        },
        { takeClaims: false, settleUsingBurn: false },
        hookData
      ],
      account: address,
      value: 0n,
    });
    
    return hash;
  };

  return { swapAndDeposit };
};