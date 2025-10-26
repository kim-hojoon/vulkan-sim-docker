#!/bin/zsh

source 003-setup_environment.sh

cd RayTracingInVulkan/build/linux/bin

# A simple scene:
./RayTracer --scene 1 --width 64 --height 64 --samples 1