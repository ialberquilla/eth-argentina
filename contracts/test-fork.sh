#!/bin/bash

# Script to run Base mainnet fork tests for SwapDepositor
#
# This test demonstrates the complete adapter registration flow:
# 1. Deploy AdapterRegistry contract
# 2. Deploy AaveAdapter with symbol (e.g., "USDbC")
# 3. Register adapter in registry (generates ENS name like "USDBC:BASE:word-word.adapters.eth")
# 4. Perform swaps using the adapter ENS name instead of address
# 5. Hook resolves ENS name to adapter address on-chain
# 6. Hook calls adapter to deposit tokens to Aave
#
# Usage: ./test-fork.sh [test_name]
# Example: ./test-fork.sh testMainnetForkSwapWithAaveDeposit

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Base Mainnet Fork Tests${NC}"
echo "================================"

# Source .env file if it exists
if [ -f .env ]; then
    source .env
fi

# Check if RPC URL is set
if [ -z "$BASE_RPC_URL" ]; then
    echo "❌ BASE_RPC_URL not set"
    echo "Please set BASE_RPC_URL environment variable or add it to .env file"
    echo "Example: export BASE_RPC_URL=https://mainnet.base.org"
    exit 1
fi

echo ""
echo "Configuration:"
echo "  RPC URL: $BASE_RPC_URL"
if [ -n "$FORK_BLOCK_NUMBER" ]; then
    echo "  Fork Block: $FORK_BLOCK_NUMBER"
else
    echo "  Fork Block: latest"
fi
if [ -n "$LIQUIDITY_AMOUNT" ]; then
    echo "  Liquidity Amount: $LIQUIDITY_AMOUNT"
fi
echo ""

# Build forge command
FORGE_CMD="forge test --match-path 'test/SwapDepositor.mainnet.t.sol'"

# Add fork block if specified
if [ -n "$FORK_BLOCK_NUMBER" ]; then
    FORGE_CMD="$FORGE_CMD --fork-block-number $FORK_BLOCK_NUMBER"
fi

# Run the fork tests
if [ -z "$1" ]; then
    # Run all fork tests
    echo -e "${GREEN}Running all mainnet fork tests...${NC}"
    eval "$FORGE_CMD -vvv"
else
    # Run specific test
    echo -e "${GREEN}Running test: $1${NC}"
    eval "$FORGE_CMD --match-test '$1' -vvvv"
fi

echo ""
echo -e "${GREEN}✓ Fork tests completed${NC}"
