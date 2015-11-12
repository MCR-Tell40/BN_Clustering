#Python script to extract the 4 ssp from each frame and combine with the BCID
#Author: Nicholas Mead
#
#*********************

import sys
from quicksort import quick_sort

#filenames
in_filename = 'desync9X.txt'
out_filename = 'desync9X_GWT.txt'

def __main__():

    class spp:
        def __init__ (self, spp):
            self.full = spp
            self.BCID = spp[:9]
            self.SPP_address = spp [9:22]
            self.hit_map = spp[22:]
    
    #read file into frame
    with open(in_filename) as in_file:
        frame_array = in_file.read()

    #create array of ssp's from file text
    frame_array = frame_array.split('\n')
        
    #split the frames into arrays of spp
    spp_array = []
    for frame in frame_array:
        if frame == '':
            break
        else:
            spp_array.append(spp(frame[8:38]))
            spp_array.append(spp(frame[38:68]))
            spp_array.append(spp(frame[68:98]))
            spp_array.append(spp(frame[98:128]))
            
    print 'Begining Sort'
                
    spp_array = quick_sort(spp_array, len(spp_array))

    with open(out_filename, 'w') as out_file:
        for spp in spp_array:
            out_file.write( spp.full + '\n' )
                 
if __name__ == '__main__':
    __main__()
