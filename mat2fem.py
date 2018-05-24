"""
Created by Vilde N. Strom, July 2017. Last updated May 2018.
"""

"""Imports and folder decrelations"""
import os,glob,shutil,sys,re


Date='Data-'+str(sys.argv[2])
pat_nr=int(sys.argv[1])
patname="Patient_{}".format(pat_nr)
root=os.getcwd()
mat_data=root+'/Matlab_Process/Data/'
mat_scar=mat_data+'ScarImages/MetaImages'
mat_txt=mat_data+'Texts'
mat_seg=mat_data+'Seg/'
pre_folder=root+'/Files/'+Date
surf=root+'/Files/'+Date+'/'+patname
vtk_srf=surf+'/vtkFiles'
msh_srf=surf+'/mshFiles'
scar_srf=surf+'/scarFiles'
vtxpath=surf+'/PreFiberFiles'
pre_fem=root+'/FEM/'+Date
fem=root+'/FEM/'+Date+'/'+patname
conv=root+'/Convertion_Process'
scar=root+'/Scar_Process'
script=root+'/scripts/'
program=os.getenv('HOME')+'/Programs'
gmsh='/usit/abel/u1/vildenst/Programs/gmsh/build/gmsh' 

""" FUNCTIONS PART 1: MATLAB SLICE ALIGNMENT """
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

""" PART 1: MATLAB SLICE ALIGNMENT """
source ='{}/seg/current_patient/'.format(root) #.mat files source path
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
		os.system('echo Patient was removed due to errors. Will continue without it.')
		sys.exit(1)

os.system('echo PART 1 DONE: SLICES ALIGNED')


""" FUNCTIONS PART 2: SURFACE GENERATION """
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


#rename to correct patient number
def rename(folder,nr,filetype):
	os.chdir(folder)
	for f in glob.glob('*.{}'.format(filetype)):
		newname=re.sub("(?:Patient_1)","Patient_"+str(nr),f)
		shutil.move(f,newname)
	os.chdir(root)


""" PART 2: SURFACE GENERATION """
#creating new output folder for the surface data
os.system('echo Creating folder {} for data storage'.format(surf))
if not os.path.exists(pre_folder):
	os.mkdir(pre_folder)
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
	folder=surf+'/'+i
	os.mkdir(folder)
	move(os.getcwd(),folder)	


#generating and moving scar surfaces
os.system('echo Making scar surfaces')
run(scar,'run.sh')
os.system('echo Moving scar files')
src=os.listdir(scar+'/Data')
for f in src:
	if f.endswith('.vtk'):
		shutil.move(scar+'/Data/'+f,surf+'/vtkFiles/')
	else:
		os.remove(scar+'/Data/'+f)

for filetype in ['txt','ply','vtk']:
	rename(surf+'/'+filetype+'Files',pat_nr,filetype)

os.system('echo All .vtk files are stored in Files/{}/{}/vtkFiles'.format(Date,patname))
os.system('echo PART 2 DONE: VTK SURFACES GENERATED')


""" FUNCTIONS PART 3: GENERATION OF MODELS & CARP FILES"""
#Generating .msh files from .vtk files
def mergevtk(i,msh_srf,vtk_srf):	
	lv_endo='{}/Patient_{}-LVEndo-Frame_1.vtk'.format(vtk_srf,i)
	rv_endo='{}/Patient_{}-RVEndo-Frame_1.vtk'.format(vtk_srf,i)
	rv_epi='{}/Patient_{}-RVEpi-Frame_1.vtk'.format(vtk_srf,i)
	msh='{}/Patient_{}.msh'.format(msh_srf,i)
	out='{}/Patient_{}.out.txt'.format(msh_srf,i)
	biv_mesh='{}/scripts/biv_mesh.geo'.format(root)
	os.system('{} -3 {} -merge {} {} {} -o {} >& {}'.format(
		gmsh, lv_endo, rv_endo, rv_epi, biv_mesh, msh, out))

#function for generating pts, elem files from msh files
def write_fem(input_file,outputname):
	os.system('python {}write_fem.py {} {}'.format(script,input_file,outputname))

def enough_scar(scarvol):
	counter=0
	for line in open(scarvol).xreadlines():
		counter+=1
		if counter>3000:
			return True
	return False

