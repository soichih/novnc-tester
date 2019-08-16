#!/bin/bash

echo "this script runs checks on novnc host"

set -e 
set -x

docker run --gpus 1 nvidia/cuda nvidia-smi
lspci | grep -i NVIDIA
nvidia-smi
vglrun glxinfo | grep -i NVIDIA

echo "everything looks good"
