"""USAGE: python write_fem.py pathtofile.msh outputname"""

import sys
import os

input_file=str(sys.argv[1])
outputname=str(sys.argv[2])

def write_fem(input_file,outputname):
	infile=open(input_file,'r')
	outfile_pts=open(outputname+'.pts','w')
	outfile_elem=open(outputname+'.elem','w')
	start_pts=False
	end_pts=False
	start_elem=False
	end_elem=False
	elem_count=0
	for line in infile:
		words=line.split()
		if words[0]=='$Nodes':
			start_pts=True
			continue
		if words[0]=='$EndNodes':
			end_pts=True
		if start_pts==True and end_pts==False:
			if len(words)==1:	#first line to write
				outfile_pts.write('{}\n'.format(words[0]))
			else:
				outfile_pts.write('{} {} {}\n'.format(words[1],words[2],words[3]))
		if words[0]=='$Elements':
			start_elem=True
			continue 	#jumping to next line
		if words[0]=='$EndElements':
			end_elem=True
		if start_elem==True and end_elem==False:
			if len(words)==1:	#first line to write
				outfile_elem.write('{}\n'.format('NR_ELEMENTS'))	#writing up nr of elements
				continue
			elif len(words)>7:
				i=int(words[5])-1
				j=int(words[6])-1
				k=int(words[7])-1
				if words[1]=='4':
					elem_count+=1
					l=int(words[8])-1
					outfile_elem.write('Tt {} {} {} {} 1\n'.format(i,j,k,l))
	infile.close()
	outfile_pts.close()
	outfile_elem.close()
	elem_name=outputname+'.elem'
	os.system('sed -i -e "s|NR_ELEMENTS|{}|g" {}'.format(elem_count,elem_name))
	
write_fem(input_file,outputname)