// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {ICompoundV3} from "../interfaces/ICompoundV3.sol";

/// @title CompoundAdapter
/// @notice Adapter for depositing tokens into Compound V3 (Comet)
/// @dev Implements the ILendingAdapter interface for Compound V3 protocol
contract CompoundAdapter is ILendingAdapter {
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    /// @notice The Compound V3 Comet contract
    ICompoundV3 public immutable comet;

    /// @notice The token symbol this adapter is configured for
    string public symbol;

    /// @notice Emitted when a deposit is made to Compound
    /// @param token The token that was deposited
    /// @param amount The amount deposited
    /// @param onBehalfOf The address receiving the cTokens
    event DepositedToCompound(Currency token, uint256 amount, address onBehalfOf);

    /// @notice Constructor
    /// @param _comet The address of the Compound V3 Comet contract
    /// @param _symbol The token symbol this adapter is configured for (e.g., "USDC", "DAI")
    constructor(address _comet, string memory _symbol) {
        require(_comet != address(0), "CompoundAdapter: Invalid comet address");
        require(bytes(_symbol).length > 0, "CompoundAdapter: Symbol cannot be empty");
        comet = ICompoundV3(_comet);
        symbol = _symbol;
    }

    /// @notice Returns the metadata for this lending adapter
    /// @dev Returns the token symbol, chain ID, and adapter address
    /// @return metadata The adapter metadata
    function getAdapterMetadata() external view override returns (AdapterMetadata memory metadata) {
        return AdapterMetadata({
            symbol: symbol,
            chainId: block.chainid,
            protocolAddress: address(this)
        });
    }

    /// @notice Deposits tokens into Compound V3
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    /// @param onBehalfOf The address that will receive the cTokens
    function deposit(Currency token, uint256 amount, address onBehalfOf) external override {
        require(amount > 0, "CompoundAdapter: Amount must be greater than 0");
        require(onBehalfOf != address(0), "CompoundAdapter: Invalid recipient");
        require(!token.isAddressZero(), "CompoundAdapter: Native currency not supported");

        address tokenAddress = Currency.unwrap(token);

        // Transfer tokens from caller to this adapter
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        // Approve Compound comet to spend tokens
        IERC20(tokenAddress).safeIncreaseAllowance(address(comet), amount);

        // Supply tokens to Compound on behalf of the specified address
        comet.supplyTo(onBehalfOf, tokenAddress, amount);

        emit DepositedToCompound(token, amount, onBehalfOf);
    }
}
