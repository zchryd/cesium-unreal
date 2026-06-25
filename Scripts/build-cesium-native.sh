#!/bin/bash
# Build cesium-native for Cesium for Unreal against UE 5.8 (Apple Silicon host).
#
# Paths are derived from the script's own location, so it works from any
# checkout. Override with environment variables when needed:
#   UNREAL_ENGINE_ROOT  Unreal Engine install dir (default: UE_5.8 under /Users/Shared)
#   PLUGIN              plugin root (default: the parent of this Scripts/ dir)
set -euo pipefail

# Resolve this script's real directory, following symlinks (it may be invoked
# via a convenience symlink that points into the plugin repo).
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

export UNREAL_ENGINE_ROOT="${UNREAL_ENGINE_ROOT:-/Users/Shared/Epic Games/UE_5.8}"
PLUGIN="${PLUGIN:-$(cd "$SCRIPT_DIR/.." && pwd)}"

echo "=== UNREAL_ENGINE_ROOT: $UNREAL_ENGINE_ROOT"
echo "=== Plugin: $PLUGIN"
cd "$PLUGIN/extern"

echo "=== Configuring cesium-native (RelWithDebInfo) ==="
cmake -B build -S . -DCMAKE_BUILD_TYPE=RelWithDebInfo

echo "=== Building + installing cesium-native (parallel 8) ==="
cmake --build build --target install --parallel 8

echo "=== Creating universal symlinks for host-arch dev build ==="
cd "$PLUGIN/Source/ThirdParty/lib"
ls -la
# Editor 'Development' config consumes the Release (RelWithDebInfo) libs.
[ -d Darwin-arm64-Release ] && ln -sfn ./Darwin-arm64-Release Darwin-universal-Release || echo "WARN: no Darwin-arm64-Release dir"
[ -d Darwin-arm64-Debug ]   && ln -sfn ./Darwin-arm64-Debug   Darwin-universal-Debug   || echo "(no Debug build — fine for Development editor)"

echo "=== cesium-native build COMPLETE ==="
ls -la "$PLUGIN/Source/ThirdParty/lib"
