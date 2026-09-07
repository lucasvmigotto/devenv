import { Badge, Callout, Card, CodeBlock, Section, TagTable } from "../components/ui";
import { baseTags } from "../data/manifest";

const BASE_PIPELINE = `base image (debian/ubuntu/alpine/archlinux)
  └─ bootstrap.sh  → installs bash per distro (POSIX sh)
  └─ setup-base.sh → packages → groupnuser.sh (UID 1000 developer)
  └─ dottod shell.sh → zsh + oh-my-zsh + Spaceship (as developer)
  └─ dottod fonts.sh → FiraCode / FiraMono / SymbolsOnly (global)
  └─ USER developer · WORKDIR $HOME · ENTRYPOINT ["zsh", "-l"]`;

const GO_WALKTHROUGH = `# 1. Builder stage pulls the upstream toolchain…
FROM golang:\${_VERSION} AS go
RUN go install golang.org/x/tools/gopls@latest   # version-conditional in practice

# 2. …and copies it into the devenv base
FROM \${_BASE_IMAGE}
USER root                                        # setup runs as root…
COPY --from=go /usr/local/go /usr/local/go
COPY --from=go /go /home/developer/go
ENV GOPATH / GOPATH/bin on PATH
RUN mkdir -p <caches> && chown -R developer:developer <caches>

# 3. …then drops privileges for runtime
USER developer · WORKDIR $HOME · VOLUME [caches]`;

export function Architecture() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Architecture & patterns</h1>
        <p className="mt-2 max-w-3xl text-slate-400">
          How the base image, the language images, and the CI matrix fit together.
        </p>
      </div>

      <Section title="Repository layout">
        <TagTable
          headers={["Path", "Role"]}
          rows={[
            [".docker/", "base.Dockerfile + one Dockerfile per language"],
            ["bin/", "pkg.sh (POSIX pkg abstraction), groupnuser.sh, setup-base.sh, bootstrap.sh"],
            ["build/", "manifest.json (single source of truth) + gen-matrix.py"],
            ["dottod/", "git submodule — shell/fonts source of truth"],
            [".github/workflows/", "base → languages → description chain + reusable build-image"],
            [
              "docs/package.json",
              "release tag source (version field); ##VERSION## placeholder in dockerhub.README.md",
            ],
          ]}
        />
      </Section>

      <Section title="Base image pipeline">
        <p>
          One parametrized <Badge>.docker/base.Dockerfile</Badge> builds all four distros via{" "}
          <Badge>_BASE_IMAGE</Badge>, <Badge>_DISTRO</Badge> and <Badge>_PRIV_TOOL</Badge> (
          <Badge>sudo</Badge> default, <Badge>-doas</Badge> suffix tag). The setup is a numbered
          pipeline:
        </p>
        <CodeBlock lang="text" code={BASE_PIPELINE} />
        <p>
          Idempotency is a first-class rule: <Badge>groupnuser.sh</Badge> renames a colliding
          UID-1000 account (e.g. Ubuntu's <Badge>ubuntu</Badge> user) instead of failing, and all
          scripts are safe to re-run.
        </p>
      </Section>

      <Section title="Language image anatomy (annotated go.Dockerfile)">
        <p>
          Language images follow two shapes: <strong>distro packages</strong> (
          <Badge>c.Dockerfile</Badge>: <Badge>pkg_update/pkg_install</Badge> with a per-distro{" "}
          <Badge>case</Badge>) and <strong>multi-stage COPY</strong> from upstream images (
          <Badge>go</Badge>, <Badge>rust</Badge>, <Badge>flutter</Badge>). Annotated walkthrough:
        </p>
        <CodeBlock lang="dockerfile" code={GO_WALKTHROUGH} />
        <div className="grid gap-4 md:grid-cols-2">
          <Card title="Conventions every image follows">
            <ul className="list-disc space-y-1 pl-5">
              <li>
                <Badge>ARG _VERSION / _DISTRO_NAME / _DISTRO_VERSION / _BASE_IMAGE</Badge> (base
                overridable for local builds)
              </li>
              <li>
                Re-declared <Badge>ARG</Badge>s after each <Badge>FROM</Badge> (global ARGs aren't
                visible in later stages)
              </li>
              <li>
                Toolchain installs run as <Badge>root</Badge>; per-user setup runs via{" "}
                <Badge>su developer</Badge> (haskell ghcup, scala coursier, node corepack)
              </li>
              <li>
                Caches <Badge>mkdir -p</Badge>'d then <Badge>chown -R developer</Badge>, declared as{" "}
                <Badge>VOLUME</Badge> under <Badge>$HOME</Badge>
              </li>
            </ul>
          </Card>
          <Card title="Notable special cases">
            <ul className="list-disc space-y-1 pl-5">
              <li>
                <Badge>gopls</Badge> install is version-conditional (pinned <Badge>v0.21.1</Badge>{" "}
                for Go &lt; 1.26)
              </li>
              <li>
                <Badge>node</Badge> pre-seeds corepack caches as <Badge>developer</Badge> so first
                use needs no download
              </li>
              <li>
                <Badge>flutter</Badge> layers curl → flutter tarball → JDK → Android cmdline-tools,
                then sdkmanager + precache
              </li>
              <li>
                <Badge>scala</Badge> uses <Badge>cs install</Badge> with exact versions (Maven has
                no bare <Badge>3.7</Badge>)
              </li>
            </ul>
          </Card>
        </div>
      </Section>

      <Section title="CI matrix (data-driven)">
        <p>
          <Badge>build/manifest.json</Badge> declares bases, languages, versions, and the{" "}
          <Badge>jdk</Badge>/<Badge>pm</Badge> variant dimensions.{" "}
          <Badge>build/gen-matrix.py</Badge> renders rows like{" "}
          <Badge>flutter-3.47.0-jdk21-debian</Badge> or <Badge>node-24.20.0-npm-debian</Badge>{" "}
          (first variant entry = default, unsuffixed). Chain:{" "}
          <Badge>Release (package.json tag) → Base → Languages → Docker Hub description</Badge>,
          gated on success at each hop (<Badge>needs.build.result == 'success'</Badge>),
          `max-parallel: 8`, GHA cache read-only, SLSA attestations on every image.
        </p>
        <Callout kind="warn">
          Platform limits shape the design: more than three <Badge>workflow_run</Badge> hops never
          fire, which is why the Docker Hub description sync is a <em>job inside</em>{" "}
          `languages.yml` rather than a fourth workflow.
        </Callout>
      </Section>

      <Section title="Tag scheme">
        <p>
          Bases: <Badge>{`{distro}-{version}[-doas]`}</Badge> plus a{" "}
          <Badge>latest → debian-trixie</Badge> alias. Languages:{" "}
          <Badge>{`{lang}-{version}[-variant]-{distro}`}</Badge>. Full enumeration lives on the
          Catalog page, generated from the manifest.
        </p>
        <TagTable
          headers={["Current base tags (sample)"]}
          rows={baseTags()
            .slice(0, 8)
            .map((t) => [t])}
        />
      </Section>
    </div>
  );
}
