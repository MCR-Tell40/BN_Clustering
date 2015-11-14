from quicksort import quick_sort
from splitspp import split_spp
import sys
from threading import Thread
from multiprocessing import Process

def time_sort(data):
    test_bcid = 0x155
    time_gap = []
    count = 0
    max_latancy = 512

    cycle_count = []
    latancy_count = []
    bcid_collection = []
    bunch_list = []
    final_list = []
    for i in range(0,512):
        cycle_count.append(0)
        latancy_count.append(0)
        bcid_collection.append([])
    
    data_readout = []
    for each_spp in data:
        for bcid in range (0,512):
            if each_spp.BCID != bcid:
                latancy_count[bcid] += 1
            elif latancy_count[bcid] < max_latancy:
                bcid_collection[bcid].append(each_spp)
                latancy_count[bcid] = 0
            else:
                cycle_count[bcid] += 1
                while len(bcid_collection) <= (bcid + cycle_count[bcid]*512):
                    bcid_collection.append([])
                bunch_list.append(bcid_collection[bcid])
                bcid_collection[bcid] = []
                latancy_count[bcid]=0

    for each_bunch in bunch_list:
        for each_spp in each_bunch:
            final_list.append(each_spp)

    for each_bunch in bcid_collection:
        for each_spp in each_bunch:
            final_list.append(each_spp)
            
    return final_list
                
def run_for_file(core):
    print 'begining process', core
    for X in reversed(range(0,624)):
        if X % 3 == core:
            with open('desync' + str(X) + '.txt') as in_file:
                print 't:', core, '\topening file\t\t', X
                raw_data = in_file.read()
        
            raw_data = raw_data.split('\n')
            raw_data = split_spp(raw_data) 
        
            with open('desync_spp' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp.string + '\n')
                print 't:', core, '\tsaving desync_spp\t', X

            raw_data = time_sort(raw_data)
            
            with open('timesync' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp.string + '\n')
                print 't:', core, '\tsaving timesync\t\t', X

if __name__ == '__main__':
    for i in range(0,int(sys.argv[1])):
        p = Process(target=run_for_file, args=(i,)).start()
    

