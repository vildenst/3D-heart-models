# Pipeline for generating personalized finite element heart models #

The pipeline is currently adjusted to work on [Abel](http://www.uio.no/english/services/it/research/hpc/abel/), a computer cluster with Linux OS. 
Clone and access this repository from a suitable location by the following commands:
1. ```$git clone https://github.com/vildenst/3D-heart-models.git```.
2. ```$cd 3D-heart-models```.

## Step 1: Software requirements ##
* [vtk](http://www.vtk.org) version 8.0.0, [itk](https://itk.org) (must be built with Module_ITKVtkGlue=ON) version 4.12.0, [gmsh](http://gmsh.info) version 2.13.1, matlab version 2017A, python version 2.7.10 including numpy, scipy and matplotlib. **software.sh** will install them for you if you don't have them.
* Run **software.sh** to create and build some necessary folders and programs: ```$sh software.sh```.

## Step 2: Segmentation ##
* Segmentation of MRI images is preferably performed using [Segment](http://medviso.com/download2/). 
* All files produced from Segment (.mat format) should be saved in the **seg** folder created from **software.sh**. It is important that the different .mat files are saved as **Patient_1.mat**, **Patient_2.mat**, ..., **Patient_N.mat**.

## Step 3: Generate finite element meshes ##
* Run **mat2fem.sh** by the command ```$sbatch mat2fem.sh nr_patients``` to generate the finite element files (.elem and .pts files). The argument should be the number of patients included into the **seg** folder. When completed, the files will be stored inside the FEM folder including pacing coordinates.
* Pre-files for the fiber orientation are located in the Files folder, all constructed to fit the fiber generation provided by [CARPentry](https://carp.medunigraz.at/carputils/cme-installation.html). 

## Step 4: Simulations ##
* Inside a patient folder which should contain a .pts, .elem, .lon and coordinate file, run ```$sbatch risk_strat_1_16.sh``` to run simulations through [CARP](https://carp.medunigraz.at).
