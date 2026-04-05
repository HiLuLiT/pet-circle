import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { Resend } from "resend";
import { invitationEmailHtml, invitationEmailText } from "./email-templates";

const resendApiKey = defineSecret("RESEND_API_KEY");

export const onInvitationCreated = onDocumentCreated(
  {
    document: "invitations/{token}",
    secrets: [resendApiKey],
  },
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

    const apiKey = resendApiKey.value();
    if (!apiKey) {
      logger.error("RESEND_API_KEY secret not set");
      return;
    }

    const resend = new Resend(apiKey);
    const fromEmail = process.env.FROM_EMAIL || "Pet Circle <noreply@petcircle.app>";
    const appUrl = process.env.APP_URL || "https://petcircle.app";
    const inviteLink = `${appUrl}/invite?token=${token}`;

    try {
      await resend.emails.send({
        from: fromEmail,
        to: data.invitedEmail,
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

      logger.info("Invitation email sent", { token, to: data.invitedEmail });
    } catch (error) {
      logger.error("Failed to send invitation email", { token, error });
    }
  },
);
