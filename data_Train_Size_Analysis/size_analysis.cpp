#include "size_analysis.h"

using namespace std;

data_train::data_train()
{

}

data_train::~data_train()
{

}

void data_train::add_spp(string input)
{
	spp_train.push_back(input);
}

int data_train::get_size()
{
	return spp_train.size();
}

void data_train::reset()
{
	spp_train.clear();
}

int get_bcid(string spp_str)
{
	string bcid_str = spp_str.substr(0,9);
	bcid_str = gtob(bcid_str);
	int bcid_int(0);

	for(int i(8); i >= 0; i--)
		bcid_int += (bcid_str[i] == '1' ? 1 : 0) * pow(2,8-i);	

	return bcid_int;
}

string gtob(string input)
{
	string output;

	output[0] = input[0];

	for (int i(1); i <9; i++)
	{
		output[i] = input[i] != output[i-1] ? '1' : '0';
	}

	return output;
}