"""Usage: python multiply_pts.py path/Patientname"""

import sys
name=sys.argv[1]
infile=open('{}.pts'.format(name),'r')
out=open('{}_new.pts'.format(name),'w')
out.write('{}'.format(infile.readline()))
for line in infile:
	num=line.split()
	x=float(num[0])*1000
	y=float(num[1])*1000
	z=float(num[2])*1000
	out.write('{} {} {}\n'.format(x,y,z))
infile.close()
out.close()