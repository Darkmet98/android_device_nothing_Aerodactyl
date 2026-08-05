#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

readonly REVISION="9f759dee5cdc5f85d076c642a192f6a9232f7058"
readonly CLANG_SHA256="41131b03d674645836c23635a7e2ae478bd869b3b3da98204365c06610ec5438"
readonly ROOT="$(repo root)"
readonly DEST="${ROOT}/prebuilts/clang/host/linux-x86/clang-r450784e"
readonly URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/${REVISION}/clang-r450784e.tar.gz"

if [[ -x "${DEST}/bin/clang" ]] && "${DEST}/bin/clang" --version | grep -q 'based on r450784e'; then
    echo "clang-r450784e is already installed"
    exit 0
fi

if [[ -e "${DEST}" ]]; then
    echo "Refusing to overwrite unexpected path: ${DEST}" >&2
    exit 1
fi

archive="$(mktemp --suffix=.tar.gz)"
staging="$(mktemp -d)"
trap 'rm -f "${archive}"; rm -rf "${staging}"' EXIT

curl -fL "${URL}" -o "${archive}"
tar -xzf "${archive}" -C "${staging}"
echo "${CLANG_SHA256}  ${staging}/bin/clang" | sha256sum -c -
"${staging}/bin/clang" --version | grep -q 'based on r450784e'
mv "${staging}" "${DEST}"
echo "Installed clang-r450784e from ${REVISION}"
