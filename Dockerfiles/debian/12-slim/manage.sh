#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

REPO_ROOT=$(r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}" && pwd)

"${REPO_ROOT}"/Scripts/core.sh "${@}" --tags 'bookworm-slim'
