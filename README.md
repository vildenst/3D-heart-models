# 3D-heart-models

# Pipeline for patient specific 3D heart models #

This manual is based on the user having access to [Abel](http://www.uio.no/english/services/it/research/hpc/abel/), a computer cluster with Linux OS. A description of the different files and folders can be found in **Manual/files&folders.md**. An introduction to cardiology is available in **Manual/Cardiology.pdf**.
Clone and access this repository from a suitable location on your Abel account by the following commands:
1. ```$git clone https://github.com/vildenst/In_Silico_Heart_Models.git```.
2. ```$cd In_Silico_Heart_Models```.

## Step 1: Software requirements ##
* On your computer: A Windows virtual machine with the program [Segment](http://medviso.com/download2/), and [Meshalyzer](https://github.com/cardiosolv/meshalyzer) to visualize FEM. Installation instructions for the programs can be found on their websites.
* On Abel: [vtk](http://www.vtk.org), [itk](https://itk.org) (must be built with Module_ITKVtkGlue=ON), [gmsh](http://gmsh.info), numpy, scipy and matplotlib. **software.sh** will install them for you if you don't have them.
* Run **software.sh** to create and build some necessary folders and programs: ```$sh software.sh```.

## Step 2: Segmentation ##
* Segmentation of MRI images is done in [Segment](http://medviso.com/download2/). For a detailed description on how to segment the images, see **Manual/segment_manual.pdf**.
* All files produced from Segment (.mat format) should be saved in the **seg** folder created from **software.sh**. It is important that the different .mat files are saved as **Patient_1.mat**, **Patient_2.mat**, ..., **Patient_N.mat**. To copy files between Abel and your computer, use scp or rsync: [Abel Faq](http://www.uio.no/english/services/it/research/hpc/abel/help/faq/).

## Step 3: Generate finite element meshes ##
* Run **mat2fem.sh** by the command ```$sbatch mat2fem.sh``` to generate the finite element meshes (.elem, .tris, and .pts files). When done, your files should be stored inside the FEM folder. The .msh files are stored in the Surface folder.

## Step 4: Pacing Coordinates ##
* Use [Meshalyzer](https://github.com/cardiosolv/meshalyzer) to pick out coordinates for the different pacing sites. A detailed description on how to find the coordinates can be found in **Manual/meshalyzer_manual.pdf**. When done, all five coordinates should be stored in a file **stim_coord.dat** inside each patient folder in FEM.

## Step 5: Create .lon files ##
* Instructions are coming soon.

## Step 6: Simulations ##
* You can now start simulations for each patient. Inside a patient folder, run ```$sbatch risk_strat_1_16.sh```. A detailed description on how to analyze the results can be found in **Manual/simulation_manual.pdf**.
