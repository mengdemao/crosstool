#!/bin/bash
# shellcheck disable=SC2086
# shellcheck disable=SC1091
# shellcheck disable=SC2154
# shellcheck disable=SC2199
# shellcheck disable=SC2181

#   _____  _____    ____    _____  _____  _______  ____    ____   _
#  / ____||  __ \  / __ \  / ____|/ ____||__   __|/ __ \  / __ \ | |
# | |     | |__) || |  | || (___ | (___     | |  | |  | || |  | || |
# | |     |  _  / | |  | | \___ \ \___ \    | |  | |  | || |  | || |
# | |____ | | \ \ | |__| | ____) |____) |   | |  | |__| || |__| || |____
#  \_____||_|  \_\ \____/ |_____/|_____/    |_|   \____/  \____/ |______|


export CI_ENV=true

export CFLAGS="-w"
export CXXFLAGS="-w"

./scripts/download.sh

./build.sh --arch=arm   --target=arm-linux-gnueabi 
./build.sh --arch=arm   --target=arm-linux-gnueabihf 
./build.sh --arch=arm64 --target=aarch64-linux-gnueabi 
./build.sh --arch=arm64 --target=aarch64-linux-gnueabihf