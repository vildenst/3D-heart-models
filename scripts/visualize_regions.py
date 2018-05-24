"""USAGE: python visualize_regions.py nr_of_regions pts_with_regions_path"""

import sys
nr_of_regions=int(sys.argv[1])
pts_with_regions=str(sys.argv[2])
infile=open('{}.dat'.format(pts_with_regions),'r')
nr_pts=infile.readline()[:-1]
pts_lst=[]
for line in infile:
	pts_lst.append(line.split())
infile.close()

def create_reg_files(region_nr,pts):
	out=open('region_{}.pts'.format(region_nr),'w')
	remaining=[]
	for lst in pts:
		if int(lst[-1])==region_nr:
			x=float(lst[0])
			y=float(lst[1])
			z=float(lst[2])
			out.write('{} {} {}\n'.format(x,y,z))
		else:
			remaining.append(lst)
	out.close()
	if region_nr==nr_of_regions:
		print('Done! You can now visualize the regions in Paraview')
		sys.exit(1)
	else:
		create_reg_files(region_nr+1,remaining)

if nr_of_regions<2:
	print('Not enough regions! Quitting program...')
	sys.exit(1)
create_reg_files(2,pts_lst)



