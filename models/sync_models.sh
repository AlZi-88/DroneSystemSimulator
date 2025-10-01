#!/bin/bash

# Set source and destination directories
SRC_DIR="/px4_sim/models"
DEST_DIR="Tools/simulation/gz/models"

# Copy all models from source to destination
cp -r "$SRC_DIR/." "$DEST_DIR/"
echo "Sync complete. Models copied."