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

# Check if RPC URL is set (optional, will use public RPC if not set)
if [ -z "$BASE_RPC_URL" ]; then
    echo "ℹ️  BASE_RPC_URL not set, using public Base RPC"
    export BASE_RPC_URL="https://mainnet.base.org"
fi

# Default to recent block if not specified
if [ -z "$FORK_BLOCK_NUMBER" ]; then
    export FORK_BLOCK_NUMBER=22000000
    echo "ℹ️  Using default fork block: $FORK_BLOCK_NUMBER"
fi

echo ""
echo "Configuration:"
echo "  RPC URL: $BASE_RPC_URL"
echo "  Fork Block: $FORK_BLOCK_NUMBER"
echo ""

# Run the fork tests
if [ -z "$1" ]; then
    # Run all fork tests
    echo -e "${GREEN}Running all mainnet fork tests...${NC}"
    forge test --match-path "test/SwapDepositor.mainnet.t.sol" --fork-url "$BASE_RPC_URL" --fork-block-number "$FORK_BLOCK_NUMBER" -vvv
else
    # Run specific test
    echo -e "${GREEN}Running test: $1${NC}"
    forge test --match-path "test/SwapDepositor.mainnet.t.sol" --match-test "$1" --fork-url "$BASE_RPC_URL" --fork-block-number "$FORK_BLOCK_NUMBER" -vvvv
fi

echo ""
echo -e "${GREEN}✓ Fork tests completed${NC}"
