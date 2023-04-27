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

if [ $CI_ENV = true ]; then
    gnu_mirror=https://ftp.gnu.org/ 
    kernel_mirror=https://mirrors.edge.kernel.org/pub/linux
fi

# 下载源码
download_resource()
{
    [ -d "${TARBALL_PATH}" ] && rm -rf  "${TARBALL_PATH}"
    mkdir -p "${TARBALL_PATH}"

    pushd "${TARBALL_PATH}" >> /dev/null || exit

    if [ ! -f "${file_binutils}" ]; then
        wget ${gnu_mirror}/gnu/binutils/${file_binutils}
    fi
    if [ ! -f ${file_gcc} ]; then
        wget ${gnu_mirror}/gnu/gcc/${dir_gcc}/${file_gcc}
    fi
    if [ ! -f ${file_gdb} ]; then
        wget ${gnu_mirror}/gnu/gdb/${file_gdb}
    fi
    if [ ! -f ${file_glibc} ]; then
        wget ${gnu_mirror}/gnu/glibc/${file_glibc}
    fi
    if [ ! -f ${file_linux} ]; then
        wget ${kernel_mirror}/kernel/v4.x/${file_linux}
    fi

    if [ ! -f ${file_gmp} ]; then
        wget ${gnu_mirror}/gnu/gmp/${file_gmp}
    fi

    if [ ! -f ${file_mpfr} ]; then
        wget ${gnu_mirror}/gnu/mpfr/${file_mpfr}
    fi

    if [ ! -f ${file_mpc} ]; then
        wget ${gnu_mirror}/gnu/mpc/${file_mpc}
    fi

    popd >> /dev/null || exit
}

download_resource