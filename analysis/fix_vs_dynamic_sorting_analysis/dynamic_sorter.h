#ifndef __dynamic_sorter_h__
#define __dynamic_sorter_h__

#include <vector>
#include "velo.h"
#include <memory>

namespace dyn
{
	int bubble_sort_time(std::vector<std::shared_ptr<velo::spp>> data_train);
	
	std::vector<std::shared_ptr<velo::spp>> bubble_sort_even	(std::vector<std::shared_ptr<velo::spp>> data_train);
	std::vector<std::shared_ptr<velo::spp>> bubble_sort_odd		(std::vector<std::shared_ptr<velo::spp>> data_train);
}

#endif