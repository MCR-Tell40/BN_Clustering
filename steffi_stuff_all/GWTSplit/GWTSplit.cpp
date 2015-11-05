#define GWTSplit_cpp
#include "GWTSplit.h"

#include <cstring>
#include <iostream>
#include <sstream>
#include <fstream>
#include <cmath>
#include <vector>
#include <algorithm>
#include <climits>
#include <cstdlib>

using namespace std;

GWTSplit::GWTSplit( const char* path, const char * inputfile, const char* bcid) : 
_path(path),
_inputfile(inputfile)
{
  // Constructor
  _bcid = (unsigned int) atoi(bcid);
  // Initialise histograms
  h_tile = new TH1F("h_tile", "h_tile", 16, -0.5, 14.5);
  hits_sensor0 = 0;
  hits_sensor1 = 0;
  hits_sensor2 = 0;
  hits_sensor3 = 0;
}

GWTSplit::~GWTSplit()
{
  // Deconstructor
  delete h_tile;

}

void GWTSplit::ReadInput(const char *modulenumber)
{
  //cout << "Read Module " << modulenumber << endl;
  for (unsigned int i = (unsigned int) atoi(modulenumber)*12; i < (unsigned int) (atoi(modulenumber) + 1)*12; i++){
    stringstream ss;
    ss << i;
    ReadFile(ss.str());
  }
  //ReadFile("180");
  cout << "Size of BCID buffer " << spp_vec.size() << endl;
}


void GWTSplit::ReadFile(string filenumber)
{
  // Read input file
  ifstream reader;

  // Loop over all 12 files in module
  string filename = _path; 
  filename.append("/");
  filename.append(_inputfile);
  filename.append(filenumber);
  filename.append(".txt");
  //cout << "Add file " << filename << endl;

  reader.open(filename.c_str()); 
  string buffer;
  vector<string> gwt_vec;

  if (reader.is_open()) {
    while (!reader.eof()){
      string line;
      getline(reader,line);
      gwt_vec.push_back(line);
    }
  }
  reader.close();
  // Split GWT in different vectors
  vector<string> fp_tmp_vec; // fixed pattern
  vector<string> pb_tmp_vec; // parity bits
  vector<string> spp1_tmp_vec; // 1st SPP
  vector<string> spp2_tmp_vec; // 2nd SPP
  vector<string> spp3_tmp_vec; // 3rd SPP
  vector<string> spp4_tmp_vec; // 4th SPP
  // Input of TRansformSPP
  vector<vector <unsigned int> > spp_tmp_vec; // SPP
  vector<unsigned int> pb_vec; // parity bits
  vector<unsigned int> fp_vec; // fixed pattern

  for (unsigned int i = 0; i < gwt_vec.size()-1; i++){
    string tmp = gwt_vec.at(i);
    string fp = ""; // fixed pattern
    string pb = ""; // parity bits for the four SPP
    string spp1 = ""; // 1st SPP
    string spp2 = ""; // 2nd SPP
    string spp3 = ""; // 3rd SPP
    string spp4 = ""; // 4th SPP

    for (unsigned int j = 0; j < tmp.length(); j++){
      std::stringstream ss;
      ss << tmp.at(j);
      string fix;
      ss >> fix;
      if (j < 4) fp.append(fix);
      if (j >= 4 && j < 8) pb.append(fix);
      if (j >= 8 && j < 38) spp1.append(fix);
      if (j >= 38 && j < 68) spp2.append(fix);
      if (j >= 68 && j < 98) spp3.append(fix);
      if (j >= 98 && j < 128) spp4.append(fix);
    }
    fp_tmp_vec.push_back(fp);
    pb_tmp_vec.push_back(pb);
    spp1_tmp_vec.push_back(spp1);
    spp2_tmp_vec.push_back(spp2);
    spp3_tmp_vec.push_back(spp3);
    spp4_tmp_vec.push_back(spp4);
  }
  
  // Strings to int to binary conversion
  vector<unsigned int> spp1_vec;
  vector<unsigned int> spp2_vec;
  vector<unsigned int> spp3_vec;
  vector<unsigned int> spp4_vec;
  // Actual conversion
  fp_vec   = String2binary(fp_tmp_vec); 
  pb_vec   = String2binary(pb_tmp_vec); 
  spp1_vec = String2binary(spp1_tmp_vec);
  spp2_vec = String2binary(spp2_tmp_vec);
  spp3_vec = String2binary(spp3_tmp_vec);
  spp4_vec = String2binary(spp4_tmp_vec);
  // Add SPPs in one vector
  spp_tmp_vec.push_back(spp1_vec);
  spp_tmp_vec.push_back(spp2_vec);
  spp_tmp_vec.push_back(spp3_vec);
  spp_tmp_vec.push_back(spp4_vec);
 
  // spp_tmp_vec.at(0).at(1) contains 1st SPP in 2nd line of file, and spp_tmp_vec.at(1).at(1) contains 2nd SPP in 2nd line of file
  //cout << (fp_tmp_vec.at(1)) << "  " << (pb_tmp_vec.at(1))<< "  "  << (spp1_tmp_vec.at(1))<< "  "  << (spp2_tmp_vec.at(1))<< "  "  << (spp3_tmp_vec.at(1))<< "  "  << (spp4_tmp_vec.at(1)) << endl;
  //cout << Int2binary(fp_vec.at(1)) << "  " << Int2binary(pb_vec.at(1))<< "  "  << Int2binary(spp1_vec.at(1))<< "  "  << Int2binary(spp2_vec.at(1))<< "  "  << Int2binary(spp3_vec.at(1))<< "  "  << Int2binary(spp4_vec.at(1)) << endl;
  TransformSPP(filenumber, spp_tmp_vec, pb_vec);
  //cout << Int2binary(spp_vec.at(1)) << endl;  

}

