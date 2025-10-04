#!/bin/bash

# Set source and destination directories
SRC_DIR="/px4_sim/px4_airframes/init.d-posix"
DEST_DIR="ROMFS/px4fmu_common/init.d-posix/airframes"
CMAKELISTS="$DEST_DIR/CMakeLists.txt"

GCS_IP=$(getent hosts host.docker.internal | awk '{ print $1 }')

# Copy all files from source to destination
cp -a "$SRC_DIR/." "$DEST_DIR/"

# Get list of airframe files (excluding .post files) from source
# Get list of airframe files (excluding .post files) from source and sort by number prefix
airframes=()
for f in "$SRC_DIR"/*; do
    [ -f "$f" ] && [[ $(basename "$f") =~ ^([0-9]+)_ ]] && airframes+=("$(basename "$f")")
done
IFS=$'\n' airframes=($(printf "%s\n" "${airframes[@]}" | sort -n))

# Read current CMakeLists.txt into an array
mapfile -t cmake_lines < "$CMAKELISTS"

# Prepare a new list for the updated CMakeLists.txt
new_cmake_lines=()
added_airframes=()

for airframe in "${airframes[@]}"; do
    # Replace __GCSIP__ with GCS_IP in the airframe file if present
    if grep -q "__GCSIP__" "$DEST_DIR/$airframe"; then
        sed -i.bak "s/__GCSIP__/$GCS_IP/g" "$DEST_DIR/$airframe"
        rm "$DEST_DIR/$airframe.bak"
    fi
    num=${airframe%%_*}
    inserted=0
    for i in "${!cmake_lines[@]}"; do
        line="${cmake_lines[$i]}"
        if [[ $line =~ ([0-9]+)_ ]]; then
            line_num="${BASH_REMATCH[1]}"
            if (( num < line_num )); then
                # Insert airframe before this line if not already present
                if ! grep -q "$airframe" <<<"${cmake_lines[*]}"; then
                    new_cmake_lines+=("	$airframe")
                    added_airframes+=("$airframe")
                fi
                inserted=1
                break
            fi
        fi
    done
    # If not inserted, insert before the third last line if not already present
    if (( !inserted )) && ! grep -q "$airframe" <<<"${cmake_lines[*]}"; then
        insert_pos=$((${#cmake_lines[@]} - 3))
        if (( insert_pos < 0 )); then
            insert_pos=0
        fi
        cmake_lines=("${cmake_lines[@]:0:$insert_pos}" "	$airframe" "${cmake_lines[@]:$insert_pos}")
        added_airframes+=("$airframe")
        inserted=1
    fi
done

# Merge new_cmake_lines into cmake_lines at correct positions
output_lines=()
inserted=0
for line in "${cmake_lines[@]}"; do
    if [[ $line =~ ([0-9]+)_ ]]; then
        num="${BASH_REMATCH[1]}"
        for af in "${new_cmake_lines[@]}"; do
            af_num="${af%%_*}"
            if (( af_num < num )); then
                output_lines+=("$af")
                # Remove from new_cmake_lines so it's not added again
                new_cmake_lines=("${new_cmake_lines[@]/$af}")
            fi
        done
    fi
    output_lines+=("$line")
done
# Add any remaining new airframes at the end
for af in "${new_cmake_lines[@]}"; do
    output_lines+=("$af")
done

# Write the updated lines back to CMakeLists.txt
printf "%s\n" "${output_lines[@]}" > "$CMAKELISTS"

echo "Sync complete. Airframes copied and CMakeLists.txt updated."
