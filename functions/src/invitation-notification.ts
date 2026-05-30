import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { sendPushToUser, writeInAppNotification } from "./fcm-utils";

/** Maximum length for the email display string in notification titles. */
const MAX_EMAIL_DISPLAY_LENGTH = 40;

/**
 * Sanitise an email for display in a notification title.
 * Caps length and falls back to a safe default.
 */
function sanitiseEmailForDisplay(email: string | undefined): string {
  if (!email || email.length === 0) return "A new member";
  if (email.length > MAX_EMAIL_DISPLAY_LENGTH) {
    return email.substring(0, MAX_EMAIL_DISPLAY_LENGTH) + "...";
  }
  return email;
}

/**
 * Firestore trigger: sends a push notification to the invitation sender
 * when a circle invite is accepted.
 *
 * Trigger path: `invitations/{token}`
 * Fires on: any document update (filtered to status changes internally).
 *
 * Accept-only: cancelled = self-initiated by inviter (no notification needed),
 * expired = automated (no notification needed). Only `pending → accepted`
 * triggers a push.
 *
 * The notification title/body are English fallback strings used by the OS
 * when displaying the push.  The client-side foreground handler can use
 * the structured `data` payload fields to build a localized string from
 * the ARB keys (inviteAcceptedTitle / inviteAcceptedBody) instead.
 */
export const onInvitationStatusChanged = onDocumentUpdated(
  { document: "invitations/{token}" },
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();

    if (!beforeData || !afterData) {
      logger.warn("Missing before/after data in invitation update");
      return;
    }

    const beforeStatus = beforeData.status as string | undefined;
    const afterStatus = afterData.status as string | undefined;

    // Only process actual status changes.
    if (beforeStatus === afterStatus) return;

    // Only notify on acceptance (pending → accepted).
    if (beforeStatus !== "pending" || afterStatus !== "accepted") return;

    const invitedByUid = afterData.invitedByUid as string | undefined;
    const invitedEmail = afterData.invitedEmail as string | undefined;
    const petName = afterData.petName as string | undefined;
    const petId = afterData.petId as string | undefined;

    if (!invitedByUid || !petName) {
      logger.warn("Invitation missing required fields for notification", {
        hasInvitedByUid: !!invitedByUid,
        hasPetName: !!petName,
      });
      return;
    }

    if (!invitedEmail) {
      logger.warn("Invitation missing invitedEmail — document may be corrupted");
      return;
    }

    const displayEmail = sanitiseEmailForDisplay(invitedEmail);
    const title = `${displayEmail} joined ${petName}'s care circle`;
    const body = "Your invitation was accepted";
    const route = "/shell";

    logger.info("Sending invite-accepted notification", {
      to: invitedByUid,
      petName,
    });

    // Send push and write in-app notification in parallel.
    await Promise.all([
      sendPushToUser(invitedByUid, {
        title,
        body,
        data: {
          type: "careCircle",
          route,
          petId: petId ?? "",
          petName: petName,
          invitedEmail: invitedEmail,
        },
      }),
      writeInAppNotification(invitedByUid, {
        title,
        body,
        type: "careCircle",
        petName,
        route,
        petId,
      }),
    ]);

    logger.info("Invite-accepted notification sent", {
      to: invitedByUid,
    });
  }
);
