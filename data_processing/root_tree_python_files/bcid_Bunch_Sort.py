from splitspp import *
import sys
from multiprocessing import Process
from copy import deepcopy
from ROOT import TH1F, TFile
import os
import glob
# ----------- sorting algorithum ----------- # 

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
    
# ----------- file control ----------- # 

def run_for_file(desync_path, desync_spp_path, decode_path, core):
    print 'begining process', core
    histo_bcid = TH1F("bcid_histo", "BCID", 3600, 0, 3600)
    fileList=[]
    for iFile in glob.glob(os.path.join(str(desync_path), '*.txt')):
        fileList.append(iFile)
    for X in range(0,len(fileList)):
        print X
        if X % int(sys.argv[4]) == core:
            with open(desync_path + '/desync' + str(X) + '.txt') as in_file:
                print 't:', core, '\topening file\t\t', X
                raw_data = in_file.read().split('\n')
            raw_data = split_spp(raw_data) 

            with open(desync_spp_path +'/desync_spp' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    out_file.write(each_spp + '\n')
                print 't:', core, '\tsaving desync_spp\t', X

            sorted_data = time_sort(raw_data)
            
            cycle = 0
            prevBCID = -1
            for each_spp in sorted_data :
                if int(each_spp) != 0:
                    # print 'cycle =',cycle, ' prevBCID =',prevBCID,' BCID =',myBCID, ' jump =',myBCID-prevBCID
                    if (int(gtob(each_spp[:9]), 2) != int(grayToBinary(each_spp[:9]),2)) :
                        print 'PROBLEM: ', int(gtob(each_spp[:9]), 2), grayToBinary(gtob(each_spp[:9]),2)
                    myBCID = gtoi(each_spp[:9])
                    if myBCID != prevBCID: # only 1 entry per bcid in the histogram
                        if myBCID < prevBCID :
                            cycle += 1
                            if cycle == 21:
                                break
                        histo_bcid.Fill(myBCID + 512*(cycle%7))
                        prevBCID = myBCID
                
            with open(decode_path + '/decoded_spp' + str(X) + '.txt', 'w') as out_file:
                for each_spp in raw_data:
                    if len(each_spp)>1 :
                        # print "each_spp=",each_spp
                        myBCID=each_spp[:9]
                        myBCID = gtob(myBCID)
                        my_spp=myBCID+each_spp[9:]
                        # print "     each_spp=",my_spp
                        out_file.write(my_spp + '\n')
            print 't:', core, '\tsaving descoded_spp\t\t', X
            
    out_file = TFile.Open("out_file.root", "RECREATE")
    histo_bcid.SetFillStyle(1001)
    histo_bcid.Write()
    out_file.Close()
            # ---------- gray to binary decoding


def grayToBinary(gray):
    binary = gray[0]
    i = 0
    while( len(gray) > i + 1 ):
        binary += `int(binary[i]) ^ int(gray[i + 1])`
        i += 1
    return binary               

# ----------- main ----------- # 

if __name__ == '__main__':
    desync_path = sys.argv[1]
    desync_spp_path = sys.argv[2]
    decode_path = sys.argv[3]
    for i in range(0,int(sys.argv[4])):
        p = Process(target=run_for_file, args=(desync_path, desync_spp_path, decode_path,i)).start()
        
