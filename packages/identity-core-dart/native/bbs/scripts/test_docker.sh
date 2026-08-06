#!/usr/bin/env bash
# Run MATTR-compatible golden tests for quark_bbs inside Docker.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
docker run --rm \
  -v "$ROOT:/work" \
  -w /work \
  -e PATH="/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  rust:1.85-bookworm \
  bash -c 'cargo test --release -- --nocapture'
