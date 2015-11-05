#define BubbleSort_cpp
#include "BubbleSort.h"
#include "../GWTSplit/GWTSplit.h"

#include <cstring>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cmath>
#include <vector>
#include <algorithm>
#include <climits>
#include <cstdlib>

#include "TFile.h"
#include "TH1F.h"
#include "TROOT.h"

using namespace std;

BubbleSort::BubbleSort( const char* path, const char * inputfile, const char *modulenumber, const char* cutoff) : 
_path(path),
_inputfile(inputfile),
_modulenumber(modulenumber),
_cutoff(cutoff)
{
  // Constructor
  string tmp = "/afs/cern.ch/user/s/sreicher/Emulation/EMILlib/output/Test_Emulation_Module_";
  tmp += _modulenumber;
  tmp += ".root";
  const char* name = (const char*) tmp.c_str();
  cout << "name " << name << endl;
  _file = new TFile(name, "RECREATE");

  total_spp = 0;
  isolated_spp = 0;
  nonisolated_spp = 0;
  indirect_spp = 0;
  direct_spp = 0;

  total_train = 0;
  empty_train = 0;
  skipped_train = 0;
  sorted_train = 0;

  // Loop over BCIDs
  //for (unsigned int i = 21; i < 23; i++){
  for (unsigned int i = 0; i < 512; i++){
    stringstream ss;
    ss << i;
    string tmp = ss.str();
    // GWT split relies on BCID
    _split = new GWTSplit(_path, _inputfile, (const char*) tmp.c_str());
    _split->ReadInput(_modulenumber);
    // Get spp vec
    vector<unsigned int> tmp_vec = _split->ReturnSPP();

    total_train++;
    if (tmp_vec.size() == 0) {
      //cout << "Buffer empty - continue " << endl;
      empty_train++;
      continue;
    }
    tmp_hs0.push_back(_split->hits_sensor0);
    tmp_hs1.push_back(_split->hits_sensor1);
    tmp_hs2.push_back(_split->hits_sensor2);
    tmp_hs3.push_back(_split->hits_sensor3);

    string tilename = "h_tile_"; tilename += tmp;
    _split->h_tile->SetName(tilename.c_str());
    if (tmp_vec.size() <= (unsigned int) atoi(_cutoff)) _split->h_tile->Write();

    spp_vec.push_back(tmp_vec);

    // Initialse clocks
    _clock.push_back(0);
  }
}

BubbleSort::~BubbleSort()
{
  // Deconstructor
  delete _split;
}

void BubbleSort::ParallelSorting()
{
  // Trains which are larger than _cutoff are directly going to output
  // 4 bit ASIC ID + 13 bit SP address + 8 bit hit pattern
  // Sort by 4 bit ASIC ID and 7 bit column ID (MSBs of SP Address)
  // ASIC ID: 2 MSB's are sensor ID and 2 LSB's are chip ID
  // Read SPPs in registry
  
  unsigned int trains_read = 0;
  bool swap_odd, swap_even;
  unsigned int clock_f = 0, clock_s = 0;
  
  while (trains_read < spp_vec.size()){
    // Check if train is too large and if so, ship output 
    if (SkipTrain(trains_read) == true) {
      // To do: Add isolation flag if train is skipped
      ShipOutput(trains_read);  
      trains_read++;
      // To do: We don't need this statement?
      if (spp_vec.size() == 1){
         break;
      }
    }

    // Start reading first BCID train in registry_f
    for (unsigned int i = 0; i < spp_vec.at(trains_read).size(); i++){
      _registry_f.push_back(spp_vec.at(trains_read).at(i));
      NextClockCycle(trains_read);
    }
    // Add latency to second global clock
    clock_s +=  _clock.at(trains_read);
    // Start swapping in first registry
    swap_odd = true;
    swap_even = true;
    while (swap_even == true || swap_odd == true){
      swap_even = Swap_first(true); // Even cycle 
      NextClockCycle(trains_read);
      swap_odd = Swap_first(false);
      NextClockCycle(trains_read); // Odd cycle
      //cout << "First registry: swap_even " << swap_even << " and swap_odd " << swap_odd << endl;
    }
    // Overwrite train with sorted train saved in _registry
    spp_vec.at(trains_read) = _registry_f;
    IsolationFlag(trains_read);
    DirectNeighbour(trains_read);
    clock_f += _clock.at(trains_read);

    // Increase number of trains processed
    if (spp_vec.size() == 1) {
      break;
    }
    trains_read++;
    if (SkipTrain(trains_read) == true) {
      // To do: Add isolation flag if train is skipped
      ShipOutput(trains_read);  
      trains_read++;
    }
    // Start reading second train in registry_s
    for (unsigned int i = 0; i < spp_vec.at(trains_read).size(); i++){
      _registry_s.push_back(spp_vec.at(trains_read).at(i));
      NextClockCycle(trains_read);
    }

    swap_odd = true;
    swap_even = true;
    // Start swapping in second registry
    while (swap_even == true || swap_odd == true){
      swap_even = Swap_second(true); // Even cycle 
      NextClockCycle(trains_read);
      swap_odd = Swap_second(false);
      NextClockCycle(trains_read); // Odd cycle
      //cout << "Second registry: swap_even " << swap_even << " and swap_odd " << swap_odd << endl;
    }
    // Overwrite train with sorted train saved in _registry
    spp_vec.at(trains_read) = _registry_s;
    IsolationFlag(trains_read);
    DirectNeighbour(trains_read);
    clock_s += _clock.at(trains_read);

    if (clock_f < clock_s){
      ShipOutput(trains_read-1);
      ShipOutput(trains_read);
    }
    else {
      ShipOutput(trains_read);
      ShipOutput(trains_read-1);
    }

    trains_read++;

    // Free registries and reset clocks
    _registry_f.clear();
    _registry_s.clear();
    clock_s = 0;
    clock_f = 0;
  }
}

