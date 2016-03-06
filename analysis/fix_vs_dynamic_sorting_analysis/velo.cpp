#include "velo.h"

struct velo::spp::impl
{
	impl():
		BCID(0),
		columnID(0),
		rowID(0),
		chipID(0),
		hitmap(0),
		BCID_given(false),
		chipID_given(false)
		{}

	uint16_t 
		BCID, 
		columnID, 
		rowID;
	
	uint8_t  
		chipID, 
		hitmap;
	
	bool BCID_given, chipID_given;
};



velo::spp::spp():pimpl(new impl()){}

velo::spp::spp(std::string input):spp()
{
	if (input.length() == 24)
	{
		pimpl->chipID 		= std::bitset<3>(input.substr(0,3)).to_ulong();
		pimpl->columnID 	= std::bitset<5>(input.substr(3,5)).to_ulong();
		pimpl->rowID		= std::bitset<8>(input.substr(9,8)).to_ulong();
		pimpl->hitmap		= std::bitset<8>(input.substr(16,8)).to_ulong();
		pimpl->BCID_given = false; pimpl->chipID_given = true;
	}	
	else if (input.length() == 30)
	{
		pimpl->BCID 		= std::bitset<9>(input.substr(0,9)).to_ulong();
		pimpl->columnID 	= std::bitset<5>(input.substr(9,5)).to_ulong();
		pimpl->rowID		= std::bitset<8>(input.substr(14,8)).to_ulong();
		pimpl->hitmap		= std::bitset<8>(input.substr(21,8)).to_ulong();
		pimpl->BCID_given = true; pimpl->chipID_given =false;
	}
	else throw velo_except(1);
}

velo::spp::spp(velo::spp const & other):
	pimpl(new impl(*other.pimpl))
{}

velo::spp::~spp(){}

velo::spp & velo::spp::operator=(const velo::spp & other)
{
	velo::spp temp(other);

	std::swap(pimpl,temp.pimpl);

	return *this;
}

/* --- access methods --- */
bool 		velo::spp::get_BCID_given	(){return pimpl->BCID_given;}
bool 		velo::spp::get_chipID_given	(){return pimpl->chipID_given;}
uint16_t 	velo::spp::get_columnID		(){return pimpl->columnID;}
uint16_t 	velo::spp::get_rowID		(){return pimpl->rowID;}
uint8_t 	velo::spp::get_hitmap		(){return pimpl->hitmap;}
uint16_t 	velo::spp::get_BCID 		()
{
	if(pimpl->BCID_given) return pimpl->BCID;
	else throw velo_except(2);
}

uint8_t velo::spp::get_chipID()
{
	if(pimpl->chipID_given) return pimpl->chipID;
	else throw velo_except(3);
}

/* --- modifier methods --- */
inline void 	velo::spp::set_BCID(uint16_t id)
	{pimpl->BCID = id;		pimpl->BCID_given = true;}
inline void 	velo::spp::det_chipID(uint8_t id)
	{pimpl->chipID = id;	pimpl->chipID_given = true;}

