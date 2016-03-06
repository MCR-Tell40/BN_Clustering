#include "dynamic_sorter.h"

int dyn::bubble_sort_time(std::vector<std::shared_ptr<velo::spp>>&& data_train)
{
	bool even_comp = false; 
	bool odd_comp = false;
	bool parity(true);
	int count(0);

	auto data = data_train;

	while(1)
	{	
		count++;

		if (parity == true)
		{
			even_comp = bubble_sort_even(&data);
			if(even_comp == false) odd_comp = false;
		}
		else
		{
			odd_comp = bubble_sort_odd(&data);
			if(odd_comp == false) even_comp = false;
		}
		parity = !parity;

		if(even_comp == true && odd_comp == true) 
		{
			return count;
		}
	}	
}

bool dyn::bubble_sort_even(std::vector<std::shared_ptr<velo::spp> > * data_train)
{
	bool comp(true);

	for(size_t i(0); i < data_train->size()-1; i += 2)
		if (data_train->at(i)->get_rowID() > data_train->at(i+1)->get_rowID())
		{
			std::swap(data_train->at(i),data_train->at(i+1));
			comp = false;
		}

	return comp;
}

bool dyn::bubble_sort_odd(std::vector<std::shared_ptr<velo::spp> > * data_train)
{
	bool comp(true);

	for(size_t i(1); i < data_train->size()-1; i += 2)
		if (data_train->at(i)->get_rowID() > data_train->at(i+1)->get_rowID())
		{
			std::swap(data_train->at(i),data_train->at(i+1));
			comp = false;
		}

	return comp;
}