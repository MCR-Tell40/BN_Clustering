#ifndef BubbleSort_h
#define BubbleSort_h

#include <vector>
#include <string>
#include "../GWTSplit/GWTSplit.h"
#include "TH1F.h"
#include "TFile.h"
#include "TTree.h"

class BubbleSort
{
  // Global variables
  const char* _path; // Path to input txt file containing GWT frames
  const char* _inputfile; // Name of input txt file containing GWT frames
  const char* _modulenumber; // Number of module
  const char* _cutoff; // Cutoff for SPPs
  std::vector<std::vector < unsigned int> > spp_vec; // SPP
  std::vector<unsigned int> _registry_f; // first registry
  std::vector<unsigned int> _registry_s; // second registry
  GWTSplit *_split;
  std::vector <unsigned int> _clock; // Clock cycles per train
  unsigned int total_spp;
  unsigned int isolated_spp;
  unsigned int nonisolated_spp;
  unsigned int direct_spp;
  unsigned int indirect_spp;
  unsigned int test_spp;

  unsigned int total_train;
  unsigned int empty_train;
  unsigned int skipped_train;
  unsigned int sorted_train;
  std::vector<unsigned int> tmp_spptot;
  std::vector<unsigned int> tmp_sppiso;
  std::vector<unsigned int> tmp_sppnoniso;
  std::vector<unsigned int> tmp_sppdir;
  std::vector<unsigned int> tmp_sppindir;

  std::vector<unsigned int> tmp_hs0;
  std::vector<unsigned int> tmp_hs1;
  std::vector<unsigned int> tmp_hs2;
  std::vector<unsigned int> tmp_hs3;

  TFile *_file;
  TTree *_treeout;

 public :
  
  BubbleSort(const char * path = " ", const char* inputfile = " ", const char* modulenumber = " ", const char* cutoff = "100");
  virtual ~BubbleSort();
  bool SkipTrain(unsigned int train); 
  virtual void NextClockCycle(unsigned int train);
  virtual void ParallelSorting();
  virtual void IsolationFlag(unsigned int train);
  virtual void DirectNeighbour(unsigned int train);
  virtual void ShipOutput(unsigned int train);
  bool Swap_first(bool even);
  bool Swap_second(bool even);
  virtual void Plot();
};

#endif