void BubbleSort::IsolationFlag(unsigned int train){

  sorted_train++;
  vector<unsigned int> tmp_vec;
  // Check columns next to hit column and if another SPP has a hit there, it is not isolated
  // This gives me a vector of all SPPs with asic ID+column address back
  for (unsigned int i = 0; i < spp_vec.at(train).size(); i++){
    unsigned int tmp = spp_vec.at(train).at(i) >> 21;
    tmp_vec.push_back(tmp);
  }

  cout << "Train with #SPPs " << tmp_vec.size() << endl;
  // The SPP is already sorted after ASIC and column ID, loop over all SPPs in train
  for (unsigned int j = 0; j < tmp_vec.size(); j++){
    bool isolated = false;
    total_spp++;
    if (tmp_vec.size() == 1){
      isolated = true; 
    }
    else {
      // Distinguish between the following cases
      if (j == 0){ // First entry in sorted train. We know that there is no SPP left of this one in the BCID train.
        // Only right neighbour
        int diff = tmp_vec.at(j+1) - tmp_vec.at(j);
        if (diff >= 2){
          isolated = true; 
        }
      }
      else if (j == (tmp_vec.size() - 1)){ //Last entry in sorted train. We know that there is no SPP right of this one in the BCID train.
        // Only  left neighbour
        int diff = tmp_vec.at(j) - tmp_vec.at(j-1);
        if (diff >= 2){
          isolated = true; 
        }
      }
      else {
        int diff_low = tmp_vec.at(j) - tmp_vec.at(j-1);
        int diff_up = tmp_vec.at(j+1) - tmp_vec.at(j);
        if (diff_low >= 2 && diff_up >= 2){
          isolated = true; 
        }
      }
    }
    if (isolated == true) isolated_spp++;
    else nonisolated_spp++;

    unsigned int flag = isolated << 6;
    spp_vec.at(train).at(j) = (spp_vec.at(train).at(j) | flag );
  }
  cout << "test" << endl;
  // Isolation check takes one clock cycle
  NextClockCycle(train);
  //cout << "Sorted and flagged " << _clock.at(train) << endl;
}

