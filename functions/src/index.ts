import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

const resendApiKey = defineSecret("RESEND_API_KEY");
import { generateOtpCode, isOtpExpired } from "./otp";
import { sendOtpEmail } from "./email";
import { checkIpRateLimit, extractClientIp } from "./rate_limit";
import {
  OTP_COLLECTION,
  OTP_TTL_MINUTES,
  OTP_MAX_ATTEMPTS,
  OTP_COOLDOWN_SECONDS,
  IP_SEND_LIMIT_PER_HOUR,
  IP_VERIFY_LIMIT_PER_HOUR,
} from "./config";

admin.initializeApp();
const db = admin.firestore();

/** Redact email for safe logging: "hi***@gmail.com" */
function redactEmail(email: string): string {
  const [local, domain] = email.split("@");
  if (!domain) return "***";
  const visible = local.slice(0, 2);
  return `${visible}***@${domain}`;
}

const ALLOWED_ORIGINS = [
  /^https:\/\/pet-circle-app\.web\.app$/,
  /^https:\/\/pet-circle-app\.firebaseapp\.com$/,
  /^http:\/\/localhost(:\d+)?$/,
];

interface SendOtpData {
  email: string;
  name?: string;
  isSignup?: boolean;
}

interface VerifyOtpData {
  email: string;
  code: string;
}

/**
 * Send a 6-digit OTP code to the given email address.
 *
 * Protections:
 * - Per-email cooldown (60s)
 * - Per-IP rate limit (5 sends/hour)
 * - CORS restricted to app domains + localhost
 */
export const sendOTP = onCall<SendOtpData>(
  { cors: ALLOWED_ORIGINS, invoker: "public", secrets: [resendApiKey] },
  async (request) => {
    const { email, name, isSignup } = request.data;

    if (!email || typeof email !== "string" || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new HttpsError("invalid-argument", "A valid email is required.");
    }

    // IP-based rate limiting
    const clientIp = extractClientIp(request.rawRequest);
    const ipCheck = await checkIpRateLimit(clientIp, "send", IP_SEND_LIMIT_PER_HOUR);
    if (!ipCheck.allowed) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many requests. Please try again later."
      );
    }

    const normalizedEmail = email.toLowerCase().trim();
    const docRef = db.collection(OTP_COLLECTION).doc(normalizedEmail);
    const existing = await docRef.get();

    // Per-email cooldown
    if (existing.exists) {
      const data = existing.data()!;
      const elapsed = Date.now() - data.createdAt;
      if (elapsed < OTP_COOLDOWN_SECONDS * 1000) {
        const remaining = Math.ceil(
          (OTP_COOLDOWN_SECONDS * 1000 - elapsed) / 1000
        );
        throw new HttpsError(
          "resource-exhausted",
          `Please wait ${remaining} seconds before requesting a new code.`
        );
      }
    }

    const code = generateOtpCode();

    await docRef.set({
      code,
      email: normalizedEmail,
      name: name ?? null,
      isSignup: isSignup ?? false,
      createdAt: Date.now(),
      attempts: 0,
      verified: false,
    });

    const result = await sendOtpEmail(normalizedEmail, code);

    if (!result.success) {
      console.error(`Failed to send OTP to ${redactEmail(normalizedEmail)}: ${result.error}`);
      throw new HttpsError("internal", "Failed to send verification email.");
    }

    return { success: true };
  }
);

/**
 * Verify the OTP code and return a Firebase Custom Auth Token.
 *
 * Protections:
 * - Per-code attempt limit (5 attempts)
 * - Per-IP rate limit (15 verifications/hour)
 * - Code expiry (10 min)
 * - Single-use enforcement
 */
export const verifyOTP = onCall<VerifyOtpData>(
  { cors: ALLOWED_ORIGINS, invoker: "public" },
  async (request) => {
    const { email, code } = request.data;

    if (!email || typeof email !== "string") {
      throw new HttpsError("invalid-argument", "Email is required.");
    }
    if (!code || typeof code !== "string" || code.length !== 6) {
      throw new HttpsError("invalid-argument", "A 6-digit code is required.");
    }

    // IP-based rate limiting
    const clientIp = extractClientIp(request.rawRequest);
    const ipCheck = await checkIpRateLimit(clientIp, "verify", IP_VERIFY_LIMIT_PER_HOUR);
    if (!ipCheck.allowed) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many attempts. Please try again later."
      );
    }

    const normalizedEmail = email.toLowerCase().trim();
    const docRef = db.collection(OTP_COLLECTION).doc(normalizedEmail);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new HttpsError("not-found", "No verification code found. Please request a new one.");
    }

    const data = doc.data()!;

    // Check if already verified
    if (data.verified) {
      throw new HttpsError("already-exists", "This code has already been used.");
    }

    // Check expiry
    if (isOtpExpired(data.createdAt, OTP_TTL_MINUTES)) {
      await docRef.delete();
      throw new HttpsError("deadline-exceeded", "This code has expired. Please request a new one.");
    }

    // Check max attempts
    if (data.attempts >= OTP_MAX_ATTEMPTS) {
      await docRef.delete();
      throw new HttpsError(
        "resource-exhausted",
        "Too many failed attempts. Please request a new code."
      );
    }

    // Verify code
    if (data.code !== code) {
      await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
      const remaining = OTP_MAX_ATTEMPTS - data.attempts - 1;
      throw new HttpsError(
        "permission-denied",
        `Incorrect code. ${remaining} attempt${remaining === 1 ? "" : "s"} remaining.`
      );
    }

    // Mark as verified
    await docRef.update({ verified: true });

    // Get or create Firebase Auth user
    let uid: string;
    let isNewUser = false;

    try {
      const userRecord = await admin.auth().getUserByEmail(normalizedEmail);
      uid = userRecord.uid;
    } catch (error: unknown) {
      const authError = error as { code?: string };
      if (authError.code === "auth/user-not-found") {
        const newUser = await admin.auth().createUser({
          email: normalizedEmail,
          displayName: data.name ?? undefined,
        });
        uid = newUser.uid;
        isNewUser = true;
      } else {
        throw new HttpsError("internal", "Failed to look up user account.");
      }
    }

    // Mint custom token
    const customToken = await admin.auth().createCustomToken(uid);

    // Clean up OTP document
    await docRef.delete();

    return { success: true, token: customToken, isNewUser };
  }
);
