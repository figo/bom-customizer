#!/usr/bin/env bash

#
# Download a BOM and print it to stdout.
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
  echoerr "   -h, --help:           print this usage"
  echoerr "   -t, --tag <tag_name>: version tag of BOM to fetch (required)"
  echoerr "   -p, --product:        name of product to fetch: can be 'tkg', 'tkr', or 'tkr-compatibility' (required)"
  echoerr "   -s, --staging:        use staging registry instead of production"
  exit 0
}

help=no
tag=""
product=""
staging=no

while (("$#")); do
  case "$1" in
  -h | --help)
    help=yes
    shift
    ;;
  -t | --tag)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-t|--tag requires a tag name to be specified"
    fi
    tag=$1
    shift
    ;;
  -p | --product)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-p|--product requires a product name to be specified (tkg, tkr, or tkr-compatibility)"
    fi
    product=$1
    shift
    ;;
  -s | --staging)
    staging=yes
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

if [[ "$tag" == "" ]]; then
  usage_error "no tag set. -t|--tag is a required option."
fi

registry="projects.registry.vmware.com"
if [[ "$staging" == "yes" ]]; then
  registry="projects-stg.registry.vmware.com"
fi

case "$product" in
"tkg")
  repo="tkg/tkg-bom"
  ;;
"tkr")
  repo="tkg/tkr-bom"
  ;;
"tkr-compatibility")
  repo="tkg/tkr-compatibility"
  ;;
*)
  usage_error "-p|--product is required and must be either 'tkg', 'tkr', or 'tkr-compatibility'"
  ;;
esac

bomimage="${registry}/${repo}:${tag}"

tmp_dir=$(mktemp -d)
cleanup() {
  rm -r "$tmp_dir"
}
trap "cleanup" EXIT SIGINT

echoerr "Fetching $bomimage ..."

imgpkg pull --image "$bomimage" --output "$tmp_dir" 1>/dev/null

unpacked_yaml_files=("$tmp_dir"/*.yaml)
if [[ ${#unpacked_yaml_files[@]} -ne 1 ]]; then
  echoerr "Error: expected exactly one yaml file in extracted image, but found ${#unpacked_yaml_files[@]}."
  exit 1
fi

cat "${unpacked_yaml_files[0]}"
