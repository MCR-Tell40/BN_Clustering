void stat_analysis()
{
	TFile * infile = new TFile ("data_train_length_analysis.root");

	TGraph * graph_mean;
	TGraph * graph_RMS;

	vector<double> mean, RMS;
	std::vector<double> ASIC_top_mean,ASIC_middle_mean,ASIC_bottom_mean;
	std::vector<double> ASIC_top_RMS,ASIC_middle_RMS,ASIC_bottom_RMS;
	std::vector<double> ASIC_top_ID,ASIC_middle_ID, ASIC_bottom_ID;

	std::vector<double> ASIC_0_mean, ASIC_1_mean, ASIC_2_mean, ASIC_3_mean, ASIC_4_mean, ASIC_5_mean;
	std::vector<double> ASIC_0_ID, ASIC_1_ID, ASIC_2_ID, ASIC_3_ID, ASIC_4_ID, ASIC_5_ID;

	for (int i(0); i < 624; i++)
	{
		stringstream histo_name;
		histo_name << "timesync_"<< i << "_datatrain_analysis";
		TH1F * histo = (TH1F*) infile->Get(histo_name.str().c_str());

		mean.push_back(histo->GetMean());
		RMS .push_back(histo->GetRMS());

		if(histo->GetMean() > 8)
		{
			ASIC_top_mean.push_back(histo->GetMean());
			ASIC_top_RMS.push_back(histo->GetRMS());
			ASIC_top_ID.push_back(i);
		}
		else if ( (histo->GetMean() > 4.5 && i < 400 ) || (histo->GetMean() > 4 && i >= 400))
		{
			ASIC_middle_mean.push_back(histo->GetMean());
			ASIC_middle_RMS.push_back(histo->GetRMS());
			ASIC_middle_ID.push_back(i);
		}
		else
		{
			ASIC_bottom_mean.push_back(histo->GetMean());
			ASIC_bottom_RMS.push_back(histo->GetRMS());
			ASIC_bottom_ID.push_back(i);
		}

		int chip_id = i % 12;

		switch(chip_id)
		{
			case 0:
			ASIC_0_mean.push_back(histo->GetMean());
			ASIC_0_ID.push_back(i);
			break;

			case 1:
			ASIC_1_mean.push_back(histo->GetMean());
			ASIC_1_ID.push_back(i);
			break;

			case 2:
			ASIC_2_mean.push_back(histo->GetMean());
			ASIC_2_ID.push_back(i);
			break;

			case 3:
			ASIC_3_mean.push_back(histo->GetMean());
			ASIC_3_ID.push_back(i);
			break;

			case 4:
			ASIC_4_mean.push_back(histo->GetMean());
			ASIC_4_ID.push_back(i);
			break;

			case 5:
			ASIC_5_mean.push_back(histo->GetMean());
			ASIC_5_ID.push_back(i);
			break;
		}
	
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

	/* sub graphs */
	TGraph * Graph_top_mean = new TGraph(ASIC_top_mean.size(), &ASIC_top_ID[0], &ASIC_top_mean[0]);	
	TGraph * Graph_top_RMS = new TGraph(ASIC_top_RMS.size(), &ASIC_top_ID[0], &ASIC_top_RMS[0]);

	TGraph * Graph_middle_mean = new TGraph(ASIC_middle_mean.size(), &ASIC_middle_ID[0], &ASIC_middle_mean[0]);	
	TGraph * Graph_middle_RMS = new TGraph(ASIC_middle_RMS.size(), &ASIC_middle_ID[0], &ASIC_middle_RMS[0]);

	TGraph * Graph_bottom_mean = new TGraph(ASIC_bottom_mean.size(), &ASIC_bottom_ID[0], &ASIC_bottom_mean[0]);	
	TGraph * Graph_bottom_RMS = new TGraph(ASIC_bottom_RMS.size(), &ASIC_bottom_ID[0], &ASIC_bottom_RMS[0]);

	TGraph * Graph_0_mean = new TGraph(ASIC_0_mean.size(), &ASIC_0_ID[0], &ASIC_0_mean[0]);
	TGraph * Graph_1_mean = new TGraph(ASIC_1_mean.size(), &ASIC_1_ID[0], &ASIC_1_mean[0]);
	TGraph * Graph_2_mean = new TGraph(ASIC_2_mean.size(), &ASIC_2_ID[0], &ASIC_2_mean[0]);
	TGraph * Graph_3_mean = new TGraph(ASIC_3_mean.size(), &ASIC_3_ID[0], &ASIC_3_mean[0]);
	TGraph * Graph_4_mean = new TGraph(ASIC_4_mean.size(), &ASIC_4_ID[0], &ASIC_4_mean[0]);
	TGraph * Graph_5_mean = new TGraph(ASIC_5_mean.size(), &ASIC_5_ID[0], &ASIC_5_mean[0]);

	/* TCanvas stuff */
	TCanvas * c1 = new TCanvas("c1","c1",900,600);	

	c1 -> SetLogy();
	c1 -> SetGridy();

	graph_mean->Draw("A*");
	graph_mean->SetMarkerStyle(20);
	graph_mean->SetMarkerColor(2);
	graph_mean->SetMarkerSize(0.5);

	graph_mean->SetTitle("Mean and RMS of Chain Length of Each ASIC");
	graph_mean->GetYaxis()->SetTitle("Chain Length");
	graph_mean->GetXaxis()->SetTitle("ASIC");
	graph_mean->GetXaxis()->SetRangeUser(0,630);

	graph_RMS->Draw("same*"); 
	graph_RMS->SetMarkerStyle(20);
	graph_RMS->SetMarkerColor(4);
	graph_RMS->SetMarkerSize(0.5);

	TLegend * leg1 = new TLegend(0.7,0.75,0.89,0.89);
	leg1->AddEntry(graph_mean,"Mean Chain Length", "p");
	leg1->AddEntry(graph_RMS,"RMS Chain Length", "p");
	leg1->SetLineColor(1);
	leg1->Draw();

	c1->SaveAs("Mean_RMS_ASIC_Graph.pdf");

	/* top graph */
	TCanvas * ct = new TCanvas("ct","ct",900,600);
	ct -> SetGridy();

	Graph_top_mean->Draw("A*");
	Graph_top_mean->SetMarkerStyle(20);
	Graph_top_mean->SetMarkerColor(2);
	Graph_top_mean->SetMarkerSize(0.5);

	Graph_top_mean->SetTitle("Mean and RMS of Chain Length of Each ASIC");
	Graph_top_mean->GetYaxis()->SetTitle("Chain Length");
	Graph_top_mean->GetXaxis()->SetTitle("ASIC");
	Graph_top_mean->GetXaxis()->SetRangeUser(0,630);
	Graph_top_mean->GetYaxis()->SetRangeUser(0,20);

	Graph_top_RMS->Draw("same*"); 
	Graph_top_RMS->SetMarkerStyle(20);
	Graph_top_RMS->SetMarkerColor(4);
	Graph_top_RMS->SetMarkerSize(0.5);

	TLegend * leg2 = new TLegend(0.7,0.75,0.89,0.89);
	leg2->AddEntry(Graph_top_mean,"Mean Chain Length", "p");
	leg2->AddEntry(Graph_top_RMS,"RMS Chain Length", "p");
	leg2->SetLineColor(1);
	leg2->Draw();	

	ct->SaveAs("TOP_Mean_RMS_ASIC_Graph.pdf");

	/* middle graph */
	TCanvas * cm = new TCanvas("cm","cm",900,600);
	cm -> SetGridy();

	Graph_middle_mean->Draw("A*");
	Graph_middle_mean->SetMarkerStyle(20);
	Graph_middle_mean->SetMarkerColor(2);
	Graph_middle_mean->SetMarkerSize(0.5);

	Graph_middle_mean->SetTitle("Mean and RMS of Chain Length of Each ASIC");
	Graph_middle_mean->GetYaxis()->SetTitle("Chain Length");
	Graph_middle_mean->GetXaxis()->SetTitle("ASIC");
	Graph_middle_mean->GetXaxis()->SetRangeUser(0,630);
	Graph_middle_mean->GetYaxis()->SetRangeUser(0,8);

	Graph_middle_RMS->Draw("same*"); 
	Graph_middle_RMS->SetMarkerStyle(20);
	Graph_middle_RMS->SetMarkerColor(4);
	Graph_middle_RMS->SetMarkerSize(0.5);

	TLegend * leg3 = new TLegend(0.7,0.75,0.89,0.89);
	leg3->AddEntry(Graph_middle_mean,"Mean Chain Length", "p");
	leg3->AddEntry(Graph_middle_RMS,"RMS Chain Length", "p");
	leg3->SetLineColor(1);
	leg3->Draw();	

	cm->SaveAs("Middle_Mean_RMS_ASIC_Graph.pdf");

	/* bottom graph */
	TCanvas * cb = new TCanvas("cb","cb",900,600);
	cb -> SetGridy();

	Graph_bottom_mean->Draw("A*");
	Graph_bottom_mean->SetMarkerStyle(20);
	Graph_bottom_mean->SetMarkerColor(2);
	Graph_bottom_mean->SetMarkerSize(0.5);

	Graph_bottom_mean->SetTitle("Mean and RMS of Chain Length of Each ASIC");
	Graph_bottom_mean->GetYaxis()->SetTitle("Chain Length");
	Graph_bottom_mean->GetXaxis()->SetTitle("ASIC");
	Graph_bottom_mean->GetXaxis()->SetRangeUser(0,630);
	Graph_bottom_mean->GetYaxis()->SetRangeUser(0,6);

	Graph_bottom_RMS->Draw("same*"); 
	Graph_bottom_RMS->SetMarkerStyle(20);
	Graph_bottom_RMS->SetMarkerColor(4);
	Graph_bottom_RMS->SetMarkerSize(0.5);

	TLegend * leg4 = new TLegend(0.7,0.75,0.89,0.89);
	leg4->AddEntry(Graph_bottom_mean,"Mean Chain Length", "p");
	leg4->AddEntry(Graph_bottom_RMS,"RMS Chain Length", "p");
	leg4->SetLineColor(1);
	leg4->Draw();

	cb->SaveAs("Bottom_Mean_RMS_ASIC_Graph.pdf");

	/* chip id */
	TCanvas * c_chip = new TCanvas("c_chip","c_chip",900,600);
	c_chip -> SetGridy();
	// c_chip -> SetLogy();

	// Graph_0_mean->Draw("");
	Graph_0_mean->Draw("A*");
	Graph_0_mean->SetMarkerStyle(20);
	Graph_0_mean->SetMarkerColor(1);
	Graph_0_mean->SetMarkerSize(0.5);

	Graph_0_mean->SetTitle("Mean and of Chain Length of Each ASIC");
	Graph_0_mean->GetYaxis()->SetTitle("Chain Length");
	Graph_0_mean->GetXaxis()->SetTitle("ASIC");
	Graph_0_mean->GetXaxis()->SetRangeUser(0,630);
	// Graph_0_mean->GetYaxis()->SetRangeUser(0,150);

	// Graph_1_mean->Draw("same");
	Graph_1_mean->Draw("same*");
	Graph_1_mean->SetMarkerStyle(20);
	Graph_1_mean->SetMarkerColor(2);
	Graph_1_mean->SetMarkerSize(0.5);

	// Graph_2_mean->Draw("same");
	Graph_2_mean->Draw("same*");
	Graph_2_mean->SetMarkerStyle(20);
	Graph_2_mean->SetMarkerColor(6);
	Graph_2_mean->SetMarkerSize(0.5);

	// Graph_3_mean->Draw("same");
	Graph_3_mean->Draw("same*");
	Graph_3_mean->SetMarkerStyle(20);
	Graph_3_mean->SetMarkerColor(4);
	Graph_3_mean->SetMarkerSize(0.5);

	// Graph_4_mean->Draw("same");
	Graph_4_mean->Draw("same*");
	Graph_4_mean->SetMarkerStyle(20);
	Graph_4_mean->SetMarkerColor(28);
	Graph_4_mean->SetMarkerSize(0.5);

	// Graph_5_mean->Draw("same");
	Graph_5_mean->Draw("same*");
	Graph_5_mean->SetMarkerStyle(20);
	Graph_5_mean->SetMarkerColor(8);
	Graph_5_mean->SetMarkerSize(0.5);

	TLegend * leg5 = new TLegend(0.7,0.7,0.89,0.89);
	leg5->AddEntry(Graph_0_mean,"Chip ID 0 Length", "p");
	leg5->AddEntry(Graph_1_mean,"Chip ID 1 Length", "p");
	leg5->AddEntry(Graph_2_mean,"Chip ID 2 Length", "p");
	leg5->AddEntry(Graph_3_mean,"Chip ID 3 Length", "p");
	leg5->AddEntry(Graph_4_mean,"Chip ID 4 Length", "p");
	leg5->AddEntry(Graph_5_mean,"Chip ID 5 Length", "p");
	leg5->SetLineColor(1);
	leg5->Draw();

	c_chip->SaveAs("Mean_ASIC_Graph_Chip.pdf");

	Graph_0_mean->GetYaxis()->SetRangeUser(0,20);

	c_chip->Update();
	c_chip->SaveAs("Mean_ASIC_Graph_Chip_lower_values.pdf");

	/* ---------------------- ind ASIC histo graphs -------------------- */

	TCanvas * c_multi = new TCanvas("c_multi","c_multi",900,600);

	c_multi -> Divide (2,2);

	TH1F * histo_ASIC_0 = (TH1F*) infile->Get("timesync_0_datatrain_analysis");
	TH1F * histo_ASIC_20 = (TH1F*) infile->Get("timesync_20_datatrain_analysis");
	TH1F * histo_ASIC_120 = (TH1F*) infile->Get("timesync_120_datatrain_analysis");
	TH1F * histo_ASIC_420 = (TH1F*) infile->Get("timesync_420_datatrain_analysis");
	
	c_multi->cd(1);

	histo_ASIC_0 -> Draw("");
	histo_ASIC_0 -> SetTitle("ASIC 0");
	histo_ASIC_0 -> GetXaxis() -> SetTitle("Data Train Length");
	histo_ASIC_0 -> GetYaxis() -> SetTitle("Count");
	
	c_multi->cd(2);

	histo_ASIC_20 -> Draw();
	histo_ASIC_20 -> SetTitle("ASIC 20");
	histo_ASIC_20 -> GetXaxis() -> SetTitle("Data Train Length");
	histo_ASIC_20 -> GetYaxis() -> SetTitle("Count");

	c_multi->cd(3);

	histo_ASIC_120 -> Draw();
	histo_ASIC_120 -> SetTitle("ASIC 120");
	histo_ASIC_120 -> GetXaxis() -> SetTitle("Data Train Length");
	histo_ASIC_120 -> GetYaxis() -> SetTitle("Count");
	
	c_multi->cd(4);

	histo_ASIC_420 -> Draw();
	histo_ASIC_420 -> SetTitle("ASIC 420");
	histo_ASIC_420 -> GetXaxis() -> SetTitle("Data Train Length");
	histo_ASIC_420 -> GetYaxis() -> SetTitle("Count");
	
	c_multi->SaveAs("Comparison_of_data_train_length_for_4_ASIC.pdf");

}
