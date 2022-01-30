# edge-node

Documentation and setup scripts for edge nodes

## Schematic

<p align="center">
  <img src="https://raw.githubusercontent.com/cognitivexr/edge-node/master/images/edge-node-components.jpg" alt="Edge Node Prototype Components">
</p>

### Hardware

* [NVIDIA Jetson Xavier NX](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-xavier-nx/)
  
  One is used for CogStream and serving Engines.
  One is connected to the camera and serves CPOP.

* [Intel RealSense D455](https://www.intelrealsense.com/depth-camera-d455/)

  Used to get reliable depth information for CPOP, however any webcam will do.
  Depth estimation can either work based on the assumption that objects are on the ground plane, or using deep learning-based depth detection (still experimental).

* [Ubiquiti airCube](https://www.ui.com/accessories/aircube/)

  Used to expose the edge node via WiFi and let devices connect.

## Installation instructions

* [Setup dependencies for running CPOP and CogStream on the Xavier Nodes](tutorials/pytorch-yolo-xavier.md)
* [Setup dependencies for Intel RealSense Depth Camera](tutorials/realsense-xavier.md)
