const test = require("node:test");
const assert = require("node:assert");

const { memberUidsFromPetData } = require("../lib/pet-cleanup");

test("memberUidsFromPetData returns [] for a missing document", () => {
  assert.deepStrictEqual(memberUidsFromPetData(undefined), []);
});

test("memberUidsFromPetData reads the denormalised memberUids array", () => {
  const uids = memberUidsFromPetData({ memberUids: ["u1", "u2"] });
  assert.deepStrictEqual(uids.sort(), ["u1", "u2"]);
});

test("memberUidsFromPetData falls back to careCircle uids", () => {
  // Pets written before `memberUids` existed only carry the care circle.
  const uids = memberUidsFromPetData({
    careCircle: [{ uid: "owner" }, { uid: "vet" }],
  });
  assert.deepStrictEqual(uids.sort(), ["owner", "vet"]);
});

test("memberUidsFromPetData de-duplicates across both sources", () => {
  const uids = memberUidsFromPetData({
    memberUids: ["u1", "u2"],
    careCircle: [{ uid: "u1" }, { uid: "u3" }],
  });
  assert.deepStrictEqual(uids.sort(), ["u1", "u2", "u3"]);
});

test("memberUidsFromPetData drops members with no uid", () => {
  // An invited-but-unregistered member has no uid yet; batching an update
  // against an empty doc id would throw and strand the whole cleanup.
  const uids = memberUidsFromPetData({
    careCircle: [{ uid: "u1" }, { name: "Invited vet" }, { uid: "" }],
  });
  assert.deepStrictEqual(uids, ["u1"]);
});

test("memberUidsFromPetData ignores non-array fields", () => {
  assert.deepStrictEqual(
    memberUidsFromPetData({ memberUids: "u1", careCircle: null }),
    []
  );
});
