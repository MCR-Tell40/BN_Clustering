#ifndef GWTSplit_h
#define GWTSplit_h

#include <vector>
#include <string>
#include "TH1F.h"

class GWTSplit
{
  // Global variables
  const char* _path; // Path to input txt file containing GWT frames
  const char* _inputfile; // Name of input txt file containing GWT frames
  unsigned int _bcid; // BCID used for selection of SPPs
  std::vector<unsigned int> spp_vec; // SPP

 public :
  
  GWTSplit(const char * path = " ", const char* inputfile = " ", const char* bcid = " ");
  virtual ~GWTSplit();
  virtual void ReadInput(const char* modulenumber);
  virtual void ReadFile(std::string filenumber);
  virtual void TransformSPP(std::string filenumber, std::vector<std::vector <unsigned int> > spp_tmp_vec, std::vector<unsigned int> pb_vec);
  virtual void CheckSPAddress();
  std::vector<unsigned int> ReturnSPP();
  const char * Int2binary(unsigned int i);
  std::vector<unsigned int> String2binary(std::vector<std::string> vec);

  // For checks
  TH1F *h_tile;
  unsigned int hits_sensor0;
  unsigned int hits_sensor1;
  unsigned int hits_sensor2;
  unsigned int hits_sensor3;
};

#endif

