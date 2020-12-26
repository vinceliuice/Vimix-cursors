#!/usr/bin/env bash

# check command avalibility
has_command() {
  "$1" -v $1 > /dev/null 2>&1
}

if [ ! "$(which xcursorgen 2> /dev/null)" ]; then
  echo xorg-xcursorgen needs to be installed to generate the cursors.
  if has_command zypper; then
    sudo zypper in xorg-xcursorgen
  elif has_command apt; then
    sudo apt install xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install -y xorg-xcursorgen
  elif has_command dnf; then
    sudo dnf install xorg-xcursorgen
  elif has_command pacman; then
    sudo pacman -S --noconfirm xorg-xcursorgen
  fi
fi

if [ ! "$(which cairosvg 2> /dev/null)" ]; then
  echo xorg-xcursorgen needs to be installed to generate png files.
  if has_command zypper; then
    sudo zypper in python-cairosvg
  elif has_command apt; then
    sudo apt install python-cairosvg
  elif has_command dnf; then
    sudo dnf install -y python-cairosvg
  elif has_command dnf; then
    sudo dnf install python-cairosvg
  elif has_command pacman; then
    sudo pacman -S --noconfirm python-cairosvg
  fi
fi

function create {
	cd "$SRC"
	mkdir -p x1 x1_25 x1_5 x2
	cd "$SRC"/$1
	find . -name "*.svg" -type f -exec sh -c 'echo -e "generating ${0%.svg}.png 32" && cairosvg -f png -o "../x1/${0%.svg}.png" --output-width 32 --output-height 32 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'echo -e "generating ${0%.svg}.png 40" && cairosvg -f png -o "../x1_25/${0%.svg}.png" --output-width 40 --output-height 40 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'echo -e "generating ${0%.svg}.png 48" && cairosvg -f png -o "../x1_5/${0%.svg}.png" --output-width 48 --output-height 48 $0' {} \;
	find . -name "*.svg" -type f -exec sh -c 'echo -e "generating ${0%.svg}.png 64" && cairosvg -f png -o "../x2/${0%.svg}.png" --output-width 64 --output-height 64 $0' {} \;

	cd $SRC

	# generate cursors
	if [[ "$THEME" =~ White$ ]]; then
		BUILD="$SRC"/../dist-white
	else BUILD="$SRC"/../dist
	fi

	OUTPUT="$BUILD"/cursors
	ALIASES="$SRC"/cursorList

	if [ ! -d "$BUILD" ]; then
		mkdir "$BUILD"
	fi
	if [ ! -d "$OUTPUT" ]; then
		mkdir "$OUTPUT"
	fi

	echo -ne "Generating cursor theme...\\r"
	for CUR in config/*.cursor; do
		BASENAME="$CUR"
		BASENAME="${BASENAME##*/}"
		BASENAME="${BASENAME%.*}"

		xcursorgen "$CUR" "$OUTPUT/$BASENAME"
	done
	echo -e "Generating cursor theme... DONE"

	cd "$OUTPUT"

	#generate aliases
	echo -ne "Generating shortcuts...\\r"
	while read ALIAS; do
		FROM="${ALIAS#* }"
		TO="${ALIAS% *}"

		if [ -e $TO ]; then
			continue
		fi
		ln -sr "$FROM" "$TO"
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"

	cd "$PWD"

	echo -ne "Generating Theme Index...\\r"
	INDEX="$OUTPUT/../index.theme"
	if [ ! -e "$OUTPUT/../$INDEX" ]; then
		touch "$INDEX"
		echo -e "[Icon Theme]\nName=$THEME\n" > "$INDEX"
	fi
	echo -e "Generating Theme Index... DONE"
}

# generate pixmaps from svg source
SRC=$PWD/src
THEME="Vimix Cursors"

create svg

THEME="Vimix Cursors - White"

create svg-white
