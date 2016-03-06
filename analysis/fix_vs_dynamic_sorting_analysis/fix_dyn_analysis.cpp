#include "dynamic_sorter.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <thread>
#include <mutex>
#include <memory>
#include <vector>


std::mutex mu;

template <class T>
void thread_print(T text){
	mu.lock();
	std::cout << text << "\n";
	mu.unlock();
}


void output(int stat, int dyn)
{
	static std::ofstream ofile("histo_data.csv");

	mu.lock();
	ofile << stat << ',' << dyn << '\n';
	mu.unlock();
}


class thread_report
{
private:
	int n_cores;
	std::vector<std::string> reports;
	std::mutex _mu;

public:
	thread_report(int n):n_cores(n)
	{
		for (int i(0); i < n_cores; i++)
			reports.push_back("");
	}
	void report(std::string rep, int ID)
	{
		_mu.lock();

		if(ID >= n_cores) return;
		reports[ID] = rep;

		for (int i(0); i < n_cores; i++) thread_print("\e[A\r\e[K\e[A");

		for (int i(0); i < n_cores; i++) 
		{
			std::stringstream text;
			text << i << " : " << reports[i];
			thread_print(text.str());
		}

		_mu.unlock();
	}
};


void help();
void Analysis(std::vector<std::shared_ptr<velo::spp>>&&);


template <class T>
class stack
{
private:
	T * _stack;
	size_t _size;
	int _location;
	std::mutex _mu;

public:
	stack(T* stack, size_t size): _stack(stack), _size(size), _location(0){}

	T get()
	{
		std::lock_guard<std::mutex> lock(_mu);
		if (_location >= _size) throw 0;
		else return _stack[_location++];
	}
};


void process(
	std::shared_ptr<stack<std::string> > file_queue,
	thread_report& console,	
	int threadID);


int main(int argc, char** argv)
{	
	// Default values
	std::string input_dir = "./";
	int start = 0, finish = 51, cores = 1;

	// cmd line args
	if(argc == 1) {help(); return -1;}
	for (int i(1); i < argc; i++)
	{
		std::string arg = argv[i];
		if (arg == "-h") {help(); return -1;}
		else if (arg == "-c" && argc > i + 1) cores  = atoi(argv[++i]);
		else if (arg == "-s" && argc > i + 1) start  = atoi(argv[++i]);
		else if (arg == "-f" && argc > i + 1) finish = atoi(argv[++i]);
		else if (arg == "-d" && argc > i + 1) input_dir = argv[++i];
		else {help(); return -1;}
	}	

	std::vector< std::string > file_v;
	for (int mod(start); mod<= finish; mod++)
	for (int side(1); side <= 2; side++)
	{
		std::stringstream filename;
		filename << input_dir;
		if (input_dir.back() != '/') filename << '/';
		filename << "module_" << mod << '_' << side << ".txt";

		file_v.push_back(filename.str());
	}

	std::shared_ptr< stack<std::string> > file_queue(new stack< std::string >(&file_v[0],file_v.size()));

	std::vector< std::shared_ptr <std::thread> > thread_v;

	thread_report console(cores);

	for (int t(0); t < cores; t++)
		thread_print("");

	for (int t(0); t < cores; t++)
		thread_v.push_back(std::shared_ptr<std::thread>(new std::thread(process,file_queue,std::ref(console),t)));

	for (auto& tr : thread_v) tr->join();
}

void process(
	std::shared_ptr<stack<std::string> > file_queue,
	thread_report& console,
	int threadID)
{
	while(1)
	{

		std::string filename;

		try
		{
			filename = file_queue->get();
			console.report(filename,threadID);
		}
		catch(int i)
		{
			return;
		}

		std::fstream ifile(filename,std::iostream::in);

		std::shared_ptr<velo::spp> sppIn;
		velo::spp sppLast;
		std::string buffer;
		std::vector<std::shared_ptr<velo::spp>> datatrain;
		bool first(true);

		while(ifile >> buffer)
		{
			if (buffer == "") continue;
			else sppIn = std::shared_ptr<velo::spp>(new velo::spp(buffer));

			if (first){
				sppLast = *sppIn;
				first = false;
			}

			if (sppLast.get_BCID() != sppIn->get_BCID())
			{
				if(datatrain.size() > 0){
					Analysis(std::move(datatrain));
					datatrain.clear();
				}
			}

			datatrain.push_back(sppIn);
			sppLast = (*sppIn);
		}
		if(datatrain.size() > 0){
			Analysis(std::move(datatrain));
			datatrain.clear();
		}
	}	
}

void Analysis(std::vector<std::shared_ptr<velo::spp>>&& datatrain)
{
	int stat_t = datatrain.size();
	int dyn_t = dyn::bubble_sort_time(std::move(datatrain));
	output(stat_t,dyn_t);
}

void help()
{
	std::cout
		<< "\nDynamic vs Fixes Sort Analysis\n\n"
		<< "Options:\n"
		<< "-h\t Help\n"
		<< "-c\t No. cores = 1\n"
		<< "-d\t Input Directory = .\n"
		<< "-s\t Start Sensor = 0\n"
		<< "-f\t Finish Sensor = 51\n\n";
}
