#Python script to extract the 4 ssp from each frame output a list of spp
#Author: Nicholas Mead
#
#*********************

# data = list of frames
# spp_list = list of spp

from conversion import *

def split_spp(data):

    class spp:
        def __init__ (self, spp):
            self.string = spp
            self.BCID = gtoi(spp[:9])
            #self.SPP_address = stob(spp[9:22])
            self.hit_map = btoi(spp[22:])
    
    #split the frames into lists of spp
    spp_list = []
    for frame in data:
        if frame == '':
            break
        else:
            
            rev_frame = frame[:7:-1]

            spp_list.append(rev_frame[0:30])
            spp_list.append(rev_frame[30:60])
            spp_list.append(rev_frame[60:90])
            spp_list.append(rev_frame[90:120])

    read_out = []
    for spp in spp_list:
        if btoi(spp[:22]) > 0:
            read_out.append(spp)
            
    return read_out
