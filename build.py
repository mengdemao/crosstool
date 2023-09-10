#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
build.py
~~~~~~~~~~~~

build crosstool script

:copyright: (c) 2023 by Meng Demao.
:license:  GPL-2.0 license, see LICENSE for more details.
"""

import os
import rtoml
import requests
import wget
import tarfile
import time
import threadpool
import multiprocessing
from multiprocessing import Pool
from lxml import etree

def download_file(url, dst_path):
    """
    下载文件
    """
    system_command = f'wget -nv -P {dst_path} {url}'
    print(system_command)
    #os.system(system_command)

def extract_file(file, src_path, dst_path):
    """
    解压文件
    """
    system_command = f'tar -xf {src_path}/{file}.* -C ${dst_path}'
    print(system_command)
   #os.system(system_command)

def process_worker(var):
    """
    下载url的文件到`os.environ['TARBALL_PATH']`
    """
    url = var[0]
    pkg = var[1]

    tarball_path = os.environ['TARBALL_PATH']
    objects_path = os.environ['OBJECTS_PATH']

    download_file(url, tarball_path)
    extract_file(pkg, tarball_path, objects_path)

class CrosstoolConfig:
    """
    交叉编译器配置设置
    """
    def __init__(self) -> None:
        version = {
         'gcc': '12.2.0',
         'binutils': '2.40',
         'glibc': '2.37',
         'linux': '6.1.27',
         'gmp': '6.2.1',
         'mpc': '1.3.1',
         'mpfr': '4.2.0',
         'isl': '0.26'
        }

        address = {}

        pkg_urls = {}
        pkg_name = {}
        pkg_file = {}

        self.package = {"version" : version, "address" : address, "pkg_urls" : pkg_urls, "pkg_name" : pkg_name, "pkg_file" : pkg_file}

        # 工具链版本号
        self.version = {'major' : '0', 'minor' : '0'}

        # 工具链目标
        self.toolchain = {}

        # 编译环境的工作目录
        self.environ = {
            'PROJECT_PATH' : '', # 工程目录
            'OBJECTS_PATH' : '', # 临时文件
            'TARBALL_PATH' : '', # 下载文件
            'PATCHES_PATH' : '', # 补丁文件
            'SCRIPTS_PATH' : '', # 脚本文件
            'OUTPUTS_PATH' : '', # 输出文件
        }

        tmp_project_path = os.popen("git rev-parse --show-toplevel").read()
        tmp_project_path = tmp_project_path.replace("\r", "").replace("\n", "")
        self.environ['PROJECT_PATH'] = tmp_project_path
        self.environ['OBJECTS_PATH'] = self.environ['PROJECT_PATH'] + '/objects'
        self.environ['TARBALL_PATH'] = self.environ['PROJECT_PATH'] + '/tarball'
        self.environ['PATCHES_PATH'] = self.environ['PROJECT_PATH'] + '/patches'
        self.environ['SCRIPTS_PATH'] = self.environ['PROJECT_PATH'] + '/scripts'
        self.environ['OUTPUTS_PATH'] = self.environ['PROJECT_PATH'] + '/outputs'

        # 设置环境变量
        for key, env in self.environ.items():
            os.environ[key] = env

        # 创建三个临时文件夹
        if not os.path.exists(self.environ['OBJECTS_PATH']):
            os.mkdir(self.environ['OBJECTS_PATH'])

        if not os.path.exists(self.environ['TARBALL_PATH']):
            os.mkdir(self.environ['TARBALL_PATH'])

        if not os.path.exists(self.environ['OUTPUTS_PATH']):
            os.mkdir(self.environ['OUTPUTS_PATH'])

    def config(self):
        '''
        读取配置文件
    	'''

        config_file_name = "config.toml"

        # 加载配置文件
        with open(config_file_name, encoding="utf-8") as config_file:
            config_file_content = config_file.read()

        # 加载toml
        config_file_object = rtoml.load(config_file_content)

        # 加载工具链版本号
        self.version = config_file_object['crosstool']['version']
        if self.version['major'] == '0':
            pass

        if self.version['minor'] == '0':
            pass

        # 加载crosstool生成目标
        self.toolchain = config_file_object['crosstool']['toolchain']

        # 加载源码包
        self.package['version'] = config_file_object['package']['version']
        self.package["address"] = config_file_object['package']['address']

        return True

    def __str__(self) -> str:
        print_string =   "crosstool package\r\n" + \
                         "| packages |  version  | \r\n" + \
                         "| -------- | --------- | \r\n" + \
                        f"| gcc      | {self.package['version']['gcc']} | \r\n" + \
                        f"| binutils | {self.package['version']['binutils']} | \r\n" + \
                        f"| glibc    | {self.package['version']['glibc']} | \r\n" + \
                        f"| linux    | {self.package['version']['linux']} | \r\n" + \
                        f"| gmp      | {self.package['version']['gmp']} | \r\n" + \
                        f"| mpc      | {self.package['version']['mpc']} | \r\n" + \
                        f"| mpfr     | {self.package['version']['mpfr']} | \r\n" + \
                        f"| isl      | {self.package['version']['isl']}  | \r\n"

        return print_string

    def calibrate(self) -> None:
        """
        探测配置是否正确
        """
        address_gnu_text = requests.get(self.package['address']['prime']['gnu'], timeout = 10)
        print(address_gnu_text.content)

    def prepare(self) -> None:
        """
        下载源码
        """
        if True:
            dep_adr_gnu = self.package['address']['prime']['gnu']
            dep_adr_linux = self.package['address']['prime']['linux']
            dep_adr_isl = self.package['address']['prime']['isl']
        else:
            dep_adr_gnu = self.package['address']['proxy']['gnu']
            dep_adr_linux = self.package['address']['proxy']['linux']
            dep_adr_isl = self.package['address']['proxy']['isl']

        # 定义一个下载地址的URL列表
        process_list = []
        pkg_list = []
        url_list = []
        for pkg, ver in self.package['version'].items():
            pkg_list.append(pkg + '-' + str(ver))

            if pkg == 'isl':
                # https://libisl.sourceforge.io/isl-0.26.tar.xz
                url_list.append(dep_adr_isl + '/isl' + '-' + str(ver) + '.tar.bz2')
            elif pkg == 'linux':
                # https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.1.27.tar.xz
                url_list.append(dep_adr_linux + '/kernel' + '/v6.x' + '/linux' + '-' + str(ver) + '.tar.xz')
            elif pkg == "gcc":
                # https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
                url_list.append(dep_adr_gnu + '/gnu' + '/' + pkg + '/' + pkg + '-' + str(ver) + '/' + pkg + '-' + str(ver) + '.tar.gz')
            elif pkg == "mpc":
                # https://mirrors.tuna.tsinghua.edu.cn/gnu/mpc/mpc-1.3.1.tar.gz
                url_list.append(dep_adr_gnu + '/gnu' + '/' + pkg + '/' + pkg + '-' + str(ver) + '.tar.gz')
            else:
                url_list.append(dep_adr_gnu + '/gnu' + '/' + pkg + '/' + pkg + '-' + str(ver) + '.tar.xz')

        # 定义下载线程池
        process_thread_pool = Pool(os.cpu_count())
        process_list = zip(url_list, pkg_list)

        assert process_thread_pool.map_async(process_worker, process_list)
        process_thread_pool.close()
        process_thread_pool.join()

if __name__ == '__main__':

    # 初始化编译器配置
    crosstool_config = CrosstoolConfig()

    # 加载配置文件
    crosstool_config.config()

    # 探测配置是否正确
    crosstool_config.calibrate()

    # 准备源码
    crosstool_config.prepare()
