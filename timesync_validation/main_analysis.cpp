#include "main_analysis.h"

using std::cout;
using std::endl;

/* time_analysis methods */

time_analysis::time_analysis(const char* file, const char* title):
title(title)
{
	infile = new std::fstream(file, std::fstream::in);
	read_data_in();
	create_graph();
}

time_analysis::~time_analysis()
{
	infile->close();
	delete infile;
	delete bcid_graph;
}

bcid time_analysis::extract_bcid(spp data_in)
{
	bcid data_out;
	for(int i(20); i < 30; i++)
	{
		data_out[i-20]=data_in[i];
	} 
	return data_out;
}

int time_analysis::bcid_to_int(bcid data_in)
{
	int int_out;
	for(int i(0); i < 9; i++)
	{
		int_out += data_in[i] * pow(2,i);
	}
	return int_out;
}

spp time_analysis::str_to_spp(std::string in_string)
{
	spp out_spp;
	for (int i(1); i < 31; i++)
	{
		out_spp[30-i] = in_string[i];
	}	
	return out_spp;
}

void time_analysis::read_data_in()
{
	long count(0);
	while(!infile->eof())
	{
		std::string buff;
		*infile >> buff;
		
		if (buff == "") break;

		data.push_back(str_to_spp(buff));
		count ++;

		if (count % 10000 == 0) cout << count << endl;
	}
}

void time_analysis::create_graph()
{
	int * y = new int[data.size()];
	int * x = new int[data.size()];

	for(int i(0); i < data.size(); i++)
	{
		y[i] = bcid_to_int(extract_bcid(data[i]));
		x[i] = i;
	}

	bcid_graph = new TGraph(data.size(),x,y);
}

/* Help text */

void print_help()
{
	cout 	<< "*****************************************" << endl
			<< "** Time Sync File Checker              **" << endl
			<< "** Argv[1] = desync folder             **" << endl
			<< "** Argv[2] = timesync folder           **" << endl
			<< "** Argv[3] = file number               **" << endl
			<< "** Argv[4] = root file (path and name) **" << endl
			<< "*****************************************" << endl
			<< "******* Built with C++ and coffee *******" << endl;
}