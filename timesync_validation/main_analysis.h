#ifndef __main_analysis_h__
#define __main_analysis_h__

#include <TGraph.h>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <TFile.h>
#include <bitset>

typedef std::bitset<30>  spp;
typedef std::bitset<9>	bcid;

class time_analysis
{
private:
	std::fstream * infile;
	TGraph * bcid_graph;
	std::vector<spp> data;  
	const char * title;
	int spp_count;

	spp str_to_spp(std::string);
	bcid extract_bcid(spp);
	int bcid_to_int(bcid);
	void read_data_in();

	void create_graph();

public:
	time_analysis(const char* file, const char* title);
	~time_analysis();

	inline void save_graph(){bcid_graph->Write(title);}
};

void print_help();

int main(int argc, char ** argv)
{
	if (argc != 5) print_help();
	else
	{
		for (int i(1); i < argc; i++)
			if 	(
				std::string(argv[i]) == "-h" ||
				std::string(argv[i]) == "--help" || 
				std::string(argv[i]) == ".h"
				)
				print_help();
		
		{
			std::string desync_file   = std::string(argv[1]) + std::string(argv[3]) + ".txt";
			std::string timesync_file = std::string(argv[2]) + std::string(argv[3]) + ".txt";

			time_analysis desync_analysis(
				desync_file.c_str(),
				"Desync BCID Evolution");

			time_analysis timesync_analysis(
				timesync_file.c_str(),
				"Timesync BCID Evolution");

			TFile * Root_file = new TFile(argv[4],"RECREATE");
			Root_file->cd();
			desync_analysis.save_graph();
			timesync_analysis.save_graph();
		}
	}
}

#endif