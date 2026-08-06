#!/usr/bin/env bash
# Build quark_bbs (libbbs) for Android via Docker + NDK Linux.
# Usage: from packages/identity-core-dart — bash native/bbs/scripts/build_android_docker.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(cd "$ROOT/../../android/src/main/jniLibs" && pwd)"
docker run --rm \
  -v "$ROOT:/work" \
  -v "$OUT:/out" \
  -w /work \
  -e PATH="/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  rust:1.85-bookworm \
  bash -c '
set -e
apt-get update -qq && apt-get install -y -qq unzip wget >/dev/null
if [ ! -d /opt/ndk ]; then
  wget -q https://dl.google.com/android/repository/android-ndk-r28b-linux.zip -O /tmp/ndk.zip
  unzip -q /tmp/ndk.zip -d /opt
  mv /opt/android-ndk-r28b /opt/ndk
fi
rustup target add aarch64-linux-android armv7-linux-androideabi
API=24
PREBUILT=/opt/ndk/toolchains/llvm/prebuilt/linux-x86_64/bin
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=$PREBUILT/aarch64-linux-android$API-clang
export CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=$PREBUILT/armv7a-linux-androideabi$API-clang
export CC_aarch64_linux_android=$CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER
export CC_armv7_linux_androideabi=$CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER
export AR_aarch64_linux_android=$PREBUILT/llvm-ar
export AR_armv7_linux_androideabi=$PREBUILT/llvm-ar
cargo build --release --target aarch64-linux-android
cargo build --release --target armv7-linux-androideabi
mkdir -p /out/arm64-v8a /out/armeabi-v7a
cp target/aarch64-linux-android/release/libbbs.so /out/arm64-v8a/
cp target/armv7-linux-androideabi/release/libbbs.so /out/armeabi-v7a/
ls -la /out/arm64-v8a /out/armeabi-v7a
'
