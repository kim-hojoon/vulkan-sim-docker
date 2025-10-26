#!/bin/zsh

cd RayTracingInVulkan/
./vcpkg_linux.sh
./build_linux.sh

cp ../vulkan-sim/configs/tested-cfgs/SM75_RTX2060/* build/linux/bin/.