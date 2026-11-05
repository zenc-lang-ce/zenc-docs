#!/usr/bin/env bash
# Copies this repository's documentation into a checkout of the website repository
# (zenc-lang-ce/zenc-lang-ce.github.io), as the site expects it: the language reference split
# into the Tour pages, the standard library, the Getting Started pages, the migration guides and
# the Rosetta examples, with Zola front matter and the GitHub alerts turned into the site's
# alert shortcode.
#
# Usage: scripts/sync_to_site.sh WEBSITE_DIR [PART...]
#   PART: shortcodes, std, tour, pages (Getting Started), migrations, rosetta. Without parts it
#   syncs them all, as .github/workflows/sync-docs.yml does before committing to the website
#   repository; `make serve` syncs only the parts whose files changed.
set -euo pipefail

docs=$(cd "$(dirname "$0")/.." && pwd)
site=$(cd "$1" && pwd)/docs.zenc-lang.org
shift
parts=${*:-shortcodes std tour pages migrations rosetta}
# The directories of the site whose pages get the section guard and the front matter below
synced_dirs=()

sync_shortcodes() {
    # e.g., misra_table.html: self-contained, no external data file
    mkdir -p "$site/templates/shortcodes/"
    rsync -a "$docs/site/templates/shortcodes/" "$site/templates/shortcodes/"
}

# Copies DIR of this repository to the site's content/docs/TARGET, with each README as the
# _index page of its section
sync_section() {
    local dir=$1 target=$2
    mkdir -p "$site/content/docs/$target/"
    rsync -a --delete --exclude='_index*.md' "$docs/$dir/" "$site/content/docs/$target/"
    find "$site/content/docs/$target/" -name "README*.md" | while read -r file; do
        mv "$file" "${file/README/_index}"
    done
    synced_dirs+=("$site/content/docs/$target")
}

sync_tour() {
    mkdir -p "$site/content/docs/tour/"
    rsync -a --delete --exclude='_index.md' "$docs/reference/" "$site/content/docs/tour/"
    synced_dirs+=("$site/content/docs/tour")
}

sync_pages() {
    # English only, shown as plain documents, with their GitHub alerts (> [!WARNING]) turned
    # into the site's alert shortcode
    for name in introduction install changelog editors; do
        title=$(grep -m 1 "^# " "$docs/$name.md" | sed 's/^# //')
        {
            printf '+++\ntitle = "%s"\ntemplate = "plain.html"\n+++\n\n' "$title"
            python3 "$docs/scripts/convert_alerts.py" "$docs/$name.md"
        } > "$site/content/docs/$name.md"
    done
}

sync_migrations() {
    # English only: one page per release, shown as plain documents
    mkdir -p "$site/content/docs/migrations/"
    rsync -a --delete --exclude='_index*.md' "$docs/migrations/" "$site/content/docs/migrations/"
    printf '+++\ntitle = "Migrations"\nsort_by = "title"\npage_template = "plain.html"\n+++\n' \
        > "$site/content/docs/migrations/_index.md"
    synced_dirs+=("$site/content/docs/migrations")
}

for part in $parts; do
    case $part in
    shortcodes) sync_shortcodes ;;
    std) sync_section std std ;;
    tour) sync_tour ;;
    pages) sync_pages ;;
    migrations) sync_migrations ;;
    rosetta) sync_section rosetta examples/rosetta ;;
    *)
        echo "unknown part: $part" >&2
        exit 1
        ;;
    esac
done

# A full sync goes over every page of the docs, as it always has
if [ -z "${*:-}" ]; then
    synced_dirs=("$site/content/docs")
fi
[ ${#synced_dirs[@]} -gt 0 ] || exit 0

# Section guard: every section needs an _index.<lang>.md for each language, or Zola fails
langs="es pt it de ru zh-cn zh-tw"
find "${synced_dirs[@]}" -name "_index.md" | while read -r index_file; do
    dir=$(dirname "$index_file")
    for lang in $langs; do
        if [ ! -f "$dir/_index.$lang.md" ]; then
            cp "$index_file" "$dir/_index.$lang.md"
        fi
    done
done

# Every page needs front matter, titled after its first heading; the Rosetta templates
# ({{trans|...}}) are dropped. One perl for every file: one process per file took most of the time.
find "${synced_dirs[@]}" -name "*.md" -exec perl -i -0777 -pe '
    s/\{\{trans\|.*\}\}//g;
    unless (/\A\+\+\+/) {
        my ($title) = /^# (.*)$/m;
        $title = "Documentation" unless defined $title;
        $title =~ s/"/\\"/g;
        $_ = "+++\ntitle = \"$title\"\n+++\n\n$_";
    }
' {} +
