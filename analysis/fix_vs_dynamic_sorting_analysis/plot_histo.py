from ROOT import TH1F, TH2F, TFile, TCanvas, TLegend, gPad
import sys, getopt

def __main__(ifile):

	with open(ifile) as ifile:
		data = ifile.read().split('\n')

	stat_histo 	= TH1F('stat_histo',	';Sort Time (Clock Cycles);Count',128,0,128)
	dyn_histo 	= TH1F('dyn_histo',		';Sort Time (Clock Cycles);Count',128,0,128)

	asym_histo = TH1F('Sort_asym',';Sort Time Differance (semiStat - Dyn);count',100,0,100)

	asym_histo2 = TH2F('Sort_asym2',';SPP / BCID;Dynamic Sorting Time Saved [25ns Clock Cycle]',64,0,64,64,0,64)
	asym_histo2.SetStats(0)

	for each in data:
		if each != '':
			stat = int(each.split(',')[0])
			dyn  = int(each.split(',')[1])

			if stat > 64:
				continue

			if stat < dyn:
				dyn_histo.Fill(stat)
				asym_histo.Fill(0)
				asym_histo2.Fill(stat,0);
			else:
				dyn_histo.Fill(dyn)
				asym_histo.Fill(stat-dyn)
				asym_histo2.Fill(stat,stat-dyn)

			stat_histo.Fill(stat)

	Canvas = TCanvas('Dynamic_vs_Static_Sorttime_Comparison','Dynamic vs Static Sorttime Comparison',900,600)	
# (fold)

	Canvas.Divide(2,0)

	stat_max = stat_histo.GetMaximum()
	dyn_max = dyn_histo.GetMaximum()

	Canvas.cd(1)

	stat_histo.Draw('')
	stat_histo.SetLineColor(4)
	stat_histo.SetStats(0)
	stat_histo.GetYaxis().SetRangeUser(0,max([stat_max,dyn_max])*1.1)
	stat_histo.GetXaxis().SetRangeUser(0,70)
	dyn_histo.Draw('same')
	dyn_histo.SetLineColor(2)

	leg = TLegend(0.4,0.7,0.89,0.89)
	leg.SetHeader('Max Sort Acceptance = 64 SPP/BCID')
	leg.SetLineColor(0)
	leg.AddEntry(stat_histo,'Semi Static Sort Time','l')
	leg.AddEntry(dyn_histo,'Dynamic Sort Time','l')
	leg.Draw()

	Canvas.cd(2)

	stat_histo.Draw('')
	stat_histo.SetLineColor(4)
	stat_histo.SetStats(0)
	stat_histo.GetYaxis().SetRangeUser(0.9,max([stat_max,dyn_max])*1.1)
	stat_histo.GetXaxis().SetRangeUser(0,70)
	dyn_histo.Draw('same')
	dyn_histo.SetLineColor(2)

	leg2 = TLegend(0.2,0.2,0.7,0.4)
	leg2.SetHeader('Max Sort Acceptance = 64 SPP/BCID')
	leg2.SetLineColor(0)
	leg2.AddEntry(stat_histo,'Semi Static Sort Time','l')
	leg2.AddEntry(dyn_histo,'Dynamic Sort Time','l')
	leg2.Draw()

	gPad.SetLogy()

	Canvas.SaveAs('semiStat_dyn_sort_time.pdf')
#(unfold)

	Canvas = TCanvas('time_saved_by_sort_1d','Time Saves by Sort 1D',900,600)
#(fold)
	asym_histo.SetLineColor(4)
	asym_histo.SetStats(0)
	asym_histo.GetXaxis().SetRangeUser(0,30)
	asym_histo.Draw()

	leg = TLegend(0.55,0.75,0.89,0.89)
	leg.SetHeader('Max Sort Acceptance = 64 SPP/BCID')
	leg.SetLineColor(0)
	leg.AddEntry(asym_histo,'Time Saved by Dynamic Sorting','l')
	leg.Draw()

	Canvas.SaveAs('time_saved_by_dynamic_sort_1d.pdf')
#(unfold)

	Canvas = TCanvas('time_saved_by_sort_1d','Time Saves by Sort 1D',900,600)
#(fold)
	asym_histo2.SetStats(0)
	asym_histo2.GetYaxis().SetRangeUser(0,30)
		

	asym_histo2.Draw('COLZ')

	Canvas.SetLogz()
	Canvas.SaveAs('time_saved_by_dynamic_sort_2d.pdf')
#(unfold)

	rfile = TFile('fix_dyn_analysis.root','RECREATE')

	stat_histo.Write()
	dyn_histo.Write()
	asym_histo.Write()
	asym_histo2.Write()



if __name__ == '__main__':
	ifile = ''
	ofile = ''
	rfile = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:],"hi:o:r:",["ifile="])
	except getopt.GetoptError:
		print 'test.py -i <inputfile>'
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			print 'test.py -i <inputfile>'
			sys.exit()
		elif opt in ("-i", "--ifile"):
			ifile = arg
   	__main__(ifile)