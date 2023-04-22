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

source env.sh

# 下载源码
download_resource()
{
    [ -d "${TARBALL_PATH}" ] && rm -rf  "${TARBALL_PATH}"
    mkdir -p "${TARBALL_PATH}"

    pushd "${TARBALL_PATH}" >> /dev/null || exit

    if [ ! -f "${file_binutils}" ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/${file_binutils}
    fi
    if [ ! -f ${file_gcc} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/${dir_gcc}/${file_gcc}
    fi
    if [ ! -f ${file_gdb} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/${file_gdb}
    fi
    if [ ! -f ${file_glibc} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${file_glibc}
    fi
    if [ ! -f ${file_linux} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v4.x/${file_linux}
    fi

    if [ ! -f ${file_gmp} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/${file_gmp}
    fi

    if [ ! -f ${file_mpfr} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/mpfr/${file_mpfr}
    fi

    if [ ! -f ${file_mpc} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/mpc/${file_mpc}
    fi

    popd >> /dev/null || exit
}