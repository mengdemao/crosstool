#!/usr/bin/env python3

import toml
import rich
from rich import print

class CompileVersion:
    def __init__(self) -> None:
        version_gcc="12.2.0"
        version_binutil="2.40"
        version_glic="2.37"
        version_linux="4.19.259"
        version_gmp="6.2.1"
        version_mpc="1.2.1"
        version_mpfr="4.1.0"
        version_isl="0.24"
        version_cloog="0.18.1"

    def readConfig(self, configFile='config.toml'):
        '''
        读取配置文件
    	'''
        buildConfig = toml.load(configFile)
        return True

if __name__ == '__main__':
    compileVersion = CompileVersion()
    compileVersion.readConfig('config.toml')
    print("build script start")

