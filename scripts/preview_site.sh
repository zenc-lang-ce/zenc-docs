#!/usr/bin/env bash
# Serves the website with this checkout's documentation, as sync-docs.yml would publish it, and
# syncs it again whenever a file changes. The website checkout is copied to .preview/, so it
# stays as it is.
#
# Usage: scripts/preview_site.sh WEBSITE_DIR [PORT]    (or `make serve`)
# Needs python3 and rsync, and Zola 0.18.0 (the version the site deploys with) or Docker.
set -euo pipefail

docs=$(cd "$(dirname "$0")/.." && pwd)
if [ ! -f "${1:-}/docs.zenc-lang.org/config.toml" ]; then
    echo "usage: $0 WEBSITE_DIR [PORT]: WEBSITE_DIR is a checkout of zenc-lang-ce/zenc-lang-ce.github.io" >&2
    exit 1
fi
web=$(cd "$1" && pwd)
port=${2:-1111}
zola_version=0.18.0
preview=$docs/.preview

mkdir -p "$preview"
rsync -a --delete --exclude .git "$web/" "$preview/site/"

echo "Syncing the documentation..."
"$docs/scripts/sync_to_site.sh" "$preview/site"

# The parts of sync_to_site.sh that a changed file of this checkout belongs to
parts_of() {
    case ${1#"$docs"/} in
    reference/*) echo tour ;;
    std/*) echo std ;;
    tools/*) echo tools ;;
    migrations/*) echo migrations ;;
    rosetta/*) echo rosetta ;;
    site/templates/shortcodes/*) echo shortcodes ;;
    scripts/sync_to_site.sh) echo shortcodes std tour pages tools migrations rosetta ;;
    *.md) echo pages ;;
    esac
}

# Sync again whenever a file of this checkout changes: only the parts it belongs to
stamp=$preview/synced
touch "$stamp"
(
    while sleep 2; do
        changed=$(find "$docs" \( -path "$preview" -o -path "$docs/.git" \) -prune -o \
            -type f -newer "$stamp" -print)
        [ -n "$changed" ] || continue
        touch "$stamp"
        parts=$(while read -r file; do parts_of "$file"; done <<< "$changed" | tr ' ' '\n' | sort -u | tr '\n' ' ')
        if [ -n "${parts// /}" ]; then
            # shellcheck disable=SC2086 # one argument per part
            "$docs/scripts/sync_to_site.sh" "$preview/site" $parts && echo "Synced $parts$(date +%H:%M:%S)"
        fi
    done
) &
watcher=$!

# The server runs in the background and the script waits for it, so that Ctrl+C or a kill
# reaches the trap at once and stops the watcher and the server (and its container) too
container=zenc-docs-preview
server=
cleanup() {
    kill "$watcher" ${server:+"$server"} 2> /dev/null || true
    docker rm -f "$container" > /dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT TERM

cd "$preview/site/docs.zenc-lang.org"
echo "Serving at http://localhost:$port/docs/"
if command -v zola > /dev/null && zola --version | grep -q " $zola_version"; then
    zola serve --port "$port" &
else
    docker run --rm --name "$container" -p "$port:$port" -v "$PWD:/app" -w /app "ghcr.io/getzola/zola:v$zola_version" \
        serve --interface 0.0.0.0 --port "$port" --base-url localhost &
fi
server=$!
wait "$server"
