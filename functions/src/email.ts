import { Resend } from "resend";
import { OTP_TTL_MINUTES } from "./config";
import {
  invitationEmailHtml,
  invitationEmailText,
  sanitiseInline,
} from "./email-templates";

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

/**
 * Resend's shared sandbox sender. Mail sent from this address is only
 * delivered to the Resend account owner, so real invitations silently never
 * arrive. Set `FROM_EMAIL` (see .env.example) to a verified domain sender in
 * any environment that needs to reach actual users.
 */
const SANDBOX_FROM_ADDRESS = "Pet Circle <onboarding@resend.dev>";

function getFromAddress(): string {
  const configured = process.env.FROM_EMAIL;
  if (configured && configured.trim().length > 0) {
    return configured.trim();
  }
  console.warn(
    "FROM_EMAIL is not set — falling back to Resend's sandbox sender, " +
      "which only delivers to the Resend account owner."
  );
  return SANDBOX_FROM_ADDRESS;
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
      from: getFromAddress(),
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

export async function sendInvitationViaResend(
  to: string,
  inviterName: string,
  petName: string,
  inviteLink: string,
): Promise<{ success: boolean; error?: string }> {
  try {
    const client = getResendClient();
    await client.emails.send({
      from: getFromAddress(),
      to: [to],
      // Sanitise the interpolated names, not the assembled subject: this also
      // caps their length, and prevents header injection via CR/LF.
      subject: `${sanitiseInline(inviterName)} invited you to ` +
        `${sanitiseInline(petName)}'s care circle`,
      html: invitationEmailHtml({ inviterName, petName, inviteLink }),
      text: invitationEmailText({ inviterName, petName, inviteLink }),
    });
    return { success: true };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.error(`Failed to send invitation email to ${to}:`, message);
    return { success: false, error: message };
  }
}
