'''
USAGE: python connect_meshes.py path/scarsurfpts path/elemcenters.dat 
				path/done.pts path/Patient
Want to exclude areas that are far away from the scar tissue,
to make the computations as fast as possible. Excluding all
values outside of the max and min x,y,z. 

After excluded, it will compare the done.pts (done scar points with region nr)
with the remaining heart element center values.
'''

import sys
import numpy as np
import shutil
from datetime import datetime
from sklearn.neighbors import NearestNeighbors

def find_extreme_pts():
	scar_pts=open(str(sys.argv[1])+'.pts','r') #open surface file
	nr=int(scar_pts.readline().strip())
	x=np.zeros(nr)
	y=np.zeros(nr)
	z=np.zeros(nr)
	counter=0
	for line in scar_pts:
		num=line.split()
		x[counter]=float(num[0])
		y[counter]=float(num[1])
		z[counter]=float(num[2])
		counter+=1
	scar_pts.close()
	return np.amin(x),np.amax(x),np.amin(y),np.amax(y),np.amin(z),np.amax(z)


def exclude_values():
	print('Collecting relevant heart coordinates...')
	xmin,xmax,ymin,ymax,zmin,zmax=find_extreme_pts()
	heart_pts=open(str(sys.argv[2]),'r')
	#nr_elem=heart_pts.readline().strip()
	included_pts=[]
	line_nr=[]
	counter=0
	for line in heart_pts:
		num=line.split()
		counter+=1
		x1= float(num[0])<xmin
		x2= float(num[0])>xmax
		y1= float(num[1])<ymin
		y2= float(num[1])>ymax
		z1= float(num[2])<zmin
		z2= float(num[2])>zmax
		if x1==x2==y1==y2==z1==z2==False: #Inside the extreme values of scar
			included_pts.append([float(num[0]),float(num[1]),float(num[2])])
			line_nr.append(counter)
	heart_pts.close()
	return included_pts,line_nr

def get_scar_pts():
	print('Collecting scar coordinates with regions...')
	scar_file=open(str(sys.argv[3]),'r')
	num_lns=scar_file.readline().strip()
	scar_pts=np.zeros((int(num_lns),3))
	region={}
	nr_regions=1
	current_reg=1
	i=0
	for line in scar_file:
		num=line.split()
		scar_pts[i]=float(num[0]),float(num[1]),float(num[2])
		region[i]=int(num[3])
		if int(num[3]) != current_reg:
			nr_regions+=1
			current_reg=int(num[3])
		i+=1
	return scar_pts,region,nr_regions


def nearest_neighbor(heart_pts,scar_pts,reg_lst,line_nr,scale):
	print('Starting searching for the nearest neighbors')
	nbrs=NearestNeighbors(n_neighbors=scale,algorithm='auto').fit(heart_pts)
	dist,ind=nbrs.kneighbors(scar_pts)
	taken=np.zeros(len(heart_pts))
	write_to_elem=[]
	for i in range(len(ind)):
		for j in range(len(ind[i])):
			index_value=ind[i][j]
			if not taken[index_value]:	#have not assigned region here before
				taken[index_value]=True
				write_to_elem.append([line_nr[index_value],reg_lst[i]])
	print('Duplicates removed and list sorted')
	return sorted(write_to_elem)

def print_regions(pts_reg_list):
	print('Writing changes to file...')
	shutil.move(str(sys.argv[4])+'.elem',str(sys.argv[4])+'_original.elem')
	infile=open(str(sys.argv[4])+'_original.elem','r')
	outfile=open(str(sys.argv[4])+'.elem','w')
	counter=0
	first=infile.readline()
	outfile.write(first)
	for line in infile:
		counter+=1
		if len(pts_reg_list)>0 and counter == int(pts_reg_list[0][0]): #need to change region
			num=line.split()
			i=int(num[1])
			j=int(num[2])
			k=int(num[3])
			l=int(num[4])
			outfile.write('Tt {} {} {} {} {}\n'.format(i,j,k,l,pts_reg_list[0][1]))
			pts_reg_list.pop(0)
		else:
			outfile.write(line)	
	infile.close()
	outfile.close()




heart_pts,line_nr=exclude_values()
scar_pts,region_nr,nr_regions=get_scar_pts()
#scale=15
scale=len(heart_pts)/float(len(scar_pts))
scale=int(round(scale))
print('scale: {}'.format(scale))
write_to_elem=nearest_neighbor(heart_pts,scar_pts,region_nr,line_nr,scale)
print_regions(write_to_elem)





