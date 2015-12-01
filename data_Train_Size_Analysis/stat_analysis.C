void stat_analysis()
{
	TFile * infile = new TFile ("data_train_length_analysis.root");

	TGraph * graph_mean;
	TGraph * graph_RMS;

	vector<double> mean, RMS;

	for (int i(100); i < 624; i++)
	{
		stringstream histo_name;
		histo_name << "timesync_"<< i << "_datatrain_analysis";
		TH1F * histo = (TH1F*) infile->Get(histo_name.str().c_str());

		mean.push_back(histo->GetMean());
		RMS .push_back(histo->GetRMS());
	}

	/* TGraph stuff because root is a pain in the ass */
	double * x_mean = new double[mean.size()];
	double * y_mean = &mean[0];

	double * x_RMS = new double[RMS.size()];
	double * y_RMS = &RMS[0];	

	for (int i(0); i < mean.size(); i++)
		x_mean[i] = x_RMS[i] = i;

	graph_mean = new TGraph(mean.size(),x_mean,y_mean);
	graph_RMS = new TGraph(RMS.size(),x_RMS,y_RMS);

	/* TCanvas stuff */
	TCanvas * c1 = new TCanvas("c1","c1",900,600);	

	c1 -> SetLogy();

	graph_mean->Draw();
	graph_mean->SetLineColor(2);
	graph_RMS->Draw("same"); 

	// /* Just for referance atm */
	// TH1F * histo0 = (TH1F*) infile->Get("overflow_histo_0");

	// TCanvas * c1 = new TCanvas("c1","c1",900,600);

	// float markerSize = 1;
	// int groupSize=3;

	// histo50->Divide(histo50,histo0,1.,1.,"b");
	// histo50->Draw("");
	// histo50->SetMarkerStyle(20);
	// histo50->SetFillColor(28);
	// histo50->SetLineColor(28);
	// histo50->SetMarkerSize(markerSize);

	// histo50->SetTitle("Proportion of Overflowing BCID Trains");
	// histo50->GetYaxis()->SetTitle("Percentage Overflow Per Sensor");
	// histo50->GetXaxis()->SetTitle("ASIC");
	// histo50->SetStats(0);

	// TLegend * leg = new TLegend(0.7,0.7,0.89,0.89);
	// leg->AddEntry(histo50,"Cut Off 50", "f");
	// leg->AddEntry(histo100,"Cut Off 100", "f");
	// leg->AddEntry(histo150,"Cut Off 150", "f");
	// leg->AddEntry(histo200,"Cut Off 200", "f");
	// leg->SetLineColor(0);
	// leg->Draw();

	// c1->SetLogy();
	// c1->Update();

	// c1->SaveAs("Number of Overflowing BCID Trains.png");
}