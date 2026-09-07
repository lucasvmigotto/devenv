import { Badge, Callout, CodeBlock, Section } from "../components/ui";

export function Development() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-white">Development</h1>
        <p className="mt-2 max-w-3xl text-slate-400">
          Extend the suite, modify images, and debug the pipeline.
        </p>
      </div>

      <Section title="Adding a language (the standard recipe)">
        <ol className="list-decimal space-y-2 pl-5">
          <li>
            Add one entry to <Badge>build/manifest.json</Badge> — name, versions, bases (and
            optional <Badge>jdk</Badge>/<Badge>pm</Badge> variant lists).{" "}
            <strong>No workflow YAML changes needed.</strong>
          </li>
          <li>
            Write <Badge>.docker/{"<name>"}.Dockerfile</Badge> following the contract:{" "}
            <Badge>ARG</Badge> block → optional builder stage →{" "}
            <Badge>{"FROM $" + "{_BASE_IMAGE}"}</Badge> → <Badge>USER root</Badge> setup →{" "}
            <Badge>chown developer</Badge> caches → <Badge>ENV</Badge> →{" "}
            <Badge>USER developer</Badge> → <Badge>VOLUME</Badge>.
          </li>
          <li>
            Validate locally: <Badge>python3 build/gen-matrix.py lang</Badge> shows your rows;{" "}
            <Badge>docker build</Badge> the image; smoke-test the toolchain as{" "}
            <Badge>developer</Badge>.
          </li>
          <li>
            Update <Badge>README.md</Badge> + <Badge>dockerhub.README.md</Badge> language tables
            (like this site's Catalog, they must match the manifest).
          </li>
        </ol>
        <Callout>
          Base restriction is a deliberate decision: upstream glibc-linked binaries exclude
          musl/Alpine (dotnet, elixir, haskell, flutter…); never silently ship a broken combo —
          narrow <Badge>bases</Badge> instead.
        </Callout>
      </Section>

      <Section title="Extending the plumbing">
        <ul className="list-disc space-y-2 pl-5">
          <li>
            <Badge>bin/pkg.sh</Badge> — POSIX-sh package abstraction (
            <Badge>pkg_update / pkg_install / pkg_clean</Badge>) over apt / apk / pacman; sourced by
            every distro-package Dockerfile.
          </li>
          <li>
            <Badge>bin/groupnuser.sh</Badge> — idempotent UID-1000 user/group creation with{" "}
            <Badge>sudo</Badge>/<Badge>doas</Badge> switch.
          </li>
          <li>
            <Badge>build/gen-matrix.py</Badge> — pure-stdlib matrix renderer; keep it
            dependency-free (a <Badge>jq</Badge>/Rust swap was evaluated and rejected: the{" "}
            <Badge>jdk</Badge>×<Badge>pm</Badge> cross-product doesn't map cleanly, and matrix
            generation is microseconds, not a hot path).
          </li>
          <li>
            <Badge>docs/package.json</Badge> + <Badge>##VERSION##</Badge> — release tags come from
            the package.json <Badge>version</Badge> field; the Docker Hub README is substituted at
            sync time.
          </li>
        </ul>
      </Section>

      <Section title="CI triggers & chain">
        <CodeBlock
          lang="text"
          code={`Release (package.json tag) → Base → Languages → Docker Hub description
             (workflow_run, success-gated)   (+ description job inside languages.yml)`}
        />
        <p>
          Each hop fires on the previous workflow's <Badge>completed</Badge> event and runs only if
          its <Badge>conclusion == 'success'</Badge>. <Badge>workflow_dispatch</Badge> is kept on
          every workflow for manual single-stage runs. GitHub caps <Badge>workflow_run</Badge>{" "}
          chains at three levels — that's why the description sync is a <em>job</em> inside{" "}
          <Badge>languages.yml</Badge>, not a fourth workflow.
        </p>
      </Section>

      <Section title="Troubleshooting (from real incidents)">
        <ul className="list-disc space-y-2 pl-5">
          <li>
            <strong>Ubuntu UID-1000 collision</strong> — upstream Ubuntu images ship an{" "}
            <Badge>ubuntu</Badge> user at UID 1000; <Badge>groupnuser.sh</Badge> renames it instead
            of failing.
          </li>
          <li>
            <strong>gopls vs old Go</strong> — <Badge>gopls@latest</Badge> requires newer Go; the
            image pins <Badge>v0.21.1</Badge> for Go &lt; 1.26 via a version conditional.
          </li>
          <li>
            <strong>Corepack first-run downloads</strong> — pre-seed caches as{" "}
            <Badge>developer</Badge> via <Badge>su</Badge> at build time and warm up the binary, so
            containers work offline.
          </li>
          <li>
            <strong>Stale base tag shadowing</strong> — always retag or rebuild the local base
            before testing a language image (<Badge>_BASE_IMAGE</Badge> override exists for this).
          </li>
          <li>
            <strong>GHA cache reservation failures</strong> — 100+ large images overflow the repo
            cache budget; the fix was read-only caching (<Badge>cache-from</Badge> only, no{" "}
            <Badge>cache-to</Badge> writes).
          </li>
          <li>
            <strong>Docker Hub 502 on push</strong> — transient registry outage; retry. Attestation
            and tagging are independent of it.
          </li>
        </ul>
      </Section>
    </div>
  );
}
