"""
Created by Vilde N. Strom, July 2017.
	Simula Research Laboratory
"""

import os
import shutil 
import datetime

now=datetime.datetime.now()
time = now.strftime("%d.%m-%H.%M")
Date='Data-'+time	#name of output folder

#Assigning variable names to important folders
root=os.getcwd()	#path to Heart_Models_folder
mat_data=root+'/Matlab_Process/Data/'
mat_scar=mat_data+'ScarImages/MetaImages'
mat_txt=mat_data+'Texts'
mat_seg=mat_data+'Seg/'
surf=root+'/Surfaces/'+Date
vtk_srf=surf+'/vtkFiles'
msh_srf=surf+'/mshFiles'
fem=root+'/FEM/'+Date
conv=root+'/Convertion_Process'
scar=root+'/Scar_Process'
script=root+'/scripts/'
program=os.getenv('HOME')+'/Programs'

""" PART 1: MATLAB SLICE ALIGNMENT """
#running the matlab script alignAll.m
def run_matlab(nr_errors,err_list):
	os.system('sh run_matlab.sh')	
	scar_files=os.listdir(mat_scar+'/')
	N2=len(scar_files) #files produces from matlab. 
	if (N-nr_errors)*2 > N2:	#not all .mat files are processed
		remove_error(N2,nr_errors,err_list)

#if an error occured in matlab, this function removes the error file(s) and restarts
def remove_error(N2,nr_errors,err_list): 
		error=(N2+nr_errors*2)/2+1
		err_path='{}Patient_{}.mat'.format(mat_seg,error)
		os.remove(err_path)		
		nr_errors+=1
		err_list.append(error)
		run_matlab(nr_errors,err_list)

#if the error file(s) produced any text files, they're deleted here.
def remove_error_files(fname):
	for i in ['LVEndo','LVEpi','RVEndo','RVEpi']:
		if os.path.isfile('{}/{}-{}-Frame_1.txt'.format(mat_txt,fname,i)):
			os.remove('{}/{}-{}-Frame_1.txt'.format(mat_txt,fname,i))

source ='{}/seg/'.format(root) #.mat files source path
files=os.listdir(source)
N=len(files)	#number of .mat files to be processed
nr_errors=0
err_list=[]
for f in files:
	shutil.copy(source+f,mat_seg+f)	#move all .mat files to Seg in Matlab_Process

os.chdir('Matlab_Process')
run_matlab(nr_errors,err_list)
if err_list:	#errors occured
	for nr in err_list:
		fname='Patient_{}'.format(nr)
		remove_error_files(fname)
		os.system('echo {} was removed due to errors. Will continue without it.'.format(fname))

os.system('echo PART 1 DONE: SLICES ALIGNED')


""" PART 2: SURFACE GENERATION """
#moves all files in a directory
def move(src,dst):
	src_files=os.listdir(src)
	for f in src_files:
		shutil.move(src+'/'+f,dst+'/'+f)

#runs a bash program with a given path
def run(path,script):
	os.chdir(path)
	os.system('sh {}'.format(script))


#removes all files in a list of folders
def remove(folder_list):
	for i in folder_list:
		files=os.listdir(mat_data+i)
		for f in files:
			os.remove(mat_data+i+f)

#creating new output folder for the surface data
os.system('echo Creating folder {} for data storage'.format(Date))
os.mkdir(surf)

#moving and deleting files before starting surface generation
move(mat_txt,conv)
move(mat_scar,scar+'/Data')
remove(['Aligned/','Seg/'])

#generating and moving heart surfaces
os.system('echo Making surfaces')
run(conv,'make_surface_all.sh')
os.system('echo Moving files to Surfaces')
for i in ['plyFiles','vtkFiles','txtFiles']:
	os.chdir(conv+'/Data/'+i)
	os.mkdir(surf+'/'+i)
	move(os.getcwd(),surf+'/'+i)

#generating and moving scar surfaces
os.system('echo Making scar surfaces')
run(scar,'run.sh')
os.system('echo Moving scar files to Surfaces')
src=os.listdir(scar+'/Data')
for f in src:
	if f.endswith('.vtk'):
		shutil.move(scar+'/Data/'+f,surf+'/vtkFiles/')
	else:
		os.remove(scar+'/Data/'+f)

os.system('echo All .vtk files are stored in Surfaces/{}/vtkFiles'.format(Date))
os.system('echo PART 2 DONE: MAKING SURFACES')

""" PART 3: GENERATION OF FEM FILES """
os.mkdir(msh_srf)	#storing msh and msh output files here
os.mkdir(fem)	#storing pts, elem and tris files here
shutil.copyfile('{}remove_site_times.py'.format(script),fem+'/remove_site_times.py')

