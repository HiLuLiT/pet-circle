import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { Resend } from "resend";
import { invitationEmailHtml, invitationEmailText } from "./email-templates";

// Singleton pattern — matches the working OTP email implementation.
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

// Use Resend's built-in sender (same as the working OTP email code).
// Switch to a verified custom domain for production.
const FROM_EMAIL = "Pet Circle <onboarding@resend.dev>";

export const onInvitationCreated = onDocumentCreated(
  "invitations/{token}",
  async (event) => {
    const snap = event.data;
    if (!snap) {
      logger.warn("No document data in event");
      return;
    }

    const data = snap.data();
    const token = event.params.token;

    if (!data.invitedEmail || !data.petName || !data.invitedByName) {
      logger.warn("Invitation missing required fields", { token });
      return;
    }

    const resend = getResendClient();
    const appUrl = process.env.APP_URL || "https://petcircle.app";
    const inviteLink = `${appUrl}/invite?token=${token}`;

    try {
      const result = await resend.emails.send({
        from: FROM_EMAIL,
        to: [data.invitedEmail],
        subject: `${data.invitedByName} invited you to ${data.petName}'s care circle`,
        html: invitationEmailHtml({
          inviterName: data.invitedByName,
          petName: data.petName,
          inviteLink,
        }),
        text: invitationEmailText({
          inviterName: data.invitedByName,
          petName: data.petName,
          inviteLink,
        }),
      });

      // Resend SDK returns { data, error } — does NOT throw on API errors.
      if (result.error) {
        logger.error("Resend API error", {
          token,
          to: data.invitedEmail,
          error: result.error,
        });
        return;
      }

      logger.info("Invitation email sent", {
        token,
        to: data.invitedEmail,
        resendId: result.data?.id,
      });
    } catch (error) {
      logger.error("Failed to send invitation email", { token, error });
    }
  },
);
