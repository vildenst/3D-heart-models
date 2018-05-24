"""USAGE: python create_par.py nr_regions pathto:TT_ISCH"""
import sys

out=open('base.par','w')
nr_reg=int(sys.argv[1])

out.write("#Don't change anything below this line\n")
out.write("dt = 25   #time step size in us\n")
out.write("num_external_imp = 1   #Load custom ionic model\n")
out.write("external_imp[0] = {}TT_ISCH.so\n".format(sys.argv[2]))
out.write('\n')
out.write("num_imp_regions = {}\n".format(nr_reg))
out.write('imp_region[0].name = "normal"\n')
out.write('imp_region[0].im = "TT_ISCH"   #Augmented LRDII\n')
out.write("imp_region[0].num_IDs = 1\n")
out.write("imp_region[0].ID[0] = 1\n")
out.write('imp_region[0].im_param = "cell_type=2,Gkr=.172,Gks=.441,GpCa=.8666,GpK=.00219"\n')
out.write('\n')


i=0.8
j=7.5
for region in range(1,nr_reg):
	if region>(nr_reg*5./6):
		j=10
	elif region>(nr_reg*4./6):
		j=9
	elif region>(nr_reg/2):
		i=0.7
		j=8.5
	elif region>(nr_reg*2./6):
		j=8

	out.write('imp_region[{}].name = "infarct"\n'.format(region))
	out.write('imp_region[{}].im  = "TT_ISCH" #Augmented LRDII\n'.format(region))
	out.write('imp_region[{}].num_IDs = 1\n'.format(region))
	out.write('imp_region[{}].ID[0] = {}\n'.format(region,region+1))
	out.write('imp_region[{}].im_param = "cell_type=2,jb_Ina*{},jb_Ical*{},Gkr=.172,Gks=.441,GpCa=.8666,GpK=.00219,Ko={},fATP=.0049"\n'.format(region,i,i,j))
	out.write('\n')


if nr_reg >1:
	out.write('num_gregions = 2\n')
else:
	out.write('num_gregions = 1\n')
out.write('\n')

out.write('#healthy tissue\n')
out.write('#gregion[0].description = "heart"\n')
out.write('gregion[0].g_il = 0.255 #standard g_il/10\n')
out.write('gregion[0].g_it = 0.0775\n')
out.write('gregion[0].num_IDs = 1\n')
out.write('gregion[0].ID[0] = 1\n')

if nr_reg>1:
	out.write('\n')
	out.write('#"infarct" tissue\n')
	out.write('gregion[1].g_il = 0.153\n')
	out.write('gregion[1].g_it = 0.0465\n')
	out.write('gregion[1].num_IDs = {}\n'.format(nr_reg-1))
	for i in range(nr_reg-1): 
		out.write('gregion[1].ID[{}] = {}\n'.format(i,i+2))



out.write('\n')
out.write('timedt = 10  #output status every xx ms\n')
out.write('# geometric data \n')
out.write('experiment = 0  #3D simulation\n')

out.write('\n')
out.write('mat_entries_per_row = 90\n')
out.write('cg_tol_ellip = 1e-4\n')
out.write('bidomain = 0\n')
out.write('purkEleType = 0 #no purkinje fibers\n')
out.write('vm_per_phie = 2\n')
out.write('parab_solve = 1   #CN is on\n')
out.write('#mass_lumping = 0\n')

out.write('\n')
out.write('num_LATs=1\n')
out.write('lats[0].measurand = 0\n')
out.write('lats[0].all = 1\n')
out.write('lats[0].threshold = 0.0\n')
out.write('lats[0].method = 1\n')
