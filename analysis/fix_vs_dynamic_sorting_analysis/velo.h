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
		//pimpl class implimentation
		struct impl;
		std::unique_ptr<impl> pimpl;
	
	public:
		spp();
		spp(std::string);
		spp(const velo::spp&);
		~spp();

		/* ---- Copy ---- */
		spp & operator=(const spp &);

		/* ---- Get ---- */

		uint16_t 	get_BCID	();
		uint8_t 	get_chipID	();
		bool 		get_BCID_given();
		bool 		get_chipID_given();
		uint16_t 	get_columnID();
		uint16_t 	get_rowID	();
		uint8_t 	get_hitmap	();

		/* ---- Set ---- */
		void set_BCID(uint16_t id);
		void det_chipID(uint8_t id);
	};

}

#endif