#!/usr/bin/env bash

#
# List available versions of a BOM on stdout.
# Requires curl and jq.
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
  echoerr "   -p, --product:        name of product to fetch: can be either 'tkg' or 'tkr' (required)"
  echoerr "   -s, --staging:        use staging registry instead of production"
  exit "$1"
}

help=no
product=""
staging=no

while (("$#")); do
  case "$1" in
  -h | --help)
    help=yes
    shift
    ;;
  -p | --product)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-p|--product requires a product name to be specified (either tkg or tkr)"
    fi
    product=$1
    shift
    ;;
  -s | --staging)
    staging=yes
    shift
    ;;
  -*)
    usage_error "Unsupported flag $1"
    ;;
  *)
    usage_error "Unsupported positional arg $1"
    ;;
  esac
done

if [[ "$help" == "yes" ]]; then
  help 0
fi

if [[ "$product" != "tkg" && "$product" != "tkr" ]]; then
  usage_error "-p|--product is required and must be either 'tkg' or 'tkr'"
fi

registry="projects.registry.vmware.com"
if [[ "$staging" == "yes" ]]; then
  registry="projects-stg.registry.vmware.com"
fi

repo="tkg/tkr-bom"
if [[ "$product" == "tkg" ]]; then
  repo="tkg/tkg-bom"
fi

bomurl="https://${registry}/v2/${repo}/tags/list"

echoerr "Listing tags for ${registry}/${repo} ..."

curl -fLsS "$bomurl" | jq -r '.tags[]'
