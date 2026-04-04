import { Resend } from "resend";
import { OTP_TTL_MINUTES } from "./config";

let resendClient: Resend | null = null;

function getResendClient(): Resend {
  if (!resendClient) {
    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey) {
      throw new Error("RESEND_API_KEY environment variable is not set");
    }
    resendClient = new Resend(apiKey);
  }
  return resendClient;
}

export function buildOtpEmailHtml(code: string): string {
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
        This code expires in ${OTP_TTL_MINUTES} minutes. If you didn't request this code, you can safely ignore this email.
      </p>
    </div>
  `.trim();
}

export function buildOtpEmailText(code: string): string {
  return `Your Pet Circle verification code is: ${code}\n\nThis code expires in ${OTP_TTL_MINUTES} minutes.\n\nIf you didn't request this code, you can safely ignore this email.`;
}

export async function sendOtpEmail(
  to: string,
  code: string
): Promise<{ success: boolean; error?: string }> {
  try {
    const client = getResendClient();
    await client.emails.send({
      from: "Pet Circle <noreply@petcircle.app>",
      to: [to],
      subject: `${code} is your Pet Circle verification code`,
      html: buildOtpEmailHtml(code),
      text: buildOtpEmailText(code),
    });
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to send OTP email to ${to}:`, message);
    return { success: false, error: message };
  }
}
