import sys
from conversion import *

if len(sys.argv) != 2:
    exit()


n = sys.argv[1]

Udata = open('../desync_spp/desync_spp' + str(n) + '.txt').read().split('\n')
Sdata = open('../timesync/timesync' + str(n) + '.txt').read().split('\n')

for x in range(0,len(Sdata)):
    print gtoi(Udata[x][:9]), '\t', gtoi(Sdata[x][:9])

    
