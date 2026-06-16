#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/openwrt"
INCLUDE_PASSWALL="${INCLUDE_PASSWALL:-true}"

if [ ! -d "${SRC_DIR}" ]; then
  echo "OpenWrt source directory not found: ${SRC_DIR}"
  exit 1
fi

cd "${SRC_DIR}"

./scripts/feeds install -a

if [ "${INCLUDE_PASSWALL}" = "true" ]; then
  ./scripts/feeds install -p small_package luci-app-passwall || ./scripts/feeds install luci-app-passwall
fi
