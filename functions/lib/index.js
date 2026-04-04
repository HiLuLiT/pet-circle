"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyOTP = exports.sendOTP = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const otp_1 = require("./otp");
const email_1 = require("./email");
const config_1 = require("./config");
admin.initializeApp();
const db = admin.firestore();
/**
 * Send a 6-digit OTP code to the given email address.
 *
 * Stores the code in Firestore with a TTL and rate-limits to one send
 * per OTP_COOLDOWN_SECONDS per email address.
 */
exports.sendOTP = (0, https_1.onCall)(async (request) => {
    const { email, name, isSignup } = request.data;
    if (!email || typeof email !== "string" || !email.includes("@")) {
        throw new https_1.HttpsError("invalid-argument", "A valid email is required.");
    }
    const normalizedEmail = email.toLowerCase().trim();
    const docRef = db.collection(config_1.OTP_COLLECTION).doc(normalizedEmail);
    const existing = await docRef.get();
    // Rate-limit: enforce cooldown between sends
    if (existing.exists) {
        const data = existing.data();
        const elapsed = Date.now() - data.createdAt;
        if (elapsed < config_1.OTP_COOLDOWN_SECONDS * 1000) {
            const remaining = Math.ceil((config_1.OTP_COOLDOWN_SECONDS * 1000 - elapsed) / 1000);
            throw new https_1.HttpsError("resource-exhausted", `Please wait ${remaining} seconds before requesting a new code.`);
        }
    }
    const code = (0, otp_1.generateOtpCode)();
    await docRef.set({
        code,
        email: normalizedEmail,
        name: name ?? null,
        isSignup: isSignup ?? false,
        createdAt: Date.now(),
        attempts: 0,
        verified: false,
    });
    const result = await (0, email_1.sendOtpEmail)(normalizedEmail, code);
    if (!result.success) {
        throw new https_1.HttpsError("internal", "Failed to send verification email.");
    }
    return { success: true };
});
/**
 * Verify the OTP code and return a Firebase Custom Auth Token.
 *
 * On success, creates the Firebase Auth user if they don't exist,
 * mints a custom token, and cleans up the OTP document.
 */
exports.verifyOTP = (0, https_1.onCall)(async (request) => {
    const { email, code } = request.data;
    if (!email || typeof email !== "string") {
        throw new https_1.HttpsError("invalid-argument", "Email is required.");
    }
    if (!code || typeof code !== "string" || code.length !== 6) {
        throw new https_1.HttpsError("invalid-argument", "A 6-digit code is required.");
    }
    const normalizedEmail = email.toLowerCase().trim();
    const docRef = db.collection(config_1.OTP_COLLECTION).doc(normalizedEmail);
    const doc = await docRef.get();
    if (!doc.exists) {
        throw new https_1.HttpsError("not-found", "No verification code found. Please request a new one.");
    }
    const data = doc.data();
    // Check if already verified
    if (data.verified) {
        throw new https_1.HttpsError("already-exists", "This code has already been used.");
    }
    // Check expiry
    if ((0, otp_1.isOtpExpired)(data.createdAt, config_1.OTP_TTL_MINUTES)) {
        await docRef.delete();
        throw new https_1.HttpsError("deadline-exceeded", "This code has expired. Please request a new one.");
    }
    // Check max attempts
    if (data.attempts >= config_1.OTP_MAX_ATTEMPTS) {
        await docRef.delete();
        throw new https_1.HttpsError("resource-exhausted", "Too many failed attempts. Please request a new code.");
    }
    // Verify code
    if (data.code !== code) {
        await docRef.update({ attempts: admin.firestore.FieldValue.increment(1) });
        const remaining = config_1.OTP_MAX_ATTEMPTS - data.attempts - 1;
        throw new https_1.HttpsError("permission-denied", `Incorrect code. ${remaining} attempt${remaining === 1 ? "" : "s"} remaining.`);
    }
    // Mark as verified
    await docRef.update({ verified: true });
    // Get or create Firebase Auth user
    let uid;
    let isNewUser = false;
    try {
        const userRecord = await admin.auth().getUserByEmail(normalizedEmail);
        uid = userRecord.uid;
    }
    catch (error) {
        const authError = error;
        if (authError.code === "auth/user-not-found") {
            const newUser = await admin.auth().createUser({
                email: normalizedEmail,
                displayName: data.name ?? undefined,
            });
            uid = newUser.uid;
            isNewUser = true;
        }
        else {
            throw new https_1.HttpsError("internal", "Failed to look up user account.");
        }
    }
    // Mint custom token
    const customToken = await admin.auth().createCustomToken(uid);
    // Clean up OTP document
    await docRef.delete();
    return { success: true, token: customToken, isNewUser };
});
//# sourceMappingURL=index.js.map