#include "velo.h"

velo::spp::spp()
{
	BCID = 0;
	chipID = 0;
	columnID = 0;
	rowID = 0;
	hitmap = 0;
	BCID_given = false;
	chipID_given = false;
}

velo::spp::spp(std::string input)
{
	if (input.length() == 24)
	{
		BCID = 0;
		chipID 		= std::bitset<3>(input.substr(0,3)).to_ulong();
		columnID 	= std::bitset<5>(input.substr(3,5)).to_ulong();
		rowID		= std::bitset<8>(input.substr(9,8)).to_ulong();
		hitmap		= std::bitset<8>(input.substr(16,8)).to_ulong();
		BCID_given = false; chipID_given = true;
	}	
	else if (input.length() == 30)
	{
		chipID = 0;
		BCID 		= std::bitset<9>(input.substr(0,9)).to_ulong();
		columnID 	= std::bitset<5>(input.substr(9,5)).to_ulong();
		rowID		= std::bitset<8>(input.substr(14,8)).to_ulong();
		hitmap		= std::bitset<8>(input.substr(21,8)).to_ulong();
		BCID_given = true; chipID_given =false;
	}
	else throw velo_except(1);
}

// velo::spp::spp(const velo::spp& copy)
// {
// 	if(copy.get_BCID_given())
// 	{
// 		BCID = copy.get_BCID();
// 		BCID_given = true;
// 	}
// 	else
// 	{
// 		BCID = 0;
// 		BCID_given = false;
// 	}

// 	if(copy.get_chipID_given())
// 	{
// 		chipID = copy.get_chipID();
// 		chipID_given = true;
// 	}
// 	else
// 	{
// 		chipID = 0;
// 		chipID_given = false;
// 	}

// 	columnID 	= copy.get_columnID();
// 	rowID 		= copy.get_rowID();
// 	hitmap 	= copy.get_hitmap();
// }

// velo::spp & velo::spp::operator=(velo::spp copy)
// {
// 	if(copy.get_BCID_given())
// 	{
// 		BCID = copy.get_BCID();
// 		BCID_given = true;
// 	}
// 	else
// 	{
// 		BCID = 0;
// 		BCID_given = false;
// 	}

// 	if(copy.get_chipID_given())
// 	{
// 		chipID = copy.get_chipID();
// 		chipID_given = true;
// 	}
// 	else
// 	{
// 		chipID = 0;
// 		chipID_given = false;
// 	}

// 	columnID 	= copy.get_columnID();
// 	rowID 	= copy.get_rowID();
// 	hitmap 	= copy.get_hitmap();

// 	return *this;
// }

uint16_t velo::spp::get_BCID()
{
	if(BCID_given) return BCID;
	else throw velo_except(2);
}

uint8_t velo::spp::get_chipID()
{
	if(chipID_given) return chipID;
	else throw velo_except(3);
}
