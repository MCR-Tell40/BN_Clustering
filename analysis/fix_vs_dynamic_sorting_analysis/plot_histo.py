from ROOT import TH1F, TFile, TCanvas, TLegend
import sys, getopt

def __main__(ifile,ofile,rfile):

	with open(ifile) as ifile:
		data = ifile.read().split('\n')

	stat_histo 	= TH1F('stat_histo',	';Sort Time (Clock Cycles);Count',52,0,52)
	dyn_histo 	= TH1F('dyn_histo',		';Sort Time (Clock Cycles);Count',52,0,52)

	asym_histo = TH1F('Sort_asym',';Sort Time Differance (stat - dyn);count',101,-50,50)

	for each in data:
		if each != '':
			stat_histo.Fill(int(each.split(',')[0]))
			dyn_histo.Fill (int(each.split(',')[1]))
			asym_histo.Fill(int(each.split(',')[0])-int(each.split(',')[1]))

	Canvas = TCanvas('Dynamic_vs_Static_Sorttime_Comparison','Dynamic vs Static Sorttime Comparison',900,600)	

	stat_max = stat_histo.GetMaximum()
	dyn_max = dyn_histo.GetMaximum()

	stat_histo.Draw('')
	stat_histo.SetLineColor(4)
	stat_histo.SetStats(0)
	stat_histo.GetYaxis().SetRangeUser(0,max([stat_max,dyn_max])*1.1)
	dyn_histo.Draw('same')
	dyn_histo.SetLineColor(2)

	leg = TLegend(0.7,0.75,0.9,0.9)
	leg.AddEntry(stat_histo,'Static Sort Time','l')
	leg.AddEntry(dyn_histo,'Dynamic Sort Time','l')
	leg.Draw()

	Canvas.SaveAs(ofile)

	if rfile != '':
		rfile = TFile(rfile,'RECREATE')

		stat_histo.Write()
		dyn_histo.Write()
		asym_histo.Write()



if __name__ == '__main__':
	ifile = ''
	ofile = ''
	rfile = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:],"hi:o:r:",["ifile=","ofile=","rfile="])
	except getopt.GetoptError:
		print 'test.py -i <inputfile> -o <outputfile>'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'test.py -i <inputfile> -o <outputfile> -r <rootfile>'
			sys.exit()
		elif opt in ("-i", "--ifile"):
			ifile = arg
		elif opt in ("-o", "--ofile"):
			ofile = arg
		elif opt in ("-r", "--rfile"):
			rfile = arg
   	print 'Input file is :', ifile
   	print 'Output file is :', ofile
   	__main__(ifile,ofile,rfile)