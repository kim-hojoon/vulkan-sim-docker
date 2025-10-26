FROM ubuntu:20.04

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================
# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Set CUDA path (Embree path will be set at runtime from mounted directory)
ENV CUDA_INSTALL_PATH=/usr/local/cuda-11.7
ENV PATH=/usr/local/cuda-11.7/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64:${LD_LIBRARY_PATH:-}

# ============================================================================
# INSTALL VULKAN-SIM REQUIRED DEPENDENCIES (from vulkan-sim README)
# ============================================================================
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    ninja-build \
    meson \
    libboost-all-dev \
    xutils-dev \
    bison \
    zlib1g-dev \
    flex \
    libglu1-mesa-dev \
    libxi-dev \
    libxmu-dev \
    libdrm-dev \
    llvm \
    libelf-dev \
    libwayland-dev \
    wayland-protocols \
    libwayland-egl-backend-dev \
    libxcb-glx0-dev \
    libxcb-shm0-dev \
    libx11-xcb-dev \
    libxcb-dri2-0-dev \
    libxcb-dri3-dev \
    libxcb-present-dev \
    libxshmfence-dev \
    libxxf86vm-dev \
    libxrandr-dev \
    libglm-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL ADDITIONAL DEPENDENCIES (fixes for build issues we encountered)
# ============================================================================
RUN apt-get update && apt-get install -y \
    # Required for downloading and basic operations
    wget \
    ca-certificates \
    # pkg-config: Required for Mesa build (meson couldn't find dependencies without it)
    pkg-config \
    # Python tools for Mesa and utilities
    python3 \
    python3-pip \
    python3-venv \
    # python3-mako: Required by Mesa build system
    python3-mako \
    # libzstd-dev: Optional but recommended for Mesa
    libzstd-dev \
    # libexpat1-dev: Required by Mesa
    libexpat1-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL LUMIBENCH DEPENDENCIES (vcpkg requirements for RayTracingInVulkan)
# ============================================================================
RUN apt-get update && apt-get install -y \
    # vcpkg bootstrap dependencies
    zip \
    unzip \
    tar \
    curl \
    # CMake and build tools for LumiBench
    cmake \
    # Additional X11 dependencies for RayTracingInVulkan
    libxinerama-dev \
    libxcursor-dev \
    xorg-dev \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# UPGRADE MESON (Ubuntu 20.04 provides 0.53, but Mesa requires >= 0.60)
# ============================================================================
RUN apt-get remove -y meson && \
    pip3 install meson==1.3.0

# ============================================================================
# INSTALL GCC-9 AND G++-9 (Required by vulkan-sim)
# ============================================================================
RUN apt-get update && apt-get install -y \
    gcc-9 \
    g++-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90 \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL CUDA 11.7 TOOLKIT
# ============================================================================
# CUDA 11.7 is compatible with Ubuntu 20.04 and provides CUDA 11 support
RUN wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run && \
    sh cuda_11.7.0_515.43.04_linux.run --silent --toolkit && \
    rm cuda_11.7.0_515.43.04_linux.run

# ============================================================================
# INSTALL VULKAN SDK (via tarball, following system directory structure)
# ============================================================================
# Using LunarG tarball but installing to system paths like apt does
ARG VULKAN_SDK_VER=1.4.328.1
WORKDIR /tmp
RUN wget -q https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VER}/linux/vulkansdk-linux-x86_64-${VULKAN_SDK_VER}.tar.xz && \
    tar -xJf vulkansdk-linux-x86_64-${VULKAN_SDK_VER}.tar.xz && \
    rm vulkansdk-linux-x86_64-${VULKAN_SDK_VER}.tar.xz

# Install to system directories (mimicking apt installation)
RUN cd ${VULKAN_SDK_VER}/x86_64 && \
    # Install binaries to /usr/bin
    cp -r bin/* /usr/bin/ && \
    # Install libraries to /usr/lib
    cp -r lib/* /usr/lib/x86_64-linux-gnu/ && \
    # Install headers to /usr/include
    cp -r include/* /usr/include/ && \
    # Install layer configs and ICDs
    mkdir -p /usr/share/vulkan && \
    cp -r share/vulkan/* /usr/share/vulkan/ && \
    # Cleanup
    cd /tmp && rm -rf ${VULKAN_SDK_VER}

# Set Vulkan environment variables (matching apt behavior)
ENV VK_LAYER_PATH=/usr/share/vulkan/explicit_layer.d

# ============================================================================
# INSTALL UTILITIES
# ============================================================================
RUN apt-get update && apt-get install -y \
    zsh \
    vim \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# NOTE: Embree is NOT installed in the Docker image
# It will be installed on the host and mounted
# ============================================================================

# ============================================================================
# SET UP WORKSPACE
# ============================================================================
WORKDIR /workspace
