import { describe, expect, it } from "bun:test";
import { footerVersions, label } from "../scripts/version.mjs";

const base = {
  repoUrl: "https://github.com/o/r",
  name: "r",
  docsVersion: "1.2.0",
  docsPath: "docs/site",
};
const sha = "abc1234def5678";

describe("footerVersions", () => {
  it("links a release build to its tag", () => {
    const v = footerVersions({ ...base, git: { exactTag: "1.2.0", lastTag: "1.2.0", sha } });
    expect(v.map(label)).toEqual(["r@v1.2.0", "docs@v1.2.0"]);
    expect(v.map((x) => x.href)).toEqual([
      "https://github.com/o/r/tree/1.2.0",
      "https://github.com/o/r/tree/1.2.0/docs/site",
    ]);
  });

  it("marks a build past the tag with its commit", () => {
    const v = footerVersions({ ...base, git: { exactTag: "", lastTag: "1.2.0", sha } });
    expect(v.map(label)).toEqual(["r@v1.2.0+abc1234", "docs@v1.2.0+abc1234"]);
    expect(v.map((x) => x.href)).toEqual([
      `https://github.com/o/r/tree/${sha}`,
      `https://github.com/o/r/tree/${sha}/docs/site`,
    ]);
  });

  it("reads dev before the first tag, and has no link without git", () => {
    const untagged = footerVersions({ ...base, git: { exactTag: "", lastTag: "", sha } });
    expect(untagged.map(label)).toEqual(["r@dev+abc1234", "docs@v1.2.0+abc1234"]);
    const nogit = footerVersions({ ...base, git: { exactTag: "", lastTag: "", sha: "" } });
    expect(nogit.map(label)).toEqual(["r@dev", "docs@v1.2.0"]);
    expect(nogit.every((x) => x.href === null)).toBe(true);
  });
});
