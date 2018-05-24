"""
Usage: python find_coord.py Patient mshPath reorderPath [node14]
"""

import numpy as np
from scipy.spatial import distance
import sys

threshold=1000
manual_ref=False
stim_coord=[0 for i in range(17)] 	#17 points to fill up
coord_lst=[0 for i in range(17)]
coord_13to16=[]
coord_7to12=[]
coord_1to6=[]
nr_13to16=[]
nr_7to12=[]
nr_1to6=[]
patient=str(sys.argv[1])
mshpath=str(sys.argv[2])
fempath=str(sys.argv[3])
manual_14=0
if len(sys.argv)==5:
	manual_14=int(sys.argv[4])	#important! Must be from original .pts, not reorder
	manual_ref=True

def read_msh():
	infile=open('{}/{}.msh'.format(mshpath,patient),'r')
	elements=False
	lv_points=[]
	rv_points=[]
	base_points=[]
	for line in infile:
		words=line.split()
		if words[0]=="$Elements":
			elements=True
		if words[0]=="$EndElements":
			elements=False
		if elements and len(words)==8:
			if words[2]=='2' and words[3]=='2': 	#LV
				for i in range(5,8):
					lv_points.append(int(words[i]))
			if words[2]=='2' and words[3]=='3': 	#RV
				for i in range(5,8):
					rv_points.append(int(words[i]))
			if words[2]=='2' and words[3]=='5': 	#BASE
				for i in range(5,8):
					base_points.append(int(words[i]))
		else:
			continue
	infile.close()
	return set(lv_points),set(rv_points),set(base_points)

def read_pts(lv,rv,base):
	pts_file=open('{}/{}.pts'.format(mshpath,patient),'r')
	pts_file.readline()	#reading first line
	lv_pts_lst=[]
	lv_pts_nr=[]
	rv_pts_nr=[]
	base_pts_lst=[]
	base_pts_nr=[]
	counter=0
	for line in pts_file:
		counter+=1
		num=line.split()
		if counter in lv:
			lv_pts_lst.append([float(num[0]),float(num[1]),float(num[2])])
			lv_pts_nr.append(counter-1)
		if counter in rv:
			rv_pts_nr.append(counter-1)
		if counter in base:
			base_pts_lst.append([float(num[0]),float(num[1]),float(num[2])])
			base_pts_nr.append(counter-1)
	pts_file.close()
	return lv_pts_lst,lv_pts_nr,rv_pts_nr,base_pts_lst,base_pts_nr

def find_rv_ref(lv_pts,lv_nr,rv_nr,base_pts,base_nr):
	base_lv=[]
	base_lv_coord=[]
	base_rv=[]
	base_rv_coord=[]
	counter=0
	for point in base_nr:
		if point in lv_nr:
			base_lv.append(point)
			base_lv_coord.append(base_pts[counter])
		if point in rv_nr:
			base_rv.append(point)
			base_rv_coord.append(base_pts[counter])
		counter+=1
	base_lv_np=np.asarray(base_lv_coord)
	centroid=[base_lv_np[:,0].mean(),base_lv_np[:,1].mean(),0.0]
	centroid_rv_dist=np.sqrt(np.sum((np.asarray(centroid)-np.asarray(base_rv_coord))**2,axis=1))
	updated_base_rv=[]
	updated_pts=[]
	for i in range(len(centroid_rv_dist)):
		if centroid_rv_dist[i]<(centroid_rv_dist.mean()):
			updated_base_rv.append(base_rv_coord[i])
			updated_pts.append(base_rv[i])

	base_rv_np=np.asarray(updated_base_rv)
	rv_mean=[base_rv_np[:,0].mean(),base_rv_np[:,1].mean(),0.0]
	rv_mean_dist=np.sqrt(np.sum((np.asarray(rv_mean)-np.asarray(updated_base_rv))**2,axis=1))
	rv_ref=updated_base_rv[int(rv_mean_dist.argmin())]
	return rv_ref

def find_apex(lv_pts,lv_nr):
	z_min=0
	node17=0	#apex
	coord17=0
	z_max=-100000
	count=0
	for coord in lv_pts:
		if coord[-1] < z_min:
			z_min=coord[-1]
			node17=lv_nr[count]
			coord17=lv_pts[count]
		if coord[-1] > z_max:
			z_max=coord[-1]
		count+=1
	stim_coord[16]=node17 #done with coord 17
	coord_lst[16]=coord17
	return z_min,z_max

def create_pts_lists(lv_pts,lv_nr,z_min,z_max):
	count=0
	height=z_max-z_min
	for coord in lv_pts:
		if abs(coord[-1]-(height/4.+z_min))<threshold:
	 		nr_13to16.append(lv_nr[count])
	 		coord_13to16.append(coord)
	 	if abs(z_min+height/2.-coord[-1])<threshold:
			nr_7to12.append(lv_nr[count])
	 		coord_7to12.append(coord)
	 	if abs(z_min+height*3/4.-coord[-1])<threshold:
	 		nr_1to6.append(lv_nr[count])
	 		coord_1to6.append(coord)
	 	count+=1

def set_node(point,dist_lst,node_nr,nr_lst,min_max="min"):
	dist=np.sqrt(np.sum((np.asarray(point)-np.asarray(dist_lst))**2,axis=1))
	minmax=dist.argmin()
	if min_max=="max":
		minmax=dist.argmax()
	stim_coord[node_nr-1]=nr_lst[int(minmax)]
	coord_lst[node_nr-1]=dist_lst[int(minmax)]