void GWTSplit::TransformSPP(string filenumber, vector<vector <unsigned int> > spp_tmp_vec, vector<unsigned int> pb_vec){
  // First, check Parity and if check is successful, strip of BCID and then add ASIC ID - otherwise a 32bit int is too small
  unsigned int tmp = atoi(filenumber.c_str());
  unsigned int module = tmp/12; // 52 modules
  unsigned int chip = tmp%12; // each module has 4 sensors and each sensor has 3 chips aka ASICs
  unsigned int asic = chip % 3; // Returns ASIC number 0,1,2  
  unsigned int sensor(0); // Sensor number 0,1,2,3 
  for (unsigned int i = 0; i < 4; i++){
    unsigned int left = -1 + i*3;
    unsigned int right = (i+1)*3;
    if (chip > left && chip < right){
      sensor = (unsigned int) i;
    }
  }

  cout << "File with number " << filenumber << " equals module " << module << " and global chip " << chip << " and sensor " << sensor << " and asic " << asic << endl;
  // Module ID goes in header
  // Means that chip = 0,1,2 (sensor 0), chip = 3,4,5 (sensor 1), chip = 6,7,8 (sensor 2), chip = 9,10,11 (sensor 3)
  // ASIC ID is then 0,1,2 (sensor 0) - 4,5,6 (sensor 1) - 8,9,10 (sensor 2) - 12,13,14 (sensor 3)
  unsigned int asic_id = 4*(sensor) + asic;
  asic_id = asic_id << 28; 
  unsigned int count_bcid = 0;
  
  // Train boundary - usual latency is 64 + 8 (readout latency)
  unsigned int train_bound = 200 + _bcid;
  // Reset boundary if necessary.
  if (train_bound >= 512){
    train_bound -= 512;  
  }
  
  for (unsigned int i = 0; i < spp_tmp_vec.at(0).size(); i++){ // Loop over each GWT frame
    unsigned int pb_tmp = pb_vec.at(i);
    for (unsigned int j = 0; j < spp_tmp_vec.size(); j++){ // Loop over each of the 4 SPP packets
      unsigned int tmp = spp_tmp_vec.at(j).at(i);
      // Remove fakes (empty hit pattern) 
      if (((tmp << 24) == 0)){
        continue;
      }
      // Remove SPPs from next train and return if the bcid of an SPP is larger than the bcid you're looking for + latency window - usual latency is 64 + 8 (readout latency)
      // Karol: bcid = event + 8 + SP_Addr%64
      if (((tmp >> 21) >= (train_bound))){
        return;
      }

      if (((tmp >> 21) != _bcid)){
        continue;
      }
      else count_bcid++;
      // Count ones in SPP
      unsigned int n = 0;
      unsigned int pb = 0;
      for (unsigned int k = 0; k < sizeof(unsigned int) * CHAR_BIT; k++){
        n += (tmp & 1); 
        tmp = tmp >> 1;
      }
      // partity bits are stored in the last 4 bits of pb_vec
      unsigned int shift = spp_tmp_vec.size() - (j + 1) ;
      pb = ((pb_tmp >> shift) & 1);
      // Parity bit pb = 0 for n % 2 == 0 
      if ((n % 2 == 0 && pb == 1) || (n % 2 != 0 && pb == 0)){
        cout << " WARNING: Parity check failed for SPP " <<  j+1 << " in line " << i+1 << endl;
        cout << n << " and " << pb << endl;
        continue;
      }
      // Strip off BCID
      spp_tmp_vec.at(j).at(i) = spp_tmp_vec.at(j).at(i) << 11; // SPP = 30 bit and 2 0 bits of int
      // Add ASIC ID
      // Shift spp by 4 and also asic ID to make the 4 MSB
      spp_tmp_vec.at(j).at(i) = spp_tmp_vec.at(j).at(i) >> 4;
      spp_tmp_vec.at(j).at(i) = (spp_tmp_vec.at(j).at(i) | asic_id);
      // Finally append to spp_vec
      spp_vec.push_back(spp_tmp_vec.at(j).at(i));
      // For each SPP, fill histogram, count number of hits per sensor
      h_tile->Fill(sensor);
      if (sensor == 0) hits_sensor0++; 
      else if (sensor == 1) hits_sensor1++; 
      else if (sensor == 2) hits_sensor2++; 
      else if (sensor == 3) hits_sensor3++; 
    }
  }
  //cout << "Count BCID " << count_bcid << endl;
}

