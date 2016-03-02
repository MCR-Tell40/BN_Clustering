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
	for (int side(0); side <= 1; side++)
	{
		std::stringstream filename;
		filename << input_dir;
		if (input_dir.back() != '/') filename << '/';
		filename << "Module_" << mod << '_' << side;

		file_v.push_back(filename.str());

	}

	std::shared_ptr< stack<std::string> > file_queue(new stack< std::string >(&file_v[0],file_v.size()));

	std::vector< std::shared_ptr <std::thread> > thread_v;

	thread_report console(cores);

	for (int t(0); t < cores; t++)
		thread_print("");

	for (int t(0); t < cores; t++)
		thread_v.push_back(std::shared_ptr<std::thread>(new std::thread(process,file_queue,std::ref(console),t)));

	for (int t(0); t < cores; t++)
		thread_v[t]->join();
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
		}
		catch(int i)
		{
			return;
		}

		//count and sort files
		std::ifstream icount(filename + "_count.txt");
		std::ifstream isort(filename + "_sort.txt");
		console.report(filename,threadID);

		std::string temp;

		while(icount >> temp)
		{
			int spp_count = std::bitset<8>(temp).to_ulong();

			if (spp_count > 48 || spp_count <= 0) continue;
			else
			{
				int ram_access = spp_count / 16;
				if (spp_count % 16 != 0) ram_access++;

				std::vector< std::shared_ptr <velo::spp> > datatrain;

				for (int i(0); i < ram_access; i++)
				{
					std::string ram_output;
					isort >> ram_output;

					if (ram_output.length() == 0) continue;

					try{
						for (int j(0); j<16; j++)
						{
							std::string spp_string = ram_output.substr(j*16,24);
							// thread_print(spp_string);				
							if (atoi(spp_string.c_str()) != 0)
								datatrain.push_back(std::shared_ptr<velo::spp>(new velo::spp(spp_string)));
						}
					}catch(velo::velo_except e)
					{
						thread_print(e.what());
					}
				}

				int dyn_time;

				if (datatrain.size() != 0)
					dyn_time = dyn::bubble_sort_time(std::move(datatrain));
				else continue;

				output(datatrain.size(),dyn_time);
				std::stringstream report;
				report << filename << " : static" << datatrain.size() << "\t: dynamic" << dyn_time << "\t: train " << datatrain.size();
				console.report(report.str(),threadID);
			}
		}
	}	
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
