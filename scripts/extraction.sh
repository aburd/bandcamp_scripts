#!/bin/bash

die() 
{ 
  print_usage
  echo "$*" >&2; 
  exit 2; 
}  # complain to STDERR and exit with error

needs_arg() 
{ 
  if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; 
}

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

  if [ -d "$full_dir_path" ]; then
    verbose_echo "Skipping extraction as this already looks like it exists..."
    verbose_echo "$(ls "$full_dir_path")"
    return -1
  fi

  verbose_echo "Extracting: Artist - $artist_name; Album - $album_name to $full_dir_path..."
  mkdir -p "$full_dir_path"
  unzip "$zip_file" -d "$full_dir_path"
}

process_mp3_file()
{
  local mp3_file="$1"
  local artist_name="$(echo $mp3_file | sed -r 's/(.*) - .*\.mp3/\1/')"
  local song_name="$(echo $mp3_file | sed -r 's/.* - (.*)\.mp3/\1/')"
  local full_dir_path="$artist_name/$artist_name - $song_name.mp3"

  verbose_echo "Moving: Artist - $artist_name; Song - $song_name to $full_dir_path..."
  mkdir -p "$artist_name"
  mv "$mp3_file" "$full_dir_path"
}

confirm_music_directory()
{
  if ! [ -d "$MUSIC_DIR" ]; then
    echo "Your music directory (MUSIC_DIR) is not set. Where would you like your music saved to?" 
    read -p 'Music Directory: ' MUSIC_DIR
    MUSIC_DIR="$(expandPath $MUSIC_DIR)"
    echo "Music directory set to '$MUSIC_DIR'"
  fi
}

print_usage() {
  echo "Extracts all the bandcamp music in your music directory"
  echo "Usage:"
  echo "  -d <music directory> : Directory"
  echo "  -v : Verbose"
  echo "  -m | --mp3 : Also handle mp3 files"
  echo "  -r | --dry-run : Do a run, don't actually move/extract any files"
  echo "  -c | --clean : Don't clean any files after processing" 
}

# MAIN
MUSIC_DIR=''
VERBOSE=false
MP3=false
DRY_RUN=false
CLEAN=true

while getopts d:hmvrc-: OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    d ) MUSIC_DIR="${OPTARG}" ;;
    h ) print_usage 
       exit 0 ;;
    m | mp3 ) MP3=true ;;
    r | dry-run ) DRY_RUN=true ;;
    v ) VERBOSE=true ;;
    c | clean ) CLEAN=false ;;
    ??* )          die "Illegal option --$OPT" ;;  # bad long option
    ? )            exit 2 ;;  # bad short option (error reported via getopts)
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

confirm_music_directory
pushd "$MUSIC_DIR" &>/dev/null

# Do stuff in Music dir
verbose_echo "Extracting all zip files..."
for zip_file in *.zip
do
  [ -e "$zip_file" ] || continue
  verbose_echo "Zip file: $zip_file"
  if [ $DRY_RUN = false ]; then
    extract_zip_file "$zip_file"
    if [ $CLEAN = true ]; then
      rm -I "$zip_file"
    fi
  fi
done
if [ $MP3 = true ]; then
  verbose_echo "Moving all mp3 files..."
  for mp3_file in *.mp3
  do
    [ -e "$mp3_file" ] || continue
    verbose_echo "MP3 file: $mp3_file"
    if [ $DRY_RUN = false ]; then
      process_mp3_file "$mp3_file" 
    fi
  done
fi
verbose_echo "Done."

popd &>/dev/null
