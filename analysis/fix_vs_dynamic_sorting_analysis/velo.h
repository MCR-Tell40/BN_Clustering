#ifndef __velo_h__
#define __velo_h__

#include <string>
#include <bitset>

namespace velo
{
	class velo_except
	{
	private:
		int errorID;
	public:
		velo_except(int e): errorID(e){}
		inline int get_error(){return errorID;}
		std::string what()
		{
			switch(errorID)
			{
				case 1:
					return "SPP input of wrong size";
				case 2:
					return "BCID not defined";
				case 3:
					return "chipID not defined";
				default:
					return "Unknown VELO error";
			}
		} 
	};

	class spp
	{
	private:
		uint16_t 
			BCID, 
			columnID, 
			rowID;
		
		uint8_t  
			chipID, 
			hitmap;
		
		bool BCID_given, chipID_given;
	
	public:
		spp();
		spp(std::string);
		// spp(const velo::spp&); //copy constructor

		/* ---- Copy ---- */
		spp & operator=(spp);

		/* ---- Get ---- */

		//conditional
		uint16_t 	get_BCID	();
		uint8_t 	get_chipID	();

		//inline
		inline bool get_BCID_given(){return BCID_given;}
		inline bool get_chipID_given(){return chipID_given;}
		inline uint16_t get_columnID(){return columnID;}
		inline uint16_t get_rowID	(){return rowID;}
		inline uint8_t 	get_hitmap	(){return hitmap;}

		/* ---- Set ---- */
		inline void set_BCID(uint16_t id)
			{BCID = id;		BCID_given = true;}
		inline void det_chipID(uint8_t id)
			{chipID = id;	chipID_given = true;}
	};

}

#endif