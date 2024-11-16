#!/bin/bash

pkgname=('envmanager')
pkgrel=1
pkgver=0.0.1

pkgdesc="Environment manager for Arch Linux"
arch=('any')
url="https://github.com/EnvManager/envmanager"
license=('MIT')
backup=(
  'etc/envmanager/config.sh'
  'etc/profile.d/00-envmanager.sh'
)

source+=(
  'init.sh'
  'core.sh'
  'config.sh'
  '00-envmanager.sh'
)
sha512sums+=(
  3f04ba6dcf11a47f2a53825d6c3f5aec8efd302a851d7993d7f67b880dfb939619f5c08fd7663827fd25095f81a580fdd985f891d5ac24f6e2a0a39e9ec70314
  eac3cd474c21829389099d0ad17498d1536aff05287c862b434a3dc5555cd537cb1a0790e6c98262a979b1158cdd93a22c73d02e6f6fef9777bb480d8cb89773
  8c4b7a42b5e47435a14b94bffbc2095919f7e1c7c2e1bd7d23cd537071f3b1402cc33e5f075f909b83cbffab69167b2653ceb3f13d49751183470ddd9521b8ba
  72c5effd99d93cb522160df2af4c36d41ff16bd0f31d52cf3c79698c0598277d8dee3632d3d5a092bd3f375da02629f051efd8dae79a3f6a186ebe9296e3c29b
)

package_envmanager() {
  source "config.sh"

  install -v -dm755 "${pkgdir}/${ENVMANAGER_GLOBAL_CONFIG_DIR}"

  # Install `envmanager`
  install -v -Dm755 "${srcdir}/core.sh" "${pkgdir}/${ENVMANAGER_SCRIPTS_DIR}/core.sh"
  install -v -Dm755 "${srcdir}/init.sh" "${pkgdir}/${ENVMANAGER_SCRIPTS_DIR}/init.sh"
  install -v -Dm755 "${srcdir}/config.sh" "${pkgdir}/${ENVMANAGER_CONFIG_FILE}"

  # Install ENVManager global initialization profile
  install -v -Dm755 "${srcdir}/00-envmanager.sh" "${pkgdir}/etc/profile.d/00-envmanager.sh"
}

