This is a guide on how to install a Python computer vision environment on the Jetson Xavier NX platform.

## Setting up the Jetson Xavier NX

To get started with the hardware, you need to write the Jetson Xavier NX Developer Kit ([JetPack SDK](https://developer.nvidia.com/embedded/jetpack)) onto a fresh microSD card.
Follow [the instructions on the NVIDIA website](https://developer.nvidia.com/embedded/learn/get-started-jetson-xavier-nx-devkit) to install the image.
The JetPack version at the time of writing is 4.5.1.


Using Linux, we can simply run the following command, where `sdX` refers to the SD card.

	unzip -p jetson-nx-jp451-sd-card-image.zip| sudo dd of=/dev/sdX bs=1M status=progress

Insert the SD card, start up the Jetson, and click through the installation procedure.
Then update the system with

	sudo apt update && sudo apt upgrade -y

Reboot and then we'll set up the environment.

## Getting PyTorch to run

We will install several libraries and dependencies to get PyTorch to run.
You can shortcut the entire procedure by downloading and running the following script that we've prepared: [setup-xavier.sh](https://github.com/cognitivexr/edge-node/blob/main/scripts/setup-xavier.sh) or run:

	curl https://raw.githubusercontent.com/cognitivexr/edge-node/main/scripts/setup-xavier.sh | bash

Here is the entire process step by step

### Installing libraries and dependencies

A computer vision pipeline with PyTorch typically has the following requirements

* numpy
* pandas
* scipy
* scikit-image
* matplotlib
* seaborn
* opencv-python
* torch
* torchvision

Getting these libraries to work on an NVIDIA Jetson is not straight forward, since pre-compiled python wheels are not always available for aarch64. `pip install` will trigger a compilation of the libraries, which, in the case of computer vision libaries, often requires lots of dependencies that can be tricky to build correctly on ARM architectures.

Some libraries are pre-installed or have pre-built wheels:
* opencv-python: 4.1.1 is pre-installed for Python 3.6 on JetPack 4.5.1
* torch: 1.8 can be downloaded as a wheel from the [NVIDIA forums](https://forums.developer.nvidia.com/t/pytorch-for-jetson-version-1-8-0-now-available/72048)

Some are pre-installed but outdated and will require updating

* numpy: 1.13 (current 1.19.5)
* matplotlib: (latest usable with Python 3.6 is 3.3.4)
* pandas: 0.22.0 (current 1.1.5)
* scipy: 0.19.1 (current 1.5.4)

#### Install procedure

To simplify things, it makes sense to install the base kit as system-wide packages, and only use virtual environments for additional dependencies. 
Follow the instructions step by step.

Install some build dependencies we'll need

	sudo apt install -y python3-pip python3-venv python3-dev libpython3-dev
	sudo apt install -y libopenblas-base
	sudo apt install -y gfortran libopenmpi-dev liblapack-dev libatlas-base-dev

Install Cython

	pip3 install Cython

Upgrade pip and other python setup tools

	pip3 install --upgrade pip
	pip3 install --upgrade protobuf

Upgrade data science libraries

	pip3 install --upgrade numpy
	pip3 install --upgrade pandas

Upgrade matplotlib to 3.3.4 (matplotlib 3.4 requires python>=3.7)

	pip3 install "matplotlib==3.3.4"

Upgrade scipy (may take quite long)

	pip3 install --upgrade scipy

Install scikit-image (may take quite long)

	pip3 install sklearn scikit-image


Install PyTorch 1.8 from the available wheel

	pip3 install -U future psutil dataclasses typing-extensions pyyaml tqdm seaborn
	wget https://nvidia.box.com/shared/static/p57jwntv436lfrd78inwl7iml6p13fzh.whl -O torch-1.8.0-cp36-cp36m-linux_aarch64.whl 
	pip3 install torch-1.8.0-cp36-cp36m-linux_aarch64.whl

At this point, you can check whether PyTorch detects the CUDA device correctly

	python3 -c 'import torch; print(torch.cuda.is_available())'

should output `True`

If the Python process terminates with `Illegal instruction (core dumped)`, it's likely related to [an issue with numpy 1.19.5 and OpenBLAS](https://github.com/numpy/numpy/issues/18131). Either run `export OPENBLAS_CORETYPE=ARMV8`, set it in your `.bashrc` file, or downgrade to numpy 1.19.4 by running `pip3 install -U "numpy==1.19.4"`.

Install torchvision v0.9.0 (version for torch 1.8)

	sudo apt install libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
	pip3 install --upgrade pillow 
	git clone --branch v0.9.0 https://github.com/pytorch/vision torchvision
	cd torchvision
	export BUILD_VERSION=0.9.0
	python3 setup.py install --user
	cd .. # running torch from torchvision/ will fail

## Testing YOLOv5

You can now test the [pre-trained YOLOv5 from torchhub](https://pytorch.org/hub/ultralytics_yolov5/) using the following commands:

	wget -q https://github.com/pjreddie/darknet/raw/master/data/dog.jpg
	python3 -c "import torch
	import cv2
	model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True).autoshape()
	model = model.cuda()
	img = cv2.cvtColor(cv2.imread('dog.jpg'), cv2.COLOR_BGR2RGB)
	pred = model(img, 320 + 32 * 4)
	for obj in pred.xyxy[0].cpu().numpy():
	    xyxy, conf, label = obj[:4], obj[4], pred.names[int(obj[5])]
	    print(xyxy, '%s (conf=%.2f%%)' % (label, conf*100))"

Where the final output should be something like:

	[     130.96      220.09      311.58      538.49] dog (conf=87.70%)
	[     126.34      133.22      565.66      423.71] bicycle (conf=82.05%)
	[     467.74      76.326      692.75      171.35] car (conf=56.09%)
	[     466.57      77.787      692.83      175.51] truck (conf=52.34%)


## Using virtual environments

The libraries and PyTorch are now installed as system-wide packages. To create a virtual environment that includes these packages, run

	python3 -m venv --system-site-packages .venv

After activating with `source .venv/bin/activate`, you can install dependencies using

	pip install -I

Where `-I` is the shorthand for `--ignore-installed`.
