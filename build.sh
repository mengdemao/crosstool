#!/bin/bash

# 目标设置
# arm   arm-linux-gnueabi
# arm   arm-linux-gnueabihf
# arm64 aarch64-linux-gnueabi
# arm64 aarch64-linux-gnueabihf

# target=aarch64-linux-gnueabi
# arch=arm64

# target=aarch64-linux-gnueabihf
# arch=arm64

# target=arm-linux-gnueabihf
# arch=arm

target=arm-linux-gnueabi
arch=arm

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
dir_test=test

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

# 创建临时文件夹
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
    tar -vxf "${TARBALL_PATH}"/${file_binutils} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_binutils} to ${BUILD_PATH}\n"

    # 解压gcc
    echo -e "start uncompress ${file_gcc} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_gcc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_gcc} to ${BUILD_PATH}\n"

    # 打入补丁
    pushd "${BUILD_PATH}/${dir_gcc}" >> /dev/null || exit
    patch -p1 < "${PATCHES_PATH}"/gcc/${version_gcc}/fix_error.patch
    popd >> /dev/null || exit

    echo -e "start uncompress ${file_gmp} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_gmp} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_gmp} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_mpfr} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_mpfr} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_mpfr} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_mpc} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_mpc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_mpc} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_isl} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_isl} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_isl} to ${BUILD_PATH}\n"

    echo -e "start uncompress ${file_cloog} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_cloog} -C "${BUILD_PATH}"
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
    tar -vxf "${TARBALL_PATH}"/${file_linux} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_linux} to ${BUILD_PATH}\n"

    # 解压glibc
    echo -e "start uncompress ${file_glibc} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_glibc} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_glibc} to ${BUILD_PATH}\n"

    # 解压glibc
    echo -e "start uncompress ${file_gdb} to ${BUILD_PATH}\n"
    tar -vxf "${TARBALL_PATH}"/${file_gdb} -C "${BUILD_PATH}"
    echo -e "end uncompress ${file_gdb} to ${BUILD_PATH}\n"
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
        --with-pkgversion="Fly Box ${version_compile}" \
        --disable-werror \
        --disable-multilib \
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
        || exit

    make -j "${NJOBS}" || exit
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
    make ARCH=${arch} INSTALL_HDR_PATH="${SYSROOT_PATH}/usr" headers_install || exit
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
        --with-system-zlib \
        --disable-bootstrap \
        --enable-threads=posix \
        --enable-check=release \
        --enable-languages=c,c++ \
        --disable-multilib \
        --without-headers \
        --with-gnu-ld \
        --with-gnu-as ||
        exit

    make all-gcc -j "${NJOBS}" || exit
    make install-gcc -j "${NJOBS}" || exit

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
    make -j"${NJOBS}" csu/subdir_lib
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
        --with-gnu-as ||
        exit

    make all-target-libgcc -j "${NJOBS}" || exit
    make install-target-libgcc -j "${NJOBS}" || exit

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

    make -j "${NJOBS}" || exit
    make install -j "${NJOBS}" || exit

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
        --with-gnu-as ||
        exit

    make -j "${NJOBS}" || exit
    make install -j "${NJOBS}" || exit

    popd >> /dev/null || exit
    popd >> /dev/null || exit
    echo -e "end compile gcc third step"
}

build_gdb() {
    echo -e "start build gdb"
    pushd "${BUILD_PATH}"/${dir_gdb} >>/dev/null || exit
    mkdir build && pushd build >> /dev/null || exit
    ../configure \
        --enable-targets=${target} \
        --prefix="${INSTALL_PATH}" \
        --enable-languages=all \
        --disable-multilib \
        --enable-interwork \
        --with-system-readline \
        --disable-nls \
        --with-python=/usr/bin/python \
        --with-system-gdbinit=/etc/gdb/gdbinit
    make "-j ${NJOBS}"
    make install
    popd >> /dev/null || exit
    popd >>/dev/null || exit
    echo -e "end build gdb"
}

build_arm32_kernel() {
    echo -e "start test compile"
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm CROSS_COMPILE=${target}- distclean || exit
    make ARCH=arm CROSS_COMPILE=${target}- imx_v6_v7_defconfig || exit
    make ARCH=arm CROSS_COMPILE=${target}- -j "${NJOBS}" || exit
    popd >>/dev/null || exit
    echo -e "end test compile"
}

build_arm64_kernel() {
    echo -e "start test compile"
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm64 CROSS_COMPILE=${target}- distclean || exit
    make ARCH=arm64 CROSS_COMPILE=${target}- defconfig || exit
    make ARCH=arm64 CROSS_COMPILE=${target}- -j "${NJOBS}" || exit
    popd >>/dev/null || exit
    echo -e "end test compile"
}

build_kernel()
{
    if [ ${arch} = arm ]; then
        build_arm32_kernel
    else
        build_arm64_kernel
    fi
}

build_program() {
    echo -e "start test compile"
    pushd "${ROOT_PATH}"/${dir_test} >>/dev/null || exit
	${target}-gcc -static test.c -o test.elf
    if [ ${arch} = arm ]; then
	    qemu-arm test.elf
    else
        qemu-aarch64 test.elf
    fi
    popd >> /dev/null || exit
    echo -e "end test compile"
}

# download_resource
prepare_resource
build_binutils
build_kernel_header
build_gcc_stage1
build_glibc_stage1
build_gcc_stage2
build_glibc_stage2
build_gcc_stage3
build_gdb
build_kernel
build_program