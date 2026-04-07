export const OTP_LENGTH = 6;
export const OTP_TTL_MINUTES = 10;
export const OTP_MAX_ATTEMPTS = 5;
export const OTP_COOLDOWN_SECONDS = 60;
export const OTP_COLLECTION = "otp_codes";

// IP-based rate limiting
export const IP_RATE_LIMIT_COLLECTION = "ip_rate_limits";
export const IP_SEND_LIMIT_PER_HOUR = 5;
export const IP_VERIFY_LIMIT_PER_HOUR = 15;
export const IP_RATE_WINDOW_MS = 60 * 60 * 1000; // 1 hour
