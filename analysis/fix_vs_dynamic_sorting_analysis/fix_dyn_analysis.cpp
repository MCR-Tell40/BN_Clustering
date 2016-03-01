#include "dynamic_sorter.h"

#include <iostream>

int main(int argc, char** argv)
{
	if (argc != 3)
	{
		std::cout 
			<< "Incorrect Arguments\n"
			<< "argv[1] = timesync dir\n"
			<< "argv[2] = number of files\n";
		return -1;
	}
}