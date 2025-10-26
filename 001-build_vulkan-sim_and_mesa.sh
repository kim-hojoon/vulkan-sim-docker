#!/bin/zsh

# 1. Set environment variables
export CUDA_INSTALL_PATH=/usr/local/cuda-11.7
source embree-3.13.5.x86_64.linux/embree-vars.sh

# 2. Build Vulkan-Sim and Mesa
cd vulkan-sim/
source setup_environment

cd ../mesa-vulkan-sim/
meson --prefix="${PWD}/lib" build -Dvulkan-drivers=swrast -Dgallium-drivers=swrast -Dplatforms=x11 -D b_lundef=false -D buildtype=debug
# This compilation produces files necessary to Vulkan-Sim but is expected to fail.
ninja -C build/ install 

export VK_ICD_FILENAMES=${PWD}/lib/share/vulkan/icd.d/lvp_icd.x86_64.json
cd ../vulkan-sim/
make -j

cd ../mesa-vulkan-sim/
# This compilation is expected to succeed.
ninja -C build/ install