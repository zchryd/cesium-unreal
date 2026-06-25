#!/bin/bash
# Build cesium-native for Cesium for Unreal against UE 5.8 (Apple Silicon host).
set -euo pipefail

export UNREAL_ENGINE_ROOT='/Users/Shared/Epic Games/UE_5.8'
PLUGIN="/Users/zach/Desktop/unrealcesium/cesium-unreal-samples/Plugins/cesium-unreal"

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
