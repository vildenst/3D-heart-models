"""USAGE: python pts_order.py ptspath"""

import sys
infile = open('{}.pts'.format(sys.argv[1]),'r')
nr=int(infile.readline())
infile.close()
out=open('nodes.dat','w')
for i in range(1,nr+1):
	out.write('{}\n'.format(i))
out.close()