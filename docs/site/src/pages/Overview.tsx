import { Badge, Callout, Card, Section } from "../components/ui";

export function Overview() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">devenv — reproducible DevContainer images</h1>
        <p className="mt-2 max-w-3xl text-slate-400">
          A suite of container images that give every developer the same shell, the same toolchains,
          and the same caches — on any machine.
        </p>
      </div>

      <Section title="Initiative">
        <p>
          Development environments drift: different OS versions, conflicting toolchains, “works on
          my machine” bugs, and hours lost onboarding. devenv answers with{" "}
          <strong>container images as the dev environment</strong> — one parametrized base image
          plus one image per programming language, all sharing the same non-root user, shell, and
          cache conventions.
        </p>
      </Section>

      <Section title="Objectives">
        <ul className="list-disc space-y-1 pl-5">
          <li>
            <strong>Reproducibility</strong> — pinned base distros, pinned toolchain versions in{" "}
            <Badge>build/manifest.json</Badge>, SLSA provenance attestations on every push.
          </li>
          <li>
            <strong>Security by default</strong> — never run as root: a <Badge>developer</Badge>{" "}
            user (UID 1000) with passwordless <Badge>sudo</Badge>/<Badge>doas</Badge> escalation
            only.
          </li>
          <li>
            <strong>Developer experience</strong> — ZSH + Spaceship prompt and Nerd Fonts, driven by
            the <Badge>dottod</Badge> dotfiles submodule so images stay in sync with the
            maintainer's workstation.
          </li>
          <li>
            <strong>Cache persistence</strong> — every language image declares <Badge>VOLUME</Badge>
            s for its dependency caches under <Badge>$HOME</Badge>, so rebuilds don't re-download
            the world.
          </li>
          <li>
            <strong>Data-driven CI</strong> — adding a language is a <Badge>manifest.json</Badge>{" "}
            entry plus one Dockerfile; no workflow YAML changes required.
          </li>
        </ul>
      </Section>

      <Section title="Non-goals">
        <p>
          devenv is not a package manager, not a CI runner image for production workloads, and not a
          minimal/distroless base — images optimize for interactive development ergonomics over byte
          size.
        </p>
        <Callout>
          All facts on this site derive from the repository itself — notably{" "}
          <Badge>README.md</Badge>, <Badge>build/manifest.json</Badge>,{" "}
          <Badge>.docker/*.Dockerfile</Badge>, <Badge>bin/*.sh</Badge>, and{" "}
          <Badge>.github/workflows/*.yml</Badge>. The language catalog is generated at build time
          from <Badge>manifest.json</Badge>, so it cannot drift from CI reality.
        </Callout>
      </Section>

      <div className="grid gap-4 md:grid-cols-3">
        <Card title="4 base distros">Debian · Ubuntu · Alpine · Arch Linux</Card>
        <Card title="28 languages">
          From assembly to zig — incl. JVM, .NET, Flutter+Android, Haskell, Smalltalk (Pharo) and
          Delphi-mode Pascal.
        </Card>
        <Card title="2 registries">Every image ships to GHCR and Docker Hub.</Card>
      </div>
    </div>
  );
}
