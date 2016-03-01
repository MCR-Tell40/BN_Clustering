#include "dynamic_sorter.h"

dyn::bubble_sort_time(std::vector<velo::spp> data_train)
{
}

std::vector<velo::spp> dyn::bubble_sort_even(std::vector<velo::spp> data_train)
{
	std::vector<velo::spp> out_vector = data_train;

	for(uint i(0); i < data_train.size()-1; i += 2)
		if (data_train[i].get_rowID() > data_train[i+1].get_rowID())
		{
			out_vector[i] = data_train[i+1];
			out_vector[i+1] = data_train[i];
		}

	return out_vector;

}

std::vector<velo::spp> dyn::bubble_sort_odd(std::vector<velo::spp> data_train)
{
	std::vector<velo::spp> out_vector = data_train;

	for(uint i(1); i < data_train.size()-1; i += 2)
		if (data_train[i].get_rowID() > data_train[i+1].get_rowID())
		{
			out_vector[i] = data_train[i+1];
			out_vector[i+1] = data_train[i];
		}

	return out_vector;
}