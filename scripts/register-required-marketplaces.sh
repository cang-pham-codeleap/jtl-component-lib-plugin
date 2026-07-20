#!/usr/bin/env bash
set -euo pipefail

register_marketplace() {
  local name="$1"
  local source="$2"

  local marketplaces
  marketplaces="$(apm marketplace list)"
  if [[ "$marketplaces" =~ [[:space:]]${name}[[:space:]] ]]; then
    printf 'APM marketplace already registered: %s\n' "$name"
    return
  fi

  apm marketplace add "$source" --name "$name"
}

register_marketplace caveman juliusbrussee/caveman
register_marketplace ponytail DietrichGebert/ponytail
register_marketplace context-mode mksglu/context-mode
register_marketplace superpowers-marketplace obra/superpowers-marketplace
register_marketplace jtl-component-lib-plugin cang-pham-codeleap/jtl-component-lib-plugin
