import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { sendInvitationViaResend } from "./email";

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

    const appUrl = process.env.APP_URL || "https://petcircle.app";
    const inviteLink = `${appUrl}/invite?token=${token}`;

    // Reuse the same email sending pattern as OTP (singleton Resend client)
    const result = await sendInvitationViaResend(
      data.invitedEmail,
      data.invitedByName,
      data.petName,
      inviteLink,
    );

    if (!result.success) {
      logger.error("Failed to send invitation email", {
        token,
        to: data.invitedEmail,
        error: result.error,
      });
      return;
    }

    logger.info("Invitation email sent", {
      token,
      to: data.invitedEmail,
    });
  },
);
