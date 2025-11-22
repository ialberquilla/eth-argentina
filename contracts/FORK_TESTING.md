# Fork Testing Guide

This guide explains how to run mainnet fork tests for the SwapDepositor hook on Base.

## Overview

The fork tests (`SwapDepositor.mainnet.t.sol`) test the SwapDepositor hook against **real Base mainnet contracts**:

- ✅ Real Aave V3 Pool on Base
- ✅ Real tokens (USDC, WETH)
- ✅ Real aTokens from Aave deposits
- ✅ Uniswap V4 infrastructure (deployed on fork for testing)

This provides much more realistic testing than mock contracts.

## Prerequisites

1. **Foundry** installed
2. **RPC access** to Base mainnet (optional - uses public RPC by default)

## Quick Start

### Run all fork tests:

```bash
cd contracts
./test-fork.sh
```

### Run a specific test:

```bash
./test-fork.sh testMainnetForkSwapWithAaveDeposit
```

### Run with custom RPC:

```bash
export BASE_RPC_URL="https://your-base-rpc-url"
./test-fork.sh
```

### Run with custom fork block:

```bash
export FORK_BLOCK_NUMBER=23000000
./test-fork.sh
```

## Test Cases

### 1. `testMainnetForkSwapWithoutHook`
Tests basic swapping without the hook functionality.
- Swaps USDC → WETH
- Verifies user receives WETH directly

### 2. `testMainnetForkSwapWithAaveDeposit`
Tests the main hook functionality with real Aave V3.
- Swaps USDC → WETH
- Automatically deposits WETH to Aave V3
- Verifies recipient receives aTokens (aWETH)
- Confirms user doesn't receive WETH directly

### 3. `testMainnetForkMultipleSwapsWithAaveDeposit`
Tests multiple consecutive swaps with Aave deposits.
- Performs 3 swaps in sequence
- Verifies aTokens accumulate correctly
- Tests hook state across multiple transactions

### 4. `testMainnetForkSwapReverseDirection`
Tests swapping in the opposite direction.
- Swaps WETH → USDC
- Deposits USDC to Aave V3
- Verifies recipient receives aUSDC

## How It Works

### Fork Setup
```solidity
vm.createSelectFork(vm.rpcUrl("base"), forkBlock);
```
Creates a fork of Base mainnet at a specific block.

### Real Contract Addresses
The tests use real Base mainnet contracts defined in `test/utils/BaseConstants.sol`:

```solidity
address constant AAVE_V3_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
address constant WETH = 0x4200000000000000000000000000000000000006;
address constant aUSDC = 0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB;
```

### Test Flow
1. **Fork Base mainnet** at recent block
2. **Deploy V4 infrastructure** (not yet on Base mainnet)
3. **Fund test accounts** using whale addresses via `vm.prank`
4. **Create liquidity pool** with USDC/WETH
5. **Execute swaps** with hook that deposits to Aave
6. **Verify** real aTokens received from Aave V3

### Funding Test Accounts
The tests use `vm.prank` to transfer tokens from whale addresses:

```solidity
vm.prank(USDC_WHALE);
usdc.transfer(user, 100000e6);
```

This works on a fork because we can impersonate any address.

## Advanced Usage

### Running with Forge Directly

```bash
forge test \
  --match-path "test/SwapDepositor.mainnet.t.sol" \
  --fork-url https://mainnet.base.org \
  --fork-block-number 22000000 \
  -vvv
```

### Verbosity Levels
- `-vv`: Show test results
- `-vvv`: Show logs and traces
- `-vvvv`: Show detailed traces (recommended for debugging)

### Gas Reports

```bash
forge test \
  --match-path "test/SwapDepositor.mainnet.t.sol" \
  --fork-url https://mainnet.base.org \
  --gas-report
```

## Configuration

### foundry.toml

```toml
[rpc_endpoints]
base = "https://mainnet.base.org"

[fork]
url = "${RPC_URL}"
block_number = 22000000
```

### Environment Variables

Create a `.env` file (optional):

```bash
# Custom RPC (recommended for faster/reliable testing)
BASE_RPC_URL=https://base-mainnet.g.alchemy.com/v2/YOUR_KEY

# Custom fork block
FORK_BLOCK_NUMBER=23000000
```

## Troubleshooting

### "insufficient funds" error
The whale addresses may have moved funds. Update `BaseConstants.sol` with current whale addresses or increase the fork block number.

### RPC rate limiting
If using public RPC, you may hit rate limits. Solutions:
1. Use a dedicated RPC provider (Alchemy, Infura, etc.)
2. Set `FORK_BLOCK_NUMBER` to a recent block
3. Run fewer tests at once

### "Transaction reverted" in Aave deposit
Ensure the fork block is recent enough that Aave V3 is deployed and functional.

## Comparison: Local vs Fork Tests

| Aspect | Local Tests | Fork Tests |
|--------|-------------|------------|
| **Speed** | ⚡ Fast | 🐢 Slower (RPC calls) |
| **Realism** | Mock contracts | Real contracts |
| **Aave Testing** | MockAavePool | Real Aave V3 |
| **Token Testing** | Mock ERC20s | Real USDC/WETH |
| **Cost** | Free | Free (read-only) |
| **Use Case** | Quick iteration | Integration testing |

## Best Practices

1. **Use local tests for rapid development** - Fast feedback loop
2. **Use fork tests before deployment** - Verify real contract integration
3. **Pin fork block** - Use `FORK_BLOCK_NUMBER` for reproducibility
4. **Use dedicated RPC** - Avoid rate limits on public endpoints
5. **Test edge cases** - Fork tests catch real-world issues

## Next Steps

After fork tests pass:
1. Deploy to Base testnet (Sepolia)
2. Test with testnet UI
3. Deploy to Base mainnet
4. Monitor with real users

## Resources

- [Base Mainnet](https://base.org)
- [Aave V3 on Base](https://app.aave.com/?marketName=proto_base_v3)
- [Foundry Fork Testing](https://book.getfoundry.sh/forge/fork-testing)
- [Base Contract Addresses](https://docs.base.org/docs/contracts)
