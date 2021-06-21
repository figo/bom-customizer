#!/usr/bin/env bash

#
# Push a BOM from stdin as a container image to a specified remote location.
# Assumes that you are already authenticated to the remote registry.
# Requires imgpkg (https://carvel.dev/imgpkg).
#

set -euo pipefail

function echoerr() {
  printf "%s\n" "$*" >&2
}

function usage_error() {
  echoerr "Error: $*"
  echoerr
  help 1
}

function help() {
  me="$(basename "${BASH_SOURCE[0]}")"
  echoerr "Usage:"
  echoerr "   $me [flags]"
  echoerr
  echoerr "Flags:"
  echoerr "   -h, --help:               print this usage"
  echoerr "   -d, --destination <dest>: the registry/repository:tag location to push the container image (required)"
  exit "$1"
}

help=no
destination=""

while (("$#")); do
  case "$1" in
  -h | --help)
    help=yes
    shift
    ;;
  -d | --destination)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-d|--destination requires a registry/repository:tag location to be specified"
    fi
    destination=$1
    shift
    ;;
  -*)
    usage_error "Unsupported flag $1" >&2
    ;;
  *)
    usage_error "Unsupported positional arg $1" >&2
    ;;
  esac
done

if [[ "$help" == "yes" ]]; then
  help 0
fi

if [[ "$destination" == "" ]]; then
  usage_error "no destination location set. -d|--destination is a required option."
fi

tmp_dir=$(mktemp -d)
cleanup() {
  rm -r "$tmp_dir"
}
trap "cleanup" EXIT SIGINT
tmp_file="$tmp_dir"/bom.yaml

echoerr "Reading BOM from stdin and pushing to '$destination' ..."

cat - > "$tmp_file"

imgpkg push --image "$destination" --file "$tmp_file"
