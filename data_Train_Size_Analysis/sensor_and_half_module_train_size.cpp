#include "sensor_and_half_module_train_size.h"

int SPP::bcid()
{
	try
	{
		return gray_to_int(binary.substr(0,9));
	}
	catch(std::exception e)
	{
		std::cout << e.what();
		exit;
	}
}

int SPP::gray_to_int(std::string gray)
{
	std::string bin(gray);

	//gray to bin
	for (int i(1); i < gray.length(); i++)
		if (bin[i-1] == gray[i])
			bin[i] = '0';
		else
			bin[i] = '1';

	//bin to int
	int output(0);
	for (int i(0); i < bin.length(); i++)
	{
		output = output << 1;

		if (bin[i] == '1')
			output = output | 1;
	}

	return output;
}

ASIC::ASIC(): cycle(0)
{
	for (int i(0); i < 512; i++)
		clean_array[i] = 0;

	train_length.push_back(clean_array);
}

ASIC::ASIC(std::ifstream& in_file): ASIC()
{
	std::string in_line;
	int last_bcid(0);

	while(in_file >> in_line)
	{
		SPP in_spp(in_line);

		if (in_spp.bcid() - last_bcid < 0)
			next_cycle();

		add_train_length(in_spp.bcid());

		
		last_bcid = in_spp.bcid();
	}
}

void ASIC::next_cycle()
{
	// increase cycle counter and create new array
	cycle++;
	train_length.push_back(clean_array);
}

void ASIC::write_to_file(std::ofstream& out_file)
{
	for (int _cycle(0); _cycle < cycle; _cycle++)
		for (int i(0); i < 511; i++)
			out_file << train_length[_cycle][i] << std::endl;
}

Sensor::Sensor(std::array<ASIC,3> a): ASIC()
{
	//get max cycle
	int maxcycle;
	if (a[0].get_cycle() > a[1].get_cycle() && a[0].get_cycle() > a[2].get_cycle())
		maxcycle = a[0].get_cycle();
	else if (a[1].get_cycle() > a[2].get_cycle())
		maxcycle = a[1].get_cycle();
	else
		maxcycle = a[2].get_cycle();

	while(cycle < maxcycle) next_cycle();

	//combine all trainlength info
	for (int i(0); i < cycle; i++)
		for (int bcid(0); bcid < 512; bcid++)
			for (int j(0); j < 3; j++)
				train_length[i][bcid] += a[j].get_train_length(i,bcid);
}

Half_Module::Half_Module(std::array<Sensor,2> s): Sensor()
{
	//get max cycle
	int maxcycle;
	if (s[0].get_cycle() > s[1].get_cycle())
		maxcycle = s[0].get_cycle();
	else
		maxcycle = s[1].get_cycle();

	while(cycle < maxcycle) next_cycle();

	//combine trainlength info
	for (int i(0); i < cycle; i++)
		for (int bcid(0); bcid < 512; bcid++)
			for (int j(0); j < 2; j++)
				train_length[i][bcid] += s[j].get_train_length(i,bcid);

}

void help()
{
	std::cout 
		<< "*******************************************\n \n"
		<< "argv[1] = timesync folder location\n"
		<< "argv[2] = destination folder for root files\n \n"
		<< "*******************************************\n";
}