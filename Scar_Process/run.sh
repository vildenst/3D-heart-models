#!/bin/bash

for f in Data/*.mhd;
do
	echo 'Subject' "${f/.mhd}"
	
	'ScarProcessing/build/ScarProcessing' $f "${f/.mhd}_scar.vtk"
done

