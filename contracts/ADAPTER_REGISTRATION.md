# Adapter Registration Standard

This document describes the standardized approach for registering lending adapters on ENS using human-readable identifiers.

## Overview

The `AdapterIdGenerator` library provides a consistent way to generate unique, human-readable identifiers for lending protocol adapters. These identifiers can be used for ENS registration, making adapters discoverable and verifiable on-chain.

## Format

All adapter IDs follow this standardized format:

```
SYMBOL:BLOCKCHAIN:WORD-WORD
```

### Components

1. **SYMBOL**: The token symbol the adapter is configured for (e.g., `USDC`, `DAI`, `WETH`)
2. **BLOCKCHAIN**: The human-readable name of the blockchain (e.g., `BASE`, `ETHEREUM`, `ARBITRUM`)
3. **WORD-WORD**: A memorable two-word identifier derived from the adapter's contract address (e.g., `swift-fox`, `bright-eagle`)

### Examples

- `USDC:BASE:swift-fox` - USDC adapter on Base
- `DAI:ETHEREUM:golden-wolf` - DAI adapter on Ethereum mainnet
- `WETH:ARBITRUM:royal-hawk` - WETH adapter on Arbitrum

## ENS Integration

For ENS registration, the adapter ID is combined with a domain suffix:

```
SYMBOL:BLOCKCHAIN:WORD-WORD.domain
```

Example: `USDC:BASE:swift-fox.adapters.eth`

## Usage

### Basic Usage

```solidity
import {AdapterIdGenerator} from "./libraries/AdapterIdGenerator.sol";
import {ILendingAdapter} from "./interfaces/ILendingAdapter.sol";

// Get metadata from your adapter
ILendingAdapter.AdapterMetadata memory metadata = adapter.getAdapterMetadata();

// Generate the standardized ID
string memory adapterId = AdapterIdGenerator.generateAdapterId(metadata);
// Result: "USDC:BASE:swift-fox" (word-based identifier is deterministic)
```

### ENS Registration

```solidity
// Generate full ENS name
string memory ensName = AdapterIdGenerator.generateAdapterIdWithDomain(
    metadata,
    "adapters.eth"
);
// Result: "USDC:BASE:swift-fox.adapters.eth"

// Generate ENS namehash for registration
bytes32 node = AdapterIdGenerator.generateENSNode(metadata, "adapters.eth");

// Use this node to register in your ENS registry
ensRegistry.setSubnodeRecord(parentNode, labelHash, owner, resolver, ttl);
```

### Complete Example

```solidity
// 1. Deploy your adapter
AaveAdapter adapter = new AaveAdapter(aavePoolAddress, "USDC");

// 2. Get the metadata
ILendingAdapter.AdapterMetadata memory metadata = adapter.getAdapterMetadata();

// 3. Generate the ENS node
bytes32 node = AdapterIdGenerator.generateENSNode(metadata, "adapters.eth");

// 4. Register in ENS
// (ENS registration code here)

// 5. Set resolver to point to the adapter
ensResolver.setAddr(node, address(adapter));
```

## Supported Blockchains

The library includes mappings for major EVM chains:

### Mainnets
- Ethereum (1) → `ETHEREUM`
- Base (8453) → `BASE`
- Optimism (10) → `OPTIMISM`
- Arbitrum (42161) → `ARBITRUM`
- Polygon (137) → `POLYGON`
- BSC (56) → `BSC`
- Avalanche (43114) → `AVALANCHE`
- zkSync (324) → `ZKSYNC`
- Linea (59144) → `LINEA`
- Scroll (534352) → `SCROLL`
- Blast (81457) → `BLAST`
- And more...

### Testnets
- Sepolia (11155111) → `SEPOLIA`
- Base Sepolia (84532) → `BASE_SEPOLIA`
- Arbitrum Sepolia (421614) → `ARBITRUM_SEPOLIA`
- Optimism Sepolia (11155420) → `OPTIMISM_SEPOLIA`

### Unknown Chains
For chains not in the mapping, the format defaults to `CHAIN_{chainId}`:
- Example: Chain ID 999999 → `CHAIN_999999`

## Benefits

1. **Consistency**: All adapters follow the same naming convention
2. **Human-Readable**: Easy to understand what each adapter is for
3. **Unique**: Combination of symbol, chain, and address ensures uniqueness
4. **Discoverable**: ENS integration makes adapters easy to find
5. **Verifiable**: Address hash allows verification of the correct contract

## Implementation Details

### Word-Based Address Encoding

The word-based identifier uses a deterministic hash of the adapter's contract address to select two words from predefined dictionaries:

```solidity
// Input: 0x1234567890123456789012345678901234567890 (adapter address)
// Output: "swift-fox" (deterministic based on keccak256 hash)
```

This provides:
- **Uniqueness**: Each deployed adapter instance has a unique address, ensuring no collisions even when multiple adapters use the same underlying protocol
- **Human-Friendly**: Easy to remember and communicate (e.g., "swift-fox", "golden-eagle")
- **Deterministic**: Always produces the same word pair for the same adapter address
- **No Hex**: Completely human-readable with no technical characters
- **Flexibility**: 4,096 possible combinations (64 adjectives × 64 nouns)

### Chain Name Resolution

Chain IDs are mapped to uppercase, human-readable names. Unknown chains use the format `CHAIN_{chainId}` to maintain uniqueness while indicating the chain ID.

## Testing

Run the test suite to verify the implementation:

```bash
forge test --match-path test/AdapterIdGenerator.t.sol -vv
```

The tests cover:
- ID generation for various chains
- ENS node generation
- Address hashing
- Chain name resolution
- Uniqueness guarantees
- Real-world examples

## Integration with Existing Adapters

All adapters implementing `ILendingAdapter` can use this library since they're required to implement `getAdapterMetadata()`:

```solidity
interface ILendingAdapter {
    function getAdapterMetadata() external view returns (AdapterMetadata memory);
    // ...
}
```

This ensures every adapter can generate its standardized ID without additional configuration.

## Future Enhancements

Potential future improvements:

1. **On-chain Registry**: A contract that maintains a registry of all registered adapters
2. **Reverse Lookup**: Query adapters by symbol and chain
3. **Metadata Storage**: Store additional adapter information in ENS records
4. **Version Management**: Support multiple versions of the same adapter

## Examples

See `script/RegisterAdapter.s.sol` for complete examples of:
- Generating adapter IDs
- Creating ENS names
- Working with deployed adapters
- Batch registration of multiple adapters
