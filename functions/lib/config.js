"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IP_RATE_WINDOW_MS = exports.IP_VERIFY_LIMIT_PER_HOUR = exports.IP_SEND_LIMIT_PER_HOUR = exports.IP_RATE_LIMIT_COLLECTION = exports.OTP_COLLECTION = exports.OTP_COOLDOWN_SECONDS = exports.OTP_MAX_ATTEMPTS = exports.OTP_TTL_MINUTES = exports.OTP_LENGTH = void 0;
exports.OTP_LENGTH = 6;
exports.OTP_TTL_MINUTES = 10;
exports.OTP_MAX_ATTEMPTS = 5;
exports.OTP_COOLDOWN_SECONDS = 60;
exports.OTP_COLLECTION = "otp_codes";
// IP-based rate limiting
exports.IP_RATE_LIMIT_COLLECTION = "ip_rate_limits";
exports.IP_SEND_LIMIT_PER_HOUR = 5;
exports.IP_VERIFY_LIMIT_PER_HOUR = 15;
exports.IP_RATE_WINDOW_MS = 60 * 60 * 1000; // 1 hour
//# sourceMappingURL=config.js.map