import numpy as np
import sys

def volume(a,b,c,d):
	b_a=np.subtract(b,a)
	c_a=np.subtract(c,a)
	d_a=np.subtract(d,a)
	cross=np.cross(c_a,d_a)
	result=np.dot(b_a,cross)
	return abs(result)/6.

def read_pts(infile):
	ptsfile=open(infile,'r')
	ptsfile.readline()
	pts=[]
	for line in ptsfile:
		num=line.split()
		pts.append(np.array((float(num[0])/1000.,float(num[1])/1000.,float(num[2])/1000.)))
	ptsfile.close()
	return pts

def calculate_volume(infile,pts):
	elemfile=open(infile,'r')
	healthy=0
	ischemic=0
	elemfile.readline()
	for line in elemfile:
		num=line.split()
		a=pts[int(num[1])]
		b=pts[int(num[2])]
		c=pts[int(num[3])]
		d=pts[int(num[4])]
		elem_vol=volume(a,b,c,d)
		if int(num[-1])==1:
			healthy+=elem_vol
		else:
			ischemic+=elem_vol
	elemfile.close()
	print('Healthy volume: %.2f ml' %(healthy/1000.))
	print('Scar volume: %.2f ml' %(ischemic/1000.))
	

pts=read_pts(str(sys.argv[1]))
calculate_volume(str(sys.argv[2]),pts)