#!/bin/bash
# 目标设置

target_list=(arm-linux-gnueabi arm-linux-gnueabihf aarch64-linux-gnueabi aarch64-linux-gnueabihf)
arch_list=(arm arm64)

target=aarch64-linux-gnueabi
arch=arm64

# 目录设置
ROOT_PATH=$(pwd)
export BUILD_PATH=${ROOT_PATH}/build
export TARBALL_PATH=${ROOT_PATH}/tarball
export PATCHES_PATH=${ROOT_PATH}/patches
export INSTALL_PATH=${ROOT_PATH}/gcc-${target}
export SYSROOT_PATH=${INSTALL_PATH}/${target}/sysroot
export PATH=${INSTALL_PATH}/bin:${PATH}

# 编译CPU数
NJOBS=6

version_compile=1.0
version_gcc=12.2.0
version_gdb=13.1
version_binutil=2.40
version_glic=2.37
version_linux=4.19.276
version_gmp=6.2.1
version_mpc=1.2.1
version_mpfr=4.1.0
version_isl=0.24
version_cloog=0.18.1

dir_gcc=gcc-${version_gcc}
dir_gdb=gdb-${version_gdb}
dir_linux=linux-${version_linux}
dir_glibc=glibc-${version_glic}
dir_binutils=binutils-${version_binutil}
dir_gmp=gmp-${version_gmp}
dir_mpc=mpc-${version_mpc}
dir_mpfr=mpfr-${version_mpfr}
dir_isl=isl-${version_isl}
dir_cloog=cloog-${version_cloog}
dir_test="test"

file_binutils=${dir_binutils}.tar.xz
file_gcc=${dir_gcc}.tar.xz
file_gdb=${dir_gdb}.tar.xz
file_linux=${dir_linux}.tar.xz
file_glibc=${dir_glibc}.tar.xz
file_gmp=${dir_gmp}.tar.bz2
file_mpc=${dir_mpc}.tar.gz
file_mpfr=${dir_mpfr}.tar.bz2
file_isl=${dir_isl}.tar.bz2
file_cloog=${dir_cloog}.tar.gz