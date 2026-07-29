/** Maximum rendered length for a user-controlled name in an email. */
const MAX_INLINE_LENGTH = 100;

/**
 * Flatten a user-controlled value to a single capped line.
 *
 * Escaping alone is not enough for these fields. `inviterName` is the sender's
 * own display name and `petName` is free text, both client-controlled, and the
 * recipient address is attacker-chosen too — so a name containing newlines can
 * forge extra lines in the plain-text part of the mail. Mail clients
 * auto-linkify bare URLs in `text/plain`, which reintroduces the very
 * attacker-planted link that HTML escaping removes, inside a message signed by
 * the project's sending domain. Collapsing line breaks and capping length
 * closes that, and applies to every MIME part and the subject alike.
 * See docs/bug-log.md BUG-041.
 */
export function sanitiseInline(value: string): string {
  return value
    .replace(/[\r\n\t]+/g, " ")
    .replace(/\s{2,}/g, " ")
    .trim()
    .slice(0, MAX_INLINE_LENGTH);
}

/**
 * Escape a string for safe interpolation into HTML text/attribute content.
 *
 * Always applied on top of [sanitiseInline] for user-controlled values, never
 * instead of it.
 */
function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

export function invitationEmailHtml(params: {
  inviterName: string;
  petName: string;
  inviteLink: string;
}): string {
  const inviterName = escapeHtml(sanitiseInline(params.inviterName));
  const petName = escapeHtml(sanitiseInline(params.petName));
  // The link ends up in an href attribute, and the invitation token is a
  // client-chosen Firestore document ID, so escape it too.
  const inviteLink = escapeHtml(params.inviteLink);
  return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>You've been invited to Pet Circle</title>
</head>
<body style="margin:0;padding:0;background:#F4F0FF;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="max-width:480px;margin:40px auto;background:#fff;border-radius:16px;overflow:hidden;">
    <tr>
      <td style="background:#6B4EFF;padding:32px 24px;text-align:center;">
        <h1 style="color:#fff;margin:0;font-size:24px;">Pet Circle</h1>
      </td>
    </tr>
    <tr>
      <td style="padding:32px 24px;">
        <h2 style="color:#1a1a1a;margin:0 0 8px;">You're invited!</h2>
        <p style="color:#666;font-size:16px;line-height:1.5;margin:0 0 24px;">
          <strong>${inviterName}</strong> has invited you to help monitor <strong>${petName}</strong>'s health on Pet Circle.
        </p>
        <p style="color:#666;font-size:14px;line-height:1.5;margin:0 0 24px;">
          You'll be able to measure respiratory rates, view health trends, and add notes &mdash; all shared with the care team.
        </p>
        <a href="${inviteLink}" style="display:block;background:#6B4EFF;color:#fff;text-decoration:none;padding:14px 32px;border-radius:48px;text-align:center;font-size:16px;font-weight:600;">
          Join ${petName}'s Circle
        </a>
        <p style="color:#999;font-size:12px;margin:24px 0 0;text-align:center;">
          This invitation expires in 7 days.
        </p>
      </td>
    </tr>
  </table>
</body>
</html>`;
}

export function invitationEmailText(params: {
  inviterName: string;
  petName: string;
  inviteLink: string;
}): string {
  // Line breaks here would let a crafted display name forge a second
  // "Join the circle:" line pointing at an attacker URL, which mail clients
  // render as a live link. See [sanitiseInline].
  const inviterName = sanitiseInline(params.inviterName);
  const petName = sanitiseInline(params.petName);
  const { inviteLink } = params;
  return [
    "You're invited to Pet Circle!",
    "",
    `${inviterName} has invited you to help monitor ${petName}'s health.`,
    "",
    `Join the circle: ${inviteLink}`,
    "",
    "This invitation expires in 7 days.",
  ].join("\n");
}
