#!/usr/bin/env bash
#
# Generate the authoritative dotkernel package manifest from Packagist.
# Run this whenever you want the dependency-policy skill to be current.
#
#   ./sync-dotkernel-packages.sh [output.json]
#
# Requires: curl, jq. No auth, no GitHub token.
#
set -euo pipefail

VENDOR="${VENDOR:-dotkernel}"
OUT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/references/dotkernel-packages.json}"

for bin in curl jq; do
  command -v "$bin" >/dev/null 2>&1 || { echo "error: $bin is required" >&2; exit 1; }
done

echo "-> listing ${VENDOR}/* on Packagist" >&2
mapfile -t pkgs < <(
  curl -fsSL "https://packagist.org/packages/list.json?vendor=${VENDOR}" \
    | jq -r '.packageNames[]' | sort
)
[ "${#pkgs[@]}" -gt 0 ] || { echo "error: empty package list" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for pkg in "${pkgs[@]}"; do
  if ! curl -fsSL "https://packagist.org/packages/${pkg}.json" -o "$tmp/raw.json"; then
    echo "   skip ${pkg} (fetch failed)" >&2
    continue
  fi

  jq '
    .package as $p
    | ( $p.versions
        | to_entries
        | map(select(.key | test("^v?[0-9]+\\.[0-9]+\\.[0-9]+$")))
        | sort_by(.value.time)
        | last
      ) as $latest
    | {
        name:        $p.name,
        description: ($p.description // ""),
        repository:  ($p.repository // null),
        latest:      ($latest.key // null),
        released:    ($latest.value.time // null),
        php:         ($latest.value.require.php // null),
        type:        ($latest.value.type // null),
        abandoned:   (($p.abandoned // null) != null),
        replacement: (if ($p.abandoned | type) == "string" then $p.abandoned else null end),
        keywords:    ($latest.value.keywords // []),
        downloads:   ($p.downloads.total // 0)
      }
  ' "$tmp/raw.json" >> "$tmp/entries.ndjson"

  printf '   %s\n' "$pkg" >&2
done

mkdir -p "$(dirname "$OUT")"
jq -s \
  --arg vendor "$VENDOR" \
  --arg generated "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
     vendor: $vendor,
     generated_at: $generated,
     source: "https://packagist.org",
     count: length,
     packages: sort_by(.name)
   }' "$tmp/entries.ndjson" > "$OUT"

echo >&2
echo "-> wrote $(jq -r '.count' "$OUT") packages to $OUT" >&2

abandoned="$(jq -r '[.packages[] | select(.abandoned)] | length' "$OUT")"
if [ "$abandoned" -gt 0 ]; then
  echo "-> $abandoned abandoned package(s) flagged:" >&2
  jq -r '.packages[] | select(.abandoned) | "     \(.name) -> \(.replacement // "no replacement declared")"' "$OUT" >&2
fi

stale="$(jq -r --arg cut "$(date -u -d '18 months ago' +%Y-%m-%d 2>/dev/null || date -u -v-18m +%Y-%m-%d)" \
  '[.packages[] | select(.released != null and (.released < $cut))] | length' "$OUT")"
[ "$stale" -gt 0 ] && echo "-> $stale package(s) with no release in 18 months (see .released)" >&2

exit 0
