#!/bin/sh
echo -ne '\033c\033]0;UTEC- Title Defense\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/UTEC Juego linux.x86_64" "$@"
