#!/bin/zsh
# Usage: ./000-update_embree_path.sh <embree_installation_directory>

WORKSPACE=/workspace

if [ $# -eq 0 ]; then
    echo "Usage: $0 <embree_directory>"
    exit 1
fi

EMBREE_DIR="$1"

# Convert to absolute path if relative
if [[ ! "$EMBREE_DIR" = /* ]]; then
    EMBREE_DIR="$(cd "$EMBREE_DIR" && pwd)"
fi

MESON_FILE="${WORKSPACE}/mesa-vulkan-sim/src/gallium/frontends/lavapipe/meson.build"

# Escape forward slashes for sed
LIB_DIR=$(echo "$EMBREE_DIR/lib" | sed 's/\//\\\//g')
HEADER_DIR=$(echo "$EMBREE_DIR/include" | sed 's/\//\\\//g')

sed -i "s/^embree_lib_dir = '.*'$/embree_lib_dir = '${LIB_DIR}'/" "$MESON_FILE"
sed -i "s/^embree_header_dir = '.*'$/embree_header_dir = '${HEADER_DIR}'/" "$MESON_FILE"

echo "Updated $MESON_FILE:"
echo "  embree_lib_dir = '$EMBREE_DIR/lib'"
echo "  embree_header_dir = '$EMBREE_DIR/include'"