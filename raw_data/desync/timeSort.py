from quicksort import quick_sort
from splitspp import split_spp
    
def time_sort(data):
    test_bcid = 0x155
    time_gap = []
    count = 0

#    for each_spp in data:
#       if each_spp.BCID == test_bcid:
#            time_gap.append(count)
#            count = 0
#        else: #each_spp.BCID != test_bcid:
#            count += 1
# 
#   time_gap = quick_sort(time_gap,len(time_gap))

    max_latancy = 512

#    for i in range(1,len(time_gap)):
#        if (time_gap[i]-time_gap[i-1]) > max_latancy:
#            max_latancy = time_gap[i] - time_gap[i-1]
#            latancy_cutoff = time_gap[i] + (0.5 * max_latancy)


    cycle_count = []
    latancy_count = []
    bcid_collection = []
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
                bcid_collection[bcid + cycle_count[bcid]].append(each_spp)
                latancy_count[bcid] = 0
            else:
                cycle_count[bcid] += 1
                while len(bcid_collection) <= (bcid + cycle_count[bcid]*512):
                    bcid_collection.append([])
                bcid_collection[bcid+cycle_count[bcid]*512]
                latancy_count[bcid]=0

    final_list = []
    for each_collection in bcid_collection:
        for each_spp in each_collection:
            final_list.append(each_spp)

    return final_list
                
def __main__():
    for X in reversed(range(0,624)):
        with open('desync' + str(X) + '.txt') as in_file:
            print 'opening file\t\t', X
            raw_data = in_file.read()
        
        raw_data = raw_data.split('\n')
        raw_data = split_spp(raw_data) 
        
        with open('desync_spp' + str(X) + '.txt', 'w') as out_file:
            for each_spp in raw_data:
                out_file.write(each_spp.string + '\n')
            print 'saving desync_spp\t', X

        raw_data = time_sort(raw_data)
            
        with open('timesync' + str(X) + '.txt', 'w') as out_file:
            for each_spp in raw_data:
                out_file.write(each_spp.string + '\n')
            print 'saving timesync\t\t', X

if __name__ == '__main__':
    __main__()