#Generating .msh files from .vtk files
def mergevtk(i,msh_srf,vtk_srf):	
	lv_endo='{}/Patient_{}-LVEndo-Frame_1.vtk'.format(vtk_srf,i)
	rv_endo='{}/Patient_{}-RVEndo-Frame_1.vtk'.format(vtk_srf,i)
	rv_epi='{}/Patient_{}-RVEpi-Frame_1.vtk'.format(vtk_srf,i)
	msh='{}/Patient_{}.msh'.format(msh_srf,i)
	out='{}/Patient_{}.out.txt'.format(msh_srf,i)
	biv_mesh='{}/scripts/biv_mesh.geo'.format(root)
	gmsh='/usit/abel/u1/vildenst/Programs/gmsh/build/gmsh' 	#path to gmsh
	os.system('{} -3 {} -merge {} {} {} -o {} >& {}'.format(
		gmsh, lv_endo, rv_endo, rv_epi, biv_mesh, msh, out))

#function for generating pts, elem and tris files from msh files
def write_fem(input_file,outputname):
	infile=open(input_file,'r')
	outfile_pts=open(outputname+'.pts','w')
	outfile_elem=open(outputname+'.elem','w')
	outfile_tris=open(outputname+'.tris','w')
	start_pts=False
	end_pts=False
	start_elem=False
	end_elem=False
	elem_count=0
	for line in infile:
		words=line.split()
		#pts part
		#write_pts(start_pts,end_pts,words,outfile_pts)
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
		#elem and tris part
		#write_elem(start_elem,end_elem,words,outfile_elem,outfile_tris)
		if words[0]=='$Elements':
			start_elem=True
			continue 	#jumping to next line
		if words[0]=='$EndElements':
			end_elem=True
		if start_elem==True and end_elem==False:
			if len(words)==1:	#first line to write
				outfile_elem.write('{}\n'.format('NR_ELEMENTS')) #writing up nr of elements
			elif len(words)>7:
				i=int(words[5])-1
				j=int(words[6])-1
				k=int(words[7])-1
				if words[1]=='2':
					outfile_tris.write('{} {} {} 1\n'.format(i,j,k))
				elif words[1]=='4':
					elem_count+=1
					l=int(words[8])-1
					outfile_elem.write('Tt {} {} {} {} 1\n'.format(i,j,k,l))
	infile.close()
	outfile_pts.close()
	outfile_elem.close()
	outfile_tris.close()
	elem_name=outputname+'.elem'
	os.system('sed -i -e "s|NR_ELEMENTS|{}|g" {}'.format(elem_count,elem_name))

#Adjusting and moving files to each patient folder
def write_files(pat_path,i):
	shutil.copyfile('{}stim_coord.dat'.format(script),pat_path+'/stim_coord.dat')
	shutil.copyfile('{}base.par'.format(script),pat_path+'/base.par')
	infile=open('{}risk_strat_1_16.sh'.format(script),'r').readlines()
	outfile=open(pat_path+'/risk_strat_1_16.sh','w')
	new_jobid='#SBATCH --job-name=Pat_{}'.format(i)
	for line in infile:
		if line != infile[2]:
			outfile.write(line)
		else:
			outfile.write(new_jobid+'\n')	#changes jobid to current patient
	outfile.close()

for i in range(1,N+1):
	if os.path.isfile('{}/Patient_{}_scar.vtk'.format(vtk_srf,i)):	#patient exists
		mergevtk(i,msh_srf,vtk_srf)	#generation of .msh files
		os.system('echo Generated .msh file for Patient {}.'.format(i))

		#generating pts, tris and elem files from msh files
		write_fem('{}/Patient_{}.msh'.format(msh_srf,i),'Patient_{}'.format(i))
		os.system('echo Generated .tris, .elem and .pts file for Patient {}.'.format(i))

		#moving FEM files to correct folder
		patient_path='{}/Patient_{}'.format(fem,i)
		os.mkdir(patient_path)
		for j in ['tris', 'elem', 'pts']:
			os.rename('Patient_{}.{}'.format(i,j), '{}/Patient_{}.{}'.format(patient_path,i,j))

		#creating stim_coord.dat and rist_strat_1_16.sh in each patient folder
		write_files(patient_path,i)

os.system('echo All .msh and .out.txt files are stored in Surfaces/mshFiles')
os.system('echo All FEM files are stored in FEM/Data-{}'.format(time))
os.system('echo PART 3 DONE: GENERATED FEM MODELS')
