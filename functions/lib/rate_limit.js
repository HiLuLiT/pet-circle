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
exports.checkIpRateLimit = checkIpRateLimit;
exports.extractClientIp = extractClientIp;
const admin = __importStar(require("firebase-admin"));
const config_1 = require("./config");
function getDb() {
    return admin.firestore();
}
/**
 * Check and enforce IP-based rate limiting.
 *
 * Maintains a sliding window of timestamps per IP+action pair.
 * Returns true if the request is allowed, false if rate-limited.
 */
async function checkIpRateLimit(ip, action, maxPerWindow) {
    const docId = `${action}_${ip.replace(/[./]/g, "_")}`;
    const docRef = getDb().collection(config_1.IP_RATE_LIMIT_COLLECTION).doc(docId);
    const now = Date.now();
    const windowStart = now - config_1.IP_RATE_WINDOW_MS;
    const doc = await docRef.get();
    if (!doc.exists) {
        await docRef.set({
            timestamps: [now],
            updatedAt: now,
        });
        return { allowed: true, remaining: maxPerWindow - 1 };
    }
    const data = doc.data();
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
function extractClientIp(rawRequest) {
    const forwarded = rawRequest.headers["x-forwarded-for"];
    if (typeof forwarded === "string") {
        return forwarded.split(",")[0].trim();
    }
    if (Array.isArray(forwarded) && forwarded.length > 0) {
        return forwarded[0].split(",")[0].trim();
    }
    return rawRequest.ip ?? "unknown";
}
//# sourceMappingURL=rate_limit.js.map