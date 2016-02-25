import ROOT as rt
import sys
from copy import deepcopy

def __main__():

	bcid_freq = rt.TH1F('bcid_freq',';Bunch ID;Count',3584,0,3584)
	bcid_freq_list = [0] * 3584

	for x in xrange(int(sys.argv[2]),int(sys.argv[3])):

		if x != 0:
			print '\033[A\r\033[K\033[A'

		print 'file ' + str(x+1) + ' / ' + sys.argv[3]

		bcid_last = -1
		cycle = 0


		with open(sys.argv[1] + '/timesync' + str(x) + '.txt') as in_file:
			data = in_file.read().split('\n')

		for spp in data:

			if spp != '':

				bcid = gray_to_int(spp[:9])

				if (bcid != bcid_last):

					if bcid - bcid_last < 0:
						cycle += 1
						if cycle == 21:
							break

					bcid_freq.Fill(bcid + 512*(cycle%7))
					bcid_last = bcid

	canvas = rt.TCanvas('','',0,0,900,600)
	canvas.SetGridx()
	canvas.SetGridy()
	bcid_freq.Draw()
	bcid_freq.SetStats(0)
	bcid_freq.SetLineColor(4)
	bcid_freq.SetFillColor(4)
	bcid_freq.GetYaxis().SetRangeUser(0,1.1*bcid_freq.GetMaximum())
	canvas.SaveAs('bcid_frequancy.pdf')
	canvas.SaveAs('bcid_frequancy.png')

	root_file = rt.TFile("bcid_frequancy.root",'RECREATE')
	bcid_freq.Write()
	root_file.Close()

def gray_to_int(gray_string):
	# value = 0
	value_string = gray_string[0]

	for x in range(1,len(gray_string)):
		if value_string[x-1] == gray_string[x]:
			value_string += '0'
		else:
			value_string += '1'

	return int(value_string,2)

if __name__ == '__main__':
	__main__()