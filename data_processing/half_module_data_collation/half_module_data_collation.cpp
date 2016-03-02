#include "half_module_data_collation.h"


void threadProcess(
	std::string iFileDir, 
	std::string oFileDir, 
	FIFO<int>& module_list, 
	int threadID)
{
	while(1)
	{
		// get next module for process or exit if done.
		int module_number;
		try {
			module_number = module_list.pop();
			thread_report("Getting next module",threadID);
		}catch(std::string i) {
			thread_report("Terminating",threadID);
			return;
		}

		std::array<FIFO<std::string>,12> asicData; //stores the data from the asic asicData[asicID][SPP]
		FIFO<std::string> side1, side2;

		for(int i(0); i < 12; i++)
		{
			std::stringstream filename;
			filename << iFileDir << "timesync" << module_number*12 + i << ".txt";
			std::ifstream iFile(filename.str());
			std::string tempIn;

			thread_report(filename.str(),threadID);

			while(iFile >> tempIn)
			{
				if (atoi(tempIn.c_str()) == 0) continue;
				asicData[i].store(tempIn);
			}
		}

		bool complete = false;
		bool next_bcid = true;
		int bcid = 0;
		while(!complete)
		{
			for (int i(0); i < 12; i++)
				if(!asicData[i].is_empty()){
					if(get_bcid(asicData[i].peak()) == bcid){
						if (i < 3 || i >= 9)
							side1.store(asicData[i].pop());
						else
							side2.store(asicData[i].pop());
						next_bcid = false;
					}
				}

			complete = true;
			for (auto& asic : asicData) if (!asic.is_empty()) complete = false;
			if (next_bcid) bcid ++;
			if (bcid >= 512) {bcid = 0; thread_report("bcid rollover",threadID);}
			next_bcid = true;
		}

		std::stringstream outFileName1;
		outFileName1 << oFileDir << "/module_" << module_number << "_";
		std::stringstream outFileName2;
		outFileName2 << outFileName1.str();
		outFileName1 << 1 << ".txt";
		outFileName2 << 2 << ".txt";

		std::ofstream oFile1(outFileName1.str());
		thread_report(outFileName1.str(),threadID);
		std::ofstream oFile2(outFileName2.str());
		thread_report(outFileName2.str(),threadID);

		while(!side1.is_empty())
			oFile1 << side1.pop() << '\n';

		while(!side2.is_empty())
			oFile2 << side2.pop() << '\n';
	}
}