#!/bin/bash

expandPath() {
  local path
  local -a pathElements resultPathElements
  IFS=':' read -r -a pathElements <<<"$1"
  : "${pathElements[@]}"
  for path in "${pathElements[@]}"; do
    : "$path"
    case $path in
      "~+"/*)
        path=$PWD/${path#"~+/"}
        ;;
      "~-"/*)
        path=$OLDPWD/${path#"~-/"}
        ;;
      "~"/*)
        path=$HOME/${path#"~/"}
        ;;
      "~"*)
        username=${path%%/*}
        username=${username#"~"}
        IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd "$username")
        if [[ $path = */* ]]; then
          path=${homedir}/${path#*/}
        else
          path=$homedir
        fi
        ;;
    esac
    resultPathElements+=( "$path" )
  done
  local result
  printf -v result '%s:' "${resultPathElements[@]}"
  printf '%s\n' "${result%:}"
}

verbose_echo()
{
  $VERBOSE && echo "$*";
}

extract_zip_file()
{
  local zip_file="$1"
  local artist_name="$(echo $zip_file | sed -r 's/(.*) - .*\.zip/\1/')"
  local album_name="$(echo $zip_file | sed -r 's/.* - (.*)\.zip/\1/')"
  local full_dir_path="$artist_name/$album_name"

  verbose_echo "Extracting: Artist - $artist_name; Album - $album_name to $full_dir_path..."
  mkdir -p "$full_dir_path"
  unzip "$zip_file" -d "$full_dir_path"
}

confirm_music_directory()
{
  if ! [ -d "$MUSIC_DIR" ]; then
    echo "Your music directory (MUSIC_DIR) is not set. Where would you like your music saved to?" 
    read -p 'Music Directory: ' MUSIC_DIR
    echo "Music directory set to '$MUSIC_DIR'"
  fi
}

print_usage() {
  echo "Extracts all the bandcamp music in your music directory"
  echo "Usage:"
  echo "  -d <music directory> : Directory"
  echo "  -v : Verbose"
}

# MAIN
MUSIC_DIR=''
VERBOSE=false

while getopts 'd:hv' flag; do
  case "${flag}" in
    d) MUSIC_DIR="${OPTARG}" ;;
    h) print_usage 
       exit 0 ;;
    v) VERBOSE=true ;;
    *) print_usage
       exit 1 ;;
  esac
done

confirm_music_directory
pushd "$MUSIC_DIR" &>/dev/null

# Do stuff
for zip_file in "$(ls *.zip)"
do
  extract_zip_file "$zip_file"
done
verbose_echo "Done."

# Clean up 
popd &>/dev/null