void BubbleSort::DirectNeighbour(unsigned int train){
  cout << "Neighbour" << endl;
  unsigned int tmp_total_spp = 0;
  unsigned int tmp_isolated_spp = 0;
  unsigned int tmp_nonisolated_spp = 0;
  unsigned int tmp_indirect_spp = 0;
  unsigned int tmp_direct_spp = 0;

  // Ok, so here is how it works: spp_vec.at(train).at() is: 4 asic, 7 column, 6 row, 8 hit pattern, 7 0's to fill the 32bit integer 
  // spp_vec.at(train).at(i) >> 21 then gives us the 11 MSB's
  vector<unsigned int> tmp_vec;
  vector<unsigned int> tmp_vec_row;

  // Check columns next to hit column and if another SPP has a hit there, it is not isolated
  for (unsigned int i = 0; i < spp_vec.at(train).size(); i++){
    unsigned int tmp = spp_vec.at(train).at(i) >> 21;
    tmp_vec.push_back(tmp);
    // Row vector - we only need the row and not the asic
    unsigned int tmp_row = spp_vec.at(train).at(i) << 11;
    tmp_row = tmp_row >> 26; 
    tmp_vec_row.push_back(tmp_row);
  }

  // Loop over all SPPs in train
  for (unsigned int j = 0; j < tmp_vec.size(); j++){
    bool isolated = false;
    tmp_total_spp++;
    if (tmp_vec.size() == 1){
      isolated = true; 
    }
    else {
      // Distinguish between the following cases
      if (j == 0){
        // Only right neighbour
        int diff = tmp_vec.at(j+1) - tmp_vec.at(j);
        if (diff >= 2){
          isolated = true; 
        }
      }
      else if (j == (tmp_vec.size() - 1)){
        // Only  left neighbour
        int diff = tmp_vec.at(j) - tmp_vec.at(j-1);
        if (diff >= 2){
          isolated = true; 
        }
      }
      else {
        int diff_low = tmp_vec.at(j) - tmp_vec.at(j-1);
        int diff_up = tmp_vec.at(j+1) - tmp_vec.at(j);
        if (diff_low >= 2 && diff_up >= 2){
          isolated = true; 
        }
      }
    }
    if (isolated == true) tmp_isolated_spp++;
    else tmp_nonisolated_spp++;
    // If there is a neighbour in the adjacent column, check if there's a neighbour in the adjacent rows
    if (isolated == false){
      bool indirect = true;
      // Copy and paste from above does not work. We've sorted after ASIC+column and not after row...
      // tmp_vec_row.at(j) = row index from 0 to 63
      // Loop over all other columns
      unsigned int k = 0;
      while (indirect == true && k < tmp_vec.size()){
        if (j==k) k++;
        else {
          // Just compare diff of all other SPPs
          int diffrow = tmp_vec_row.at(j) - tmp_vec_row.at(k); 
          //cout << "Row " << tmp_vec_row.at(j) << " and " << tmp_vec_row.at(k) << " makes " << diffrow << endl;
          if (fabs(diffrow) < 2){
            indirect = false;
          }
          k++;
        }
      }

      if (indirect == true){
        indirect_spp++;
        tmp_indirect_spp++;
      }
      else{
        direct_spp++;
        tmp_direct_spp++;
      }
    }
  }
  tmp_spptot.push_back(tmp_total_spp);
  tmp_sppiso.push_back(tmp_isolated_spp);
  tmp_sppnoniso.push_back(tmp_nonisolated_spp);
  tmp_sppdir.push_back(tmp_direct_spp);
  tmp_sppindir.push_back(tmp_indirect_spp);
  cout << "End neighbour" << endl;
}


bool BubbleSort::Swap_first(bool even)
{
  bool swap = false; // Indicates if a swap has occured
  unsigned int val;
  if (even == true) val = 0;
  else val = 1;
    
  for (unsigned int i = val; i < _registry_f.size(); i += 2){
    // Use only 11 MSBs for comparison
    if ((i+1) >=  _registry_f.size()) break;
    unsigned int  left = _registry_f[i] >> 21;
    unsigned int right = _registry_f[i+1] >> 21;
    if (left > right){
      unsigned int tmp = _registry_f[i];
      _registry_f[i] = _registry_f[i+1];
      _registry_f[i+1] = tmp;   
      swap = true;
    }
    //if (swap == true) cout << "Swapped " << _split->Int2binary(_registry_f.at(i) >> 21) << " and " << _split->Int2binary(_registry_f.at(i+1)>>21) << endl; 
  }

  return swap;
}

bool BubbleSort::Swap_second(bool even)
{
  bool swap = false; // Indicates if a swap has occured
  unsigned int val;
  if (even == true) val = 0;
  else val = 1;
    
  for (unsigned int i = val; i < _registry_s.size(); i += 2){
    // Use only 11 MSBs for comparison
    if ((i+1) >= _registry_s.size()) break;
    unsigned int  left = _registry_s[i] >> 21;
    unsigned int right = _registry_s[i+1] >> 21;
    if (left > right){
      unsigned int tmp = _registry_s[i];
      _registry_s[i] = _registry_s[i+1];
      _registry_s[i+1] = tmp;   
      swap = true;
    }
    //if (swap == true) cout << "Swapped " << _split->Int2binary(_registry_f.at(i) >> 21) << " and " << _split->Int2binary(_registry_f.at(i+1)>>21) << endl; 
  }

  return swap;
}

