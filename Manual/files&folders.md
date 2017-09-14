## Overview over the different files and folders ##

### README.md ###
Overview of the entire pipeline with instructions.

### VTK ###
Visualization Toolkit version 8.0.0, collected from http://www.vtk.org/download/.
**software.sh** compiles and builds VTK for you in the location $HOME/Programs, unless you already have VTK installed.
In that case, **software.sh** will ask for the path to its build folder instead.

### ITK ###
Insight Toolkit version 4.12.0, collected from https://itk.org/ITK/resources/software.html.
You have to compile and build ITK with Module_ITKVtkGlue=ON (default is OFF).
**software.sh** compiles and builds ITK for you in the location $HOME/Programs, unless you already have ITK installed.
In that case, **software.sh** will ask for the path to its build folder instead.

### gmsh ###
gmsh version 2.13.1, collected from http://gmsh.info. **software.sh** compiles and builds gmsh for you in 
the location $HOME/Programs, unless you already have gmsh installed. 
In that case, **software.sh** will ask for the path to its executable instead.

### Medical_Image_Processing_Toolbox ###
A matlab toolbox collected from https://se.mathworks.com/products/image.html. 
The toolbox enables the matlab process to run correctly. It will automatically be downloaded
in $HOME/Programs. **alignAll.m** is hardcoded to look for the toolbox in that folder, so please do not change its location.

### software.sh ###
The first program you should run to build and compile necessary programs, such as: VTK, ITK, gmsh, numpy, scipy, matplotlib,
ConvertFile, ScarProcessing and msh2carp.c. If you already have the three first softwares installed, it will ask for their
path instead. The other programs will be installed or build and compiled. Also, **software.sh** creates some empty folders
not allowed by git. 

### Matlab_Process ###
Folder with matlab programs that alignes all .mat files, and generates .txt files from it.
Also, .mhd files are created for the scar tissue.
These files are collected and modified from https://github.com/MAP-MD/Cardiac/tree/Cmr2Mesh.

### Convertion_Process ###
Folder with an executable program ConvertFile that converts the .txt files generated in
the matlab process to .ply and .vtk files. **software.sh** compiles ConvertFile.
These files are collected and modified from https://github.com/MAP-MD/Cardiac/tree/Cmr2Mesh.

### Scar_Process ###
Folder with an executable program ScarProcessing that converts the .mhd files generated in 
the matlab process to .vtk files. **software.sh** compiles ScarProcessing.
These files are collected and modified from https://github.com/MAP-MD/Cardiac/tree/Cmr2Mesh.

### mat2fem.sh ###
Bash job script that loads necessary modules before calling **mat2fem.py**.

### mat2fem.py ###
Python script that automates the process from transforming .mat files into FEM files.It results in Patient_i folders inside the FEM folder, 
where each Patient_i folder should contain a **Patient_i.pts**, **Patient_i.elem**, **Patient_i.tris**, **risk_strat_1_16.sh** and **stim_coord.dat**.

### Manual ###
* **segment_manual.pdf** contains detailed information on how to segment MRI images for this pipeline. The original manual from the developers
can be found [here](http://medviso.com/documents/segment/manual.pdf).
* **meshalyzer_manual.pdf** containes detailed information on how to pick out coordinates for the different pacing sites. The original manuals from the developers
can be found [here](http://medviso.com/documents/segment/manual.pdf) and [here](https://github.com/cardiosolv/meshalyzer/tree/master/manual).
* **Cardiology.pdf** is an introduction to cardiology, with some good background knowledge for understanding this pipeline.
* **simulations.pdf** containes some information on how to analyze the simulations in step 5.

### scripts ###
Folder containing four files used in the finite element mesh creations and simulations:
* **biv_mesh.geo** is used when converting .vtk files into .msh files.
* **stim_coord.dat** should contain the five pacing coordinates before starting simulations on a patient.
* **base.par** is the base parameter file.
* **rish_strat_1_16.sh** is used to run simulations on a patient.








