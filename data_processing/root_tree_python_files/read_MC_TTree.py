#!/usr/bin/python

from ROOT import TFile
from ROOT import gDirectory
from ROOT import TGraph, TH1F
# open the file
myfile = TFile( 'rootFiles/MC_FS_SPP.root' )

# retrieve the ntuple of interest
myBranch = gDirectory.Get( 'SPP' )
#entries = myBranch.GetEntries("ASIC==126")
#entries_per_ASIC = TGraph()
entries_per_ASIC = TH1F("average_SPP_per_ASIC","average_SPP_per_ASIC", 128, 0, 128)
for i in range (0, 625):
    condition="ASIC=="+str(i)
    number_entries=myBranch.GetEntries(condition)
    print 'ASIC =',i, '  entries =',number_entries
    #entries_per_ASIC.SetPoint(i, i, number_entries)
    entries_per_ASIC.Fill(number_entries)

out_file = TFile("entries_per_ASIC.root","RECREATE")
entries_per_ASIC.SetName("entries_per_ASIC")
entries_per_ASIC.Write()
out_file.Close()


# break

# for jentry in xrange( entries ):
#     # get the next tree in the chain and verify
#     ientry = myBranch.LoadTree( jentry )
#     if ientry < 0:
#         break

#     # copy next entry into memory and verify
#     nb = myBranch.GetEntry( jentry )
#     if nb <= 0:
#         continue

#     # use the values directly from the tree
#     print 'ASIC=',myBranch.ASIC
#     nEvent = int(myBranch.ASIC)
#     if nEvent < 0:
#         continue

   
