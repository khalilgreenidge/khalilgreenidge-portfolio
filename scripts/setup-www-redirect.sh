#!/usr/bin/env bash
# Creates a Cloudflare Single Redirect rule sending www.khalilgreenidge.com
# to the apex (301, path and query preserved). Idempotent: re-running replaces
# the rule this script manages and leaves any other redirect rules alone.
#
# Needs a token with Zone -> Single Redirect: Edit on the zone.
# (Config Rules: Edit is NOT sufficient - it does not grant the
#  http_request_dynamic_redirect phase that Single Redirects live in.)
#   CLOUDFLARE_API_TOKEN=... ./scripts/setup-www-redirect.sh
set -euo pipefail

ZONE_NAME="khalilgreenidge.com"
DESC="www -> apex (managed by setup-www-redirect.sh)"
: "${CLOUDFLARE_API_TOKEN:?set CLOUDFLARE_API_TOKEN}"
API="https://api.cloudflare.com/client/v4"
AUTH=(-H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" -H "Content-Type: application/json")

api() { curl -sS "${AUTH[@]}" "$@"; }
check() { jq -e '.success' >/dev/null <<<"$1" || { jq -r '.errors' <<<"$1" >&2; exit 1; }; }

zones=$(api "${API}/zones?name=${ZONE_NAME}")
check "$zones"
zone_id=$(jq -r '.result[0].id // empty' <<<"$zones")
[ -n "$zone_id" ] || { echo "zone ${ZONE_NAME} not found on this account" >&2; exit 1; }
echo "zone ${ZONE_NAME} -> ${zone_id}"

phase="${API}/zones/${zone_id}/rulesets/phases/http_request_dynamic_redirect/entrypoint"
existing=$(api "${phase}" || true)
if jq -e '.success' >/dev/null 2>&1 <<<"$existing"; then
  keep=$(jq --arg d "$DESC" '[.result.rules[]? | select(.description != $d)]' <<<"$existing")
else
  keep='[]'   # no entrypoint ruleset yet; PUT creates it
fi

rule=$(jq -n --arg d "$DESC" --arg host "www.${ZONE_NAME}" --arg apex "https://${ZONE_NAME}" '{
  action: "redirect",
  description: $d,
  enabled: true,
  expression: ("(http.host eq \"" + $host + "\")"),
  action_parameters: {
    from_value: {
      status_code: 301,
      target_url: { expression: ("concat(\"" + $apex + "\", http.request.uri.path)") },
      preserve_query_string: true
    }
  }
}')

body=$(jq -n --argjson keep "$keep" --argjson rule "$rule" \
  '{name: "default", rules: ($keep + [$rule])}')

resp=$(api -X PUT "${phase}" -d "$body")
check "$resp"
echo "redirect rule installed:"
jq -r '.result.rules[] | "  [\(.action)] \(.expression) -> \(.action_parameters.from_value.target_url.expression // "n/a")"' <<<"$resp"
