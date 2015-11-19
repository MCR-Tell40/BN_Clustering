#ifndef __main_analysis_h__
#define __main_analysis_h__

#include <TGraph.h>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <TFile.h>
#include <bitset>
#include <math.h>

//+#define __debug__

class time_analysis
{
private:
	/* --- Member Variables --- */
	std::string 	file_name;
	std::fstream * 	infile;
	TGraph * 		bcid_graph;
	std::vector<std::string> data;  
	const char * 	title;

	/* --- Methodss --- */
	void 	read_data_in	();
	void 	create_graph	();
	int 	extract_bcid	(std::string);
	int 	bcid_to_int		(std::string);
	int 	gray_to_int		(std::string);
	int 	bin_to_int		(std::string);

	static std::string blank9;
public:
	time_analysis(const char* file, const char* title);
	~time_analysis();

	inline void save_graph(){bcid_graph->Write(title);}
};

std::string time_analysis::blank9("         ");

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
		
		{`
			std::string desync_file   = std::string(argv[1]) + "desync_spp" + std::string(argv[4]) + ".txt";
			std::string timesync_file = std::string(argv[2]) + "timesync" + std::string(argv[4]) + ".txt";
			std::string root_file_name =  std::string(argv[3]) + "asic" + std::string(argv[4]) + "_bcid_order.root";

			time_analysis desync_analysis(
				desync_file.c_str(),
				"Desync BCID Evolution");

			#ifdef __debug__
			std::cout << "Desync Analysis Complete" << std::endl;
			#endif

			time_analysis timesync_analysis(
				timesync_file.c_str(),
				"Timesync BCID Evolution");

			#ifdef __debug__
			std::cout << "Timesyc Analysis Complete" << std::endl;
			#endif

			TFile * Root_file = new TFile(root_file_name.c_str(),"RECREATE");
			Root_file->cd();

			#ifdef __debug__
			std::cout << "Root File Open" << std::endl;
			#endif

			desync_analysis.save_graph();
			timesync_analysis.save_graph();

			#ifdef __debug__
			std::cout << "Root File Saved" << std::endl;
			#endif

			Root_file->Close();
		}
	}
}

#endif