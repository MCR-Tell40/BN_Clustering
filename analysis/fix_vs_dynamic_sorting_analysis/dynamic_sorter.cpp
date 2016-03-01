#include "dynamic_sorter.h"

int dyn::bubble_sort_time(std::vector<std::shared_ptr<velo::spp>>&& data_train)
{
	bool even_comp = false; 
	bool odd_comp = false;
	bool parity(true);
	int count(0);

	auto data = data_train;

	// std::cout << "***\n";
	// for (int i(0); i < data.size(); i++)
	// 	std:: cout << data[i]->get_rowID() << "\n";

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

		// std::cout << 'e' << even_comp << 'o' << odd_comp << 'p' << parity << 'c' << count << '\n';

		if(even_comp == true && odd_comp == true) 
		{
			// std::cout << "***\n";
			// for (int i(0); i < data.size(); i++)
			// 	std:: cout << data[i]->get_rowID() << "\n";

			return count;
		}
	}	
}

// bool dyn::train_compare(
// 	std::vector<std::shared_ptr<velo::spp>> data_train1, 
// 	std::vector<std::shared_ptr<velo::spp>> data_train2)
// {
// 	if (data_train1.size() != data_train2.size()) return false;

// 	for (int i(0); i < data_train1.size(); i++)
// 		if (data_train1->at(i)->get_rowID() != data_train2->at(i)->get_rowID())
// 		{
// 			std::cout << "trains not equal";
// 			return false;
// 		}

// 	std::cout << "trains equal";
// 	return true;
// }

bool dyn::bubble_sort_even(std::vector<std::shared_ptr<velo::spp> > * data_train)
{
	bool comp(true);

	for(size_t i(0); i < data_train->size()-1; i += 2)
		if (data_train->at(i)->get_rowID() < data_train->at(i+1)->get_rowID())
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
		if (data_train->at(i)->get_rowID() < data_train->at(i+1)->get_rowID())
		{
			std::swap(data_train->at(i),data_train->at(i+1));
			comp = false;
		}

	return comp;
}