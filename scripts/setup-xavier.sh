#!/bin/bash

sudo -v
sudo apt update && sudo apt upgrade -y
sudo apt install -y libopenblas-base libopenblas-dev python3-pip python3-venv python3-dev libpython3-dev gfortran libopenmpi-dev liblapack-dev libatlas-base-dev libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev

TMPDIR=$(mktemp -d)
echo "moving to $TMPDIR"
cd $TMPDIR

pip3 install -U pip

# avoids warnings caused by invoking the pip3 wrapper script
PIP_INSTALL="python3 -m pip install --user"

export OPENBLAS_CORETYPE=ARMV8

${PIP_INSTALL} -U Cython
${PIP_INSTALL} -U protobuf
${PIP_INSTALL} -U numpy pandas "matplotlib==3.3.4" scipy sklearn scikit-image

# install dependencies from source and PyTorch from wheel provided by NVIDIA
${PIP_INSTALL} -U future psutil dataclasses typing-extensions pyyaml tqdm
wget https://nvidia.box.com/shared/static/p57jwntv436lfrd78inwl7iml6p13fzh.whl -O torch-1.8.0-cp36-cp36m-linux_aarch64.whl 
${PIP_INSTALL} torch-1.8.0-cp36-cp36m-linux_aarch64.whl

# check whether everything's good so far
python3 -c 'import torch; assert torch.cuda.is_available()' || { echo "something went wrong when importing torch and checking for cuda"; exit 1; }

# install torchvision from source
${PIP_INSTALL} -U pillow
git clone --branch v0.9.0 https://github.com/pytorch/vision torchvision
cd torchvision
export BUILD_VERSION=0.9.0
python3 setup.py install --user
