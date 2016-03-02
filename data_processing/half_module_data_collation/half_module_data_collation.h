#ifndef __half_module_data_collation_h__
#define __half_module_data_collation_h__

#include <vector>
#include <string>
#include <iostream>
#include <thread>
#include <mutex>
#include <bitset>
#include <fstream>
#include <sstream>
#include <array>

std::mutex globalMtx;

// thread safe (when needed) First-In-First-Out vector wrapper
template <class T>
struct FIFO
{
	std::mutex _mu;
	std::vector<T> array;
	int index;
	FIFO():index(0){}
	bool is_empty(){return 0 == array.size() || index == array.size();} //not thread safe
	T peak(){return array[index];} //not thread safe
	T pop(){
		std::lock_guard<std::mutex> lock(_mu);
		if (is_empty()) throw std::string("FIFO empty");
		return array[index++];
	}
	void store(T item){
		std::lock_guard<std::mutex> lock(_mu);
		array.push_back(item);
	}
};

//returns bcid of spp
int get_bcid(std::string spp)
{
	std::string bcid(spp);
	for (int i(1); i < 9; i++)
		if (bcid[i-1] != spp[i])
			bcid[i] = '1';
		else
			bcid[i] = '0';

	return std::bitset<9>(bcid.substr(0,9)).to_ulong();
}

template<class T>
void thread_report(T msg, int ID)
{
	std::lock_guard<std::mutex> lock(globalMtx);
	std::cout << ID << ": " << msg << std::endl;
}

void help()
{
	std::cout
		<< "******************\n"
		<< "-i    In  file dir\n"
		<< "-o    Out file dir\n"
		<< "-c    No. Corse\n"
		<< "******************\n";
}

void threadProcess(
	std::string iFileDir, 
	std::string oFileDir, 
	FIFO<int>& module_list, 
	int threadID);

int main(int argc, char** argv)
{
	std::string iFileDir(".");
	std::string oFileDir(".");
	FIFO<int> module_list;
	int nCores(1);

	for(int i(1); i < argc; i++)
	{
		if (std::string(argv[i]) == "-h"){help(); return 1;}
		else if (std::string(argv[i]) == "-i" && i+1 < argc)
			iFileDir = argv[++i];
		else if (std::string(argv[i]) == "-o" && i+1 < argc)
			oFileDir = argv[++i];
		else if (std::string(argv[i]) == "-c" && i+1 < argc)
			nCores = atoi(argv[++i]);
		else {help(); return -1;}
	}

	std::cout << "iFileDir = " << iFileDir << "\noFileDir = " << oFileDir << std::endl;

	for(int i(0); i < 52; i++) module_list.store(i);

	std::vector<std::thread> threads;
	for (int i(0); i < nCores; i++)
		threads.push_back(std::thread(threadProcess,iFileDir,oFileDir,std::ref(module_list),i));

	for (auto& tr : threads) tr.join();
}

#endif