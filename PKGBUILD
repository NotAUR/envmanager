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
  32056d38c67ae7b31be23f1c803371a582517e0b9ced670bbb0fa4fd0c2c94fe80758e4477b7a1d2def4dc0af21618179313e12570dc0094ebf5df8bc30c9375
  06f2d7ddae6815504095ddca4f00c01e70ecb115db8022c6bf855558bfed202a3e650a652c22278d843b06495ad49b8529f5aaeda54ea57a7fabcf3751b660d7
  3cac110334f2736bcd7daab8479f20de61f085fbd292c4552ca18a16ad1caa06a36121c4e1dad4cf91def42e1a2280253e0d342f79353b8709f5555ec05d05ec
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

