#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/openwrt"
CONFIG_FILE="${SRC_DIR}/.config"
INCLUDE_PASSWALL="${INCLUDE_PASSWALL:-true}"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "OpenWrt config file not found: ${CONFIG_FILE}"
  exit 1
fi

require_config() {
  local key="$1"
  if ! grep -Eq "^${key}=y$" "${CONFIG_FILE}"; then
    echo "Missing required config: ${key}=y"
    exit 1
  fi
}

require_config "CONFIG_TARGET_ramips"
require_config "CONFIG_TARGET_ramips_mt7621"
require_config "CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_mi-router-3g"
require_config "CONFIG_PACKAGE_luci"

if [ "${INCLUDE_PASSWALL}" = "true" ]; then
  require_config "CONFIG_PACKAGE_luci-app-passwall"
fi

echo "R3G package options verified."
