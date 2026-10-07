#!/usr/bin/env bash

# Generate SVG cursors (cursors_scalable/) from the SVG sources.
# GNOME Shell 51+ draws Wayland client cursors only from this format,
# KDE Plasma 6.2+ reads it too. Needs nothing beyond bash and coreutils.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/src"
ALIASES="$SRC/cursorList"

# The SVG sources are 32px and map to the nominal size 24 lines in src/config
NOMINAL_SIZE=24

function create_scalable {
	local svg_dir="$SRC/$1"
	local output="$ROOT/$2/cursors_scalable"
	local cur name size hot_x hot_y png delay frame entry entries json sep alias target

	echo -ne "Generating scalable cursors in $2...\\r"
	rm -rf "$output"
	mkdir -p "$output"

	for cur in "$SRC"/config/*.cursor; do
		name="${cur##*/}"
		name="${name%.*}"
		mkdir "$output/$name"

		# one metadata entry per frame, hotspot taken from the nominal size line
		entries=()
		while read -r size hot_x hot_y png delay; do
			if [ "$size" != "$NOMINAL_SIZE" ]; then
				continue
			fi
			frame="${png##*/}"
			frame="${frame%.png}.svg"
			cp "$svg_dir/$frame" "$output/$name/"

			printf -v entry '    {\n        "filename": "%s",\n' "$frame"
			if [ -n "$delay" ]; then
				printf -v entry '%s        "delay": %s,\n' "$entry" "$delay"
			fi
			printf -v entry '%s        "hotspot_x": %s,\n        "hotspot_y": %s,\n        "nominal_size": %s\n    }' \
				"$entry" "$hot_x" "$hot_y" "$NOMINAL_SIZE"
			entries+=("$entry")
		done < "$cur"

		json="["
		sep=""
		for entry in "${entries[@]}"; do
			json+="$sep"$'\n'"$entry"
			sep=","
		done
		printf '%s\n]\n' "$json" > "$output/$name/metadata.json"
	done

	# aliases as directory symlinks; hash names only matter to libXcursor
	while read -r alias target; do
		if [[ "$alias" =~ ^[0-9a-f]{32}$ ]] || [ -e "$output/$alias" ] || [ -L "$output/$alias" ]; then
			continue
		fi
		ln -sr "$output/$target" "$output/$alias"
	done < "$ALIASES"

	echo -e "Generating scalable cursors in $2... DONE"
}

create_scalable svg dist
create_scalable svg-white dist-white
