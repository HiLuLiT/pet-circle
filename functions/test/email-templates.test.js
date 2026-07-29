"use strict";

/**
 * Tests for the invitation email templates.
 *
 * These cover the BUG-041 fixes, which are security-relevant: `inviterName`
 * and `petName` reach the templates from client-controlled Firestore fields
 * (`invitedByName` is the sender's own display name), and the recipient
 * address is chosen by the sender too — so a crafted name is attacker input
 * in mail that legitimately originates from the project's sending domain.
 *
 * Run with `npm test` in `functions/` (builds first, then `node --test`).
 * Requires the compiled output in `lib/`, so it exercises exactly what ships.
 */

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  sanitiseInline,
  invitationEmailHtml,
  invitationEmailText,
} = require("../lib/email-templates");

const LINK = "https://petcircle.app/invite?token=abc123";

/**
 * The payload from the security review: a display name that uses newlines to
 * forge an extra "Join the circle:" line pointing at an attacker URL, framed
 * so it is indistinguishable from the real one in the plain-text part.
 */
const FORGED_LINE_NAME = [
  "Alice",
  "",
  "Join the circle: https://evil.example/petcircle",
  "",
  "Original invite (expired):",
].join("\n");

test("sanitiseInline flattens CR, LF and tabs to single spaces", () => {
  assert.equal(sanitiseInline("a\nb"), "a b");
  assert.equal(sanitiseInline("a\r\nb"), "a b");
  assert.equal(sanitiseInline("a\tb"), "a b");
  assert.equal(sanitiseInline("a\n\n\nb"), "a b");
});

test("sanitiseInline collapses whitespace runs and trims", () => {
  assert.equal(sanitiseInline("  a     b  "), "a b");
  assert.equal(sanitiseInline("\n\n  Alice  \n\n"), "Alice");
});

test("sanitiseInline caps length at 100 characters", () => {
  const long = "x".repeat(500);
  assert.equal(sanitiseInline(long).length, 100);
});

test("sanitiseInline leaves an ordinary name untouched", () => {
  assert.equal(sanitiseInline("Hila Bar-Barak"), "Hila Bar-Barak");
});

test("sanitiseInline output never contains a line break", () => {
  const out = sanitiseInline(FORGED_LINE_NAME);
  assert.ok(!out.includes("\n"), "expected no LF in sanitised output");
  assert.ok(!out.includes("\r"), "expected no CR in sanitised output");
});

test("sanitiseInline handles empty and whitespace-only input", () => {
  assert.equal(sanitiseInline(""), "");
  assert.equal(sanitiseInline("   \n\t  "), "");
});

test("text template renders exactly one Join-the-circle line (BUG-041)", () => {
  const body = invitationEmailText({
    inviterName: FORGED_LINE_NAME,
    petName: "Rex",
    inviteLink: LINK,
  });

  const joinLines = body
    .split("\n")
    .filter((line) => line.startsWith("Join the circle:"));

  assert.equal(
    joinLines.length,
    1,
    "a crafted display name must not be able to forge a second " +
      "Join-the-circle line at the start of a line"
  );
  assert.equal(joinLines[0], `Join the circle: ${LINK}`);
});

test("text template keeps the crafted name confined to one line", () => {
  const body = invitationEmailText({
    inviterName: FORGED_LINE_NAME,
    petName: "Rex",
    inviteLink: LINK,
  });

  // The line carrying the inviter name must be a single line: the attacker's
  // own text may still appear inside it, but it can no longer control the
  // body's line structure, which is what made the forged link convincing.
  const nameLines = body
    .split("\n")
    .filter((line) => line.includes("Alice"));
  assert.equal(nameLines.length, 1);
  assert.ok(nameLines[0].includes("has invited you to"));
});

test("text template renders an ordinary invitation correctly", () => {
  const body = invitationEmailText({
    inviterName: "Hila",
    petName: "Rex",
    inviteLink: LINK,
  });

  assert.ok(body.includes("Hila has invited you to help monitor Rex's health."));
  assert.ok(body.includes(`Join the circle: ${LINK}`));
});

test("html template escapes markup in the inviter name", () => {
  const html = invitationEmailHtml({
    inviterName: '<script>alert(1)</script>',
    petName: "Rex",
    inviteLink: LINK,
  });

  assert.ok(!html.includes("<script>"), "raw <script> must not survive");
  assert.ok(html.includes("&lt;script&gt;"));
});

test("html template escapes markup in the pet name at every site", () => {
  const html = invitationEmailHtml({
    inviterName: "Hila",
    petName: '<img src=x onerror=alert(1)>',
    inviteLink: LINK,
  });

  assert.ok(!html.includes("<img src=x"), "raw <img> must not survive");
  // petName is interpolated twice: the body copy and the button label.
  const escapedCount = html.split("&lt;img src=x").length - 1;
  assert.equal(escapedCount, 2, "both petName sites must be escaped");
});

test("html template escapes quotes so attributes cannot be broken out of", () => {
  const html = invitationEmailHtml({
    inviterName: '" onmouseover="alert(1)',
    petName: "Rex",
    inviteLink: LINK,
  });

  assert.ok(!html.includes('" onmouseover="'));
  assert.ok(html.includes("&quot;"));
});

test("html template escapes ampersands without double-escaping", () => {
  const html = invitationEmailHtml({
    inviterName: "Ben & Jerry",
    petName: "Rex",
    inviteLink: LINK,
  });

  assert.ok(html.includes("Ben &amp; Jerry"));
  assert.ok(!html.includes("&amp;amp;"), "ampersand must be escaped once only");
});

test("html template flattens a newline-crafted name before escaping", () => {
  const html = invitationEmailHtml({
    inviterName: FORGED_LINE_NAME,
    petName: "Rex",
    inviteLink: LINK,
  });

  // sanitiseInline runs before escapeHtml, so the name contributes no line
  // breaks to the markup either.
  const nameLines = html.split("\n").filter((l) => l.includes("Alice"));
  assert.equal(nameLines.length, 1);
});

test("html template keeps the invite link usable in the href", () => {
  const html = invitationEmailHtml({
    inviterName: "Hila",
    petName: "Rex",
    inviteLink: LINK,
  });

  // Escaping the link must not mangle it — there is no '&' in this link, so
  // it should appear verbatim inside the href.
  assert.ok(html.includes(`href="${LINK}"`));
});

test("html template escapes a link carrying a crafted token", () => {
  const html = invitationEmailHtml({
    inviterName: "Hila",
    petName: "Rex",
    inviteLink: 'https://petcircle.app/invite?token=x" onclick="alert(1)',
  });

  assert.ok(!html.includes('" onclick="'), "must not break out of the href");
  assert.ok(html.includes("&quot;"));
});
