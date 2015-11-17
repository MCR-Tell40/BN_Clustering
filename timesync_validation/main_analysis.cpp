#include "main_analysis.h"

using std::cout;
using std::endl;
using std::string;
using std::atoi;
/* time_analysis methods */

time_analysis::time_analysis(const char* file, const char* title):
file_name(file),
title(title)
{
	infile = new std::fstream(file, std::fstream::in);		
	if (!infile->is_open())
		std::cout << "File: " << file << " did not open fool!" << endl;
	
	read_data_in();
	create_graph();
}

void time_analysis::read_data_in()
{
	long count(0);
	std::string buff;
	while(getline(*infile,buff))
	{
		data.push_back(buff);
		count ++;

		if (count % 10000 == 0) cout << "File:" << file_name << " : " << count << endl;
	}
}

void time_analysis::create_graph()
{
	int * y = new int[data.size()];
	int * x = new int[data.size()];

	for(int i(0); i < data.size(); i++)
	{
		y[i] = extract_bcid(data[i]);
		#ifdef __debug__
		cout << data[i] << " : " << data[i].substr(0,9) << " : " << y[i] << endl;
		#endif
		x[i] = i;
	}

	bcid_graph = new TGraph(data.size(),x,y);

	delete x,y;
}

int time_analysis::extract_bcid(string data_in)
{
  return gray_to_int(data_in.substr(0,9));
}

int time_analysis::gray_to_int(string in_bcid)
{
	string out_bcid(blank9);
	out_bcid[0] = in_bcid[0];
	for (int i(1); i < 9; i++)
	{
		out_bcid[i] = in_bcid[i] != out_bcid[i-1] ? '1' : '0';
	}
	return bin_to_int(out_bcid);
}

int time_analysis::bin_to_int(string data_in)
{
	int int_out(0);
	for(int i(8); i >= 0; i--)
	{
		int_out += (data_in[i] == '1' ? 1 : 0) * pow(2,8-i);
	}
	return int_out;
}

time_analysis::~time_analysis()
{
	infile->close();
	delete infile;
	delete bcid_graph;
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
