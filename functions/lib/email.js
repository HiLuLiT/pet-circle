"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildOtpEmailHtml = buildOtpEmailHtml;
exports.buildOtpEmailText = buildOtpEmailText;
exports.sendOtpEmail = sendOtpEmail;
const resend_1 = require("resend");
const config_1 = require("./config");
let resendClient = null;
function getResendClient() {
    if (!resendClient) {
        const apiKey = process.env.RESEND_API_KEY;
        if (!apiKey) {
            throw new Error("RESEND_API_KEY environment variable is not set");
        }
        resendClient = new resend_1.Resend(apiKey);
    }
    return resendClient;
}
function buildOtpEmailHtml(code) {
    return `
    <div style="font-family: 'Helvetica Neue', Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 40px 24px;">
      <h2 style="color: #1a1a1a; font-size: 24px; margin-bottom: 8px;">Pet Circle</h2>
      <p style="color: #666; font-size: 16px; line-height: 1.5;">
        Your verification code is:
      </p>
      <div style="background: #f5f0ff; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
        <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #6B4EFF;">${code}</span>
      </div>
      <p style="color: #999; font-size: 14px; line-height: 1.5;">
        This code expires in ${config_1.OTP_TTL_MINUTES} minutes. If you didn't request this code, you can safely ignore this email.
      </p>
    </div>
  `.trim();
}
function buildOtpEmailText(code) {
    return `Your Pet Circle verification code is: ${code}\n\nThis code expires in ${config_1.OTP_TTL_MINUTES} minutes.\n\nIf you didn't request this code, you can safely ignore this email.`;
}
async function sendOtpEmail(to, code) {
    try {
        const client = getResendClient();
        await client.emails.send({
            from: "Pet Circle <onboarding@resend.dev>",
            to: [to],
            subject: `${code} is your Pet Circle verification code`,
            html: buildOtpEmailHtml(code),
            text: buildOtpEmailText(code),
        });
        return { success: true };
    }
    catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        console.error(`Failed to send OTP email to ${to}:`, message);
        return { success: false, error: message };
    }
}
//# sourceMappingURL=email.js.map