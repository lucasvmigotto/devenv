#!/usr/bin/env python3
"""Generate a GitHub Actions build matrix from build/manifest.json.

Usage:
    gen-matrix.py base    # base-image rows
    gen-matrix.py lang    # language-image rows
"""
import json
import sys


def load():
    with open("build/manifest.json") as f:
        return json.load(f)


def base_rows(m):
    default = m.get("default_priv_tool", "sudo")
    rows = []
    for b in m["bases"]:
        for v in b["versions"]:
            for p in m["priv_tools"]:
                base_image = f"{b['image']}:{v}{b.get('tag_suffix', '')}"
                tag = f"{b['name']}-{v}"
                if p != default:
                    tag = f"{tag}-{p}"
                rows.append({
                    "distro": b["name"],
                    "version": v,
                    "base_image": base_image,
                    "pkg": b["pkg"],
                    "priv": p,
                    "tag": tag,
                })
    return rows


def lang_rows(m):
    rows = []
    for lang in m["languages"]:
        for v in lang["versions"]:
            for distro in lang["bases"]:
                rows.append({
                    "name": lang["name"],
                    "version": v,
                    "distro": distro,
                    "base_version": m["default_versions"][distro],
                    "tag": f"{lang['name']}-{v}-{distro}",
                })
    return rows


def main():
    kind = sys.argv[1] if len(sys.argv) > 1 else "base"
    m = load()
    rows = base_rows(m) if kind == "base" else lang_rows(m)
    print(json.dumps(rows))


if __name__ == "__main__":
    main()
