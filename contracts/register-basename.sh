#!/bin/bash

# Script to register a basename on Base Sepolia
# This is a two-step process with a 60-second wait

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Register Basename on Base Sepolia${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    exit 1
fi

source .env

if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${YELLOW}⚠️  PRIVATE_KEY not set${NC}"
    exit 1
fi

echo -e "${GREEN}Using the all-in-one method (60 second wait)${NC}"
echo ""
echo "This will:"
echo "1. Check if name is available"
echo "2. Submit commitment"
echo "3. Wait 60 seconds"
echo "4. Register the name"
echo ""
read -p "Press ENTER to continue, or Ctrl+C to abort: "

echo ""
echo -e "${GREEN}Running registration...${NC}"
echo ""

forge script script/RegisterBasename.s.sol \
    --rpc-url baseSepolia \
    --broadcast \
    -vvv

echo ""
echo -e "${GREEN}✓ Complete!${NC}"
echo ""
echo "Next step:"
echo "./deploy-base-sepolia.sh"
