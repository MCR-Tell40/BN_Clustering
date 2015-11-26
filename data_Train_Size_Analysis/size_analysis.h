#ifndef __size_analysis_h__
#define __size_analysis_h__

#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include <TH1F.h>
#include <TFile.h>

int get_bcid(std::string);

class data_train
{
private:
	std::vector<std::string> spp_train;

public:
	data_train();
	~data_train();

	void add_spp(std::string);
	int get_size();
	void reset();
};

int main(int argc, char ** argv)
{
	if (argc != 3)
	{
		std::cout << "Incorrect Arguments, see source for help" << endl;
		return -1;
	}

	std::stringstream filename;
	filename << argv[1] << "timeSync" << argv[2] << ".txt";

	std::fstream * in_file = new fstream(filename.str().c_str());

	TH1F * histo = new TH1F(
		"data_train_length_analysis",
		"data train length analysis",
		150,0,150
		);

	/* Get data from file and input to histo */
	std::string buffer;
	int bcid_last(-1);
	data_train data;
	while(*in_file >> buffer)
	{
		int bcid = get_bcid(buffer);

		if (bcid != bcid_last && data_train.get_size() != 0)
		{
			histo->Fill(data_train.get_size());
			data_train.reset();
		}

		data_train.add_spp(buffer);
		bcid_last = bcid;
	}

	/* Write root file */
	TFile * out_file = new TFile("data_train_length_analysis.root","RECREATE");
	out_file->cd();
	histo->Write();
	out_file->Close();
}

// ./prog dir_of_source filenumber

#endif 