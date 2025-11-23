#!/bin/bash

# USDC Bridge Test Script
# Bridges USDC from Arc Testnet to Base Sepolia

set -e

echo "=============================================="
echo "USDC Bridge Test Script"
echo "Arc Testnet → Base Sepolia"
echo "=============================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    echo ""
    echo "Please create a .env file with:"
    echo "  PRIVATE_KEY=your_private_key_here"
    echo ""
    exit 1
fi

# Check if PRIVATE_KEY is set
if ! grep -q "PRIVATE_KEY" .env; then
    echo "❌ Error: PRIVATE_KEY not found in .env"
    echo ""
    echo "Please add to .env file:"
    echo "  PRIVATE_KEY=your_private_key_here"
    echo ""
    exit 1
fi

echo "📋 Options:"
echo "  1. Run complete automated bridge test (TypeScript)"
echo "  2. Run Foundry script - Bridge from Arc"
echo "  3. Run Foundry script - Check balances"
echo "  4. Run Foundry script - Check bridge status"
echo ""
read -p "Select option (1-4): " option

case $option in
    1)
        echo ""
        echo "🚀 Running automated bridge test..."
        echo ""

        # Check if node_modules exists
        if [ ! -d "node_modules" ]; then
            echo "📦 Installing dependencies..."
            npm install
            echo ""
        fi

        npx ts-node script/testing/test-usdc-bridge.ts
        ;;

    2)
        echo ""
        echo "🌉 Bridging USDC from Arc Testnet..."
        echo ""

        forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
            --rpc-url https://rpc.testnet.arc.network \
            --broadcast \
            --legacy \
            -vvv
        ;;

    3)
        echo ""
        echo "💰 Checking balances..."
        echo ""

        echo "Arc Testnet:"
        forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
            --sig "checkBalance()" \
            --rpc-url https://rpc.testnet.arc.network

        echo ""
        echo "Base Sepolia:"
        forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
            --sig "checkBalance()" \
            --rpc-url https://sepolia.base.org
        ;;

    4)
        echo ""
        echo "🔍 Checking bridge status..."
        echo ""

        echo "Arc Testnet Bridge:"
        forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
            --sig "checkBridgeStatus()" \
            --rpc-url https://rpc.testnet.arc.network

        echo ""
        echo "Base Sepolia Bridge:"
        forge script script/TestCCTPBridge.s.sol:TestCCTPBridge \
            --sig "checkBridgeStatus()" \
            --rpc-url https://sepolia.base.org
        ;;

    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "=============================================="
echo "✅ Done!"
echo "=============================================="
