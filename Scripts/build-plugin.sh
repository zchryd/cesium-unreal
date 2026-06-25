#!/bin/bash
# Build the cesium-unreal plugin against UE 5.8 by compiling the samples editor target.
#
# Paths are derived from the script's own location, so it works from any
# checkout. Override with environment variables when needed:
#   UNREAL_ENGINE_ROOT  Unreal Engine install dir (default: UE_5.8 under /Users/Shared)
#   PLUGIN              plugin root (default: the parent of this Scripts/ dir)
#   PROJECT             .uproject to build (default: the one in the project root)
set -uo pipefail

# Resolve this script's real directory, following symlinks (it may be invoked
# via a convenience symlink that points into the plugin repo).
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"

UE="${UNREAL_ENGINE_ROOT:-/Users/Shared/Epic Games/UE_5.8}"
PLUGIN="${PLUGIN:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Plugin lives at <project>/Plugins/<plugin>, so the project root is two up.
PROJECT_ROOT="$(cd "$PLUGIN/../.." && pwd)"
PROJ="${PROJECT:-$(ls "$PROJECT_ROOT"/*.uproject 2>/dev/null | head -1)}"

if [ -z "$PROJ" ] || [ ! -f "$PROJ" ]; then
  echo "ERROR: no .uproject found in $PROJECT_ROOT (set PROJECT=/path/to/Foo.uproject)" >&2
  exit 1
fi

echo "=== Engine:  $UE"
echo "=== Project: $PROJ"

echo "=== Generating project files ==="
"$UE/Engine/Build/BatchFiles/Mac/GenerateProjectFiles.sh" -project="$PROJ" -game 2>&1 | tail -15

echo "=== Building devEditor (Mac, Development) ==="
"$UE/Engine/Build/BatchFiles/Mac/Build.sh" devEditor Mac Development -project="$PROJ" -waitmutex
echo "BUILD_RC=$?"
