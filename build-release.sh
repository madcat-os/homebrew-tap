#!/usr/bin/env bash
set -euo pipefail

# ── madcat release builder ───────────────────────────────────
# Builds madcat-index CLI + NAPI .node for the current platform,
# then uploads to Cloudflare R2 (madcat-cdn bucket).
#
# Usage:
#   ./build-release.sh              # build + upload current platform
#   ./build-release.sh --upload-only # skip build, just upload existing binaries
#
# Requires:
#   - ~/.credentials sourced (CF_API_KEY, CF_API_EMAIL, CLOUDFLARE_ACCOUNT_ID)
#   - Rust toolchain via rustup
#   - madcat-memory repo at ~/Projects/madcat-memory

set -a
[ -f "$HOME/.credentials" ] && . "$HOME/.credentials"
set +a

# ── config ───────────────────────────────────────────────────
BUCKET="madcat-cdn"
CF_API="https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/r2/buckets/${BUCKET}/objects"
MEMORY_DIR="$HOME/Projects/madcat-memory"
RELEASE_DIR="$MEMORY_DIR/target/release"

# ── platform detection ───────────────────────────────────────
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS-$ARCH" in
  darwin-arm64)
    PLATFORM="darwin-arm64"
    NODE_FILE="madcat-memory.darwin-arm64.node"
    NAPI_LIB="libmadcat_memory_napi.dylib"
    FEATURES="fastembed,postgres,gpu-metal,gpu-coreml"
    ;;
  linux-aarch64)
    PLATFORM="linux-arm64"
    NODE_FILE="madcat-memory.linux-arm64-gnu.node"
    NAPI_LIB="libmadcat_memory_napi.so"
    FEATURES="fastembed,postgres"
    ;;
  linux-x86_64)
    PLATFORM="linux-x64"
    NODE_FILE="madcat-memory.linux-x64-gnu.node"
    NAPI_LIB="libmadcat_memory_napi.so"
    FEATURES="fastembed,postgres,gpu-cuda"
    ;;
  *)
    echo "unsupported platform: $OS-$ARCH" >&2
    exit 1
    ;;
esac

# ── version ──────────────────────────────────────────────────
cd "$MEMORY_DIR"
VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/.*"\(.*\)"/\1/')
HASH=$(git rev-parse --short HEAD)
TAG="v${VERSION}+${HASH}"

echo "=== madcat release: $PLATFORM $TAG ==="

# ── build ────────────────────────────────────────────────────
if [[ "${1:-}" != "--upload-only" ]]; then
  echo "▸ building madcat-index ($PLATFORM, features: $FEATURES)"
  cargo build --release -p madcat-index \
    --no-default-features --features "$FEATURES"

  echo "▸ building NAPI ($PLATFORM)"
  cargo build --release -p madcat-memory-napi
else
  echo "▸ skipping build (--upload-only)"
fi

# ── verify binaries exist ────────────────────────────────────
CLI="$RELEASE_DIR/madcat-index"
NAPI="$RELEASE_DIR/$NAPI_LIB"

[ -f "$CLI" ]  || { echo "missing: $CLI" >&2; exit 1; }
[ -f "$NAPI" ] || { echo "missing: $NAPI" >&2; exit 1; }

CLI_SIZE=$(du -h "$CLI" | cut -f1)
NAPI_SIZE=$(du -h "$NAPI" | cut -f1)
echo "  madcat-index: $CLI_SIZE"
echo "  $NAPI_LIB:    $NAPI_SIZE"

# ── upload ───────────────────────────────────────────────────
upload() {
  local file="$1"
  local key="$2"
  echo "▸ uploading $key ($(du -h "$file" | cut -f1))"
  curl -sf -X PUT "${CF_API}/${key}" \
    -H "X-Auth-Email: $CF_API_EMAIL" \
    -H "X-Auth-Key: $CF_API_KEY" \
    --data-binary "@${file}" > /dev/null
  echo "  ✓ https://pub-74d54066bfe6435e908e11e9f3d14482.r2.dev/${key}"
}

# Upload versioned
upload "$CLI"  "releases/${TAG}/madcat-index-${PLATFORM}"
upload "$NAPI" "releases/${TAG}/${NODE_FILE}"

# Upload latest (overwrite)
upload "$CLI"  "latest/madcat-index-${PLATFORM}"
upload "$NAPI" "latest/${NODE_FILE}"

echo ""
echo "=== done: $PLATFORM $TAG ==="
echo "  latest: https://pub-74d54066bfe6435e908e11e9f3d14482.r2.dev/latest/madcat-index-${PLATFORM}"
echo "  latest: https://pub-74d54066bfe6435e908e11e9f3d14482.r2.dev/latest/${NODE_FILE}"
