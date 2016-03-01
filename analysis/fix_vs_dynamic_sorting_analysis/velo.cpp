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
	if input.length() == 24
	{
		BCID = 0;
		chipID 		= std::bitset<3>(input.substr(0,3)).to_ulong();
		columnID 	= std::bitset<5>(input.substr(3,5)).to_ulong();
		rowID		= std::bitset<8>(input.substr(9,8)).to_ulong();
		hitmap		= std::bitmap<8>(input.substr(16,8)).to_ulong();
		BCID_given = false; chipID_given = true;
	}	
	else if input.length() == 30
	{
		chipID = 0;
		BCID 		= std::bitset<9>(input.substr(0,9)).to_ulong();
		columnID 	= std::bitset<5>(input.substr(9,5)).to_ulong();
		rowID		= std::bitset<8>(input.substr(14,8)).to_ulong();
		hitmap		= std::bitmap<8>(input.substr(21,8)).to_ulong();
		BCID_given = true; chipID_given =false;
	}
	else throw velo_exept(1);
}

velo::spp::spp(spp& copy)
{
	if(copy.BCID_given())
	{
		this->BCID = copy.get_BCID();
		this->BCID_given = true;
	}
	else
	{
		this->BCID = 0;
		this->BCID_given = false;
	}

	if(copy.chipID_given())
	{
		this->chipID = copy.get_chipID();
		this->chipID_given = true;
	}
	else
	{
		this->chipID = 0;
		this->chipID_given = false;
	}

	this->columnID 	= copy.get_columnID();
	this->rowID 		= copy.get_rowID();
	this->hitmap 	= copy.get_hitmap();
}

velo::spp & velo::spp::operator=(velo::spp copy)
{
	if(copy.BCID_given())
	{
		this->BCID = copy.get_BCID();
		this->BCID_given = true;
	}
	else
	{
		this->BCID = 0;
		this->BCID_given = false;
	}

	if(copy.chipID_given())
	{
		this->chipID = copy.get_chipID();
		this->chipID_given = true;
	}
	else
	{
		this->chipID = 0;
		this->chipID_given = false;
	}

	this->columnID 	= copy.get_columnID();
	this->rowID 	= copy.get_rowID();
	this->hitmap 	= copy.get_hitmap();

	return *this;
}

uint16_t velo::spp::get_BCID()
{
	if(BCID_given) return BCID;
	else throw velo_exept(2);
}

uint8_t velo::spp::get_chipID()
{
	if(chipID_given) return chipID;
	else throw velo_exept(3);
}
