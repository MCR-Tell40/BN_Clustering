#Python script to extract the 4 ssp from each frame output a list of spp
#Author: Nicholas Mead
#
#*********************

# data = list of frames
# spp_list = list of spp

from str_to_bin import *

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
            spp_list.append(frame[8:38])
            spp_list.append(frame[38:68])
            spp_list.append(frame[68:98])
            spp_list.append(frame[98:128])

    read_out = []
    for spp in spp_list:
        if btoi(spp[22:]) > 0:
            read_out.append(spp)
            
    return read_out
