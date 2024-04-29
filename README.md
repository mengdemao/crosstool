# crosstool

交叉工具链构建

## 构建方法

加载docker
```shell
docker run --name build-crosstool -v ${ROOT_PATH}:/crosstool --rm -it mengdemao/docker-crosstool /bin/bash
```

```shell
# 下载编译器源码并且执行预编译
./scripts/prepare.sh

# 执行构建
./build.sh --arch=arm --target=arm-linux-gnueabi
./build.sh --arch=arm --target=arm-linux-gnueabihf
./build.sh --arch=aarch64 --target=aarch64-linux-gnueabi
./build.sh --arch=aarch64 --target=aarch64-linux-gnueabihf
```

编译结果自动生成到install目录下面

## 设置全局变量

```shell
# 目标设置
target=arm-linux-gnueabihf
target=arm-linux-gnueabi
target=aarch64-linux-gnueabihf
target=aarch64-linux-gnueabi
```

## 构建分析

### sysroot

> gcc编译器寻找库文件与头文件的地址

[sysroot概念](https://gcc.gnu.org/onlinedocs/gcc/Directory-Options.html#index-isysroot)

目前编译器将其安排到`[编译器根目录]/target`

### fakeroot

> fakeroot设置一种可以运行假的root权限的环境






