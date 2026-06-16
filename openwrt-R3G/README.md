# openwrt-R3G

Build Xiaomi Mi Router 3G (R3G / MIR3G) firmware from the official OpenWrt
source tree, with only PassWall added from the same third-party feed style used
by the H5000M project.

## Build Source

- OpenWrt source: `https://github.com/openwrt/openwrt.git`
- Default OpenWrt ref: `v25.12.4`
- Third-party feed: `https://github.com/kenzok8/small-package.git`
- Extra app: `luci-app-passwall`

## Device Target

- Target: `ramips`
- Subtarget: `mt7621`
- Device: `xiaomi_mi-router-3g`

The seed file is:

```text
openwrt-R3G/configs/r3g.seed
```

## GitHub Actions

Use the workflow named `Build openwrt-R3G firmware`.

Default inputs:

- `openwrt_ref`: `v25.12.4`
- `passwall`: enabled
- `create_release`: enabled

Build output path:

```text
openwrt-R3G/openwrt/bin/targets/ramips/mt7621
```

## Local Build

From the repository root:

```sh
bash ./openwrt-R3G/scripts/prepare-source.sh v25.12.4
cd openwrt-R3G/openwrt
./scripts/feeds update -a
cd ../..
bash ./openwrt-R3G/scripts/install-feeds.sh
INCLUDE_PASSWALL=true bash ./openwrt-R3G/scripts/apply-package-options.sh
cd openwrt-R3G/openwrt
make defconfig
make download -j"$(nproc)"
make -j"$(nproc)"
```

## Flashing Note

R3G has NAND flash, so keep the official OpenWrt install/sysupgrade guidance for
the exact current firmware state. Use `factory` images only for first install
paths that explicitly call for them, and use `sysupgrade` images for OpenWrt to
OpenWrt upgrades.
