#!/bin/bash

# 目标设置
target=arm-linux-gnueabihf

# 目录设置
ROOT_PATH=$(pwd)
export SRC_PATH=${ROOT_PATH}/src
export BUILD_PATH=${ROOT_PATH}/build
export INSTALL_PATH=${ROOT_PATH}/install
export SYSROOT_PATH=${INSTALL_PATH}/${target}/sysroot

version_gcc=12.2.0
version_binutil=2.39
version_glic=2.36
version_linux=4.19.229
version_gmp=6.2.1
version_mpc=1.2.1
version_mpfr=4.1.0
version_isl=0.24
version_cloog=0.18.1

dir_gcc=gcc-${version_gcc}
dir_linux=linux-${version_linux}
dir_glibc=glibc-${version_glic}
dir_binutils=binutils-${version_binutil}
dir_gmp=gmp-${version_gmp}
dir_mpc=mpc-${version_mpc}
dir_mpfr=mpfr-${version_mpfr}
dir_isl=isl-${version_isl}
dir_cloog=cloog-${version_cloog}

file_binutils=${dir_binutils}.tar.xz
file_gcc=${dir_gcc}.tar.xz
file_linux=${dir_linux}.tar.xz
file_glibc=${dir_glibc}.tar.xz
file_gmp=${dir_gmp}.tar.bz2
file_mpc=${dir_mpc}.tar.gz
file_mpfr=${dir_mpfr}.tar.bz2
file_isl=${dir_isl}.tar.bz2
file_cloog=${dir_cloog}.tar.gz

# 创建临时文件夹
download_resource() 
{
    [ -d "${SRC_PATH}" ] && rm -rf  "${SRC_PATH}"
    mkdir -p "${SRC_PATH}"
    
    pushd "${SRC_PATH}" >> /dev/null || exit

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

    if [ ! -f ${file_gmp} ]; then
        wget http://gcc.gnu.org/pub/gcc/infrastructure/${file_gmp}
    fi

    if [ ! -f ${file_mpfr} ]; then
        wget http://gcc.gnu.org/pub/gcc/infrastructure/${file_mpfr}
    fi

    if [ ! -f ${file_mpc} ]; then
        wget http://gcc.gnu.org/pub/gcc/infrastructure/${file_mpc}
    fi

    if [ ! -f ${file_isl} ]; then
        wget http://gcc.gnu.org/pub/gcc/infrastructure/${file_isl}
    fi

    if [ ! -f ${file_cloog} ]; then
        wget http://gcc.gnu.org/pub/gcc/infrastructure/${file_cloog}
    fi

    popd >> /dev/null || exit
}

prepare_resource()
{
    # 创建目标文件夹
    [ -d "${INSTALL_PATH}" ] && rm -rf  "${INSTALL_PATH}"
    mkdir -p "${INSTALL_PATH}"
    
    [ -d "${BUILD_PATH}" ] && rm -rf  "${BUILD_PATH}"
    mkdir -p "${BUILD_PATH}"

    # 解压binutils
    echo -e "start uncompress ${file_binutils} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_binutils} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_binutils} to ${BUILD_PATH}\n"

    # 解压gcc
    echo -e "start uncompress ${file_gcc} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_gcc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_gcc} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_gmp} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_gmp} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_gmp} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_mpfr} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_mpfr} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_mpfr} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_mpc} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_mpc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_mpc} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_isl} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_isl} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_isl} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_cloog} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_cloog} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_cloog} to ${BUILD_PATH}\n"

    pushd "${BUILD_PATH}"/${dir_gcc} >> /dev/null || exit
    ln -s "${BUILD_PATH}"/${dir_gmp} gmp
    ln -s "${BUILD_PATH}"/${dir_mpc} mpc
    ln -s "${BUILD_PATH}"/${dir_mpfr} mpfr
    ln -s "${BUILD_PATH}"/${dir_isl} isl
    ln -s "${BUILD_PATH}"/${dir_cloog} cloog
    popd >> /dev/null || exit

    # 解压头文件
    echo -e "start uncompress ${file_linux} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_linux} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_linux} to ${BUILD_PATH}\n"

    # 解压glibc
    echo -e "start uncompress ${file_glibc} to ${BUILD_PATH}\n"
    tar -vxf "${SRC_PATH}"/${file_glibc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_glibc} to ${BUILD_PATH}\n"
}

# 编译binutils
build_binutils() {
    echo -e "start compile binutils"
    pushd "${BUILD_PATH}"/${dir_binutils} >>/dev/null || exit
    [ -d build ] && rm -rf build 
    mkdir build
    pushd build >>/dev/null || exit

    ../configure \
        --prefix="${INSTALL_PATH}" \
        --target=${target} \
        --with-sysroot="${SYSROOT_PATH}" \
        --with-lib-path="${INSTALL_PATH}"/lib \
        --disable-werror \
        --enable-lto \
        --disable-gdb \
        --disable-nls \
        --enable-gold \
        --enable-plugins \
        --enable-relro \
    	--enable-threads \
        --enable-ld=default \
		--enable-64-bit-bfd \
		--disable-bootstrap \
        --disable-shared \
        --enable-multilib \
        --with-sysroot="${SYSROOT_PATH}" \
        || exit
		
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
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm INSTALL_HDR_PATH="${SYSROOT_PATH}/usr" headers_install || exit
    popd >>/dev/null || exit
    echo -e "end compile linux kernel header"
}

