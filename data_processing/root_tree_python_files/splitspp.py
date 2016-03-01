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
            self.SPP_address = stob(spp[9:22])
            self.hit_map = btoi(spp[22:])
    
    #split the frames into lists of spp
    spp_list = []
    for frame in data:
        if frame == '':
            break
        elif frame[:4]=="0110": # "idle" header
            pass
        else:
            spp_list.append(frame[37:7:-1])
            spp_list.append(frame[67:37:-1])
            spp_list.append(frame[97:67:-1])
            spp_list.append(frame[128:97:-1])
            
    #return spp_list
    read_out = []
    for spp in spp_list:
        if btoi(spp[9:22]) > 0: #filter spp without SPP address
            read_out.append(spp)
            
    return read_out
