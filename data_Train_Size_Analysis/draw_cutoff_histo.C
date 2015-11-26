void draw_cutoff_histo()
{
	TFile * infile = new TFile ("data_train_length_analysis.root");

	TH1F * histo50 = (TH1F*) infile->Get("overflow_histo_50");
	TH1F * histo100 = (TH1F*) infile->Get("overflow_histo_100");
	TH1F * histo150 = (TH1F*) infile->Get("overflow_histo_150");
	TH1F * histo200 = (TH1F*) infile->Get("overflow_histo_200");

	TCanvas * c1 = new TCanvas("c1","c1",900,600);

	float markerSize = 1;

	histo50->Draw("");
	histo50->SetMarkerStyle(20);
	histo50->SetFillColor(28);
	histo50->SetLineColor(28);
	histo50->SetMarkerSize(markerSize);

	histo50->SetTitle("Number of Overflowing BCID Trains");
	histo50->GetYaxis()->SetTitle("Number of Overflow Trains Per Sensor");
	histo50->GetXaxis()->SetTitle("ASIC");
	histo50->SetStats(0);

	histo100->Draw("same");
	histo100->SetMarkerStyle(20);
	histo100->SetLineColor(2);
	histo100->SetFillColor(2);
	histo100->SetMarkerSize(markerSize);

	histo150->Draw("same");
	histo150->SetMarkerStyle(20);
	histo150->SetLineColor(4);
	histo150->SetFillColor(4);
	histo150->SetMarkerSize(markerSize);

	histo200->Draw("same");
	histo200->SetMarkerStyle(20);
	histo200->SetLineColor(8);
	histo200->SetFillColor(8);
	histo200->SetMarkerSize(markerSize);

	TLegend * leg = new TLegend(0.7,0.7,0.89,0.89);
	leg->AddEntry(histo50,"Cut Off 50", "f");
	leg->AddEntry(histo100,"Cut Off 100", "f");
	leg->AddEntry(histo150,"Cut Off 150", "f");
	leg->AddEntry(histo200,"Cut Off 200", "f");
	leg->SetLineColor(0);
	leg->Draw();

	c1->SetLogy();
	c1->Update();

	c1->SaveAs("Number of Overflowing BCID Trains.png");
}