"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const email_1 = require("../email");
describe("buildOtpEmailHtml", () => {
    it("includes the OTP code in the HTML body", () => {
        const html = (0, email_1.buildOtpEmailHtml)("123456");
        expect(html).toContain("123456");
    });
    it("includes the expiry time", () => {
        const html = (0, email_1.buildOtpEmailHtml)("123456");
        expect(html).toContain("10 minutes");
    });
    it("includes the app name", () => {
        const html = (0, email_1.buildOtpEmailHtml)("123456");
        expect(html).toContain("Pet Circle");
    });
});
describe("buildOtpEmailText", () => {
    it("includes the OTP code in plain text", () => {
        const text = (0, email_1.buildOtpEmailText)("123456");
        expect(text).toContain("123456");
    });
});
//# sourceMappingURL=email.test.js.map