import sys
import numpy as np
from scipy.spatial import distance
def read_msh():
	infile=open(str(sys.argv[1]),'r') #read scar surface file
	for i in range(4):
		infile.readline()
	nr_pts=int(infile.readline()[:-1])
	counter=1
	pts=[]
	while counter<=nr_pts:
		num=infile.readline().split()
		pts.append([float(num[-3]),float(num[-2]),float(num[-1])])
		counter+=1
	for i in range(2):
		infile.readline()
	nr_elem=int(infile.readline()[:-1])
	counter=1
	elem=[]
	while counter<=nr_elem:
		num=infile.readline().split()
		if int(num[1])==3:
			reg=int(num[6])
			node1=int(num[-4])-1
			node2=int(num[-3])-1
			node3=int(num[-2])-1
			node4=int(num[-1])-1
			elem.append([node1,node2,node3,node4,reg])
		counter+=1
	infile.close()
	return pts, elem

def sort_partitions(elem):
	parts={}
	for lst in elem:
		if lst[-1] in parts:
			parts[lst[-1]]+=[lst[0],lst[1],lst[2],lst[3]]
		else:
			parts[lst[-1]]=[lst[0],lst[1],lst[2],lst[3]]
	for key in parts:
		parts[key]=list(set(parts[key]))
	return parts

def compute_center(elemlst,pts):
	points=[]
	for elem in elemlst:
		points.append(pts[elem])
	return np.mean(np.asarray(points),axis=0)

def nearest_center_point(centers,points):
	nodes=[]
	for coord in centers:
		dist=100
		ind=0
		for pt in points:
			a=np.asarray(coord)
			b=np.asarray(pt)
			curr_dist=distance.euclidean(a,b)
			if curr_dist<dist:
				dist=curr_dist
				ind=points.index(pt)
		nodes.append(ind)
	return nodes

def make_nodefile(nodes):
	out=open('nodes_pacing.dat','w')
	invol=open('test_bz_vol.pts','r')
	n=int(invol.readline()[:-1])
	invol.close()
	for i in range(n):
		if i in nodes:
			out.write('1\n')
		else:
			out.write('0\n')
	out.close()

def make_coordfile(nodes):
	out=open('stim_coord_bz.dat','w')
	for i in nodes:
		out.write('{}\n'.format(i))
	out.close()

def find_bz_nodes():
	nodes={}
	infile=open(str(sys.argv[3]),'r') #.elem reorder file
	nr_elem=int(infile.readline()[:-1])
	print('started .elem collecting')
	for line in infile:
		num=line.split()
		for i in range(1,5):
			if int(num[i]) in nodes:
				nodes[int(num[i])]+=[int(num[-1])]
			else:
				nodes[int(num[i])]=[int(num[-1])]
	print('Done collecting')
	for key in nodes:
		nodes[key]=list(set(nodes[key]))
	bz_nodes=[]
	for key in nodes:
		if 1 in nodes[key] and 2 in nodes[key]:	#Border zone node
			bz_nodes.append(int(key))
	print('Finished with finding BZ elements')
	return bz_nodes

def find_nearest_heart_pt(centers,bz_nodes):
	points=[]
	points_ind=[]
	nodes=[]
	infile=open(str(sys.argv[2]),'r') #patient reorder pts
	nr_pts=int(infile.readline()[:-1])
	counter=0
	bz_set=set(bz_nodes)
	print('collecting points in BZ')
	for line in infile:
		if counter in bz_set:
			num=line.split()
			pt1=float(num[0])/1000
			pt2=float(num[1])/1000
			pt3=float(num[2])/1000
			points.append([pt1,pt2,pt3])
			points_ind.append(counter)
		counter+=1
	infile.close()
	print('DONE collecting points in BZ')
	for coord in centers:
		dist=distance.cdist(np.asarray([coord]),np.asarray(points),'euclidean')
		nodes.append(points_ind[np.argmin(dist)])
	return nodes


def find_center(elem_dict,pts):
	centers=[]
	for key in elem_dict:
		centers.append(compute_center(elem_dict[key],pts))
	#center_pts=nearest_center_point(centers,pts)
	#make_nodefile(center_pts)
	bz_nodes=find_bz_nodes()
	nodes=find_nearest_heart_pt(centers,bz_nodes)
	make_coordfile(nodes)

pts,elem=read_msh()
parts=sort_partitions(elem)		
find_center(parts,pts)

