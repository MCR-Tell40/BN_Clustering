from quicksort import quick_sort
from splitspp import split_spp
from conversion import *
import sys
from threading import Thread
from multiprocessing import Process
from copy import deepcopy

def time_sort(data):
    
    bunch_list = []
    for x in xrange(0,512):
        bunch_list.append([])
    
    final_list = []

    prev_opp = -1
    for x in range(0,len(data)):
        bcid = gtoi(data[x][:9])
        bunch_list[bcid].append(deepcopy(data[x]))
        opp = (bcid + 256) % 512
         
        if prev_opp == -1:
            prev_opp = opp

        #print prev_opp, '\t', opp
            
        if prev_opp < opp and opp - prev_opp < 256:
            for bcid in range(prev_opp, opp):
                if len(bunch_list[bcid]) > 0:
                    for spp in bunch_list[bcid]:
                        final_list.append(deepcopy(spp))
                        #print '\t'*2, gtoi(spp[:9])
                bunch_list[bcid] = []
            prev_opp = opp
       
        elif (opp - prev_opp) < -256: #i.e. opp has cycled back round to 0 but prev_opp has not
            for bcid in range(prev_opp,512) + range(0,opp):
               if len(bunch_list[bcid]) > 0:
                    for spp in bunch_list[bcid]:
                        final_list.append(deepcopy(spp))
                        #print '\t'*2, gtoi(spp[:9])
               bunch_list[bcid] = []
            prev_opp = opp

        #else:
        #    print 'no print'
            
    for bcid in range(prev_opp,512):
        for spp in bunch_list[bcid]:
            final_list.append(spp)
    for bcid in range(0,prev_opp):
        for spp in bunch_list[bcid]:
            final_list.append(spp)
           
    return final_list
    
def run_for_file(core):
    print 'begining process', core
    for X in reversed(range(0,624)):
        if X % int(sys.argv[1]) == core:
            with open('desync' + str(X) + '.txt') as in_file:
                print 't:', core, '\topening file\t\t', X
                raw_data = in_file.read()
        
            raw_data = raw_data.split('\n')
            raw_data = split_spp(raw_data) 
        
            with open('desync_spp' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp + '\n')
                print 't:', core, '\tsaving desync_spp\t', X

            raw_data = time_sort(raw_data)
            
            with open('timesync' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp + '\n')
                print 't:', core, '\tsaving timesync\t\t', X
               
if __name__ == '__main__':
    for i in range(0,int(sys.argv[1])):
        p = Process(target=run_for_file, args=(i,)).start()
        
