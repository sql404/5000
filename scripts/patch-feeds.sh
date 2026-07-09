#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${ROOT_DIR}/openwrt"

inject_luci_theme_argon() {
  local argon_dir="${SRC_DIR}/package/luci-theme-argon"
  local argon_config_dir="${SRC_DIR}/package/luci-app-argon-config"

  # 1. 注入 luci-theme-argon 主题 (使用适配 OpenWrt 25.12 现代 LuCI 的 master 分支)
  if [ -d "${argon_dir}" ]; then
    echo "luci-theme-argon source already exists, skipping clone."
  else
    echo "Injecting luci-theme-argon source (master branch)..."
    git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git "${argon_dir}"
  fi

  # 2. 注入配套的后台设置插件 (同样拉取主线 master)
  if [ -d "${argon_config_dir}" ]; then
    echo "luci-app-argon-config source already exists, skipping clone."
  else
    echo "Injecting luci-app-argon-config source..."
    git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git "${argon_config_dir}"
  fi
}
patch_tcping() {
  local makefile="${SRC_DIR}/package/feeds/small_package/tcping/Makefile"

  [ -f "${makefile}" ] || return 0

  if grep -q 'STRIP=true' "${makefile}"; then
    echo "tcping feed patch already applied."
    return 0
  fi

  sed -i 's|LDFLAGS="$(TARGET_LDFLAGS)"|LDFLAGS="$(TARGET_LDFLAGS)" STRIP=true|' "${makefile}"
  echo "Patched tcping feed package to skip upstream strip."
}

patch_python_build_backend() {
  local makefile="$1"
  local package_name="$2"

  [ -f "${makefile}" ] || return 0

  if grep -q '^PKG_BUILD_DEPENDS=.*python-setuptools/host' "${makefile}"; then
    echo "${package_name} feed patch already applied."
    return 0
  fi

  sed -i '/^include \.\.\/pypi\.mk$/i PKG_BUILD_DEPENDS:=python-setuptools/host' "${makefile}"
  echo "Patched ${package_name} feed package to provide setuptools build backend."
}

patch_luci_mosdns_jsmin() {
  local makefile="${SRC_DIR}/package/feeds/small_package/luci-app-mosdns/Makefile"

  [ -f "${makefile}" ] || return 0

  if grep -q '^LUCI_MINIFY_JS:=0' "${makefile}"; then
    echo "luci-app-mosdns jsmin patch already applied."
    return 0
  fi

  sed -i '/^LUCI_MINIFY_JS:=/a LUCI_MINIFY_JS:=0' "${makefile}"
  echo "Patched luci-app-mosdns to skip JS minification."
}

patch_passwall2_nftset_empty_insert() {
  local script="${SRC_DIR}/package/feeds/small_package/luci-app-passwall2/root/usr/share/passwall2/nftables.sh"

  [ -f "${script}" ] || return 0

  if grep -q 'H5000M_EMPTY_NFTSET_GUARD' "${script}"; then
    echo "PassWall2 nftset empty insert patch already applied."
    return 0
  fi

  if grep -q '\[ \$# -gt 0 \] || \[ ! -t 0 \] && insert_nftset' "${script}"; then
    sed -i 's/\[ \$# -gt 0 \] || \[ ! -t 0 \] && insert_nftset "$nftset_name" "$timeout_argument_element" "$@"/[ "$#" -gt 0 ] \&\& insert_nftset "$nftset_name" "$timeout_argument_element" "$@" # H5000M_EMPTY_NFTSET_GUARD/' "${script}"
    echo "Patched PassWall2 nftables.sh to skip empty nftset insert in non-interactive builds."
  else
    echo "PassWall2 nftset empty insert pattern not found; upstream may already be fixed."
  fi
}

# --- 执行区 ---
inject_luci_theme_argon

patch_tcping
patch_python_build_backend "${SRC_DIR}/package/feeds/packages/python-pyserial/Makefile" "python-pyserial"
patch_python_build_backend "${SRC_DIR}/package/feeds/packages/python-websockets/Makefile" "python-websockets"
patch_luci_mosdns_jsmin
patch_passwall2_nftset_empty_insert
