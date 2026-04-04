import * as crypto from "crypto";
import { OTP_LENGTH } from "./config";

/**
 * Generate a cryptographically random 6-digit OTP code.
 */
export function generateOtpCode(): string {
  const max = Math.pow(10, OTP_LENGTH);
  const num = crypto.randomInt(0, max);
  return num.toString().padStart(OTP_LENGTH, "0");
}

/**
 * Check if an OTP has expired based on its creation timestamp.
 */
export function isOtpExpired(createdAtMs: number, ttlMinutes: number): boolean {
  const elapsedMs = Date.now() - createdAtMs;
  return elapsedMs >= ttlMinutes * 60 * 1000;
}
