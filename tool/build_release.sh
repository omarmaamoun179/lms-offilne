#!/usr/bin/env bash
set -euo pipefail

flutter="${FLUTTER:-flutter}"
platform="${1:-android}"
symbols="build/debug-info/$platform"

case "$platform" in
  android)
    "$flutter" build apk --release --obfuscate --split-debug-info="$symbols" --split-per-abi
    ;;
  ios)
    "$flutter" build ipa --release --obfuscate --split-debug-info="$symbols"
    ;;
  *)
    echo "usage: tool/build_release.sh [android|ios]" >&2
    exit 1
    ;;
esac

echo "Symbols for crash reports: $symbols (keep them, never ship them)"
