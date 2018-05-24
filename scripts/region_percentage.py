"""USAGE: python region_percentage.py elempath"""

import sys
elemname=str(sys.argv[1])
infile=open('{}.elem'.format(elemname),'r')
reg_dict={}
num_elem=infile.readline().strip()
for line in infile:
	num=line.split()
	if int(num[-1])>1:
		if int(num[-1]) in reg_dict:
			reg_dict[int(num[-1])]+=1
		else:
			reg_dict[int(num[-1])]=1
print('Nr of elements within each region:')
print reg_dict
s=0
for key in reg_dict:
	s+=reg_dict[key]
print('Total scar percentage: %.2f' %((s/float(num_elem))*100))