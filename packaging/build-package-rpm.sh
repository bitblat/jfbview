#!/bin/bash

version="$1"
dist="$2"
arch="$3"
package_file_prefix="jfbview-${version}-${dist}.${arch}"

function install_build_deps() {
  yum install -y epel-release
  yum install -y \
    cmake make gcc-c++ rpm-build \
    ncurses-devel imlib2-devel \
    libjpeg-devel mesa-libGLU-devel libXi-devel libXrandr-devel
}

function build_package() {
  cd "$(dirname "$0")/.."
  mkdir -p build upload
  cmake -H. -Bbuild \
    -DPACKAGE_FORMAT=RPM \
    -DPACKAGE_FILE_PREFIX="$package_file_prefix" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
    -DCMAKE_VERBOSE_MAKEFILE=ON
  cmake --build build --target package
  mv build/*.rpm upload/
}

function install_test_deps() {
  if [ -e /etc/centos-release ]; then
    dnf --enablerepo=PowerTools install -y gtest-devel
  else
    yum install -y epel-release
    yum install -y gtest-devel
  fi
}

function run_tests() {
  cd "$(dirname "$0")/.."
  mkdir -p build_tests
  cmake -H. -Bbuild_tests \
    -DBUILD_TESTING=ON \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_VERBOSE_MAKEFILE=ON
  cmake --build build_tests
  env CTEST_OUTPUT_ON_FAILURE=1 \
    cmake --build build_tests --target test
}

set -ex

install_build_deps
install_test_deps
run_tests
build_package

