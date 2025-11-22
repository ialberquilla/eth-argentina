/**
 * Circle CCTP Attestation Service Integration
 * Fetches attestations for cross-chain USDC transfers
 */

import { getAttestationAPI } from "./cctp-config";

export interface AttestationResponse {
  attestation: string;
  status: "pending" | "complete";
}

/**
 * Wait for and fetch attestation from Circle's Iris API
 * @param messageHash Hash of the CCTP message
 * @param chainId Source chain ID
 * @param maxAttempts Maximum number of polling attempts (default: 60)
 * @param pollInterval Interval between polls in ms (default: 3000)
 * @returns Attestation signature
 */
export async function getAttestation(
  messageHash: string,
  chainId: number,
  maxAttempts: number = 60,
  pollInterval: number = 3000
): Promise<string> {
  const apiUrl = getAttestationAPI(chainId);
  const url = `${apiUrl}/v1/attestations/${messageHash}`;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      const response = await fetch(url);

      if (!response.ok) {
        if (response.status === 404) {
          // Attestation not ready yet, wait and retry
          await sleep(pollInterval);
          continue;
        }
        throw new Error(`Attestation API error: ${response.status} ${response.statusText}`);
      }

      const data: AttestationResponse = await response.json();

      if (data.status === "complete" && data.attestation) {
        return data.attestation;
      }

      // Status is pending, wait and retry
      await sleep(pollInterval);
    } catch (error) {
      if (attempt === maxAttempts - 1) {
        throw new Error(`Failed to get attestation after ${maxAttempts} attempts: ${error}`);
      }
      await sleep(pollInterval);
    }
  }

  throw new Error(`Attestation timeout after ${maxAttempts * pollInterval / 1000} seconds`);
}

/**
 * Get message hash from transaction receipt
 * @param txHash Transaction hash of the depositForBurn call
 * @param chainId Source chain ID
 * @returns Message hash for attestation lookup
 */
export async function getMessageHashFromTx(
  txHash: string,
  chainId: number
): Promise<string> {
  // This would require parsing the transaction receipt for the MessageSent event
  // Implementation depends on whether using ethers, viem, or web3.js
  // For now, this is a placeholder that should be implemented based on the library used

  throw new Error("getMessageHashFromTx not yet implemented - needs transaction parsing");
}

/**
 * Sleep helper for polling
 */
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Parse message bytes from MessageSent event
 * @param eventLog MessageSent event log
 * @returns Message bytes
 */
export function parseMessageFromEvent(eventLog: any): string {
  // Extract message bytes from the MessageSent event
  // The message parameter is the first (and only) indexed parameter
  return eventLog.args?.message || eventLog.data;
}

/**
 * Calculate message hash from message bytes
 * @param messageBytes Message bytes from MessageSent event
 * @returns Keccak256 hash of the message
 */
export function calculateMessageHash(messageBytes: string): string {
  // Use keccak256 to hash the message bytes
  // This would typically use ethers.utils.keccak256 or viem's keccak256
  // For now, returning as-is since we'll use viem in the frontend
  return messageBytes;
}
