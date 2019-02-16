#!/usr/bin/env bash

# Basics from: https://kvz.io/blog/2013/11/21/bash-best-practices/
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

args="${1:-}"

# Script
SRC=${__dir}/src
PROJECT=${args[0]}
PROJECT_NAME=hugoblocks-${PROJECT}
PROJECT_SRC=${SRC}/${PROJECT_NAME}
HUGOBLOCKS_SRC=${__dir}/src/hugoblocks
PROJECT_BUILD="${__dir}/build/${PROJECT_NAME}"
SASS="${__dir}/node_modules/.bin/node-sass-chokidar"

function usage() {
  >&2 echo "./build.sh [PROJECT]"
  >&2 echo "    Project could be: explo, flow, focus, zeno, etc."
}

if [[ -z "${PROJECT}" ]]; then
  >&2 echo "no project given."; usage; exit 1;
fi

if [[ ! -d "${PROJECT_SRC}" ]]; then
  >&2 echo "project source not found in:" ${PROJECT_SRC}; usage; exit 1;
fi

mkdir -p ${PROJECT_BUILD}
mkdir -p ${PROJECT_BUILD}/static/css/

cp -R ${HUGOBLOCKS_SRC}/*  ${PROJECT_BUILD}/
cp -R ${PROJECT_SRC}/* ${PROJECT_BUILD}/
${SASS} ${PROJECT_SRC}/style/style.scss     \
  --source-map true                         \
  ---include-path ${SRC} \
  -o ${PROJECT_BUILD}/static/css/
