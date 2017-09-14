#!/bin/bash 
######################################
#Written by Vilde N. Strom, July 2017#
#	Simula Research Laboratory		 #
######################################

root=$PWD 	#path to In_Silico_Heart_Models

#creates Programs folder if it doesn't exist
if [ ! -d "~/Programs" ]; then
	mkdir ~/Programs
fi 

#changing to Programs folder to install VTK, ITK & gmsh
cd ~/Programs	
Programs_path=$PWD

#moving matlab toolbox to Programs
mv $root/Medical_Image_Processing_Toolbox .
echo "Moved Medical_Image_Processing_Toolbox to" $PWD

#loading new modules
module purge
module load cmake
module load gcc

#Installing VTK
read -p "Do you want to install VTK (y/n)? " vtkchoice
case "$vtkchoice" in
	y|Y|Yes|yes ) 
	echo "Installing VTK... This will take some time"
	echo "Downloading VTK in " $Programs_path
	mv $root/VTK .
	mkdir VTK-build && cd VTK-build	#cd into build folder
	echo "building VTK in "$PWD
	cmake ../VTK 	#running cmake with path to VTK src folder
	make -j10
	vtk_dir=$PWD;;	#path to VTK build
	n|N|No|no ) 
	echo "Will not install VTK. Removing VTK folder ..."
	rm -rf $root/VTK
	read -p "Please specify the path to your VTK build: " vtk_dir;;	#path to VTK build
	* ) 
	echo "Invalid answer. Please type y or n next time. Shutting down program ..."
	exit 1;;
esac

export VTK_DIR=$vtk_dir 	#setting path to VTK build

#Installing ITK
read -p "Do you want to install ITK (y/n)? " itkchoice
case "$itkchoice" in
	y|Y|Yes|yes ) 
	echo "installing ITK ... This will take some time"
	echo 'downloading ITK in '$Programs_path
	mv $root/ITK . && cd $Programs_path/ITK
	mkdir bin && cd bin 	#cd into bin folder 
	echo 'Building ITK in '$PWD
	echo "You will now be directed into the cmake interface to enable ITKVtkGlue."
	echo "Please do the following after the interface opens:"
	echo "1) Press c to configure."
	echo "2) Press t to enable advanced options. Then use the arrow keys to scroll"
	echo "down to Module_ITKVtkGlue, and press enter. It should now say ON instead of OFF."
	echo "3) Press c to configure, two times in a row."
	echo "4) Press g to generate."
	read -p "Press enter if understood: " ccmake
	case "$ccmake" in
		* ) 
		ccmake .. 	#need to turn on Glue (connects VTK & ITK)
		make -j10
		itk_dir=$PWD;;	#path to ITK build
	esac;;
	n|N|No|no ) 
	echo "Will not install ITK. Removing ITK folder ..."
	rm -rf $root/ITK
	read -p "Please specify the path to your ITK build: " itk_dir;;	#path to ITK build
	* ) 
	echo "Invalid answer. Please type y or n next time. Shutting down program ..."
	exit 1;;
esac

export ITK_DIR=$itk_dir 	#setting path to ITK build

#building Convertion_Process
mkdir $root/Convertion_Process/ConvertFile/build
cd $root/Convertion_Process/ConvertFile/build
echo "Building ConvertFile in "$PWD
cmake ..
make

#building Scar_Process
mkdir $root/Scar_Process/ScarProcessing/build
cd $root/Scar_Process/ScarProcessing/build
echo "Building ScarProcessing in "$PWD
cmake ..
make

#Installing gmsh
read -p "Do you want to install gmsh (y/n)? " gmshchoice
case "$gmshchoice" in
	y|Y|Yes|yes ) 
	echo "Installing gmsh ... This might take some time"
	echo "Downloading gmsh in "$Programs_path
	cd $Programs_path && mv $root/gmsh . #moving gmsh folder into Programs
	mkdir gmsh/build && cd gmsh/build 	#cd into build folder
	echo "Building gmsh in "$PWD
	module purge						#clean up old modules listed
	module load openmpi.intel/1.8.5 	#need to load new module
	module load cmake 					#reload cmake
	cmake ../ -DENABLE_FLTK=0 .. 		#building gmsh without GUI (need FLTK for that)
	make -j10	
	cd $root;;
	n|N|No|no ) 
	echo "Will not install gmsh. Removing gmsh folder ..."
	rm -rf $root/gmsh
	read -p "Please specify the path to your gmsh executable: " gmsh_path 	#need users gmsh path
	cd $root
	old_gmsh="'{}/gmsh/build/gmsh'.format(os.getenv('HOME')+'/Programs')" 	#original path to gmsh in mat2fem.py
	sed -i -e "s|$old_gmsh|'$gmsh_path'|g" mat2fem.py 		#changed gmsh path in mat2fem.py
	echo 'Have updated gmsh path in mat2fem.py to '$gmsh_path;;
	* ) 
	echo "Invalid answer. Please type y or n next time. Shutting down program ..."
	exit 1;;
esac

#installing necessary python packages
echo "Checking if numpy, scipy and matplotlib are installed ..."
module purge
module load python2
pip install --user numpy
pip install --user scipy
pip install -U matplotlib --user


#need to create some empty folders
seg='seg'
Surfaces='Surfaces'
FEM='FEM'
Conv_Data='Convertion_Process/Data/'
Matlab_Data='Matlab_Process/Data'
Matlab_align=$Matlab_Data'/Aligned'
Matlab_scar=$Matlab_Data'/ScarImages'
Scar_meta=$Matlab_scar'/MetaImages'
Matlab_seg=$Matlab_Data'/Seg'
Matlab_text=$Matlab_Data'/Texts'
Scar_data='Scar_Process/Data'


declare -a folders=($seg $Surfaces $Conv_Data $Matlab_Data 
				$Matlab_align $Matlab_scar $Matlab_seg 
				$Matlab_text $Scar_data $FEM $Scar_meta)

for f in "${folders[@]}"
do
	mkdir $f
	echo 'Created directory '$f
done

