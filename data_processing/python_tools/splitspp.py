#Python script to extract the 4 ssp from each frame output a list of spp
#Author: Nicholas Mead
#
#*********************

# data = list of frames
# spp_list = list of spp

from conversion import *

def split_spp(data):
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

    read_out = []
    for spp in spp_list:
        if int(spp,2) > 0:
            read_out.append(spp)
            
    return read_out
