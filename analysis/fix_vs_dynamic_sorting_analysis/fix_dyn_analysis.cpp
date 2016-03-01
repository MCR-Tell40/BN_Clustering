#include "dynamic_sorter.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <thread>
#include <mutex>
#include <memory>
#include <vector>
#include <TH1F.h>
#include <TFile.h>

void help();

template <class T>
class stack
{
private:
	T * _stack;
	size_t _size;
	int _location;
	std:: mutex _mu;
public:
	stack(T* stack, size_t size): _stack(stack), _size(size), _location(0){}

	T get()
	{
		std::lock_guard<std::mutex> lock(_mu);
		if (_location == _size) throw;
		else return _stack[_location++];
	}
};


int main(int argc, char** argv)
{	
	// Default values
	std::string input_dir = "./";
	int start = 0, finish = 51, cores = 1;

	// cmd line args
	for (int i(1); i < argc; i++)
	{
		std::string arg = argv[i];
		if (arg == "-h") {help(); return -1;}
		else if (arg == "-c" && argc > i + 1) cores  = atoi(argv[++i]);
		else if (arg == "-s" && argc > i + 1) start  = atoi(argv[++i]);
		else if (arg == "-f" && argc > i + 1) finish = atoi(argv[++i]);
		else if (arg == "-i" && argc > i + 1) input_dir = argv[++i];
		else {help(); return -1;}
	}	

	std::vector<std::string> sort_file_v;
	std::vector<std::string> count_file_v;
	for (int side(0); side <= 1; side++)
		for (int mod(start); mod<= finish; mod++)
		{
			std::stringstream sort_filename, count_filename;
			sort_filename, count_filename << input_dir;
			if (input_dir.back() != '/') sort_filename << '/';
			sort_filename << "Module_" << mod << '_' << side << "_.txt";

			sort_file_v.push_back(sort_filename.str());

		}

	std::shared_ptr<stack<std::string>> file_queue(new stack<std::string>(&sort_file_v[0],sort_file_v.size()));
	std::shared_ptr<TH1F> dynamic_sort_h(new TH1F("dynamic_sort_h",";Sort Time;Count",50,0,50));
	std::shared_ptr<TH1F> static_sort_h(new TH1F("static_sort_h",";Sort Time;Count",50,0,50));

}

void process(
	std::shared_ptr<stack<std::string>> sort_file_queue,
	std::shared_ptr<stack<std::string>> count_file_queue, 
	std::shared_ptr<TH1F> dynamic_sort_h, 
	std::shared_ptr<TH1F> static_sort_h, 
	int threadID
	)
{
	while(1)
	{	
		std::ifstream ifile_count, ifile_sort;		
		//get new file if available, else exit thread
		try
		{
			ifile_count.open(count_file_queue->get());
			ifile_sort.open(sort_file_queue->get());
		}
		catch(...)
		{
			return;
		}

		std::string line_in("");
		std::string line_prev("");
		std::vector<std::string> spp_v;
		
	}
}

void help()
{
	std::cout
		<< "\nDynamic vs Fixes Sort Analysis\n\n"
		<< "Options:\n"
		<< "-h\t Help\n"
		<< "-c\t No. cores = 1"
		<< "-i\t Input Directory = .\n"
		<< "-s\t Start Sensor = 0\n"
		<< "-f\t Finish Sensor = 51\n\n";

}
