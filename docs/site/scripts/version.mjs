// The footer's versions: one per versioned part of the project, then the
// docs site's own, each linked to the tag it was built from
// (`devenv@v1.2.0 · docs@v1.2.0`). Pure, so it is unit-tested; the git
// lookups live in gitInfo().
import { execFileSync } from "node:child_process";

const TAG = "[0-9]*.[0-9]*.[0-9]*"; // release.yml tags plain SemVer, no "v"

function git(repo, ...args) {
  try {
    return execFileSync("git", ["-C", repo, ...args], {
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim();
  } catch {
    return "";
  }
}

// What git knows about the build: the release tag on HEAD (exact), the
// newest release tag behind it, and HEAD's sha. Empty strings without git.
export function gitInfo(repo) {
  return {
    exactTag: git(repo, "describe", "--tags", "--exact-match", "--match", TAG),
    lastTag: git(repo, "describe", "--tags", "--abbrev=0", "--match", TAG),
    sha: git(repo, "rev-parse", "HEAD"),
  };
}

// footerVersions — [{ name, version, href }] for the footer.
//   on a release tag   devenv@v1.12.0          -> <repo>/tree/1.12.0
//   past a tag         devenv@v1.12.0+abc1234  -> <repo>/tree/<sha>
//   no tag yet         devenv@dev+abc1234      -> <repo>/tree/<sha>
//   no git             devenv@dev              (no link)
// The docs entry carries the site's own version and links to the same
// tree, under docsPath.
export function footerVersions({ repoUrl, name, docsVersion, docsPath, git }) {
  const { exactTag, lastTag, sha } = git;
  const short = sha.slice(0, 7);
  const ref = exactTag || sha;
  const project = exactTag || (sha ? `${lastTag || "dev"}+${short}` : "dev");
  const docs = exactTag || !sha ? docsVersion : `${docsVersion}+${short}`;
  const tree = ref ? `${repoUrl}/tree/${ref}` : null;
  return [
    { name, version: project, href: tree },
    { name: "docs", version: docs, href: tree && `${tree}/${docsPath}` },
  ];
}

// `name@vX.Y.Z` (the "v" is display-only), or `name@dev…` before any release.
export function label({ name, version }) {
  return /^\d/.test(version) ? `${name}@v${version}` : `${name}@${version}`;
}
