import os
import sys
import shutil

#Collecting the folders with times that should not be deleted
def read_status():
	try:
		infile = open('status', 'r')
	except IOError:
		print('No status file in the %s folder') %rootpath
		exit()
	keep = []
	for line in infile:
		words = line.split()
		if len(line.split())>1:
			current_line = words[0]+' '+words[1]
			if current_line == 'Last successful':
				keep.append(words[-1])
	infile.close()
	return keep

#Remove the irrelevant folders, keep the relevant ones
def remove_folders(keep):
	for dirs in os.walk('.').next()[1]:
		if dirs[0:2] == 's1' or dirs[3:7] in keep:
			print('keeping %s') %dirs
		else:
			print('removing %s') %dirs
			shutil.rmtree(dirs)

#Two command line arguments must be given.
#1 - The name of the patient folder to clean
#2 - # sites to clean (4 means site 1-4 will be cleaned)
def run():
	try:
		os.chdir(str(sys.argv[1]))
		nr_sites = int(sys.argv[2])	
	except IndexError:
		print('Must provide two cmd line args: patient folder and #sites')
		exit()
	root = os.getcwd()
	sites = ['site'+str(i) for i in range(1,nr_sites+1)]
	for subfolders in sites:
	 	print('----cleaning up %s-----') %subfolders
	 	if os.path.isdir(subfolders):	#site i exists
	 		os.chdir(subfolders)
	 		remove_folders(read_status())
	 		os.chdir(root)

if __name__ == '__main__':
	run()

