#!/bin/bash

# Set source and destination directories
SRC_DIR="/px4_sim/models"
DEST_DIR="Tools/simulation/gz/models"

# Copy all model folders from source to destination without overwriting existing content
for model_dir in "$SRC_DIR"/*/; do
    model_name=$(basename "$model_dir")
    dest_model_dir="$DEST_DIR/$model_name"
    if [ ! -d "$dest_model_dir" ]; then
        cp -r "$model_dir" "$DEST_DIR/"
    else
        echo "Skipping $model_name (already exists)"
    fi
done
echo "Sync complete. Models copied."