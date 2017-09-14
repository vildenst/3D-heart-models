#!/bin/bash

mkdir -p ./Data/vtkFiles
mkdir -p ./Data/plyFiles
mkdir -p ./Data/txtFiles

module load python2

for f in *.txt
	do
		python make_surface.py "$f"

		'./ConvertFile/build/ConvertFile' "${f/.txt}".ply "${f/.txt}".vtk
		mv "${f/.txt}".vtk ./Data/vtkFiles
		mv "${f/.txt}".ply ./Data/plyFiles
	    	mv $f ./Data/txtFiles
done


