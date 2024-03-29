# crosstool

交叉工具链构建

## 构建方法

加载docker
```shell
docker run --name build-crosstool -v ${ROOT_PATH}:/crosstool --rm -it mengdemao/docker-crosstool /bin/bash
```

```shell
# 下载GCC源码
bash ./scripts/download.sh


# 执行构建
./build.sh --arch=arm --target=arm-linux-gnueabi
./build.sh --arch=arm --target=arm-linux-gnueabihf
./build.sh --arch=aarch64 --target=aarch64-linux-gnueabi
./build.sh --arch=aarch64 --target=aarch64-linux-gnueabihf
```

## 设置全局变量

```shell
# 目标设置
target=arm-linux-gnueabihf
target=arm-linux-gnueabi
target=aarch64-linux-gnueabihf
target=aarch64-linux-gnueabi
```

```shell
# 目录设置
ROOT_PATH=$(pwd)
export BUILD_PATH=${ROOT_PATH}/build
export TARBALL_PATH=${ROOT_PATH}/tarball
export PATCHES_PATH=${ROOT_PATH}/patches
export INSTALL_PATH=${ROOT_PATH}/gcc-${target}
export SYSROOT_PATH=${INSTALL_PATH}/${target}/sysroot
```

```shell
# 目录设置与文件下载
version_compile=1.0
version_gcc=12.2.0
version_gdb=13.1.0
version_binutil=2.40
version_glic=2.37
version_linux=4.19.276
version_gmp=6.2.1
version_mpc=1.2.1
version_mpfr=4.1.0
version_isl=0.24
version_cloog=0.18.1

dir_gcc=gcc-${version_gcc}
dir_gdb=gcc-${version_gdb}
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
        wget https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/${dir_gdb}/${file_gdb}
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
```

## binutil编译

```shell
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

    make -j "$(nproc)" || exit
    make install || exit

    popd >>/dev/null || exit
    popd >>/dev/null || exit
    echo -e "end compile binutils"
}
```

## Linux内核头文件

```shell
# 编译内核头文件
build_kernel_header()
{
    echo -e "start compile linux kernel header"
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm INSTALL_HDR_PATH="${SYSROOT_PATH}/usr" headers_install || exit
    popd >>/dev/null || exit
    echo -e "end compile linux kernel header"
}
```

## gcc第一次编译

```diff
diff -urN gcc-12.2.0-diff/libsanitizer/asan/asan_linux.cpp gcc-12.2.0/libsanitizer/asan/asan_linux.cpp
--- gcc-12.2.0-diff/libsanitizer/asan/asan_linux.cpp	2022-09-21 22:59:44.758432852 +0800
+++ gcc-12.2.0/libsanitizer/asan/asan_linux.cpp	2022-09-21 22:58:51.075097959 +0800
@@ -65,6 +65,10 @@
 #define ucontext_t xucontext_t
 #endif

+#ifndef PATH_MAX
+#define PATH_MAX 4096
+#endif
+
 typedef enum {
   ASAN_RT_VERSION_UNDEFINED = 0,
   ASAN_RT_VERSION_DYNAMIC,
```

```shell
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
```

## glibc第一次编译

```shell
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
```

## gcc第二次编译

```shell
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
```

## glibc第二次编译

```shell
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
```

## gcc第三次编译

```shell
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
```

## 编译gdb

```shell
build_gdb() {
    echo -e "start build gdb"
    pushd "${ROOT_PATH}"/${dir_gdb} >>/dev/null || exit
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
    make "-j$(nproc)"
    make install
    popd >> /dev/null || exit
    popd >>/dev/null || exit
    echo -e "end build gdb"
}
```

## 编译器测试

```shell
build_kernel() {
    echo -e "start test compile"
    pushd "${BUILD_PATH}"/${dir_linux} >>/dev/null || exit
    make ARCH=arm CROSS_COMPILE=${target}- distclean || exit
    make ARCH=arm CROSS_COMPILE=${target}- imx_v6_v7_defconfig || exit
    make ARCH=arm CROSS_COMPILE=${target}- -j "$(nproc)" || exit
    popd >>/dev/null || exit
    echo -e "end test compile"
}

build_program() {
    echo -e "start test compile"
    pushd "${ROOT_PATH}"/${dir_test} >>/dev/null || exit
	${INSTALL_PATH}/bin/${target}-gcc -static test.c -o test.elf
	qemu-arm test.elf
    popd >>/dev/null || exit
    echo -e "end test compile"
}
```

