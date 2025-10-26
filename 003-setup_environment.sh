#!/bin/zsh

WORKSPACE=/workspace

export CUDA_INSTALL_PATH=/usr/local/cuda-11.7
source ${WORKSPACE}/embree-3.13.5.x86_64.linux/embree-vars.sh
export VK_ICD_FILENAMES=${WORKSPACE}/mesa-vulkan-sim/lib/share/vulkan/icd.d/lvp_icd.x86_64.json

export GPGPUSIM_ROOT=${WORKSPACE}/vulkan-sim/
export MESA_ROOT=${WORKSPACE}/mesa-vulkan-sim/

# Add to LD_LIBRARY_PATH only if not already present
VULKAN_SIM_LIB="${GPGPUSIM_ROOT}lib/gcc-9.4.0/cuda-11070/release"
[[ ":$LD_LIBRARY_PATH:" != *":$VULKAN_SIM_LIB:"* ]] && export LD_LIBRARY_PATH=${VULKAN_SIM_LIB}:${LD_LIBRARY_PATH}

MESA_LIB="${MESA_ROOT}lib/lib/x86_64-linux-gnu"
[[ ":$LD_LIBRARY_PATH:" != *":$MESA_LIB:"* ]] && export LD_LIBRARY_PATH=${MESA_LIB}:${LD_LIBRARY_PATH}

echo "Environment configured:"
echo "  CUDA_INSTALL_PATH: $CUDA_INSTALL_PATH"
echo "  GPGPUSIM_ROOT: $GPGPUSIM_ROOT"
echo "  MESA_ROOT: $MESA_ROOT"
echo "  VK_ICD_FILENAMES: $VK_ICD_FILENAMES"
echo "  LD_LIBRARY_PATH: $LD_LIBRARY_PATH"