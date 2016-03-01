#ifndef __dynamic_sorter_h__
#define __dynamic_sorter_h__

#include <vector>
#include "velo.h"

namespace dyn
{
	int bubble_sort_time(std::vector<velo::spp> data_train);
	
	std::vector<velo::spp> bubble_sort_even(std::vector<velo::spp> data_train);
	std::vector<velo::spp> bubble_sort_odd(std::vector<velo::spp> data_train);
}

#endif