"""USAGE: python vtx_generation.py path/mshName"""

import sys
import shutil
patient=str(sys.argv[1])
infile = open(patient+'.msh','r')	#reading msh file

start_elem=False
end_elem=False
start_node=False
end_node=False
z_coords={}
rv_set=set()
lv_set=set()
base_set=set()
epi_set=set()

#function for adding numbers to set
def add(set_var,words):
	for i in words[5:8]:
		set_var.add(int(i))

#function for writing sorted list to file
def write(sort_lst,location):
	for i in range(len(sort_lst)):
		location.write('{}\n'.format(int(sort_lst[i])-1))

for line in infile:	#reading .msh file
	words=line.split()
	if words[0]=='$Elements':
			start_elem=True
			continue 	#jumping to next line
	if words[0]=='$EndElements':
		end_elem=True
	if words[0]=='$Nodes':
		start_node=True
		continue 	#jumping to next line
	if words[0]=='$EndNodes':
		end_node=True
	if start_node==True and end_node==False:
		if len(words)<4:
			continue
		else:
			z_coords[int(words[0])]=float(words[-1])
	if start_elem==True and end_elem==False:
		if len(words)<4:
			continue
		if words[2]=='2' and words[3]=='2':	#LV
			add(lv_set,words)
		elif words[2]=='2' and words[3]=='3': #RV
			add(rv_set,words)
		elif words[2]=='2' and words[3]=='4': #EPI
			add(epi_set,words)
		elif words[2]=='2' and words[3]=='5': #BASE
			add(base_set,words)
infile.close()

#sorting the sets in increasing order
sorted_lv=sorted(lv_set)
sorted_rv=sorted(rv_set)
sorted_epi=sorted(epi_set)
sorted_base=sorted(base_set)

#adding first line to files: # of nodes
lv=open('lv.vtx','w')
lv.write('{}\n'.format(len(sorted_lv)))
rv=open('rv.vtx','w')	
rv.write('{}\n'.format(len(sorted_rv)))
epi=open('epi.vtx','w')	
epi.write('{}\n'.format(len(sorted_epi)))
base=open('base.vtx','w')
base.write('{}\n'.format(len(sorted_base)))
apex=open('apex.vtx','w')
apex.write('1\n')

#adding second line to files: extra
for f in [lv, rv, epi, base, apex]:
	f.write('extra\n')

#writing the sorted lists to files
write(sorted_lv,lv)
write(sorted_rv,rv)
write(sorted_epi,epi)
write(sorted_base,base)
value=min(z_coords, key=z_coords.get)
apex.write('{}\n'.format(int(value)-1))
for f in [lv, rv, epi, base, apex]:
	f.close()

#import os
#root=os.getcwd()
#for f in ['lv', 'rv', 'epi', 'base', 'apex']:
#	shutil.move('{}/{}.vtx'.format(root,f),'{}/{}/{}.vtx'.format(root,patient,f))
