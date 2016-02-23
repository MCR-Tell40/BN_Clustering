import ROOT as rt
import sys
from subprocess import call

# def Sensor_graph():

def Half_Module_graph():
	# graph creation
	cut_off_16 = rt.TH1F("cut_off_16",";Module Number;Sort Acceptance Effeciency",104,0,52)
	cut_off_32 = rt.TH1F("cut_off_32",";Module;Effeciency",104,0,52)
	cut_off_64 = rt.TH1F("cut_off_64",";Module;Effeciency",104,0,52)
	empty_bcid = rt.TH1F("empty_bcid",";Module;Effeciency",104,0,52)
	total = rt.TH1F("total_trains","total trains;Module;number",104,0,52)

	print ' ' #for progress bar

	for x in range(0,int(sys.argv[1])):
		
		print '\033[A\r\033[K' + str(x+1) + ' / ' + sys.argv[1]

		with open('output/Half_Module/Half_Module_train_lengths_'+str(x)+'_1.txt') as in_file:
			data = in_file.read().split('\n')

			for bcid_size in data:
				if (bcid_size != ''):
					total.Fill(x)
					if (int(bcid_size) < 64):
						cut_off_64.Fill(x)
					if (int(bcid_size) < 32):
						cut_off_32.Fill(x)
					if (int(bcid_size) < 16):
						cut_off_16.Fill(x)
					if (int(bcid_size) == 0):
						empty_bcid.Fill(x)

		with open('output/Half_Module/Half_Module_train_lengths_'+str(x)+'_2.txt') as in_file:
			data = in_file.read().split('\n')

			for bcid_size in data:
			    if (bcid_size != ''):
					total.Fill(x+0.5)
					if (int(bcid_size) < 64):
						cut_off_64.Fill(x+0.5)
					if (int(bcid_size) < 32):
						cut_off_32.Fill(x+0.5)
					if (int(bcid_size) < 16):
						cut_off_16.Fill(x+0.5)
					if (int(bcid_size) == 0):
						empty_bcid.Fill(x+0.5)

	rt.TH1.Divide(cut_off_16,total)
	rt.TH1.Divide(cut_off_32,total)
	rt.TH1.Divide(cut_off_64,total)
	rt.TH1.Divide(empty_bcid,total)

	bypass_Effeciency_canvas = rt.TCanvas('bypass_Effeciency_canvas','Bypass Effeciency',10,10,910,610)
	bypass_Effeciency_canvas.SetGridy()

	cut_off_16.Draw('')
	cut_off_16.SetStats(0)
	cut_off_16.SetLineColor(1)
	cut_off_16.GetYaxis().SetRangeUser(0,1)
	cut_off_32.SetLineColor(2)
	cut_off_32.Draw('same')
	cut_off_64.SetLineColor(4)
	cut_off_64.Draw('same')

	empty_bcid.Draw('same')
	# empty_bcid.SetFillColor(3)
	empty_bcid.SetLineColor(3)
	# empty_bcid.SetFillStyle(1050)

	leg = rt.TLegend(0.7,0.475,0.9,0.675,'Sort Threshold Value')
	leg.SetLineColor(1)
	leg.AddEntry(cut_off_64,' 64','l')
	leg.AddEntry(cut_off_32,' 32','l')
	leg.AddEntry(cut_off_16,' 16','l')
	leg.AddEntry(empty_bcid,' Empty','l')
	leg.Draw()

	bypass_Effeciency_canvas.Update()

	# while (1):
	# 	x =1 

	bypass_Effeciency_canvas.SaveAs('Sort_Acceptance_Efficiancy.pdf')

def __main__():
	# ASIC_graph()
	# Sensor_graph()
	Half_Module_graph()

if __name__ == '__main__':
	__main__()