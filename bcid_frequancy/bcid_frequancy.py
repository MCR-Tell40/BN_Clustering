import ROOT as rt
import sys
from copy import deepcopy

def __main__():

	bcid_freq = rt.TH1F('bcid_freq',';BCID;Count',512,0,512)

	for x in xrange(int(sys.argv[2]),int(sys.argv[3])):

		if x != 0:
			print '\033[A\r\033[K\033[A'

		print 'file ' + str(x+1) + ' / ' + sys.argv[3]

		bcid_last = -1

		with open(sys.argv[1] + '/timesync' + str(x) + '.txt') as in_file:
			data = in_file.read().split('\n')

		for spp in data:

			if spp != '':

				bcid = gray_to_int(spp[:9])

				if (bcid != bcid_last):
					bcid_freq.Fill(bcid)
					bcid_last = bcid

	canvas = rt.TCanvas('','',0,0,900,600)
	canvas.SetGridx()
	canvas.SetGridy()
	bcid_freq.Draw('e')
	bcid_freq.SetStats(0)
	canvas.SaveAs('bcid_frequancy.pdf')


def gray_to_int(gray_string):
	value = 0
	value_string = gray_string[0]

	for x in range(1,len(gray_string)):
		if value_string[x-1] == gray_string[x]:
			value_string += '0'
		else:
			value_string += '1'


	for char in value_string:
		value = value | int(char)
		value = value << 1

	return value



if __name__ == '__main__':
	__main__()