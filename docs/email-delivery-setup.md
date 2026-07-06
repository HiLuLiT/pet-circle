# Email Delivery Setup & Troubleshooting

Runbook for diagnosing "invitation emails don't arrive" reports. Care-circle
invitation email sending is **fully implemented in code** — this is a
deployment/configuration checklist, not a missing-feature list.

## Relevant files

| File | Role |
|---|---|
| `functions/src/invitation-email.ts` | Firestore-triggered function `onInvitationCreated`, fires on create of `invitations/{token}` |
| `functions/src/email.ts` | `sendInvitationViaResend()` — calls the Resend API |
| `functions/src/email-templates.ts` | HTML/text templates for the invite email |
| `functions/src/index.ts` | Exports `onInvitationCreated` (and `onInvitationStatusChanged`) |
| `firebase.json` | Functions codebase config + predeploy build step |
| `firestore.rules` | Security rules for the `invitations` collection |

---

## Quick checklist (scan this first)

1. **Resend sender is `onboarding@resend.dev`** (test/sandbox address) — sending to anyone other than the Resend account's own verified email will likely fail silently. **Verify a real domain in Resend and update the `from` address.** (Most likely root cause.)
2. **Functions deployed?** Run `firebase deploy --only functions --project pet-circle-app` and confirm with `firebase functions:list`.
3. **`RESEND_API_KEY` secret set?** `firebase functions:secrets:access RESEND_API_KEY` should return a value.
4. **`APP_URL` configured?** If unset, invite links point at `https://petcircle.app`, which 404s for recipients unless that's the real deployed domain.
5. **Check logs and Firestore.** `firebase functions:log --only onInvitationCreated` for send errors; confirm a doc actually appears at `invitations/{token}` (if not, it's a client/Firestore-rules issue, not email).

---

## 1. Most likely culprit — Resend test-mode sender restriction

Both `sendInvitationViaResend()` and `sendOtpEmail()` in `functions/src/email.ts` currently send `from: "Pet Circle <onboarding@resend.dev>"`:

```ts
// functions/src/email.ts
await client.emails.send({
  from: "Pet Circle <onboarding@resend.dev>",
  to: [to],
  subject: `${inviterName} invited you to ${petName}'s care circle`,
  html: invitationEmailHtml({ inviterName, petName, inviteLink }),
  text: invitationEmailText({ inviterName, petName, inviteLink }),
});
```

`onboarding@resend.dev` is Resend's **shared sandbox/test sender**. Accounts that haven't verified their own sending domain can typically only deliver successfully to the **Resend account owner's own verified email address** — invitations sent to any other recipient will not be delivered (and often without a visible error surfaced back to the app, since the Firestore trigger only logs failures server-side; see §5).

This matches the reported symptom exactly: the inviter (developer/tester) may have received test emails during development, but real invitees never do.

**Fix:**
1. In the [Resend dashboard](https://resend.com/domains), add and verify a real sending domain (add the SPF and DKIM DNS records Resend provides).
2. Once verified, update the `from` address in `functions/src/email.ts` (both `sendOtpEmail` and `sendInvitationViaResend`) to use that domain, e.g.:
   ```ts
   from: "Pet Circle <invites@yourdomain.com>",
   ```
3. Redeploy functions (see §2).

---

## 2. Functions not deployed / stale

Any change to `functions/src/*.ts` (including the `from` address fix above) requires a redeploy — it does not take effect automatically.

```bash
firebase deploy --only functions --project pet-circle-app
```

`firebase.json` runs `npm --prefix "$RESOURCE_DIR" run build` as a predeploy step, so a TypeScript build error will block deployment — watch the deploy output for build failures.

Confirm the function is actually live:

```bash
firebase functions:list
```

Look for `onInvitationCreated` (Firestore trigger, codebase `default`) in the output. If it's missing, the deploy didn't succeed or targeted the wrong project.

---

## 3. Missing secret

`onInvitationCreated` declares `RESEND_API_KEY` as a required Firebase Secret:

```ts
// functions/src/invitation-email.ts
const resendApiKey = defineSecret("RESEND_API_KEY");

export const onInvitationCreated = onDocumentCreated(
  { document: "invitations/{token}", secrets: [resendApiKey] },
  ...
```

and `functions/src/email.ts` reads it via `process.env.RESEND_API_KEY`, throwing if unset:

```ts
const apiKey = process.env.RESEND_API_KEY;
if (!apiKey) {
  throw new Error("RESEND_API_KEY environment variable is not set");
}
```

If the secret was never set (or was set on a different Firebase project), every invocation throws and the invitation silently fails to send (the trigger catches the error and just logs it — see §5).

**Set it:**

```bash
firebase functions:secrets:set RESEND_API_KEY --project pet-circle-app
```

(Paste the key from the Resend dashboard's **API Keys** page when prompted.)

**Verify it's set:**

```bash
firebase functions:secrets:access RESEND_API_KEY --project pet-circle-app
```

This should print the key value. If it errors with "not found," the secret doesn't exist for this project and must be set, followed by a redeploy (secrets are bound at deploy time).

---

## 4. `APP_URL` misconfiguration

`onInvitationCreated` builds the invite link as:

```ts
// functions/src/invitation-email.ts
const appUrl = process.env.APP_URL || "https://petcircle.app";
const inviteLink = `${appUrl}/invite?token=${token}`;
```

It reads `APP_URL` from **`process.env`**, not from `functions.config()`. If `APP_URL` isn't set, the invite link defaults to `https://petcircle.app`, which will 404 (or not resolve at all) if that isn't the actual deployed web app domain — the email would arrive, but the link inside it would be broken.

**To set it**, since this function uses 2nd-gen `firebase-functions/v2` with plain `process.env` reads, use a `.env` file in the functions directory (2nd-gen functions load `functions/.env.<project-id>` or `functions/.env` automatically at deploy/runtime — do NOT use `firebase functions:config:set`, which only works for 1st-gen and is not read by this code):

```bash
# functions/.env.pet-circle-app
APP_URL=https://pet-circle-app.web.app
```

(Substitute the real production domain if a custom domain is configured.) Redeploy functions after adding/editing this file.

---

## 5. Debugging steps

**Check function execution logs** for thrown errors or the explicit `logger.error("Failed to send invitation email", ...)` call in `invitation-email.ts`:

```bash
firebase functions:log --only onInvitationCreated --project pet-circle-app
```

Look for either:
- `"Invitation missing required fields"` — the Firestore doc is malformed (missing `invitedEmail`, `petName`, or `invitedByName`)
- `"Failed to send invitation email"` with an `error` field — this is the Resend API's actual error message (e.g. domain not verified, invalid API key, recipient restricted)
- No log entries at all for the expected time window — the trigger never fired (see below)

**Confirm the Firestore doc is created.** In the Firebase console, check `invitations/{token}` was actually written when an invite is sent from the app. If **no document appears**:
- This is a **client-side or Firestore-rules problem**, not an email problem.
- Check `firestore.rules` — the `invitations` collection's create rule requires the caller to be signed in, to be the pet's owner, and to set `invitedByUid` to their own uid:
  ```
  // firestore.rules
  match /invitations/{token} {
    allow create: if canCreateInvitation();
    ...
  }

  function canCreateInvitation() {
    return signedIn() &&
        request.resource.data.invitedByUid == request.auth.uid &&
        isPetOwner(request.resource.data.petId);
  }
  ```
  A rules rejection fails silently in most UI flows unless the client surfaces the Firestore error — check the app logs / Flutter console for a `PERMISSION_DENIED` error from the invite-creation call.

If the document **is** created but no email log appears at all, the Cloud Function trigger itself may not be deployed or may be attached to the wrong Firestore database — re-check §2.
