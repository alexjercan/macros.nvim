#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/macros.csv" <<'CSV'
egg 1pc,6,0,5
chicken thigh 100g,25,0,5
chicken breast 100g,31,0,3.6
CSV

search=$(lua "$root/macros.lua" --database "$tmp/macros.csv" search chick --json)
expected='{"results":[{"id":"chicken breast:g","name":"chicken breast","unit":"g"},{"id":"chicken thigh:g","name":"chicken thigh","unit":"g"}]}'
test "$search" = "$expected"

gram=$(lua "$root/macros.lua" --database "$tmp/macros.csv" calculate --food chicken\ breast:g --amount 150 --json)
test "$gram" = '{"food":"chicken breast","amount":150,"unit":"g","protein":46.5,"carbs":0,"fat":5.4}'

piece=$(lua "$root/macros.lua" --database "$tmp/macros.csv" calculate --food egg:pc --amount 2 --json)
test "$piece" = '{"food":"egg","amount":2,"unit":"pc","protein":12,"carbs":0,"fat":10}'

if lua "$root/macros.lua" --database "$tmp/macros.csv" calculate --food egg:pc --amount 0 --json >"$tmp/out" 2>"$tmp/err"; then
    echo "zero amount unexpectedly succeeded" >&2
    exit 1
fi
test ! -s "$tmp/out"
grep -q 'positive finite number' "$tmp/err"

echo "CLI integration: ok"
