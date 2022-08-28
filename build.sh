#!/bin/bash

# 设置
root_path=$(pwd)
target=arm-linux-gnueabihf
tmp_path=${root_path}/object

export INSTALL_PATH=${root_path}/${target}

version_gcc=12.2.0
version_binutil=2.39
version_glic=2.36
version_linux=4.19.229

dir_gcc=gcc-${version_gcc}
dir_linux=linux-${version_linux}
dir_glibc=glibc-${version_glic}
dir_binutils=binutils-${version_binutil}

file_binutils=${dir_binutils}.tar.xz
file_gcc=${dir_gcc}.tar.xz
file_linux=${dir_linux}.tar.xz
file_glibc=${dir_glibc}.tar.xz

# 创建临时文件夹
prepare_resource() 
{
    [ -d "${tmp_path}" ] && rm -rf  "${tmp_path}"
    mkdir -p "${tmp_path}"

    if [ ! -f "${file_binutils}" ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/binutils/${file_binutils}
    fi
    if [ ! -f ${file_gcc} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/${dir_gcc}/${file_gcc}
    fi
    if [ ! -f ${file_glibc} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${file_glibc}
    fi
    if [ ! -f ${file_linux} ]; then
        wget https://mirrors.tuna.tsinghua.edu.cn/kernel/v4.x/${file_linux}
    fi

    # 创建目标文件夹
    [ -d "${INSTALL_PATH}" ] && rm -rf  "${INSTALL_PATH}"
    mkdir -p "${INSTALL_PATH}"
    
    # 解压binutils
    echo -e "start uncompress ${file_binutils} to ${tmp_path}\n"
    tar -vxf ${file_binutils} -C "${tmp_path}"
    echo -e "end uncompress ${file_binutils} to ${tmp_path}\n"

    # 解压gcc
    echo -e "start uncompress ${file_gcc} to ${tmp_path}\n"
    tar -vxf ${file_gcc} -C "${tmp_path}"

    # 执行代码依赖下载    
    cd "${tmp_path}"/${dir_gcc} || exit
    ./contrib/download_prerequisites
    cd - || exit

    echo -e "end uncompress ${file_gcc} to ${tmp_path}\n"

    # 解压头文件
    echo -e "start uncompress ${file_linux} to ${tmp_path}\n"
    tar -vxf ${file_linux} -C "${tmp_path}"
    echo -e "end uncompress ${file_linux} to ${tmp_path}\n"

    # 解压glibc
    echo -e "start uncompress ${file_glibc} to ${tmp_path}\n"
    tar -vxf ${file_glibc} -C "${tmp_path}"
    echo -e "end uncompress ${file_glibc} to ${tmp_path}\n"
}

# 编译binutils
build_binutils() {
    echo -e "start compile binutils"
    pushd "${tmp_path}"/${dir_binutils} >>/dev/null || exit
    [ -d build ] && rm -rf build 
    mkdir build
    pushd build >>/dev/null || exit

    ../configure \
        --prefix="${INSTALL_PATH}" \
        --target=${target} \
        --with-sysroot="${INSTALL_PATH}" \
        --with-lib-path="${INSTALL_PATH}"/lib \
        --disable-werror \
        --enable-lto \
        --disable-gdb \
        --disable-nls \
        --enable-gold \
        --enable-plugins \
        --enable-relro || exit

    make -j "$(nproc)" || exit
    make install || exit

    popd >>/dev/null || exit
    popd >>/dev/null || exit
    echo -e "end compile binutils"
}

# 编译内核头文件
build_kernel_header() 
{
    echo -e "start compile linux kernel header"
    pushd "${tmp_path}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm INSTALL_HDR_PATH="${INSTALL_PATH}"/${target} headers_install || exit
    popd >>/dev/null || exit
    echo -e "end compile linux kernel header"
}

# 第一次编译gcc
build_gcc_first() 
{
    echo -e "start compile gcc first step"
    pushd "${tmp_path}"/${dir_gcc} >>/dev/null || exit

    [ -d build ] && rm -rf build 
    mkdir build
    pushd build >>/dev/null || exit
    ../configure \
        --target=${target} \
        --prefix="${INSTALL_PATH}" \
        --with-glibc-version=2.36 \
        --enable-bootstrap \
        --enable-threads=posix \
        --enable-check=release \
        --enable-languages=c,c++ \
        --disable-multilib \
        --with-mode=arm \
        --with-float=hard ||
        exit

    make all-gcc -j "$(nproc)" || exit
    make install-gcc -j "$(nproc)" || exit

    popd >>/dev/null || exit
    popd >>/dev/null || exit
    echo -e "end compile gcc first step"
}

# 第一次编译glibc
build_glibc_first() {
    echo -e "start compile glibc first step"
    pushd "${tmp_path}"/${dir_glibc} >>/dev/null || exit
    
    [ -d build ] && rm -rf build 
    mkdir build
    pushd build >>/dev/null || exit
    ../configure \
        --prefix="${INSTALL_PATH}/${target}" \
        --host=${target} \
        --target=${target} \
        --build="$(../scripts/config.guess)" \
        --enable-kernel=3.2 \
        --with-headers="${INSTALL_PATH}"/${target}/include \
        --disable-multilib \
        libc_cv_forced_unwind=yes                     \
        libc_cv_ctors_header=yes                      \
        libc_cv_c_cleanup=yes                         \
        with_selinux=no || exit
    make install-bootstrap-headers=yes install-headers || exit
    make -j"$(nproc)" csu/subdir_lib 
    install csu/crt1.o csu/crti.o csu/crtn.o "${INSTALL_PATH}"/${target}/lib
    ${target}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o "${INSTALL_PATH}"/${target}/lib/libc.so
    touch "${INSTALL_PATH}"/${target}/include/gnu/stubs.h
    popd >>/dev/null || exit
    popd >>/dev/null || exit
    echo -e "end compile glibc first step"
}

# 第二次编译gcc
build_gcc_second() {
    echo -e "start compile gcc second step"
    pushd "${tmp_path}"/${dir_gcc}/build >>/dev/null || exit
    make all-target-libgcc -j "$(nproc)" || exit
    make install-target-libgcc -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end compile gcc second step"
}

# 第二次编译glibc
build_glibc_second() {
    echo -e "start compile glibc second step"
    pushd "${tmp_path}"/${dir_glibc}/build >>/dev/null || exit
    make -j "$(nproc)" || exit
    make install -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end compile glibc second step"
}

# 第三次编译gcc
build_gcc_third() {
    echo -e "start compile gcc third step"
    pushd "${tmp_path}"/${dir_gcc}/build >>/dev/null || exit
    make -j "$(nproc)" || exit
    make install -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end compile gcc third step"
}

build_kernel() {
    echo -e "start test compile"
    pushd "${tmp_path}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm CROSS_COMPILE=${target}- distclean || exit
    make ARCH=arm CROSS_COMPILE=${target}- imx_v6_v7_defconfig || exit
    make ARCH=arm CROSS_COMPILE=${target}- -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end test compile"
}

# prepare_resource
build_binutils
build_kernel_header
build_gcc_first
build_glibc_first
build_gcc_second
build_glibc_second
build_gcc_third
build_kernel
