import * as admin from "firebase-admin";
import {
  IP_RATE_LIMIT_COLLECTION,
  IP_RATE_WINDOW_MS,
} from "./config";

function getDb(): admin.firestore.Firestore {
  return admin.firestore();
}

interface RateLimitDoc {
  timestamps: number[];
  updatedAt: number;
}

/**
 * Check and enforce IP-based rate limiting.
 *
 * Maintains a sliding window of timestamps per IP+action pair.
 * Returns true if the request is allowed, false if rate-limited.
 */
export async function checkIpRateLimit(
  ip: string,
  action: "send" | "verify",
  maxPerWindow: number
): Promise<{ allowed: boolean; remaining: number }> {
  const docId = `${action}_${ip.replace(/[./]/g, "_")}`;
  const docRef = getDb().collection(IP_RATE_LIMIT_COLLECTION).doc(docId);
  const now = Date.now();
  const windowStart = now - IP_RATE_WINDOW_MS;

  const doc = await docRef.get();

  if (!doc.exists) {
    await docRef.set({
      timestamps: [now],
      updatedAt: now,
    });
    return { allowed: true, remaining: maxPerWindow - 1 };
  }

  const data = doc.data() as RateLimitDoc;

  // Filter to only timestamps within the current window
  const recentTimestamps = data.timestamps.filter((ts) => ts > windowStart);

  if (recentTimestamps.length >= maxPerWindow) {
    return { allowed: false, remaining: 0 };
  }

  // Add current timestamp and update
  await docRef.set({
    timestamps: [...recentTimestamps, now],
    updatedAt: now,
  });

  return { allowed: true, remaining: maxPerWindow - recentTimestamps.length - 1 };
}

/**
 * Extract client IP from Cloud Functions request.
 * Cloud Run uses x-forwarded-for header; take the first (leftmost) IP.
 */
export function extractClientIp(rawRequest: {
  headers: Record<string, string | string[] | undefined>;
  ip?: string;
}): string {
  const forwarded = rawRequest.headers["x-forwarded-for"];
  if (typeof forwarded === "string") {
    return forwarded.split(",")[0].trim();
  }
  if (Array.isArray(forwarded) && forwarded.length > 0) {
    return forwarded[0].split(",")[0].trim();
  }
  return rawRequest.ip ?? "unknown";
}
