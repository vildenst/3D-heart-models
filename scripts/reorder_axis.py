"""USAGE: python reorder_axis.py mshpath elempath Patient"""

import sys,os
import numpy as np
import itertools

mshpath=str(sys.argv[1])
fempath=str(sys.argv[2])
patient=str(sys.argv[3])
infile=open('{}/{}.msh'.format(mshpath,patient),'r')
for i in range(13):
	infile.readline()
num_pts=int(infile.readline()[:-1])
partition=[0 for i in range(num_pts)]
pts_lst=[]
counter=0
while counter < num_pts:
	counter+=1
	num=infile.readline().split()
	num=[float(i) for i in num]
	pts_lst.append([num[1],num[2],num[3],counter-1])
infile.readline()
infile.readline()

num_elem=int(infile.readline()[:-1])
elem_lst=[]
counter=0
elem_count=0
while counter<num_elem:
	counter+=1
	num=infile.readline().split()
	num=[int(i) for i in num]
	if num[1]==4:
		elem_count+=1
		elem_lst.append([num[-4]-1,num[-3]-1,num[-2]-1,num[-1]-1])
infile.close()
print('Done reading gmsh file...')


def partition(points,dim,rounds):
	new_lst=[]
	rounds+=1
	for lst in points:
		pts_array=np.asarray(lst)
		mean=np.mean(pts_array,axis=0)
		reference=mean[dim]
		left=[]
		right=[]
		for coord in lst:
			if coord[dim]<reference:
				left.append(coord)
			else:
				right.append(coord)
		new_lst.append(left)
		new_lst.append(right)
	if dim==2:
		dim=0
	else:
		dim+=1
	if rounds<14:
		return partition(new_lst,dim,rounds)
	else:
		return new_lst

tmp=[]
tmp.append(pts_lst)		
new=partition(tmp,2,0)
print('partition done')
reorder=list(itertools.chain(*new))


out_pts=open('{}_reorder.pts'.format(patient),'w')
reorderfile=open('{}_reorder.reorder'.format(patient),'w')
out_pts.write('{}\n'.format(num_pts))
reorder_dict={}
counter=0
for node in reorder:
	out_pts.write('{} {} {}\n'.format(node[0]*1000,node[1]*1000,node[2]*1000))
	reorderfile.write('{}\n'.format(node[3]))
	reorder_dict[int(node[3])]=counter
	counter+=1
out_pts.close()
reorderfile.close()

in_elem=open('{}/{}.elem'.format(fempath,patient),'r')
regions=[]
in_elem.readline()
for line in in_elem:
	num=line.split()
	regions.append(int(num[-1]))
in_elem.close()

out_elem=open('{}_reorder.elem'.format(patient),'w')
out_elem.write('{}\n'.format(elem_count))
count=0
for nodes in elem_lst:
	node1=reorder_dict[nodes[0]]
	node2=reorder_dict[nodes[1]]
	node3=reorder_dict[nodes[2]]
	node4=reorder_dict[nodes[3]]
	out_elem.write('Tt {} {} {} {} {}\n'.format(node1,node2,node3,node4,regions[count]))
	count+=1
out_elem.close()
