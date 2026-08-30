# OrangeFox recovery device tree for the Bluefox NX1

OrangeFox (TWRP-based) device tree for the Bluefox NX1, ported from the
PixelOS 17 tree (`device/bluefox/NX1` + `device/bluefox/NX1-kernel`).

## Device facts used by this tree

- SoC: MediaTek MT6768 (Helio G81), arm64, 4K kernel pages.
- A/B with **Virtual A/B** (VAB) + vendor ramdisk; no dedicated recovery
  partition - recovery lives inside `vendor_boot`.
- GKI boot header v4, `Image.gz` + `dtb/nx1.dtb` + `dtbo.img` prebuilts.
- Dynamic partitions: system, system_ext, product, vendor, system_dlkm,
  vendor_dlkm, odm_dlkm (super = 9663676416).
- Data: F2FS with FBE (aes-256-xts:aes-256-cts v2), metadata encryption,
  TrustKernel TEE (keymint AIDL v3 / gatekeeper).
- Touch: JADARD JD9365 TDDI (firmware + `jd9365tg_i2c.ko`/`jd9365tn_i2c.ko`).

## Build

This tree targets the OrangeFox **fox_14.1** minimal source (R12.x), synced
per the [official build page](https://wiki.orangefox.tech/dev/building).

```bash
cd ~/fox_14.1
source build/envsetup.sh
lunch twrp_NX1-ap2a-eng
mka adbd recoveryimage vendorbootimage
```

Outputs (in `out/target/product/NX1/`):

- `OrangeFox-unofficial-NX1.img` (recovery image)
- `vendor_boot.img` - flash this for VAB devices:

```bash
fastboot flash vendor_boot out/target/product/NX1/vendor_boot.img
fastboot reboot
```

## What is included

- **Build-time source patches** (`patches/`): the OrangeFox-side changes
  (recovery GUI/vibrator/flashlight fixes, fastbootd HAL stubs, libc++
  `__libcpp_verbose_abort`, servicemanager VINTF skip, libbinder NDK36 stub,
  libvintf v9) are shipped as git patches and applied automatically and
  idempotently from `device.mk` (`git apply --check ... && git apply ...`),
  so a clean `repo sync` of the OrangeFox tree is enough - no manual edits
  required.

- Prebuilt stock GKI kernel, DTB and DTBO.
- All 148 first-stage modules from the stock `vendor_boot` ramdisk, installed
  through `BOARD_VENDOR_RAMDISK_KERNEL_MODULES`, with the exact stock
  `modules.load.recovery` order.
- Stock first-stage `fstab.mt6768` at `first_stage_ramdisk/`.
- Stock recovery `recovery.fstab` and `ueventd.rc`, plus the MTK ueventd rules
  in the recovery root (`vendor/etc/ueventd.rc`).
- MTK AIDL boot control HAL from the stock recovery ramdisk
  (`android.hardware.boot-service.mtk_recovery` + rc + VINTF fragment) so
  OrangeFox can switch slots (`OF_USE_AIDL_BOOT_CONTROL=1`).
- `mtk_plpath_utils` (boot-region symlinks) and its rc, called from
  `init.recovery.mt6768.rc` exactly like stock.
- Stock `android.hardware.health-service.example_recovery` + rc + fragment.
- TrustKernel TEE blobs for decryption: `teed`, `tee_check_keybox`,
  `android.hardware.gatekeeper-service.trustkernel`,
  `android.hardware.security.keymint@3.0-service.trustkernel` and their
  vendor libs / rc / VINTF fragments, plus the system TAs from
  `/vendor/app/t6`. keystore2 is started from `init.recovery.mt6768.rc`
  (class `hal`), and `keystore`/`teed`/HAL domains are permissive because the
  recovery ramdisk files carry `rootfs` labels.
- JADARD touch firmware.
- MTK musb-hdrc USB gadget setup (adb / mtp / fastbootd).

## Known limitations

- **Decryption works** (metadata auto-decrypt + lock-screen PIN page), but the
  TrustKernel services depend on several recovery-source patches; see the
  change list in the OrangeFox source (`gui/gui.cpp`, `system/libvintf`,
  `frameworks/native/cmds/servicemanager`, `external/libcxx`).
- The recovery servicemanager is built with
  `-DRECOVERY_SERVICEMANAGER_NO_VINTF=1` so the keymint process can register
  its secureclock/sharedsecret instances (the stock vendor manifest does not
  declare them) while keeping all normal servicemanager APIs (including
  `getDeclaredInstances` and `servicemanager.ready`). The binary is vendored
  in `recovery/root/system/bin/` because the Soong recovery-variant install
  is unreliable in this build flow.
- TrustKernel VINTF fragments are shipped in BOTH
  `vendor/etc/vintf/manifest/` (for the normal device-manifest path) and
  `system/etc/vintf/manifest/` (for the recovery servicemanager, which reads
  the recovery-style manifest from /system).
- MTP works: `init.recovery.usb.rc` wires configfs (adb/mtp/fastboot), and
  `partitionmanager.cpp` re-binds the UDC with retries because the NX1 musb
  fails the first bind after a `none` switch with -19 (ENODEV).
- Temperature: recovery has no CPU thermal zone, so the mtk-gauge zone
  (`thermal_zone6`) is shown instead of an invalid 0 degC.
- The TrustKernel protect storage on `/mnt/vendor/persist/t6` (and
  `/mnt/vendor/protect_f/tee`) must keep the `tkcore_protect_data_file`
  label. teed running permissively in recovery rewrites those files, so
  `init.recovery.mt6768.rc` recursively `restorecon`s both trees on every
  boot (`on fs` and again `on post-fs` before teed starts). Without this,
  the system-side `tee` domain (enforcing) cannot read gatekeeper state and
  PIN verification fails after a recovery decrypt.
- **Backlight:** `TW_BRIGHTNESS_PATH` uses the usual MTK path
  (`/sys/class/leds/lcd-backlight/brightness`); adjust if the panel exposes a
  different sysfs node.
- Display size/theme assume 540x1168/240dpi (stock values).

## License

GPL-3.0-or-later, like OrangeFox. If you build and release this tree publicly,
you must publish the source (including any modifications), per the OrangeFox
wiki.

Credits: OrangeFox project, TWRP team, the PixelOS 17 NX1 tree
(linx3141), and `device/oneplus/dodge` used as the structural reference.
