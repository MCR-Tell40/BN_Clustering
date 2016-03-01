#ifndef __dynamic_sorter_h__
#define __dynamic_sorter_h__

#include <vector>
#include "velo.h"
#include <memory>
#include <iostream>
#include <algorithm>

namespace dyn
{
	int bubble_sort_time	(std::vector<std::shared_ptr<velo::spp> >&& data_train);
	
	bool bubble_sort_even	(std::vector<std::shared_ptr<velo::spp> >* data_train);
	bool bubble_sort_odd	(std::vector<std::shared_ptr<velo::spp> >* data_train);

	bool train_compare(
		std::vector<std::shared_ptr<velo::spp>> data_train1, 
		std::vector<std::shared_ptr<velo::spp>> data_train2);
}

#endif