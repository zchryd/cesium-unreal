#!/bin/bash
# Build the cesium-unreal plugin against UE 5.8 by compiling the samples editor target.
set -uo pipefail
UE='/Users/Shared/Epic Games/UE_5.8'
PROJ='/Users/zach/Desktop/unrealcesium/cesium-unreal-samples/CesiumForUnrealSamples.uproject'

echo "=== Generating project files ==="
"$UE/Engine/Build/BatchFiles/Mac/GenerateProjectFiles.sh" -project="$PROJ" -game 2>&1 | tail -15

echo "=== Building devEditor (Mac, Development) ==="
"$UE/Engine/Build/BatchFiles/Mac/Build.sh" devEditor Mac Development -project="$PROJ" -waitmutex
echo "BUILD_RC=$?"
