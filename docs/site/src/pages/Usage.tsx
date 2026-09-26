import { Badge, Callout, CodeBlock, Section } from "../components/ui";

export function Usage() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Usage</h1>
        <p className="mt-2 max-w-3xl text-slate-400">
          Pull an image and start hacking — no local toolchain required.
        </p>
      </div>

      <Section title="1. Run a base image">
        <CodeBlock
          code={`# interactive zsh, non-root developer user
docker run -it --rm lucasvmigotto/devenv:latest

# passwordless escalation inside the container
sudo -n true   # or: doas -n true  (on -doas tags)`}
        />
      </Section>

      <Section title="2. Run a language image">
        <CodeBlock
          code={`docker run -it --rm lucasvmigotto/devenv:go-1.26-debian
docker run -it --rm lucasvmigotto/devenv:python-3.14-alpine
docker run -it --rm lucasvmigotto/devenv:node-24.20.0-npm-debian`}
        />
        <p>
          Pick a tag from the <Badge>Catalog</Badge> page. Variant suffixes: <Badge>-jdk21</Badge>{" "}
          (flutter), <Badge>-npm</Badge>/<Badge>-pnpm</Badge> (node), <Badge>-doas</Badge> (bases).
        </p>
      </Section>

      <Section title="3. Persist caches with named volumes">
        <p>
          Declared <Badge>VOLUME</Badge>s are anonymous by default; mount named volumes to keep them
          across rebuilds:
        </p>
        <CodeBlock
          code={`docker run -it --rm \\
  -v rust-cargo:/home/developer/.cargo \\
  lucasvmigotto/devenv:rust-1.89-debian`}
        />
      </Section>

      <Section title="4. Use as a DevContainer">
        <CodeBlock
          lang="json"
          code={`{
  "image": "lucasvmigotto/devenv:go-1.26-debian",
  "remoteUser": "developer"
}`}
        />
        <CodeBlock
          lang="yaml"
          code={`services:
  dev:
    image: lucasvmigotto/devenv:rust-1.89-debian
    user: developer
    volumes:
      - rust-cargo:/home/developer/.cargo
      - ./:/workspace
    working_dir: /workspace

volumes:
  rust-cargo:`}
        />
      </Section>

      <Section title="5. Build from source">
        <p>Base image (single parametrized Dockerfile):</p>
        <CodeBlock
          code={`docker build -f .docker/base.Dockerfile \\
    --build-arg _BASE_IMAGE=debian:trixie-slim \\
    --build-arg _DISTRO=debian \\
    --build-arg _PRIV_TOOL=sudo \\
    -t devenv:debian-trixie .`}
        />
        <p>Language image (base reference is overridable via `_BASE_IMAGE`):</p>
        <CodeBlock
          code={`docker build -f .docker/rust.Dockerfile \\
    --build-arg _VERSION=1.89 \\
    --build-arg _DISTRO_NAME=debian \\
    --build-arg _DISTRO_VERSION=trixie \\
    --build-arg _BASE_IMAGE=devenv:debian-trixie \\
    -t devenv:rust .`}
        />
        <Callout>
          Language builds run <em>after</em> the base in CI (<Badge>workflow_run</Badge> chain);
          locally, point <Badge>_BASE_IMAGE</Badge> at a tag you built or pulled.
        </Callout>
      </Section>
    </div>
  );
}
