#!/usr/bin/python

import sys, getopt
from multiprocessing import Process
from copy import deepcopy
from ROOT import TH1F, TH2F, TFile
import os
import glob

from splitspp import *


def main(input_folder, output_folder, iCore, nCores):
    fileList=[]
    histo_global = TH2F("histo_sppAdd", "SPP Address", 128, 0, 128, 32, 0, 32)
    for iFile in glob.glob(os.path.join(str(input_folder), '*.txt')):
        fileList.append(iFile)
    fileNumber=-1
    for thisFile in fileList:
        fileNumber += 1
        if fileNumber % nCores == iCore:
            asicID = ((thisFile.split('/')[1]).split('.')[0]
            histo_sppAdd = TH2F("histo_sppAdd_"+asicID, "SPP hitmap at ASIC_"+asicID, 128, 0, 128, 32, 0, 32)
            outputFile = output_folder+(thisFile.split('/')[1]).split('.')[0]+'.root'
            print 'core:',iCore, " i_file:",thisFile,' o_file=',outputFile
            with open(thisFile) as i_file:
                raw_data = i_file.read().split('\n')
            spp_list = split_spp(raw_data) 

            for spp in spp_list:
                if (int(spp) != 0):
                    mySppCol = int(spp[9:15],2)
                    mySppRow = int(spp[15:22],2)
                    histo_sppAdd.Fill(mySppRow, mySppCol)
                    histo_global.Fill(mySppRow, mySppCol)
                        
       
            out_file = TFile.Open(outputFile, "RECREATE")
            histo_sppAdd.SetFillStyle(1001)
            histo_sppAdd.GetXaxis().SetTitle("Col") 
            histo_sppAdd.GetYaxis().SetTitle("Row") 
            histo_sppAdd.Write()
            out_file.Close()

    out_file = TFile.Open(output_folder+'global.root', "RECREATE")
    histo_global.SetFillStyle(1001)
    histo_global.GetXaxis().SetTitle("Col") 
    histo_global.GetYaxis().SetTitle("Row") 
    histo_global.Write()
    out_file.Close()



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