# 第一次编译gcc
build_gcc_stage1() 
{
    echo -e "start compile gcc first step"
    pushd "${BUILD_PATH}"/${dir_gcc} >>/dev/null || exit

    [ -d build_gcc_stage1 ] && rm -rf build_gcc_stage1 
    mkdir build_gcc_stage1
    pushd build_gcc_stage1 >>/dev/null || exit
    ../configure \
        --target=${target} \
        --prefix="${INSTALL_PATH}" \
        --with-sysroot="${SYSROOT_PATH}" \
        --with-glibc-version=${version_glic} \
        --disable-bootstrap \
        --enable-threads=posix \
        --enable-check=release \
        --enable-languages=c,c++ \
        --disable-multilib \
        --without-headers \
        --with-gnu-ld \
        --with-gnu-as \
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
build_glibc_stage1() {
    echo -e "start compile glibc first step"
    pushd "${BUILD_PATH}"/${dir_glibc} >>/dev/null || exit
    
    [ -d build_glibc_stage1 ] && rm -rf build_glibc_stage1 
    mkdir build_glibc_stage1
    pushd build_glibc_stage1 >>/dev/null || exit
    ../configure \
        --prefix="${INSTALL_PATH}/${target}" \
        --host=${target} \
        --target=${target} \
        --build="$(../scripts/config.guess)" \
        --enable-kernel=3.2 \
        --with-headers="${SYSROOT_PATH}"/usr/include \
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
build_gcc_stage2() {
    echo -e "start compile gcc second step"
    pushd "${BUILD_PATH}"/${dir_gcc} >> /dev/null || exit
    
    [ -d build_gcc_stage2 ] && rm -rf build_gcc_stage2
    mkdir build_gcc_stage2
    pushd build_gcc_stage2 >>/dev/null || exit
    ../configure \
        --target=${target} \
        --prefix="${INSTALL_PATH}" \
        --with-sysroot="${SYSROOT_PATH}" \
        --with-glibc-version=${version_glic} \
        --disable-bootstrap \
        --enable-threads=posix \
        --enable-check=release \
        --enable-languages=c,c++ \
        --disable-multilib \
        --enable-shared \
        --disable-nls \
        --with-gnu-ld \
        --with-gnu-as \
        --with-mode=arm \
        --with-float=hard ||
        exit

    make all-target-libgcc -j "$(nproc)" || exit
    make install-target-libgcc -j "$(nproc)" || exit
    
    popd >>/dev/null || exit
    popd >> /dev/null || exit
    echo -e "end compile gcc second step"
}

# 第二次编译glibc
build_glibc_stage2() {
    echo -e "start compile glibc second step"
    pushd "${BUILD_PATH}"/${dir_glibc} >>/dev/null || exit

    [ -d build_glibc_stage2 ] && rm -rf build_glibc_stage2
    mkdir build_glibc_stage2
    pushd build_glibc_stage2 >>/dev/null || exit
    
    ../configure \
        --prefix="${INSTALL_PATH}/${target}" \
        --host=${target} \
        --target=${target} \
        --build="$(../scripts/config.guess)" \
        --enable-kernel=3.2 \
        --with-headers="${SYSROOT_PATH}"/usr/include \
        --disable-multilib \
        libc_cv_forced_unwind=yes                     \
        libc_cv_ctors_header=yes                      \
        libc_cv_c_cleanup=yes                         \
        with_selinux=no || exit

    make -j "$(nproc)" || exit
    make install -j "$(nproc)" || exit
    
    popd >>/dev/null || exit
    popd >>/dev/null || exit
    echo -e "end compile glibc second step"
}

# 第三次编译gcc
build_gcc_stage3() {
    echo -e "start compile gcc third step"
    
    pushd "${BUILD_PATH}"/${dir_gcc} >>/dev/null || exit

    [ -d build_gcc_stage3 ] && rm -rf build_gcc_stage3
    mkdir build_gcc_stage3
    pushd build_gcc_stage3 >>/dev/null || exit
    ../configure \
        --target=${target} \
        --prefix="${INSTALL_PATH}" \
        --with-sysroot="${SYSROOT_PATH}" \
        --with-glibc-version=${version_glic} \
        --disable-bootstrap \
        --enable-threads=posix \
        --enable-check=release \
        --enable-languages=c,c++ \
        --disable-multilib \
        --enable-shared \
        --disable-nls \
        --with-gnu-ld \
        --with-gnu-as \
        --with-mode=arm \
        --with-float=hard ||
        exit

    make -j "$(nproc)" || exit
    make install -j "$(nproc)" || exit
    
    popd >> /dev/null || exit
    popd >> /dev/null || exit
    echo -e "end compile gcc third step"
}

build_kernel() {
    echo -e "start test compile"
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm CROSS_COMPILE=${target}- distclean || exit
    make ARCH=arm CROSS_COMPILE=${target}- imx_v6_v7_defconfig || exit
    make ARCH=arm CROSS_COMPILE=${target}- -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end test compile"
}

download_resource
prepare_resource
build_binutils
build_kernel_header
build_gcc_stage1
build_glibc_stage1
build_gcc_stage2
build_glibc_stage2
build_gcc_stage3
build_kernel
