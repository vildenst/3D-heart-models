import sys
name=str(sys.argv[1])
output=str(sys.argv[2])
infile_pts=open('{}.pts'.format(name),'r')
infile_elem=open('{}.elem'.format(name),'r')
infile_lon=open('{}.lon'.format(name),'r')
out=open('{}.vtk'.format(output),'w')
out.write('# vtk DataFile Version 4.1\n')
out.write('vtk output\n')
out.write('ASCII\n')
out.write('DATASET UNSTRUCTURED_GRID\n')
nr_pts=infile_pts.readline()
out.write('POINTS {} float\n'.format(nr_pts[:-1]))
for line in infile_pts:
	out.write(line)
infile_pts.close()
out.write('\n')
nr_elem=infile_elem.readline()[:-1]
out.write('CELLS {} {}\n'.format(nr_elem,int(nr_elem)*5))
for line in infile_elem:
	num=line.split()
	out.write('4 {} {} {} {}\n'.format(int(num[1]),int(num[2]),int(num[3]),int(num[4])))
out.write('\n')
out.write('CELL_TYPES {}\n'.format(nr_elem))
for i in range(int(nr_elem)):
	out.write('10\n')
infile_elem.close()
out.write('\n')
out.write('CELL_DATA {}\n'.format(nr_elem))
out.write('\n')
out.write('VECTORS vectors double\n')
infile_lon.readline()
for line in infile_lon:
	num=line.split()
	out.write('{} {} {}\n'.format(num[0],num[1],num[2]))
infile_lon.close()
out.close()

