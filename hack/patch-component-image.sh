#!/usr/bin/env bash

#
# Read a BOM from stdin and perform one component customization, printing the resulting modified BOM to stdout.
# Given a component name and an image name, patch-edit that image's values.
# Requires ytt (https://carvel.dev/ytt).
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
  echoerr "   -h, --help:                       print this usage"
  echoerr "   -c, --component <component_name>: name of the component within the BOM's component list to be customized (required)"
  echoerr "   -c, --image <image_name>:         name of the component's image to be customized (required)"
  echoerr "   -v, --value <yaml_string>:        the new YAML value for the component's image as a string"
  echoerr "   -f, --value-file <filename>:      the filename which contains the new YAML value for the component's image"
  exit "$1"
}

help=no
component=""
image=""
value=""
value_file=""

while (("$#")); do
  case "$1" in
  -h | --help)
    help=yes
    shift
    ;;
  -c | --component)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-c|--component requires a component name to be specified"
    fi
    component=$1
    shift
    ;;
  -i | --image)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-i|--image requires a component's image name to be specified"
    fi
    image=$1
    shift
    ;;
  -v | --value)
    shift
    # YAML values can start with "-" for arrays, so don't check if the next argument starts with "-".
    if [[ "$#" == "0" ]]; then
      usage_error "-v|--value requires a YAML value to be specified"
    fi
    value=$1
    shift
    ;;
  -f | --value-file)
    shift
    if [[ "$#" == "0" || "$1" == -* ]]; then
      usage_error "-f|--value-file requires a YAML filename to be specified"
    fi
    value_file=$1
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

if [[ "$component" == "" ]]; then
  usage_error "no component name set. -c|--component is a required option."
fi

if [[ "$image" == "" ]]; then
  usage_error "no image name set. -i|--image is a required option."
fi

if [[ "$value" == "" && "$value_file" == "" ]]; then
  usage_error "no value set. must use either -v|--value or -f|--value-file to set a new value for the component."
fi

if [[ "$value" != "" && "$value_file" != "" ]]; then
  usage_error "multiple values set. must use either -v|--value or -f|--value-file to set a new value for the component."
fi

if [[ "$value" == "" ]]; then
  value=$(cat "$value_file")
fi

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_dir="${here}/ytt/patch_component_image"

echoerr "Reading BOM from stdin ..."

ytt --file - --file "$template_dir" \
  --data-value "component_name=${component}" \
  --data-value "image_name=${image}" \
  --data-value-yaml "image_value=${value}"
