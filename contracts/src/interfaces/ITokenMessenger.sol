// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ITokenMessenger
 * @notice Interface for Circle's CCTP TokenMessenger contract
 * @dev Used to initiate cross-chain USDC transfers via depositForBurn
 */
interface ITokenMessenger {
    /**
     * @notice Deposits and burns tokens from sender to be minted on destination domain
     * @dev Emits a Burn event and calls MessageTransmitter's sendMessage
     * @param amount Amount of tokens to burn
     * @param destinationDomain Destination domain identifier
     * @param mintRecipient Address to receive minted tokens on destination chain
     * @param burnToken Address of token to burn (USDC)
     * @return nonce Unique nonce for the message
     */
    function depositForBurn(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken
    ) external returns (uint64 nonce);

    /**
     * @notice Deposits and burns tokens with caller specified destination caller on destination domain
     * @dev Emits a Burn event and calls MessageTransmitter's sendMessage
     * @param amount Amount of tokens to burn
     * @param destinationDomain Destination domain identifier
     * @param mintRecipient Address to receive minted tokens on destination chain
     * @param burnToken Address of token to burn (USDC)
     * @param destinationCaller Authorized caller on destination domain (zero bytes32 allows any caller)
     * @return nonce Unique nonce for the message
     */
    function depositForBurnWithCaller(
        uint256 amount,
        uint32 destinationDomain,
        bytes32 mintRecipient,
        address burnToken,
        bytes32 destinationCaller
    ) external returns (uint64 nonce);

    /**
     * @notice Returns the local minter (TokenMinter contract address)
     * @return Address of the TokenMinter
     */
    function localMinter() external view returns (address);

    /**
     * @notice Returns the local MessageTransmitter
     * @return Address of the MessageTransmitter
     */
    function localMessageTransmitter() external view returns (address);
}
