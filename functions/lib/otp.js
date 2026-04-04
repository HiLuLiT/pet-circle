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
exports.generateOtpCode = generateOtpCode;
exports.isOtpExpired = isOtpExpired;
const crypto = __importStar(require("crypto"));
const config_1 = require("./config");
/**
 * Generate a cryptographically random 6-digit OTP code.
 */
function generateOtpCode() {
    const max = Math.pow(10, config_1.OTP_LENGTH);
    const num = crypto.randomInt(0, max);
    return num.toString().padStart(config_1.OTP_LENGTH, "0");
}
/**
 * Check if an OTP has expired based on its creation timestamp.
 */
function isOtpExpired(createdAtMs, ttlMinutes) {
    const elapsedMs = Date.now() - createdAtMs;
    return elapsedMs >= ttlMinutes * 60 * 1000;
}
//# sourceMappingURL=otp.js.map