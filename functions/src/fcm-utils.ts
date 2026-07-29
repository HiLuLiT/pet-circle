import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";

const db = admin.firestore();

export interface PushPayload {
  title: string;
  body: string;
  data: Record<string, string>;
}

export interface InAppNotification {
  title: string;
  body: string;
  type: string;
  petName?: string;
  route?: string;
  petId?: string;
  /**
   * Localization keys mirroring `AppNotification.titleKey` / `bodyKey` on the
   * client. When set, the in-app row is re-localized at render time by
   * `lib/utils/notification_localizer.dart`; `title`/`body` remain the frozen
   * fallback that the OS renders for the push banner itself.
   */
  titleKey?: string;
  bodyKey?: string;
  /** Positional arguments for a templated `titleKey`/`bodyKey`. */
  args?: string[];
}

/**
 * Send a push notification to all registered devices for a user.
 * Reads FCM tokens from `users/{uid}/fcmTokens`, sends a multicast,
 * and cleans up any stale tokens that failed delivery.
 */
export async function sendPushToUser(
  uid: string,
  payload: PushPayload
): Promise<void> {
  const snapshot = await db
    .collection("users")
    .doc(uid)
    .collection("fcmTokens")
    .get();

  if (snapshot.empty) {
    logger.info("No FCM tokens for user — skipping push", { uid });
    return;
  }

  const tokenDocs = snapshot.docs;
  const tokens = tokenDocs
    .map((doc) => doc.data().token as string | undefined)
    .filter((t): t is string => typeof t === "string" && t.length > 0);

  if (tokens.length === 0) {
    logger.info("All FCM token docs empty — skipping push", { uid });
    return;
  }

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data,
    android: {
      priority: "high",
      notification: {
        channelId: "push_notifications",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
    apns: {
      payload: {
        aps: {
          // Badge count is managed client-side on app foreground.
          // Do not set badge here — it would overwrite the real count.
          sound: "default",
        },
      },
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);

    logger.info("FCM multicast result", {
      uid,
      success: response.successCount,
      failure: response.failureCount,
    });

    // Clean up stale/invalid tokens (errors logged internally, don't propagate).
    try {
      await cleanupStaleTokens(uid, tokenDocs, response.responses);
    } catch (cleanupError) {
      const msg =
        cleanupError instanceof Error
          ? cleanupError.message
          : String(cleanupError);
      logger.warn("Stale token cleanup failed", { uid, error: msg });
    }
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    logger.error("FCM send failed", { uid, error: msg });
  }
}

/**
 * Write an in-app notification to the user's Firestore notifications
 * subcollection, matching the AppNotification model on the client.
 *
 * Returns the document ID, or `null` if the write failed.
 *
 * The ID is generated locally by `.doc()` and written with `.set()` rather
 * than letting `.add()` assign one, so callers can put it in the FCM `data`
 * payload. The client stores the in-app row under that same ID, which is what
 * lets `markRead` find the document — see `NotificationService.markRead`.
 * Using `.add()` here left the client keying rows by `message.messageId`,
 * so marking a pushed notification read failed with `not-found` and the
 * optimistic flip rolled back (docs/bug-log.md BUG-038, same root-cause class
 * as BUG-037 on the client side).
 */
export async function writeInAppNotification(
  uid: string,
  notification: InAppNotification
): Promise<string | null> {
  try {
    const ref = db
      .collection("users")
      .doc(uid)
      .collection("notifications")
      .doc();

    await ref.set({
      title: notification.title,
      body: notification.body,
      type: notification.type,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
      ...(notification.petName && { petName: notification.petName }),
      ...(notification.route && { route: notification.route }),
      ...(notification.petId && { petId: notification.petId }),
      ...(notification.titleKey && { titleKey: notification.titleKey }),
      ...(notification.bodyKey && { bodyKey: notification.bodyKey }),
      // Omit empty args to match the client's own write shape
      // (AppNotification.toFirestore uses `if (args.isNotEmpty)`).
      ...(notification.args && notification.args.length > 0
        ? { args: notification.args }
        : {}),
    });

    return ref.id;
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    logger.error("Failed to write in-app notification", { uid, error: msg });
    return null;
  }
}

/**
 * Delete FCM token documents that failed with registration errors.
 */
async function cleanupStaleTokens(
  uid: string,
  tokenDocs: admin.firestore.QueryDocumentSnapshot[],
  responses: admin.messaging.SendResponse[]
): Promise<void> {
  const staleErrors = new Set([
    "messaging/registration-token-not-registered",
    "messaging/invalid-registration-token",
  ]);

  const deletePromises: Promise<admin.firestore.WriteResult>[] = [];

  for (let i = 0; i < responses.length; i++) {
    const resp = responses[i];
    if (!resp.success && resp.error?.code) {
      if (staleErrors.has(resp.error.code)) {
        const doc = tokenDocs[i];
        if (doc) {
          logger.info("Removing stale FCM token", {
            uid,
            docId: doc.id,
            error: resp.error.code,
          });
          deletePromises.push(doc.ref.delete());
        }
      }
    }
  }

  if (deletePromises.length > 0) {
    await Promise.all(deletePromises);
    logger.info("Cleaned up stale tokens", {
      uid,
      count: deletePromises.length,
    });
  }
}
