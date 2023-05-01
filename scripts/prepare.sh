#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC1091
# shellcheck disable=SC2154
#   _____  _____    ____    _____  _____  _______  ____    ____   _
#  / ____||  __ \  / __ \  / ____|/ ____||__   __|/ __ \  / __ \ | |
# | |     | |__) || |  | || (___ | (___     | |  | |  | || |  | || |
# | |     |  _  / | |  | | \___ \ \___ \    | |  | |  | || |  | || |
# | |____ | | \ \ | |__| | ____) |____) |   | |  | |__| || |__| || |____
#  \_____||_|  \_\ \____/ |_____/|_____/    |_|   \____/  \____/ |______|

set -e

source scripts/env.sh

# 下载地址

gnu_mirror=https://mirrors.tuna.tsinghua.edu.cn
kernel_mirror=https://mirrors.tuna.tsinghua.edu.cn

if [ $CI_ENV ]; then
    gnu_mirror=https://ftp.gnu.org/
    kernel_mirror=https://mirrors.edge.kernel.org/pub/linux
fi

if [ ! -d "${TARBALL_PATH}" ]; then
    mkdir -p "${TARBALL_PATH}"
fi

pushd "${TARBALL_PATH}" >> /dev/null || exit

if [ ! -f "${file_binutils}" ]; then
    wget -nv ${gnu_mirror}/gnu/binutils/${file_binutils}
fi
if [ ! -f ${file_gcc} ]; then
    wget -nv ${gnu_mirror}/gnu/gcc/${dir_gcc}/${file_gcc}
fi
if [ ! -f ${file_gdb} ]; then
    wget -nv ${gnu_mirror}/gnu/gdb/${file_gdb}
fi
if [ ! -f ${file_glibc} ]; then
    wget -nv ${gnu_mirror}/gnu/glibc/${file_glibc}
fi
if [ ! -f ${file_linux} ]; then
    wget -nv ${kernel_mirror}/kernel/v4.x/${file_linux}
fi

if [ ! -f ${file_gmp} ]; then
    wget -nv ${gnu_mirror}/gnu/gmp/${file_gmp}
fi

if [ ! -f ${file_mpfr} ]; then
    wget -nv ${gnu_mirror}/gnu/mpfr/${file_mpfr}
fi

if [ ! -f ${file_mpc} ]; then
    wget -nv ${gnu_mirror}/gnu/mpc/${file_mpc}
fi

if [ ! -f ${file_isl} ]; then
        wget -nv https://libisl.sourceforge.io/${file_isl}
fi

popd >> /dev/null || exit

[ -d "${BUILD_PATH}" ] && rm -rf  "${BUILD_PATH}"
mkdir -p "${BUILD_PATH}"

# 解压binutils
echo -e "start uncompress ${file_binutils} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_binutils} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_binutils} to ${BUILD_PATH}\n"

# 解压gcc
echo -e "start uncompress ${file_gcc} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_gcc} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_gcc} to ${BUILD_PATH}\n"

# 打入补丁
pushd "${BUILD_PATH}/${dir_gcc}" >> /dev/null || exit
patch -p1 < "${PATCHES_PATH}"/gcc/${version_gcc}/fix_error.patch >> /dev/null
popd >> /dev/null || exit

echo -e "start uncompress ${file_gmp} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_gmp} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_gmp} to ${BUILD_PATH}\n"

echo -e "start uncompress ${file_mpfr} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_mpfr} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_mpfr} to ${BUILD_PATH}\n"

echo -e "start uncompress ${file_mpc} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_mpc} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_mpc} to ${BUILD_PATH}\n"

echo -e "start uncompress ${file_isl} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_isl} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_isl} to ${BUILD_PATH}\n"

echo -e "start add soft link to ${BUILD_PATH}"
pushd "${BUILD_PATH}"/${dir_gcc} >> /dev/null || exit
ln -s "${BUILD_PATH}"/${dir_gmp} gmp
ln -s "${BUILD_PATH}"/${dir_mpc} mpc
ln -s "${BUILD_PATH}"/${dir_mpfr} mpfr
ln -s "${BUILD_PATH}"/${dir_isl} isl
popd >> /dev/null || exit
echo -e "end add soft link  to ${BUILD_PATH}\n"

# 解压头文件
echo -e "start uncompress ${file_linux} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_linux} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_linux} to ${BUILD_PATH}\n"

# 解压glibc
echo -e "start uncompress ${file_glibc} to ${BUILD_PATH}"
tar -xf "${TARBALL_PATH}"/${file_glibc} -C "${BUILD_PATH}"
echo -e "end uncompress ${file_glibc} to ${BUILD_PATH}\n"
