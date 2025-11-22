// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title IMessageTransmitter
 * @notice Interface for Circle's CCTP MessageTransmitter contract
 * @dev Used to send and receive cross-chain messages
 */
interface IMessageTransmitter {
    /**
     * @notice Emitted when a message is sent
     * @param message Raw bytes of the message
     */
    event MessageSent(bytes message);

    /**
     * @notice Emitted when a message is received
     * @param caller Caller (msg.sender) on destination domain
     * @param sourceDomain Source domain
     * @param nonce Unique nonce
     * @param sender Sender on source domain
     * @param messageBody Message body bytes
     */
    event MessageReceived(
        address indexed caller,
        uint32 sourceDomain,
        uint64 indexed nonce,
        bytes32 sender,
        bytes messageBody
    );

    /**
     * @notice Receive a message from a remote chain
     * @dev Validates message and attestation, then triggers handler
     * @param message Formatted message (header + body)
     * @param attestation Attestation signature from Circle
     * @return success True if message was received successfully
     */
    function receiveMessage(bytes calldata message, bytes calldata attestation)
        external
        returns (bool success);

    /**
     * @notice Replace a message with a new message body and/or destination caller
     * @param originalMessage Original message bytes
     * @param originalAttestation Original attestation
     * @param newMessageBody New message body
     * @param newDestinationCaller New destination caller
     */
    function replaceMessage(
        bytes calldata originalMessage,
        bytes calldata originalAttestation,
        bytes calldata newMessageBody,
        bytes32 newDestinationCaller
    ) external;

    /**
     * @notice Send a message to a remote chain
     * @param destinationDomain Destination domain identifier
     * @param recipient Address of message recipient on destination domain
     * @param messageBody Raw bytes of message body
     * @return nonce Unique nonce for the message
     */
    function sendMessage(
        uint32 destinationDomain,
        bytes32 recipient,
        bytes calldata messageBody
    ) external returns (uint64 nonce);

    /**
     * @notice Send a message to a remote chain with a specified caller
     * @param destinationDomain Destination domain identifier
     * @param recipient Address of message recipient on destination domain
     * @param destinationCaller Caller on destination domain (zero bytes32 allows any caller)
     * @param messageBody Raw bytes of message body
     * @return nonce Unique nonce for the message
     */
    function sendMessageWithCaller(
        uint32 destinationDomain,
        bytes32 recipient,
        bytes32 destinationCaller,
        bytes calldata messageBody
    ) external returns (uint64 nonce);

    /**
     * @notice Returns maximum allowed message body size
     * @return Maximum message body size in bytes
     */
    function maxMessageBodySize() external view returns (uint256);

    /**
     * @notice Returns the next available nonce
     * @return Next nonce
     */
    function nextAvailableNonce() external view returns (uint64);

    /**
     * @notice Checks if a nonce has been used
     * @param sourceDomain Source domain
     * @param nonce Nonce to check
     * @return True if nonce has been used
     */
    function usedNonces(uint32 sourceDomain, uint64 nonce) external view returns (bool);
}