void GWTSplit::CheckSPAddress()
{
  // SPP = BCID (9 bit) + SPAddress (13 bit) + hit pattern (8 bit)
  // Loop over each SPP, check module and chip (52 modules with 12 chips each)
  // Loop over each SPP and check if the SPP address is the same

 unsigned int count_doubles = 0;
 unsigned int count_singles = 1; // begins at one 
  vector<unsigned int> tmp;

 for (unsigned int i = 0; i < spp_vec.size(); i++){ // Loop over each SPP
    // SPP contains 4bit ASIC ID and then 13bit SPP address
    tmp.push_back(spp_vec.at(i) >> 15); 
  }
  cout << "Sort and check for multiple SPP addresses" << endl;
  sort(tmp.begin(), tmp.end());
  for (unsigned int i = 0; i < tmp.size()-1; i++){
    unsigned int first = tmp.at(i);
    unsigned int last = tmp.at(i+1);
    if (first == last){
      cout << "===== " << i << " =====" << endl;
      cout << "F " << first << endl;
      cout << "L " << last << endl;
      count_doubles++;
    }
    else count_singles++;
  }
  cout << "Singles " << count_singles << " and doubles " << count_doubles << endl;

}

std::vector<unsigned int> GWTSplit::ReturnSPP()
{
  return spp_vec;
}

vector<unsigned int> GWTSplit::String2binary(vector<string> vec)
{ 
  vector<unsigned int> ret;

  for (unsigned int i = 0; i < vec.size(); i++){
    unsigned int bin = 0;
    unsigned int maxpower = vec.at(i).size();
    // This should not be complicated but it is.    
    for (unsigned int j = maxpower; j >= 1; j--){
      unsigned int w = (unsigned int) pow(2, maxpower-j);
      string tmp = "";
      bin += w*atoi((tmp+vec.at(i).at(j-1)).c_str());
    }
    ret.push_back(bin);
  }
  return ret;
}

const char * GWTSplit::Int2binary(unsigned int i)
{
  size_t bits = sizeof(unsigned int) * CHAR_BIT;

  char * str = (char*)  malloc(bits + 1);
  if(!str) return NULL;
  str[bits] = 0;

  // type punning because signed shift is implementation-defined
  unsigned u = *(unsigned *)&i;
  for(; bits--; u >>= 1)
    str[bits] = u & 1 ? '1' : '0';

 // cout << "=== Converted " << i << " to binary format " << str << " ===" << endl;
  return str;
}
