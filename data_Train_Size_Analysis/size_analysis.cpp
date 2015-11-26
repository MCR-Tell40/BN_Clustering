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
	spp_train.reset();
}

int get_bcid(string spp_str)
{
	string bcid_str = spp_str.substr(0,9);
	int bcid_int(0);

	for(int i(8); i >= 0; i--)
	{
		bcid_int += atoi(bcid_str(i)) * pow(2,(8 - i));
	}	

	return bcid_int;
}

