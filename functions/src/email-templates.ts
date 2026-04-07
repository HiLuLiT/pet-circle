export function invitationEmailHtml(params: {
  inviterName: string;
  petName: string;
  inviteLink: string;
}): string {
  const { inviterName, petName, inviteLink } = params;
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
  const { inviterName, petName, inviteLink } = params;
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
