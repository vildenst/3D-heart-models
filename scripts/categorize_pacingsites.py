import sys
import numpy as np
from sklearn.neighbors import NearestNeighbors

name=str(sys.argv[1]) #Patient name (no extension)
coords=str(sys.argv[2]) #stim_coord.dat

def read_pts(name):
	points=[]
	in_pts=open('{}.pts'.format(name),'r')
	nr_pts=int(in_pts.readline())
	for line in in_pts:
		num=line.split()
		x=float(num[0])
		y=float(num[1])
		z=float(num[2])
		points.append([x,y,z])
	in_pts.close()
	print('Done reading pts file')
	return points

def find_scar_pts(name,points):
	pts=[]
	in_elem=open('{}.elem'.format(name),'r')
	nr_elem=int(in_elem.readline())
	for line in in_elem:
		num=line.split()
		if int(num[-1])>1:	#scar element
			for i in range(1,5):
				pts.append(int(num[i]))
	in_elem.close()
	if len(pts)==0:	#no scar elements
		print('No scar in this patient!')
		sys.exit(1)
	print('Done finding scar elements')
	scar_pts=list(set(pts))
	scar_coords=[]
	for node in scar_pts:
		scar_coords.append(points[node])
	return scar_coords

def find_distance(node,scar,output,counter):
	nbrs=NearestNeighbors(n_neighbors=1,algorithm='auto').fit(np.asarray(scar))
	dist,ind=nbrs.kneighbors(np.asarray(np.asarray(node)))
	infarct_thres=600 
	bz_thres=6000
	print('site %i: %.0f microns from scar tissue' %(counter,dist[0][0]))
	if float(dist)<infarct_thres:
		#print('Infarct site')
		output.append('Infarct site')
	elif float(dist)>infarct_thres and float(dist)<bz_thres:
		#print('Border zone site')
		output.append('Border zone site')
	else:
		#print('Healthy site')
		output.append('Healthy site')
	return output

def categorize_coord(coords,points,scar_pts):
	coordinates=[]
	output=[]
	in_coord=open(coords,'r')
	for node in in_coord:
		coordinates.append(node)
	in_coord.close()
	scar_array=np.asarray(scar_pts)
	counter=1
	for node in coordinates:
		point=np.asarray([points[int(node)]])
		output=find_distance(point,scar_array,output,counter)
		counter+=1
	return output,coordinates

def write_output(output,coordinates):
	outfile=open('categorize_coords.dat','w')
	counter=0
	for category in output:
		outfile.write('({}) {}: {}\n'.format(counter+1,int(coordinates[counter]),category))
		counter+=1

points=read_pts(name)
scar_pts=find_scar_pts(name,points)
output,coordinates = categorize_coord(coords,points,scar_pts)
write_output(output,coordinates)