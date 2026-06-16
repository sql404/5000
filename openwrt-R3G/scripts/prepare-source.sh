#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/openwrt"
REF="${1:-${OPENWRT_REF:-v25.12.4}}"
REPO_URL="${OPENWRT_REPO:-https://github.com/openwrt/openwrt.git}"
INCLUDE_PASSWALL="${INCLUDE_PASSWALL:-true}"

if [ -d "${SRC_DIR}/.git" ]; then
  echo "Updating official OpenWrt source: ${REF}"
  git -C "${SRC_DIR}" remote set-url origin "${REPO_URL}"
  git -C "${SRC_DIR}" fetch --tags --depth=1 origin "${REF}"
  git -C "${SRC_DIR}" checkout --detach FETCH_HEAD
else
  echo "Cloning official OpenWrt source: ${REF}"
  git clone --depth=1 --branch "${REF}" "${REPO_URL}" "${SRC_DIR}"
fi

cp "${ROOT_DIR}/configs/r3g.seed" "${SRC_DIR}/.config"

append_feed_once() {
  local feed_line="$1"
  local feed_name
  feed_name="$(printf '%s\n' "${feed_line}" | awk '{print $2}')"
  if ! grep -Eq "^src-git[[:space:]]+${feed_name}[[:space:]]" "${SRC_DIR}/feeds.conf.default"; then
    printf '%s\n' "${feed_line}" >> "${SRC_DIR}/feeds.conf.default"
  fi
}

if [ "${INCLUDE_PASSWALL}" = "true" ]; then
  echo "Adding kenzok8/small-package feed for PassWall"
  append_feed_once "src-git small_package https://github.com/kenzok8/small-package.git"
fi

echo "OpenWrt source is ready: ${SRC_DIR}"
echo "Current ref: ${REF}"