def set_between_node(ref_pt1,ref_pt2,dist_lst,node_nr,nr_lst,dim=0,l_r="right"):
	dist1=np.sqrt(np.sum((np.asarray(ref_pt1)-np.asarray(dist_lst))**2,axis=1))
	dist2=np.sqrt(np.sum((np.asarray(ref_pt2)-np.asarray(dist_lst))**2,axis=1))
	diff=np.linalg.norm(np.asarray(ref_pt1)-np.asarray(ref_pt2))
	thres=100000
	for i in range(len(dist1)):
		distance=dist_lst[i][dim]< ref_pt1[dim]
		if l_r=="left":
			distance=dist_lst[i][dim]>ref_pt1[dim]
		if distance and abs(dist1[i]-dist2[i])<thres and dist1[i]>diff/2.:
				thres=abs(dist1[i]-dist2[i])
				stim_coord[node_nr-1]=nr_lst[i]
				coord_lst[node_nr-1]=dist_lst[i]

def find_13to16(rv_ref,lv_pts,lv_nr):
	reversed_coord=False
	manual_correct=False
	if manual_ref:
		for i in range(len(lv_nr)):
			if manual_14==lv_nr[i]:
				print('Adjusting to manually chosen site 14')
				set_node(lv_pts[i],coord_13to16,14,nr_13to16)
				manual_correct=True
		if not manual_correct:
			print('Chosen node not in LV surface. Try again..')
			exit(1)

	else:
		set_node(rv_ref,coord_13to16,14,nr_13to16)
	set_node(coord_lst[13],coord_13to16,16,nr_13to16,min_max="max")
	set_between_node(coord_lst[13],coord_lst[15],coord_13to16,13,nr_13to16)
	set_between_node(coord_lst[13],coord_lst[15],coord_13to16,15,nr_13to16,l_r="left")

	if coord_lst[12]==0:	#Case where coordinate system is "reversed"
		reversed_coord=True
		set_between_node(coord_lst[13],coord_lst[15],coord_13to16,13,nr_13to16,dim=1,l_r="left")
		set_node(coord_lst[12],coord_13to16,15,nr_13to16,min_max="max")
	return reversed_coord

def set_7to12_node(node1,coord,minmax="min",x="r",y="r",ref="r",dim=0):
	pts_lst=coord_7to12
	nr_lst=nr_7to12
	thres=100000
	ref_arg=np.sqrt(np.sum((np.asarray(coord_lst[13])-np.asarray(pts_lst))**2,axis=1))
	min_max=ref_arg.argmin()
	if minmax=="max":
		min_max=ref_arg.argmax()
	ref_node=pts_lst[int(min_max)]
	dist_ref=np.sqrt(np.sum((np.asarray(ref_node)-np.asarray(pts_lst))**2,axis=1))
	dist_node=np.sqrt(np.sum((np.asarray(coord_lst[node1-1])-np.asarray(pts_lst))**2,axis=1))
	for i in range(len(pts_lst)):
		x_i=pts_lst[i][0]<coord_lst[node1-1][0]
		y_i=pts_lst[i][1]<coord_lst[node1-1][1]
		ref_dim=pts_lst[i][dim]<ref_node[dim]
		if x=="l":
			x_i=pts_lst[i][0]>coord_lst[node1-1][0]
		if y=="l":
			y_i=pts_lst[i][1]>coord_lst[node1-1][1]
		if ref=="l":
			ref_dim=pts_lst[i][dim]>ref_node[dim]
		if abs(dist_node[i]-dist_ref[i])<thres and x_i and y_i and ref_dim:
			thres=abs(dist_node[i]-dist_ref[i])
			stim_coord[coord-1]=nr_lst[i]
			coord_lst[coord-1]=pts_lst[i]

def find_1to12(reversed_coord):
	set_node(coord_lst[12],coord_7to12,7,nr_7to12)
	set_node(coord_lst[14],coord_7to12,10,nr_7to12)
	if reversed_coord:
		set_7to12_node(10,9,y="l",dim=1)
		set_7to12_node(7,8,ref="l",dim=1)
		set_7to12_node(10,11,minmax="max",x="l",y="l",dim=1)
		set_7to12_node(7,12,minmax="max",x="l",ref="l",dim=1)
	else:
		set_7to12_node(10,9,ref="l")
		set_7to12_node(7,8,x="l")
		set_7to12_node(10,11,minmax="max",y="l",ref="l")
		set_7to12_node(7,12,minmax="max",x="l",y="l")

	for i in range(6,12):
		set_node(coord_lst[i],coord_1to6,i-5,nr_1to6)

def write_reorder():
	reorder_file=open('{}/{}_reorder.reorder'.format(fempath,patient),'r')
	stim_coord_reorder=[0 for i in range(17)]
	counter=0
	for line in reorder_file:
		num=line.split()
		if int(num[0]) in stim_coord:
			stim_coord_reorder[stim_coord.index(int(num[0]))]=counter
		counter+=1
	reorder_file.close()
	stim_coord_file=open('stim_coord.dat','w')
	for i in stim_coord_reorder:
		stim_coord_file.write('{}\n'.format(i))
	stim_coord_file.close()

lv,rv,base=read_msh()
lv_pts,lv_nr,rv_nr,base_pts,base_nr=read_pts(lv,rv,base)
rv_ref=find_rv_ref(lv_pts,set(lv_nr),set(rv_nr),base_pts,base_nr)
z_min,z_max=find_apex(lv_pts,lv_nr)
create_pts_lists(lv_pts,lv_nr,z_min,z_max)
reversed_coord=find_13to16(rv_ref,lv_pts,lv_nr)
find_1to12(reversed_coord)
write_reorder()



	