def incorporate_scar(i,surfmsh,volmsh,patient_path,regfile):
	#generate CARP files of scar and move to scarFiles
	surfname='Patient_{}_scarsurf'.format(i)
	volname='Patient_{}_scarvol'.format(i)
	write_fem(surfmsh,surfname)
	write_fem(volmsh,volname)
	for j in ['elem', 'pts']:
		os.rename('{}.{}'.format(surfname,j),'{}/{}.{}'.format(scar_srf,surfname,j))
		os.rename('{}.{}'.format(volname,j),'{}/{}.{}'.format(scar_srf,volname,j))

	#find element centers of heart model and move to scarFiles
	os.system('python {}elemcenters.py {}/Patient_{}'.format(script,msh_srf,i))
	centers='{}/Patient_{}_centers.dat'.format(scar_srf,i)
	os.rename('elemcenters.dat',centers)

	#generate scar regions
	surfpath=scar_srf+'/'+surfname
	volpath=scar_srf+'/'+volname
	os.system('python {}generate_regions.py {} {} {}'.format(script,surfpath,volpath,i))
	regions='{}/Patient_{}_regions.dat'.format(scar_srf,i)
	os.rename('done.pts',regions)
	os.rename(regfile,'{}/{}'.format(scar_srf,regfile))

	#include scar regions into elem file
	args='{} {} {} {}/Patient_{}'.format(surfpath,centers,regions,msh_srf,i)
	os.system('python {}connect_meshes.py {}'.format(script,args))
	src='{}/Patient_{}.elem'.format(msh_srf,i)
	dst='{}/Patient_{}.elem'.format(patient_path,i)
	os.rename(src,dst)

def includescar(i,patient_path):
	os.chdir(msh_srf)
	scarvtk=vtk_srf+'/Patient_{}_scar.vtk'.format(i)
	surf_geo=script+'scar_surf.geo'
	vol_geo=script+'scar_vol.geo'
	surfmsh="{}/Patient_{}_scarsurf.msh".format(msh_srf,i)
	volmsh="{}/Patient_{}_scarvol.msh".format(msh_srf,i)
	surfout='{}/Patient_{}_scarsurf.out.txt'.format(msh_srf,i)
	volout='{}/Patient_{}_scarvol.out.txt'.format(msh_srf,i)

	#generate Finite element surface and volume of scar
	os.system('{} -3 {} {} -o {} >& {}'.format(gmsh,scarvtk,surf_geo,surfmsh,surfout))
	os.system('{} -3 {} {} -o {} >& {}'.format(gmsh,scarvtk,vol_geo,volmsh,volout))

	regfile='nr_regions_Patient_{}.dat'.format(i)
	if enough_scar(volmsh):
		incorporate_scar(i,surfmsh,volmsh,patient_path,regfile)
	else:
		os.system('echo Remark: No scar tissue for Patient {}'.format(i))
		nr_reg_out=open('{}/{}'.format(scar_srf,regfile),'w')
		nr_reg_out.write('1\n')
		nr_reg_out.close()
		name='Patient_{}.elem'.format(i)
		os.rename('{}/{}'.format(msh_srf,name), '{}/{}'.format(patient_path,name))
	return regfile

def multiplypts(i,patient_path):
	os.system('python {}multiply_pts.py {}/Patient_{}'.format(script,msh_srf,i))
	src='{}/Patient_{}.pts'.format(msh_srf,i)
	dst='{}/Patient_{}_original.pts'.format(msh_srf,i)
	os.rename(src,dst)
	src='{}/Patient_{}_new.pts'.format(msh_srf,i)
	dst='{}/Patient_{}.pts'.format(patient_path,i)
	os.rename(src,dst)

def vtxgeneration(i):
	os.chdir(vtxpath)
	tmp='Patient_{}'.format(i)
	os.system('python {}vtx_generation.py {}/Patient_{}'.format(script,msh_srf,i))
	os.system('sh {}fix_elem_prelon.sh {} {}/{}'.format(script,tmp,patient_path,tmp))
	shutil.copyfile(script+'run.sh',vtxpath+'/run.sh')

