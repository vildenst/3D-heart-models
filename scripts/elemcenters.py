"""USAGE: python elemcenters.py path/patientname"""

import sys

patient=str(sys.argv[1])
pts=open(patient+'.pts','r')
pts_lst=[]
pts.readline()
for line in pts:
	coord=line.split()
	x=float(coord[0])
	y=float(coord[1])
	z=float(coord[2])
	pts_lst.append([x,y,z])
pts.close()

def find_centroid(coord1,coord2,coord3,coord4):
	x=(coord1[0]+coord2[0]+coord3[0]+coord4[0])/4.
	y=(coord1[1]+coord2[1]+coord3[1]+coord4[1])/4.
	z=(coord1[2]+coord2[2]+coord3[2]+coord4[2])/4.
	return x,y,z

elem=open(patient+'.elem','r')
elemcenters=open('elemcenters.dat','w')
elem.readline()
for line in elem:
	row=line.split()
	coord1=pts_lst[int(row[-5])]
	coord2=pts_lst[int(row[-4])]
	coord3=pts_lst[int(row[-3])]
	coord4=pts_lst[int(row[-2])]
	x,y,z=find_centroid(coord1,coord2,coord3,coord4)
	elemcenters.write('%.3f %.3f %.3f\n' %(x,y,z))
elem.close()
elemcenters.close()
