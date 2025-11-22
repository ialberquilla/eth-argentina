// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {ILendingAdapter} from "../interfaces/ILendingAdapter.sol";
import {IAavePool} from "../interfaces/IAavePool.sol";

/// @title AaveAdapter
/// @notice Adapter for depositing tokens into Aave v3
/// @dev Implements the ILendingAdapter interface for Aave v3 protocol
contract AaveAdapter is ILendingAdapter {
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    /// @notice The Aave v3 Pool contract
    IAavePool public immutable aavePool;

    /// @notice The token symbol this adapter is configured for
    string public immutable symbol;

    /// @notice Emitted when a deposit is made to Aave
    /// @param token The token that was deposited
    /// @param amount The amount deposited
    /// @param onBehalfOf The address receiving the aTokens
    event DepositedToAave(Currency token, uint256 amount, address onBehalfOf);

    /// @notice Constructor
    /// @param _aavePool The address of the Aave v3 Pool contract
    /// @param _symbol The token symbol this adapter is configured for (e.g., "USDC", "DAI")
    constructor(address _aavePool, string memory _symbol) {
        require(_aavePool != address(0), "AaveAdapter: Invalid pool address");
        require(bytes(_symbol).length > 0, "AaveAdapter: Symbol cannot be empty");
        aavePool = IAavePool(_aavePool);
        symbol = _symbol;
    }

    /// @notice Returns the metadata for this lending adapter
    /// @dev Returns the token symbol, chain ID, and Aave pool address
    /// @return metadata The adapter metadata
    function getAdapterMetadata() external view override returns (AdapterMetadata memory metadata) {
        return AdapterMetadata({
            symbol: symbol,
            chainId: block.chainid,
            protocolAddress: address(aavePool)
        });
    }

    /// @notice Deposits tokens into Aave v3
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    /// @param onBehalfOf The address that will receive the aTokens
    function deposit(Currency token, uint256 amount, address onBehalfOf) external override {
        require(amount > 0, "AaveAdapter: Amount must be greater than 0");
        require(onBehalfOf != address(0), "AaveAdapter: Invalid recipient");
        require(!token.isAddressZero(), "AaveAdapter: Native currency not supported");

        address tokenAddress = Currency.unwrap(token);

        // Transfer tokens from caller to this adapter
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);

        // Approve Aave pool to spend tokens
        IERC20(tokenAddress).safeIncreaseAllowance(address(aavePool), amount);

        // Supply tokens to Aave on behalf of the specified address
        aavePool.supply(tokenAddress, amount, onBehalfOf, 0);

        emit DepositedToAave(token, amount, onBehalfOf);
    }
}