def pargeneration(patient_path,regfile):
	regionfile=open('{}/{}'.format(scar_srf,regfile),'r')
	nr_reg=regionfile.readline().strip()
	regionfile.close()
	os.system('python {}create_par.py {} {}'.format(script,nr_reg,script))
	os.rename('base.par','{}/base.par'.format(patient_path))


#Adjusting and moving files to each patient folder
def write_files(pat_path,i):
	infile=open('{}risk_strat_1_16.sh'.format(script),'r').readlines()
	outfile=open(pat_path+'/risk_strat_1_16.sh','w')
	new_jobid='#SBATCH --job-name=Pat_{}'.format(i)
	for line in infile:
		if line != infile[2]:
			outfile.write(line)
		else:
			outfile.write(new_jobid+'\n')	#changes jobid to current patient
	outfile.close()


def reorder(i,patpath):
	os.system('python {}reorder_axis.py {} {} Patient_{}'.format(script,msh_srf,patpath,i))
	for f in ['reorder','pts','elem']:
		name='Patient_{}_reorder.{}'.format(i,f)
		os.rename(name,'{}/{}'.format(patpath,name))

def findcoordinates(i,patpath):
	os.system('python {}find_coord.py Patient_{} {} {}'.format(script,i,msh_srf,patpath))
	os.rename('stim_coord.dat','{}/stim_coord.dat'.format(patpath))

def fix_vtx(i,patpath):
	os.system('python {}fix_vtx.py {}/Patient_{}_reorder {}'.format(script,patpath,i,vtxpath))
	for tmp in ['base','epi','lv','rv','apex']:
		os.rename(tmp+'.vtx','{}/{}.vtx'.format(vtxpath,tmp))

""" PART 3: GENERATION OF MODELS AND CARP FILES"""
for f in [msh_srf,pre_fem,fem,scar_srf,vtxpath]:
	if not os.path.exists(f):
		os.mkdir(f)

i=int(pat_nr)
if os.path.isfile('{}/Patient_{}_scar.vtk'.format(vtk_srf,i)):	#patient exists
	os.system('echo Creating a finite element mesh for Patient {}, may take some time...'.format(i))
	os.system('echo The finite element generation progress can be inspected in Files/{}/{}/mshFiles'.format(Date,patname))
	mergevtk(i,msh_srf,vtk_srf)	#generation of .msh files
	os.system('echo Generated .msh file for Patient {}.'.format(i))

	#generating pts, tris and elem files from msh files
	os.system('echo Generating CARP files for Patient {}'.format(i))
	write_fem('{}/Patient_{}.msh'.format(msh_srf,i),'Patient_{}'.format(i))
	patient_path=fem
	for j in ['elem', 'pts']:
		os.rename('Patient_{}.{}'.format(i,j), '{}/Patient_{}.{}'.format(msh_srf,i,j))

	#including scar 
	os.system('echo Including scar tissue into the model for Patient {}'.format(i))
	regfile = includescar(i,patient_path)

	multiplypts(i,patient_path)
	os.system('echo Generating pre-fiber orientation files in Files/{}/{}/PreFiberFiles'.format(Date,patname))
	vtxgeneration(i)
	os.system('echo Generating a patient specific paramater file')
	pargeneration(patient_path,regfile)
	write_files(patient_path,i)
	reorder(i,patient_path)
	for j in ['elem', 'pts']:
		name='Patient_{}.{}'.format(i,j)
		os.rename('{}/{}'.format(patient_path,name), '{}/{}'.format(msh_srf,name))
	findcoordinates(i,patient_path)
	fix_vtx(i,patient_path)
		

		

os.system('echo PART 3 DONE: GENERATED MODELS AND NECESSARY CARP FILES')
os.system('echo ==========PROCESS COMPLETE=============')
os.system('echo All .msh and .out.txt files are stored in Files/{}/{}/mshFiles'.format(Date,patname))
os.system('echo All scar generation files are stored in Files/{}/{}/scarFiles'.format(Date,patname))
os.system('echo All pre-fiber orientation files are stored in Files/{}/{}/PreFiberFiles'.format(Date,patname))
os.system('echo All CARP files are stored in FEM/{}/{}'.format(Date,patname))
os.system('echo =======================================')

