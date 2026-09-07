import { clsx } from "clsx";
import type { ReactNode } from "react";
import { twMerge } from "tailwind-merge";

export function cx(...inputs: (string | false | null | undefined)[]) {
  return twMerge(clsx(...inputs));
}

export function Section({
  id,
  title,
  children,
}: {
  id?: string;
  title: string;
  children: ReactNode;
}) {
  return (
    <section id={id} className="scroll-mt-20 space-y-3">
      <h2 className="text-xl font-semibold text-sky-300">{title}</h2>
      <div className="space-y-3 text-sm leading-relaxed text-slate-300">{children}</div>
    </section>
  );
}

export function Card({
  title,
  children,
  className,
}: {
  title?: string;
  children: ReactNode;
  className?: string;
}) {
  return (
    <div className={cx("rounded-xl border border-slate-800 bg-slate-900/60 p-4", className)}>
      {title ? <h3 className="mb-2 text-sm font-semibold text-slate-100">{title}</h3> : null}
      <div className="text-sm text-slate-300">{children}</div>
    </div>
  );
}

export function Badge({ children }: { children: ReactNode }) {
  return (
    <code className="rounded bg-slate-800 px-1.5 py-0.5 font-mono text-xs text-sky-200">
      {children}
    </code>
  );
}

export function Callout({
  kind = "note",
  children,
}: {
  kind?: "note" | "warn";
  children: ReactNode;
}) {
  return (
    <div
      className={cx(
        "rounded-lg border-l-4 p-3 text-sm",
        kind === "warn"
          ? "border-amber-400 bg-amber-950/40 text-amber-100"
          : "border-sky-400 bg-sky-950/40 text-sky-100",
      )}
    >
      {children}
    </div>
  );
}

export function CodeBlock({ code, lang = "bash" }: { code: string; lang?: string }) {
  return (
    <pre className="overflow-x-auto rounded-lg border border-slate-800 bg-black/60 p-4 text-[13px] leading-relaxed">
      <code data-lang={lang} className="text-slate-200">
        {code}
      </code>
    </pre>
  );
}

export function TagTable({ headers, rows }: { headers: string[]; rows: string[][] }) {
  return (
    <div className="overflow-x-auto rounded-lg border border-slate-800">
      <table className="w-full text-left text-sm">
        <thead>
          <tr className="bg-slate-900 text-xs uppercase tracking-wide text-slate-400">
            {headers.map((h) => (
              <th key={h} className="px-4 py-2 font-medium">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, i) => (
            <tr key={row.join("|")} className={i % 2 === 0 ? "bg-slate-950/60" : "bg-slate-900/40"}>
              {row.map((cell, j) => (
                // biome-ignore lint/suspicious/noArrayIndexKey: static tables, order never changes
                <td key={j} className="px-4 py-2 align-top text-slate-300">
                  {cell}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
