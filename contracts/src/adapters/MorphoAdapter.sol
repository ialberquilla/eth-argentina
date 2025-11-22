// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {IMorpho} from "../interfaces/IMorpho.sol";

/// @title MorphoAdapter
/// @notice Adapter for depositing tokens into Morpho Blue
/// @dev Implements the ILendingAdapter interface for Morpho Blue protocol
contract MorphoAdapter is ILendingAdapter {
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    /// @notice The Morpho Blue contract
    IMorpho public immutable morpho;

    /// @notice The token symbol this adapter is configured for
    string public symbol;

    /// @notice The market parameters for this adapter
    IMorpho.MarketParams public marketParams;

    /// @notice Emitted when a deposit is made to Morpho
    /// @param token The token that was deposited
    /// @param amount The amount deposited
    /// @param onBehalfOf The address receiving the supply position
    event DepositedToMorpho(Currency token, uint256 amount, address onBehalfOf);

    /// @notice Constructor
    /// @param _morpho The address of the Morpho Blue contract
    /// @param _symbol The token symbol this adapter is configured for (e.g., "USDC", "DAI")
    /// @param _marketParams The market parameters for the Morpho market
    constructor(
        address _morpho,
        string memory _symbol,
        IMorpho.MarketParams memory _marketParams
    ) {
        require(_morpho != address(0), "MorphoAdapter: Invalid morpho address");
        require(bytes(_symbol).length > 0, "MorphoAdapter: Symbol cannot be empty");
        require(_marketParams.loanToken != address(0), "MorphoAdapter: Invalid loan token");

        morpho = IMorpho(_morpho);
        symbol = _symbol;
        marketParams = _marketParams;
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

    /// @notice Deposits tokens into Morpho Blue
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    /// @param onBehalfOf The address that will receive the supply position
    function deposit(Currency token, uint256 amount, address onBehalfOf) external override {
        require(amount > 0, "MorphoAdapter: Amount must be greater than 0");
        require(onBehalfOf != address(0), "MorphoAdapter: Invalid recipient");
        require(!token.isAddressZero(), "MorphoAdapter: Native currency not supported");

        address tokenAddress = Currency.unwrap(token);
        require(tokenAddress == marketParams.loanToken, "MorphoAdapter: Token mismatch");

        // Transfer tokens from caller to this adapter
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        // Approve Morpho to spend tokens
        IERC20(tokenAddress).safeIncreaseAllowance(address(morpho), amount);

        // Supply tokens to Morpho on behalf of the specified address
        // Using 0 for shares means we supply based on assets amount
        morpho.supply(marketParams, amount, 0, onBehalfOf, "");

        emit DepositedToMorpho(token, amount, onBehalfOf);
    }
}
