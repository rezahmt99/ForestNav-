# Data Acquisition Guidelines for ForestNav Challenge

## Objective
The objective of the ForestNav Challenge is to utilize point-cloud data for accurate biomass calculation and visualization. This document outlines guidelines and considerations for data acquisition to ensure effective implementation of the project objectives.

## Selection of Sensors
- **Velodyne Puck Lidar**: Considered for its long range (100~150m) but limited vertical view (30°).
- **Intel Realsense D435 Depth Camera**: Provides a wider view (63.4°) but shorter range (up to 10m max).
- **Challenges**: Lidar's vertical resolution limitations and depth camera's range constraints for distant trees.
- **Proposed Solutions**: Explore rotating Lidar, elevate existing Lidar, or consider alternative sensors like Time of Flight (ToF) cameras.

## 3D Reconstruction
- **Method**: Utilize depth cameras for 3D reconstruction by fusing depth information from multiple frames to create dense point clouds.
- **Objective**: Improve resolution and range of point clouds to enhance accuracy in biomass estimation.

## Sensor Integration
- **Stereolabs ZED Camera**: Identified as an alternative with improved range performance (0.3-20m) and integrated IMU support.
- **Compatibility**: Compatible with NVIDIA Xavier platform, facilitating seamless integration with existing rover setup.

## Data Processing
- **Software Tools**: Utilize CloudCompare, Python, and R scripts for data processing and analysis.
- **Steps**: Include outlier removal, point cloud segmentation, and subsampling to optimize data for biomass calculation.
- **Toolkits**: Leverage specialized plugins and algorithms (e.g., TREEISO plugin, Mean Shift clustering) for accurate tree segmentation and parameter extraction.

## Workflow
- **Integration**: Ensure compatibility and seamless integration of sensor data with processing tools and platforms.
- **Accuracy**: Maintain high standards in data alignment, transformation, and preprocessing for reliable 3D model generation.

## Conclusion
These guidelines provide a structured approach to acquiring and processing point-cloud data for biomass calculation in the ForestNav Challenge. By following these recommendations, the project aims to achieve accurate biomass estimates and meaningful visualization of forest data.

