#!/bin/bash

# Script to run Base mainnet fork tests for SwapDepositor
# Usage: ./test-fork.sh [test_name]
# Example: ./test-fork.sh testMainnetForkSwapWithAaveDeposit

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Running Base Mainnet Fork Tests${NC}"
echo "================================"

# Check if RPC URL is set
if [ -z "$BASE_RPC_URL" ]; then
    echo "❌ BASE_RPC_URL not set"
    echo "Please set BASE_RPC_URL environment variable"
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
