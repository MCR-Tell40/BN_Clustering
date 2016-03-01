#!/usr/bin/python

import sys, getopt, os, glob
from multiprocessing import Process
from copy import deepcopy
from ROOT import TH1F, TH2F, TFile, TTree
from ROOT import gROOT, AddressOf

from splitspp import *

gROOT.ProcessLine(
    "struct SPP {\
    Int_t     fAsicID;\
    Int_t     fCol;\
    Int_t     fRow;\
    Int_t     fOriginal_BCID;\
    Int_t     fFull_BCID;\
    Char_t    fHitmap[8];\
    Int_t     fHitmap_I;\
    };" 
);

from ROOT import SPP

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


def main(input_folder, output_folder, iCore, nCores):
    mySPP = SPP()
    f = TFile( str(output_folder)+'MC_FS_SPP.root', 'RECREATE' )
    tree = TTree( 'SPP', 'Just A Tree' )
    tree.Branch( 'ASIC',AddressOf(mySPP,'fAsicID'), 'AsicID/I')
    tree.Branch( 'Col', AddressOf(mySPP,'fCol'),'Col/I')
    tree.Branch( 'Row', AddressOf(mySPP,'fRow'),'Row/I')
    tree.Branch( 'Original_BCID', AddressOf(mySPP, 'fOriginal_BCID'), 'Original_BCID/I')
    tree.Branch( 'Full_BCID', AddressOf(mySPP,'fFull_BCID'), 'Full_BCID/I' )
    tree.Branch( 'Hitmap', AddressOf( mySPP, 'fHitmap' ), 'Hitmap/C' )
    tree.Branch( 'Hitmap_I', AddressOf( mySPP, 'fHitmap_I' ), 'Hitmap_I/I' )

    fileList=[]
    for iFile in glob.glob(os.path.join(str(input_folder), '*.txt')):
        fileList.append(iFile)
    for thisFile in fileList:
        asicID = int(((thisFile.split('/')[1]).split('.')[0]).split('desync')[1])
        
        if asicID % nCores == iCore:
            print 'Processing file:',thisFile
            with open(thisFile) as i_file:
                raw_data = i_file.read().split('\n')
            spp_list = split_spp(raw_data) 
            spp_sorted = time_sort(spp_list)
            cycle = 0
            prevBCID = -1
            for each_spp in spp_sorted:
                if int(each_spp) != 0:
                    myBCID = gtoi(each_spp[:9])
                    if myBCID < prevBCID :
                        cycle += 1
                        if cycle == 21:
                            break
                    prevBCID = myBCID

                    mySPP.fAsicID = asicID
                    mySPP.fCol = int(each_spp[9:16],2) #7 bits: from 0 to 128
                    mySPP.fRow = int(each_spp[16:22],2) #6 bits: from 0 to 64
                    mySPP.fOriginal_BCID = myBCID
                    mySPP.fFull_BCID = myBCID + 512*(cycle%7)
                    mySPP.fHitmap = str(each_spp[22:])      # note string assignment
                    mySPP.fHitmap_I = int(each_spp[22:],2)      # note string assignment
                    tree.Fill()

    f.Write()
    f.Close()

if __name__ == "__main__":
    input_folder = ''
    output_folder = ''
    cores = 1
    try:
        opts, args = getopt.getopt(sys.argv[1:],'hi:o:c:')#,["ifile=","ofile="])
    except getopt.GetoptError:
        print 'bcid_ratio_per_sensor.py -i <inputfile> -o <outputfile> -c <n_cores>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'bcid_ratio_per_sensor.py -i <inputfile> -o <outputfile> -c <n_cores>'
            sys.exit()
        elif opt in ("-i", "--ifile"):
            input_folder = arg
        elif opt in ("-o", "--ofile"):
            output_folder = arg
        elif opt in ("-c","--cores"):
            cores = int(arg)
    for iCore in range(0,cores):
        p = Process(target=main, args=(input_folder, output_folder, iCore, cores)).start()
