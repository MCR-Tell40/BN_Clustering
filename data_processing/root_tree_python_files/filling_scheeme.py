#!/usr/bin/env python

import sys
from multiprocessing import Process
from copy import deepcopy
from ROOT import TH1F, TFile, TGraph
import os
import glob

max_height = 10000

myfs=[
	'72b', '8e', '72b', '38e', '72b', '8e', #-> 0..270
	'72b', '8e', '72b', '38e', '72b', '8e', #-> 271..540
	'72b', '8e', '72b', '8e', '72b', '39e', #-> 541..811
	'72b', '8e', '72b', '8e', '72b', '38e', #-> 812..1081
	'72b', '8e', '72b', '8e', '72b', '38e', #-> 1082..1351
	'72b', '8e', '72b', '8e', '72b', '8e', #-> 1352..1591
	'72b', '39e', '72b', '8e', '72b', '8e', #-> 1592..1862
	'72b', '38e', '72b', '8e', '72b', '8e', #-> 1863..2132
	'72b', '38e', '72b', '8e', '72b', '8e', #-> 2133..2402
	'72b', '8e', '72b', '39e', '72b', '8e', #-> 2403..2673
	'72b', '8e', '72b', '38e', '72b', '8e', #-> 2674..2943
	'72b', '8e', '72b', '38e', '72b', '8e', #-> 2944..3213
	'72b', '8e', '72b', '8e', '72b', '119e' #-> 3214..3564
]
if __name__ == '__main__':
        print myfs
	fs_histo = TH1F('filling_scheme', 'Forbidden BCIDs', 3600, 0, 3600)
	myPosition=0
	for each_fill in myfs:
                if each_fill == '72b' :
			for i in range (0,72):
#				fs_histo.Fill(myPosition, 2500)
				myPosition += 1
		elif each_fill == '8e':
			for i in range (0,8):
                                for i in range (0,max_height):
                                        fs_histo.Fill(myPosition)
				myPosition += 1
		elif each_fill == '38e':
			for i in range (0,38):
                                for i in range (0,max_height):
                                        fs_histo.Fill(myPosition)
				myPosition += 1
		elif each_fill == '39e':
			for i in range (0,39):
                                for i in range (0,max_height):
                                        fs_histo.Fill(myPosition)
				myPosition += 1
		elif each_fill == '119e':
			for i in range (0,119):
                                for i in range (0,max_height):
                                        fs_histo.Fill(myPosition)
				myPosition += 1
		else:
			print 'Problem here: each_fill =',each_fill,' myPosition =',myPosition

	out_file = TFile.Open("nominal_filling.root", "RECREATE")
        fs_histo.SetLineColor(2)
        fs_histo.SetFillColor(2)
        fs_histo.SetFillStyle(3013)
	fs_histo.Write()
	out_file.Close()
	# for i_loop in range', '(0,12):
	# 	for j_loop in range', '(0,6):
	# 		if (j_loop == 0) or (j_loop == 2) or (j_loop = 4):
	# 			for i in range', '(0,72):
	# 				fs.Fill(i_loop*6)
	# 		elif j_loop == 
