#Python script to extract the 4 ssp from each frame output a list of spp
#Author: Nicholas Mead
#
#*********************

# data = list of frames
# spp_list = list of spp

from str_to_bin import stob

def split_spp(data):

    class spp:
        def __init__ (self, spp):
            self.string = spp
            self.BCID = stob(spp[:9])
            self.SPP_address = stob(spp[9:22])
            self.hit_map = stob(spp[22:])
    
    #split the frames into lists of spp
    spp_list = []
    for frame in data:
        if frame == '':
            break
        else:
            spp_list.append(spp(frame[8:38]))
            spp_list.append(spp(frame[38:68]))
            spp_list.append(spp(frame[68:98]))
            spp_list.append(spp(frame[98:128]))
    
    return spp_list