void BubbleSort::ShipOutput(unsigned int train)
{
  for (unsigned int i = 0; i < spp_vec.at(train).size(); i++){
    NextClockCycle(train);
  }

  //cout << "Output shipped for " << train << " after " << _clock.at(train) << " clock cycles." <<endl; 

}

bool BubbleSort::SkipTrain(unsigned int train)
{
  if (spp_vec.at(train).size() > (unsigned int) atoi(_cutoff)){
    skipped_train++;
    //cout << "SPP train from module " << _modulenumber << " is larger than cutoff " << _cutoff << endl;
    return true;
  }
  else {
    //sorted++;
    return false;
  }
}

void BubbleSort::NextClockCycle(unsigned int train)
{
  _clock.at(train)++;
}

void BubbleSort::Plot(){
  cout << "Plot" << endl;
   
  _treeout = new TTree("outtree", "outtree");
  unsigned int hs0(0), hs1(0), hs2(0), hs3(0), clock(0);
  unsigned int spptot(0), sppiso(0), sppnoniso(0), sppdir(0), sppindir(0);

  _treeout->Branch("hits_sensor0", &hs0, "hits_sensor0/I");
  _treeout->Branch("hits_sensor1", &hs1, "hits_sensor1/I");
  _treeout->Branch("hits_sensor2", &hs2, "hits_sensor2/I");
  _treeout->Branch("hits_sensor3", &hs3, "hits_sensor3/I");
  _treeout->Branch("clock", &clock, "clock/I");
  _treeout->Branch("total_spp", &spptot, "total_spp/I");
  _treeout->Branch("isolated_spp", &sppiso, "isolated_spp/I");
  _treeout->Branch("nonisolated_spp", &sppnoniso, "nonisolated_spp/I");
  _treeout->Branch("direct_spp", &sppdir, "direct_spp/I");
  _treeout->Branch("indirect_spp", &sppindir, "indirect_spp/I");
  gROOT->SetStyle("Plain"); 

  TH1F h1("h_nSPP","h_nSPP", 500, 0, 500);
  h1.SetTitle("");
  h1.GetXaxis()->SetTitle("# SPP per BCID train");
  TH1F h2("h_nClock","h_nClock", 500, 0, 500);
  h2.SetTitle("");
  h2.GetXaxis()->SetTitle("# clock cycles per BCID train");
  TH1F h3("h_ClockpSPP","h_ClockpSPP", 500, 0, 5);
  h3.SetTitle("");
  h3.GetXaxis()->SetTitle("# clock cycles per SPP");
  cout << "Train statistic: All trains "<< total_train << ", empty trains " << empty_train << ", skipped trains " << skipped_train << ", sorted trains " << sorted_train << endl; 
  cout << "SPP statistics " << total_spp << ", isolated SP " << isolated_spp << ", non isolated SP " << nonisolated_spp << endl;
  cout << "Total SPP statistics " << direct_spp << " direct and " << indirect_spp << " indirect neighbours." << endl;

  for (unsigned int i = 0; i < spp_vec.size(); i++){
    
    if (spp_vec.at(i).size() <= (unsigned int) atoi(_cutoff)){
      h1.Fill(spp_vec.at(i).size());
      h2.Fill(_clock.at(i));
      h3.Fill((float) spp_vec.at(i).size()/((float)_clock.at(i)));
      clock = _clock.at(i);
      hs0 = tmp_hs0.at(i);
      hs1 = tmp_hs1.at(i);
      hs2 = tmp_hs2.at(i);
      hs3 = tmp_hs3.at(i);
    }
    if (i < tmp_spptot.size()){
      spptot = tmp_spptot.at(i);
      sppiso = tmp_sppiso.at(i);
      sppnoniso = tmp_sppnoniso.at(i);
      sppdir = tmp_sppdir.at(i);
      sppindir = tmp_sppindir.at(i);
      _treeout->Fill();
    }
  }
  h1.Write();
  h2.Write();
  h3.Write();
  _treeout->Write();
  _file->Close();

}

