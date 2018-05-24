import sys,shutil
infile=open(str(sys.argv[1])+'.reorder','r')
reorder_lst={}
counter=0
for line in infile:
	reorder_lst[int(line)]=counter
	counter+=1
infile.close()

vtxpath=str(sys.argv[2])
for name in ['apex','base','lv','rv','epi']:
	shutil.copy('{}/{}.vtx'.format(vtxpath,name),'{}/{}_old.vtx'.format(vtxpath,name))
	out_name=open('{}/{}.vtx'.format(vtxpath,name),'w')
	in_name=open('{}/{}_old.vtx'.format(vtxpath,name),'r')
	num=int(in_name.readline())
	in_name.readline()
	out_name.write('{}\n'.format(num))
	out_name.write('extra\n')
	for line in in_name:
		out_name.write('{}\n'.format(reorder_lst[int(line)]))
	out_name.close()
	in_name.close()
	print('done with {}'.format(name))
