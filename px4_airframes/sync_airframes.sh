#!/bin/bash

# Set source and destination directories
SRC_DIR="/px4_sim/px4_airframes/init.d-posix"
DEST_DIR="ROMFS/px4fmu_common/init.d-posix/airframes"
CMAKELISTS="$DEST_DIR/CMakeLists.txt"

# Copy all files from source to destination
cp -a "$SRC_DIR/." "$DEST_DIR/"

# Generate CMakeLists.txt with all airframe files
echo "# Auto-generated CMakeLists.txt for airframes" > "$CMAKELISTS"
for f in "$SRC_DIR"/*; do
    [ -f "$f" ] && echo "px4_add_airframe(${f##*/})" >> "$CMAKELISTS"
done

echo "Sync complete. Airframes copied and CMakeLists.txt updated."