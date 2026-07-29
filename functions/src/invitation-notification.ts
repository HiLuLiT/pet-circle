import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { sendPushToUser, writeInAppNotification } from "./fcm-utils";
import { FUNCTION_REGION } from "./config";

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
 * when displaying the push. The `data` payload also carries the ARB keys
 * (`inviteAcceptedTitle` / `inviteAcceptedBody`) plus `args`, which the
 * client's foreground handler uses to render the in-app row in the user's
 * own locale, and `notificationId` so that row can be marked read.
 */
export const onInvitationStatusChanged = onDocumentUpdated(
  { document: "invitations/{token}", region: FUNCTION_REGION },
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

    // `title`/`body` are the frozen English fallback the OS renders for the
    // push banner, and what non-key-aware clients display. They are pinned to
    // the EN values of the `inviteAcceptedTitle` / `inviteAcceptedBody` ARB
    // keys — placeholder order is (email, petName). Nothing automated ties
    // these together, so edit both sides if either changes.
    const title = `${displayEmail} joined ${petName}'s care circle`;
    const body = "Your invitation was accepted";
    const titleKey = "inviteAcceptedTitle";
    const bodyKey = "inviteAcceptedBody";
    // Pass the truncated display email, not the raw one, so the localized
    // in-app row and the OS banner agree for long addresses.
    const args = [displayEmail, petName];
    const route = "/shell";

    logger.info("Sending invite-accepted notification", {
      to: invitedByUid,
      petName,
    });

    // Write the in-app notification FIRST, then push. This must stay
    // sequential: the push carries the notification's document ID so the
    // client can mark it read, and if the push were delivered and tapped
    // before the Firestore write landed, `markRead` would hit `not-found` and
    // silently revert (the intermittent form of BUG-038). Do not "optimize"
    // this back into a Promise.all.
    const notificationId = await writeInAppNotification(invitedByUid, {
      title,
      body,
      type: "careCircle",
      petName,
      route,
      petId,
      titleKey,
      bodyKey,
      args,
    });

    if (notificationId === null) {
      logger.warn(
        "In-app notification write failed — push will not carry a notificationId",
        { to: invitedByUid }
      );
    }

    await sendPushToUser(invitedByUid, {
      title,
      body,
      data: {
        type: "careCircle",
        route,
        petId: petId ?? "",
        petName: petName,
        invitedEmail: invitedEmail,
        titleKey,
        bodyKey,
        // FCM data values must be strings, so args travels as JSON.
        args: JSON.stringify(args),
        ...(notificationId ? { notificationId } : {}),
      },
    });

    logger.info("Invite-accepted notification sent", {
      to: invitedByUid,
    });
  }
);
