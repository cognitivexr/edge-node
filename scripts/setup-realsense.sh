#!/bin/bash

sudo -v
sudo apt update && sudo apt upgrade -y
sudo apt install libssl-dev

# get source code and unpack
TMPDIR=$(mktemp -d)
echo "moving to $TMPDIR"
cd $TMPDIR

wget https://github.com/IntelRealSense/librealsense/archive/refs/tags/v2.48.0.zip
unzip v2.48.0.zip
cd librealsense-2.48.0
mkdir build && cd build

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64
export PATH=$PATH:$CUDA_HOME/bin

cmake ../ -DFORCE_RSUSB_BACKEND=ON -DBUILD_PYTHON_BINDINGS:bool=true -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_BUILD_TYPE=release -DBUILD_EXAMPLES=true -DBUILD_GRAPHICAL_EXAMPLES=true -DBUILD_WITH_CUDA:bool=true

make -j4
sudo make install

# TODO check and put in global path:
echo export PYTHONPATH=/usr/local/lib/python3.6/pyrealsense2 >> ~/.bashrc

sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && udevadm trigger
