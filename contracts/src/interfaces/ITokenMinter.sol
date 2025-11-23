// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ITokenMinter
 * @notice Interface for Circle's CCTP TokenMinter contract
 * @dev The TokenMinter is the actual contract that burns USDC, not the TokenMessenger
 */
interface ITokenMinter {
    /**
     * @notice Returns the burn limit per message for a given token
     * @param burnToken Address of the token to check
     * @return uint256 Maximum amount that can be burned per message
     */
    function burnLimitsPerMessage(address burnToken) external view returns (uint256);
}
