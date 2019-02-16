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

function usage() {
  >&2 echo "./build.sh [PROJECT]"
  >&2 echo "    Project could be: explo, flow, focus, zeno, etc."
}

function build() {
  SRC=${__dir}/src
  PROJECT=$1
  PROJECT_NAME=hugoblocks-${PROJECT}
  PROJECT_SRC=${SRC}/${PROJECT_NAME}
  HUGOBLOCKS_SRC=${__dir}/src/hugoblocks
  PROJECT_BUILD="${__dir}/build/${PROJECT_NAME}"
  SASS="${__dir}/node_modules/.bin/node-sass-chokidar"

  if [[ ! -d "${PROJECT_SRC}" ]]; then
    >&2 echo "project source not found in:" ${PROJECT_SRC}; usage; exit 1;
  fi

  echo "building ${PROJECT}"

  mkdir -p ${PROJECT_BUILD}
  mkdir -p ${PROJECT_BUILD}/static/css/

  cp -R ${HUGOBLOCKS_SRC}/*  ${PROJECT_BUILD}/
  cp -R ${PROJECT_SRC}/* ${PROJECT_BUILD}/
  ${SASS} ${PROJECT_SRC}/style/style.scss     \
    --source-map true                         \
    ---include-path ${SRC} \
    -o ${PROJECT_BUILD}/static/css/
}

if [[ -z "${args[0]}" ]]; then
  >&2 echo "no project given."; usage; exit 1;
fi

ALL_PROJECTS=(explo flow focus zeno)

if [ "${args[0]}" == "all" ]; then
  for project in ${ALL_PROJECTS[*]}; do
    build "${project}";
  done
else
  build "${args[0]}"
fi

echo "done"