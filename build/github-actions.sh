#!/bin/bash

set -euxo pipefail

mac_prepare_tools() {
  export HOMEBREW_NO_AUTO_UPDATE=1
  brew unlink $(brew list --formula)
  brew install xz coreutils gnu-tar
  brew link --force xz coreutils gnu-tar
}

mac_build_perl() {
  export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
  rm -rf ~/perl ~/cpm
  mkdir ~/perl
  curl -fsSL https://github.com/skaji/relocatable-perl/releases/download/5.36.0.0/perl-darwin-2level.tar.xz | gtar xJf - --strip-components 1 -C ~/perl
  curl -fsSL --compressed -o ~/cpm https://raw.githubusercontent.com/skaji/cpm/main/cpm
  ~/perl/bin/perl ~/cpm install -g --cpmfile build/cpm.yml
  sudo rm -rf /opt/perl
  sudo install -m 755 -o $USER -g staff -d /opt/perl
  ~/perl/bin/perl build/relocatable-perl-build --prefix /opt/perl --perl_version $(cat BUILD_VERSION)
  /opt/perl/bin/perl ~/cpm install -g App::cpanminus App::ChangeShebang
  /opt/perl/bin/change-shebang -f /opt/perl/bin/*
}

mac_create_artifacts() {
  local archname=$(if [[ $(uname -m) = x86_64 ]]; then echo amd64; else echo arm64; fi)
  rm -rf darwin-$archname perl-darwin-$archname*
  gcp -r /opt/perl perl-darwin-$archname
  gtar cf perl-darwin-$archname.tar perl-darwin-$archname
  mkdir darwin-$archname
  gzip -9 --stdout perl-darwin-$archname.tar > darwin-$archname/perl-darwin-$archname.tar.gz
  xz   -9 --stdout perl-darwin-$archname.tar > darwin-$archname/perl-darwin-$archname.tar.xz
}

linux_amd64_create_artifacts() {
  mkdir linux-amd64
  ID=$(docker create skaji/relocatable-perl)
  docker cp $ID:/perl-linux-amd64.tar.gz linux-amd64/
  docker cp $ID:/perl-linux-amd64.tar.xz linux-amd64/
  docker rm $ID
}

linux_arm64_create_artifacts() {
  mkdir linux-arm64
  ID=$(docker create --platform linux/arm64 skaji/relocatable-perl)
  docker cp $ID:/perl-linux-arm64.tar.gz linux-arm64/
  docker cp $ID:/perl-linux-arm64.tar.xz linux-arm64/
  docker rm $ID
}

linux_ppc64le_create_artifacts() {
  mkdir linux-ppc64le
  docker images
  ID=$(docker create --platform linux/ppc64le skaji/relocatable-perl)
  docker cp $ID:/perl-linux-ppc64le.tar.gz linux-ppc64le/
  docker cp $ID:/perl-linux-ppc64le.tar.xz linux-ppc64le/
  docker rm $ID
}

case "$1" in
mac_prepare_tools)
  mac_prepare_tools
  ;;
mac_build_perl)
  mac_build_perl
  ;;
mac_create_artifacts)
  mac_create_artifacts
  ;;
linux_amd64_create_artifacts)
  linux_amd64_create_artifacts
  ;;
linux_arm64_create_artifacts)
  linux_arm64_create_artifacts
  ;;
linux_ppc64le_create_artifacts)
  linux_ppc64le_create_artifacts
  ;;
*)
  echo "unknown command: $1" >&2
  exit 1
  ;;
esac
