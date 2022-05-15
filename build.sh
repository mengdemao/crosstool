#!/bin/bash

root_path=$(pwd)
target=arm-linux-gnueabi

object_dir=${root_path}/object

target_dir=${root_path}/${target}

dir_gmp=gmp-6.2.1
file_gmp=gmp-6.2.1.tar.xz

dir_mpc=mpc-1.2.1
file_mpc=mpc-1.2.1.tar.gz

dir_mpfr=mpfr-4.1.0
file_mpfr=mpfr-4.1.0.tar.xz

dir_isl=isl-0.24
file_isl=isl-0.24.tar.xz

dir_cloog=cloog-0.18.1
file_cloog=cloog-0.18.1.tar.gz

dir_gcc=gcc-7.5.0
file_gcc=${dir_gcc}.tar.xz

dir_binutils=binutils-2.38
file_binutils=binutils-2.38.tar.xz

dir_linux=linux-4.19.229
file_linux=linux-4.19.229.tar.xz

dir_glibc=glibc-2.35
file_glibc=glibc-2.35.tar.xz

# 创建临时文件夹
if [ -d ${object_dir} ]; then
    rm -rf ${object_dir}
fi
mkdir -p ${object_dir}

if [ ! -f ${file_binutils} ]; then 
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
if [ -d ${target_dir} ]; then
    rm -rf ${target_dir}
fi
mkdir -p ${target_dir}

# 解压binutils
echo -e "start uncompress ${file_binutils} to ${object_dir}\n"
tar -vxf ${file_binutils} -C ${object_dir}
echo -e "end uncompress ${file_binutils} to ${object_dir}\n"

# 解压gcc
echo -e "start uncompress ${file_gcc} to ${object_dir}\n"
tar -vxf ${file_gcc} -C ${object_dir}
echo -e "end uncompress ${file_gcc} to ${object_dir}\n"

# 解压gmp
echo -e "start uncompress ${file_gmp} to ${object_dir}\n"
tar -vxf ${file_gmp} -C ${object_dir}
echo -e "end uncompress ${file_gmp} to ${object_gmp}\n"

# 解压mpc
echo -e "start uncompress ${file_mpc} to ${object_dir}\n"
tar -vxf ${file_mpc} -C ${object_dir}
echo -e "end uncompress ${file_mpc} to ${object_dir}\n"

# 解压mpfr
echo -e "start uncompress ${file_mpfr} to ${object_dir}\n"
tar -vxf ${file_mpfr} -C ${object_dir}
echo -e "end uncompress ${file_mpfr} to ${object_dir}\n"

# 解压isl
echo -e "start uncompress ${file_isl} to ${object_dir}\n"
tar -vxf ${file_isl} -C ${object_dir}
echo -e "end uncompress ${file_isl} to ${object_dir}\n"

# 解压isl
echo -e "start uncompress ${file_cloog} to ${object_dir}\n"
tar -vxf ${file_cloog} -C ${object_dir}
echo -e "end uncompress ${file_cloog} to ${object_dir}\n"

# 解压mpfr
echo -e "start uncompress ${file_cloog} to ${object_dir}\n"
tar -vxf ${file_cloog} -C ${object_dir}
echo -e "end uncompress ${file_cloog} to ${object_dir}\n"

# 创建链接
ln -s ${object_dir}/${dir_isl}      ${object_dir}/${dir_gcc}/isl 
ln -s ${object_dir}/${dir_gmp}      ${object_dir}/${dir_gcc}/gmp 
ln -s ${object_dir}/${dir_mpc}      ${object_dir}/${dir_gcc}/mpc 
ln -s ${object_dir}/${dir_mpfr}     ${object_dir}/${dir_gcc}/mpfr 
ln -s ${object_dir}/${dir_cloog}    ${object_dir}/${dir_gcc}/cloog 

# 解压头文件
echo -e "start uncompress ${file_linux} to ${object_dir}\n"
tar -vxf ${file_linux} -C ${object_dir}
echo -e "end uncompress ${file_linux} to ${object_dir}\n"

# 解压头文件
echo -e "start uncompress ${file_glibc} to ${object_dir}\n"
tar -vxf ${file_glibc} -C ${object_dir}
echo -e "end uncompress ${file_glibc} to ${object_dir}\n"

# 编译binutils第一遍
echo -e "start compile binutils"
pushd ${object_dir}/${dir_binutils} >> /dev/null
mkdir build 
pushd build

../configure \
    --prefix=${target_dir} \
    --target=${target} \
    --disable-werror \
    --enable-lto
    --disable-gdb \
    --disable-nls \
    --enable-gold \
    --enable-plugins \
    --enable-relro \
    --with-sysroot

make -j `nproc`
make install

popd >> /dev/null
popd >> /dev/null
echo -e "end compile binutils"

# 编译内核头文件
echo -e "start compile linux kernel header"
pushd ${object_dir}/${dir_linux} >> /dev/null
make ARCH=arm INSTALL_HDR_PATH=${target_dir}/${target} headers_install
popd >> /dev/null
echo -e "end compile linux kernel header"

# 第一次编译gcc
echo -e "start compile gcc first step"
pushd ${object_dir}/${dir_gcc} >> /dev/null
mkdir build
pushd build >> /dev/null
../configure                                       \
    --target=${target}                             \
    --prefix=${target_dir}                         \
    --with-glibc-version=2.35                      \
    --enable-languages=c,c++ 

make all-gcc -j `nproc`
make install-gcc -j `nproc`
popd >> /dev/null
popd >> /dev/null
echo -e "end compile gcc first step"

# 第一次编译glibc
echo -e "start compile glibc"
pushd ${object_dir}/${dir_glibc} >> /dev/null
mkdir build
pushd build >> /dev/null
../configure \
    --prefix=${target_dir} \
    --build=${MACHTYPE}
    --host=${target} \
    --build=$(../scripts/config.guess) \
    --enable-kernel=3.2 \
    --with-headers=${target_dir}/${target}/include \
    libc_cv_forced_unwind=yes  \
    with_selinux=no
make -j `nproc`
make install-bootstrap-headers=yes install-headers

popd >> /dev/null
popd >> /dev/null
echo -e "end compile glibc"

# 第二次编译gcc
echo -e "start compile gcc second step"
pushd ${object_dir}/${dir_gcc}/build >> /dev/null
make all-target-libgcc -j `nproc`
make install-target-libgcc -j `nproc`
popd >> /dev/null
echo -e "end compile gcc second step"

# 第二次编译glibc
echo -e "start compile glibc second step"
pushd ${object_dir}/${dir_glibc}/build >> /dev/null
make -j `nproc`
make install -j `nproc`
popd >> /dev/null
echo -e "end compile glibc second step"

# 第三次编译gcc
echo -e "start compile gcc third step"
pushd ${object_dir}/${dir_gcc}/build >> /dev/null
make  -j `nproc`
make install -j `nproc`
popd >> /dev/null
echo -e "end compile gcc third step"

echo -e "start test compile"
pushd ${object_dir}/${dir_gcc} >> /dev/null
make ARCH=arm CROSS_COMPILE=arm-linux-eabi- imx_v6_v7_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-eabi- -j `nproc`
popd >> /dev/null
echo -e "end test compile"