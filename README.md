# ForestNav Challenge

In this project for the ForestNav Challenge, we aim to address the data processing and biomass calculation aspects using point-cloud data. This will be achieved through the utilization of software such as CloudCompare, along with Python and R scripts. The goal is to visualize forest biomass quantities via barplot and boxplot graphs.

## 3D Reconstruction

### Challenges with Intel Realsense Camera
- **Field of View (FOV) and Distorted Frames:** Explored 3D reconstruction to combine singular frames into a high-resolution point cloud.

### Liberalsense Kinfu
- **Attempted Implementation:** Faced challenges in operationalizing on Windows through Visual Studio.

### Manual Fusion
- **CloudCompare:** Difficulty in aligning frames accurately.

## Hardware Limitations and Alternatives
- **Intel Realsense Depth Camera:** Lack of positional tracking.
- **Stereolabs ZED Camera:** Better performance with integrated IMU system and compatibility with NVIDIA's Jetson platform.

## Point Cloud Processing

### LiDAR: Point Cloud Segmentation and Subsampling
- **Segmentation:** Divided point cloud into subsets based on tree distribution.
- **Subsampling:** Reduced point density while preserving critical information.

### Stereolabs ZED Data Processing
- **Conversion:** Converted ZED camera data to .txt format for better manipulation.
- **Outlier Removal and Geometry Fixes:** Streamlined data processing and ensured accuracy.

## Biomass Calculation

### DBH Extraction
- **CloudCompare:** Used TREEISO plugin and Cross Section function for tree segmentation and clustering.
- **3DFin (Forest Inventory):** Automatic computation of tree parameters.

### Plant Species Identification
- **Pl@ntNet API:** Identified plant species through image analysis, generating reports with scientific names, common names, and confidence scores.

## Analysis and Visualization
- **R Studio:** Facilitates comprehensive data analysis with standardized data for Italy, providing region-specific biomass calculations.
- **Visual Representations:** Generated bar plots and box plots to aid in data interpretation.

## References
1. Stereolabs ZED Camera
2. CloudCompare TREEISO Plugin
3. 3DFin (Forest Inventory)
4. Pl@ntNet API
5. R Studio
