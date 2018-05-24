"""USAGE: python generate_regions.py path/scarsurfpts path/scarvolpts"""

import sys
import numpy as np
out_done=open('done.pts','w')

def collect_pts(filename,pts_array): #help function
	counter=0
	for line in filename:
		num=line.split()
		pts_array[counter]=float(num[0]),float(num[1]),float(num[2])
		counter+=1
	return pts_array

def first():	#labeling surface points to region [2]
	surf_name=str(sys.argv[1])
	vol_name=str(sys.argv[2])
	in_surf=open(surf_name+'.pts','r')
	num_surf=in_surf.readline().strip()
	surf_pts=np.zeros((int(num_surf),3))
	surf_pts=collect_pts(in_surf,surf_pts)
	in_surf.close()

	in_vol=open(vol_name+'.pts','r')
	num_vol=in_vol.readline().strip()
	out_done.write('{}\n'.format(num_vol))
	vol_pts=np.zeros((int(num_vol),3))
	vol_pts=collect_pts(in_vol,vol_pts)
	in_vol.close()

	print('Collected points...')
	return surf_pts,vol_pts


'''
Want to set all the remaining points to the given region_nr
'''
def last_region(region_nr,rem_pts):
	for i in range(len(rem_pts)):
		x=rem_pts[i,0]
 		y=rem_pts[i,1]
 		z=rem_pts[i,2]
		out_done.write('{} {} {} {}\n'.format(x,y,z,region_nr))
	nr_reg_out=open('nr_regions_Patient_{}.dat'.format(sys.argv[3]),'w')
	nr_reg_out.write('{}\n'.format(region_nr))
	nr_reg_out.close()

'''
Must find the nearest neighbor for every coordinate in
the done file, to create the next region
'''
from datetime import datetime
from sklearn.neighbors import NearestNeighbors

def nearest_neighbor(surf_pts,vol_pts,region_nr):
	if len(vol_pts)<(len(surf_pts)):
		last_region(region_nr,vol_pts)
		print('Assigned {} points to region {}'.format(len(vol_pts),region_nr))
		out_done.close()
		sys.exit(1)
	nbrs=NearestNeighbors(n_neighbors=scale,algorithm='auto').fit(vol_pts)
	dist,ind=nbrs.kneighbors(surf_pts)
	oneD=np.reshape(ind,len(ind)*len(ind[0]))
	oneD=np.unique(sorted(oneD))
	rem_vol=[]
	for i in range(len(vol_pts)):
		if i in oneD:
			out_done.write('{} {} {} {}\n'.format(vol_pts[i][0],vol_pts[i][1],vol_pts[i][2],region_nr))
		else:
			rem_vol.append(vol_pts[i])
	print('Done with region {}'.format(region_nr))
	nearest_neighbor(surf_pts,np.asarray(rem_vol),region_nr+1)

surf_pts,vol_pts=first()
scale=int(round(len(vol_pts)/(5*len(surf_pts))))
nearest_neighbor(surf_pts,vol_pts,2)
out_done.close()

