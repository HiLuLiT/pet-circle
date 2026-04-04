import { generateOtpCode, isOtpExpired } from "../otp";

describe("generateOtpCode", () => {
  it("returns a 6-digit numeric string", () => {
    const code = generateOtpCode();
    expect(code).toMatch(/^\d{6}$/);
  });

  it("generates different codes on successive calls", () => {
    const codes = new Set(Array.from({ length: 20 }, () => generateOtpCode()));
    expect(codes.size).toBeGreaterThan(1);
  });
});

describe("isOtpExpired", () => {
  it("returns false for a timestamp within the TTL", () => {
    const now = Date.now();
    const createdAt = now - 5 * 60 * 1000; // 5 minutes ago
    expect(isOtpExpired(createdAt, 10)).toBe(false);
  });

  it("returns true for a timestamp beyond the TTL", () => {
    const now = Date.now();
    const createdAt = now - 15 * 60 * 1000; // 15 minutes ago
    expect(isOtpExpired(createdAt, 10)).toBe(true);
  });

  it("returns true for exactly expired timestamp", () => {
    const now = Date.now();
    const createdAt = now - 10 * 60 * 1000; // exactly 10 minutes ago
    expect(isOtpExpired(createdAt, 10)).toBe(true);
  });
});
