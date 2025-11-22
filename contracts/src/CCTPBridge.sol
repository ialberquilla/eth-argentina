// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ITokenMessenger} from "./interfaces/ITokenMessenger.sol";
import {IMessageTransmitter} from "./interfaces/IMessageTransmitter.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

/**
 * @title CCTPBridge
 * @notice Facilitates cross-chain USDC transfers from Arc to Base using Circle's CCTP
 * @dev This contract handles the source chain operations for bridging USDC
 * @dev On the destination chain, it can trigger automated swaps after receiving funds
 */
contract CCTPBridge {
    /// @notice Circle's TokenMessenger contract for CCTP
    ITokenMessenger public immutable tokenMessenger;

    /// @notice Circle's MessageTransmitter contract for CCTP
    IMessageTransmitter public immutable messageTransmitter;

    /// @notice USDC token contract
    IERC20 public immutable usdc;

    /// @notice Domain ID for the destination chain (Base = 6, Arc Testnet = 26)
    uint32 public immutable destinationDomain;

    /// @notice Address of the CCTPBridge contract on the destination chain
    address public destinationBridge;

    /// @notice Emitted when USDC is bridged to another chain
    event USDCBridged(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint32 destinationDomain,
        uint64 nonce,
        bytes32 swapParams
    );

    /// @notice Emitted when USDC is received from another chain
    event USDCReceived(
        address indexed recipient,
        uint256 amount,
        uint32 sourceDomain,
        uint64 nonce
    );

    /// @notice Emitted when a swap is executed after receiving bridged USDC
    event SwapExecuted(
        address indexed recipient,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut
    );

    error InvalidAmount();
    error InvalidRecipient();
    error InsufficientAllowance();
    error DestinationBridgeNotSet();

    /**
     * @notice Constructor
     * @param _tokenMessenger Address of Circle's TokenMessenger contract
     * @param _messageTransmitter Address of Circle's MessageTransmitter contract
     * @param _usdc Address of USDC token
     * @param _destinationDomain Domain ID of the destination chain
     */
    constructor(
        address _tokenMessenger,
        address _messageTransmitter,
        address _usdc,
        uint32 _destinationDomain
    ) {
        tokenMessenger = ITokenMessenger(_tokenMessenger);
        messageTransmitter = IMessageTransmitter(_messageTransmitter);
        usdc = IERC20(_usdc);
        destinationDomain = _destinationDomain;
    }

    /**
     * @notice Set the destination bridge address (only callable by owner in production)
     * @param _destinationBridge Address of CCTPBridge on destination chain
     */
    function setDestinationBridge(address _destinationBridge) external {
        // In production, add access control here
        destinationBridge = _destinationBridge;
    }

    /**
     * @notice Bridge USDC to destination chain (Base) without automatic swap
     * @param amount Amount of USDC to bridge
     * @param recipient Address to receive USDC on destination chain
     * @return nonce Unique identifier for this bridge transaction
     */
    function bridgeUSDC(uint256 amount, address recipient) external returns (uint64 nonce) {
        if (amount == 0) revert InvalidAmount();
        if (recipient == address(0)) revert InvalidRecipient();

        // Transfer USDC from sender to this contract
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Approve TokenMessenger to burn USDC
        require(usdc.approve(address(tokenMessenger), amount), "Approval failed");

        // Convert recipient address to bytes32
        bytes32 mintRecipient = bytes32(uint256(uint160(recipient)));

        // Initiate cross-chain transfer via CCTP
        nonce = tokenMessenger.depositForBurn(
            amount,
            destinationDomain,
            mintRecipient,
            address(usdc)
        );

        emit USDCBridged(msg.sender, recipient, amount, destinationDomain, nonce, bytes32(0));
    }

    /**
     * @notice Bridge USDC to Base and trigger a swap on arrival
     * @dev Encodes swap parameters to be executed on the destination chain
     * @param amount Amount of USDC to bridge
     * @param recipient Address to receive swapped tokens on destination chain
     * @param swapParams Encoded swap parameters (tokenOut, minAmountOut, deadline, etc.)
     * @return nonce Unique identifier for this bridge transaction
     */
    function bridgeAndSwap(
        uint256 amount,
        address recipient,
        bytes calldata swapParams
    ) external returns (uint64 nonce) {
        if (amount == 0) revert InvalidAmount();
        if (recipient == address(0)) revert InvalidRecipient();
        if (destinationBridge == address(0)) revert DestinationBridgeNotSet();

        // Transfer USDC from sender to this contract
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Approve TokenMessenger to burn USDC
        require(usdc.approve(address(tokenMessenger), amount), "Approval failed");

        // Convert destination bridge address to bytes32
        bytes32 mintRecipient = bytes32(uint256(uint160(destinationBridge)));

        // Use depositForBurnWithCaller to ensure only destination bridge can mint
        bytes32 destinationCaller = bytes32(uint256(uint160(destinationBridge)));

        // Initiate cross-chain transfer via CCTP with specified caller
        nonce = tokenMessenger.depositForBurnWithCaller(
            amount,
            destinationDomain,
            mintRecipient,
            address(usdc),
            destinationCaller
        );

        // Encode message body with recipient and swap params
        bytes memory messageBody = abi.encode(recipient, swapParams);

        // Send additional message with swap instructions
        messageTransmitter.sendMessageWithCaller(
            destinationDomain,
            mintRecipient,
            destinationCaller,
            messageBody
        );

        emit USDCBridged(
            msg.sender,
            recipient,
            amount,
            destinationDomain,
            nonce,
            keccak256(swapParams)
        );
    }

    /**
     * @notice Receive bridged USDC and execute swap on destination chain
     * @dev This function is called by the MessageTransmitter after attestation
     * @param messageBody Encoded message containing recipient and swap parameters
     */
    function handleReceiveMessage(
        uint32 sourceDomain,
        bytes32 sender,
        bytes calldata messageBody
    ) external {
        // Verify caller is the MessageTransmitter
        require(msg.sender == address(messageTransmitter), "Invalid caller");

        // Decode message body
        (address recipient, bytes memory swapParams) = abi.decode(messageBody, (address, bytes));

        // Get USDC balance to determine amount received
        uint256 amount = usdc.balanceOf(address(this));

        if (swapParams.length > 0) {
            // Execute swap if swap parameters are provided
            _executeSwap(recipient, amount, swapParams);
        } else {
            // Transfer USDC directly to recipient
            require(usdc.transfer(recipient, amount), "Transfer failed");
            emit USDCReceived(recipient, amount, sourceDomain, 0);
        }
    }

    /**
     * @notice Internal function to execute swap on destination chain
     * @dev Override this function to integrate with specific DEX (Uniswap V4, etc.)
     * @param recipient Address to receive swapped tokens
     * @param amountIn Amount of USDC to swap
     * @param swapParams Encoded swap parameters
     */
    function _executeSwap(
        address recipient,
        uint256 amountIn,
        bytes memory swapParams
    ) internal virtual {
        // Decode swap parameters
        (address tokenOut, uint256 minAmountOut, uint256 deadline) =
            abi.decode(swapParams, (address, uint256, uint256));

        // TODO: Integrate with Uniswap V4 or other DEX
        // For now, this is a placeholder that would need to be implemented
        // based on the specific DEX integration (could use SwapDepositor hook)

        // Example flow:
        // 1. Approve USDC to DEX router
        // 2. Execute swap
        // 3. Transfer output tokens to recipient

        emit SwapExecuted(recipient, amountIn, tokenOut, 0);
    }

    /**
     * @notice Emergency function to recover stuck tokens
     * @dev Only callable by owner in production
     * @param token Address of token to recover
     * @param to Address to send recovered tokens
     * @param amount Amount to recover
     */
    function recoverTokens(address token, address to, uint256 amount) external {
        // In production, add access control here
        require(IERC20(token).transfer(to, amount), "Recovery failed");
    }
}
