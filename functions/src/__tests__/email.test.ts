import { buildOtpEmailHtml, buildOtpEmailText } from "../email";

describe("buildOtpEmailHtml", () => {
  it("includes the OTP code in the HTML body", () => {
    const html = buildOtpEmailHtml("123456");
    expect(html).toContain("123456");
  });

  it("includes the expiry time", () => {
    const html = buildOtpEmailHtml("123456");
    expect(html).toContain("10 minutes");
  });

  it("includes the app name", () => {
    const html = buildOtpEmailHtml("123456");
    expect(html).toContain("Pet Circle");
  });
});

describe("buildOtpEmailText", () => {
  it("includes the OTP code in plain text", () => {
    const text = buildOtpEmailText("123456");
    expect(text).toContain("123456");
  });
});
