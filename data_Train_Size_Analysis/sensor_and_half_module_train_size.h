#ifndef __sensor_and_half_module_train_size_h__
#define __sensor_and_half_module_train_size_h__

#include <vector>
#include <array>
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <exception>
#include <stdlib.h>

void help();

class SPP
{
private:
	std::string binary;
public:
	SPP(std::string binary):binary(binary){}

	int bcid();
	int gray_to_int(std::string gray);
};

class ASIC
{
protected:
	std::vector<std::array<int,512>> train_length;
	std::array<int,512> clean_array;
	int cycle;
public:
	ASIC();
	ASIC(std::ifstream&);

	inline void set_train_length(int BCID, int length){train_length[cycle][BCID] = length;}
	inline void add_train_length(int BCID){train_length[cycle][BCID]++;}
	void next_cycle();

	inline int get_cycle(){return cycle;}
	inline int get_train_length(int cycle_num, int bcid)
	{
		if (cycle_num < cycle && bcid < 512)
			return train_length[cycle_num][bcid];
		else
			return 0;
	}

};

class Sensor : public ASIC
{
public:
	Sensor():ASIC(){}
	Sensor(std::array<ASIC,3>);
};

class Half_Module : public Sensor
{
public:
	Half_Module():Sensor(){}
	Half_Module(std::array<Sensor,2>);
};

int main(int argc, char** argv)
{

	if (argc != 3) 
	{
		help();
		return 0;
	}

	std::array<ASIC,624> ASIC_array;
	std::array<Sensor,208> Sensor_array;
	std::array<Half_Module,104> Half_Module_array;

	int ASIC_min_cycle;
	int Sensor_min_cycle;
	int Half_Module_min_cycle;

	//	asic creation 
	for (int i(0); i < 624; i++)
	{
		std::cout << "\r\033[K" // line
			<< "ASIC " << i+1 << " / 624";
			
		std::stringstream filename;

		filename << argv[1] << "/timesync" << i << ".txt";

		std::ifstream in_file(filename.str());

		ASIC_array[i] = ASIC(in_file);

		if (i==0) 
			ASIC_min_cycle = ASIC_array[0].get_cycle();
		else if (ASIC_min_cycle < ASIC_array[i].get_cycle())
			ASIC_min_cycle = ASIC_array[i].get_cycle();

		std::cout << " #cycle = " << ASIC_min_cycle;
		std::cout.flush();

	}

	std:: cout << '\n';

	for (int i(0); i < 208; i++)
	{
		std::cout << "\r\033[K" // line
			<< "Sensor " << i+1 << " / 208";
		std::cout.flush();

		std::array<ASIC,3> in_array = {
			ASIC_array[i*3],
			ASIC_array[i*3+1],
			ASIC_array[i*3+2]
		};

		Sensor_array[i] = Sensor(in_array);
	}
	std:: cout << '\n';

	for (int i(0); i < 52; i++)
	{
		std::cout << "\r\033[K" // line
			<< "Module " << i+1 << " / 52";
		std::cout.flush();
	
		std::array<Sensor,2>
			half_1({Sensor_array[i*4],Sensor_array[i*4+2]}),
			half_2({Sensor_array[i*4+1],Sensor_array[i*4+3]});

		Half_Module_array[i*2] = Half_Module(half_1);
		Half_Module_array[i*2+1] = Half_Module(half_2);
	}
	std:: cout << '\n';



}



#endif

