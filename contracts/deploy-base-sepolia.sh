#!/bin/bash

# Script to deploy on Base Sepolia with ENS names
# This checks basename ownership and deploys everything

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Base Sepolia Deployment with ENS Names${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  .env file not found!${NC}"
    echo "Please create .env with:"
    echo "  PRIVATE_KEY=your_private_key"
    echo "  BASE_SEPOLIA_RPC_URL=https://sepolia.base.org"
    exit 1
fi

# Source .env to get variables
source .env

# Check if PRIVATE_KEY is set
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${YELLOW}⚠️  PRIVATE_KEY not set in .env${NC}"
    exit 1
fi

# Verify the address derived from the private key
echo -e "${GREEN}Step 0: Verifying configuration...${NC}"
LOADED_ADDRESS=$(cast wallet address "$PRIVATE_KEY")

if [ -z "$LOADED_ADDRESS" ]; then
     echo -e "${RED}Error: Could not derive address from PRIVATE_KEY.${NC}"
     exit 1
fi

echo "Loaded .env file."
echo "Deployer Address: $LOADED_ADDRESS"
echo ""

echo -e "${GREEN}Step 1: Checking basename ownership...${NC}"
echo ""

# Run script without broadcast to check ownership, passing the key explicitly
forge script script/RegisterBasenameAndDeploy.s.sol \
    --rpc-url baseSepolia \
    --private-key "$PRIVATE_KEY" \
    -vv

echo ""
echo -e "${GREEN}Step 2: Deploying contracts and registering ENS names...${NC}"
echo ""

# Deploy with broadcast, passing the key explicitly
forge script script/RegisterBasenameAndDeploy.s.sol \
    --rpc-url baseSepolia \
    --private-key "$PRIVATE_KEY" \
    --broadcast \
    --verify \
    -vvv

echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo "Check your deployment on BaseScan:"
echo "https://sepolia.basescan.org"
