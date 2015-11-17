from splitspp import *
import sys
from multiprocessing import Process
from copy import deepcopy

# ----------- sorting algorithum ----------- # 

def time_sort(data):
    
    # Containers
    bunch_list = []
    final_list = []
    
    for x in xrange(0,512):
        bunch_list.append([])

    prev_opp = -1 # -1 so initial state is detectable
    for x in range(0,len(data)):
        bcid = gtoi(data[x][:9]) #read bicd as int from gray code
        bunch_list[bcid].append(deepcopy(data[x])) #store in bcid ordered list
        opp = (bcid + 256) % 512 #calculate 'opposite' bcid i.e. the one 256 away
         
        #initialise prev_opp
        if prev_opp == -1: 
            prev_opp = opp

        #check if bcid is bigger than previos largest
        if prev_opp < opp and opp - prev_opp < 256:
            for bcid in range(prev_opp, opp):
                if len(bunch_list[bcid]) > 0:
                    for spp in bunch_list[bcid]:
                        final_list.append(deepcopy(spp))
                bunch_list[bcid] = []
            prev_opp = opp

        #check if bcid has reset
        elif (opp - prev_opp) < -256: #i.e. opp has cycled back round to 0 but prev_opp has not
            for bcid in range(prev_opp,512) + range(0,opp):
               if len(bunch_list[bcid]) > 0:
                    for spp in bunch_list[bcid]:
                        final_list.append(deepcopy(spp))
               bunch_list[bcid] = []
            prev_opp = opp
            
    #add all remaining bcid's to final list in correct order
    for bcid in range(prev_opp,512) + range(0,prev_opp):
        for spp in bunch_list[bcid]:
            final_list.append(spp)
           
    return final_list
    
# ----------- file control ----------- # 

def run_for_file(desync_path, desync_spp_path, timesync_path, core):
    print 'begining process', core
    for X in reversed(range(0,624)):
        if X % int(sys.argv[4]) == core:
            with open(desync_path + '/desync' + str(X) + '.txt') as in_file:
                print 't:', core, '\topening file\t\t', X
                raw_data = in_file.read().split('\n')
            raw_data = split_spp(raw_data) 
        

            with open(desync_spp_path +'/desync_spp' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp + '\n')
                print 't:', core, '\tsaving desync_spp\t', X


            raw_data = time_sort(raw_data)
            
            with open(timesync_path + '/timesync' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp + '\n')
                print 't:', core, '\tsaving timesync\t\t', X
               
# ----------- main ----------- # 

if __name__ == '__main__':
    desync_path = sys.argv[1]
    desync_spp_path = sys.argv[2]
    timesync_path = sys.argv[3]
    for i in range(0,int(sys.argv[4])):
        p = Process(target=run_for_file, args=(desync_path, desync_spp_path, timesync_path,i)).start()
        
