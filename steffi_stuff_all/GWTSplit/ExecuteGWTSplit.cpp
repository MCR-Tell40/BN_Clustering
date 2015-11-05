#include "GWTSplit.h"
#include "ExecuteGWTSplit.h"
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <sstream>

using namespace std;

int main(int argc, const char* argv[])
{
  if ( argc > 3){
    for (int i = 1; i <= argc; i++){
      if (strcmp( argv[i], "--help") == 0 || strcmp( argv[i], "-h") == 0){ 
        PrintHelp();
        return 1;
      }
      GWTSplit *split = new GWTSplit(argv[1], argv[2], argv[3]);
      // Loop routine which does the same for each input file
      // Loop over one module and change the ParityCheck and TransFormSPP stuff - remove SPP if check has failed
      split->ReadInput(argv[4]);
      split->CheckSPAddress();
      return 0;
    }
  }
  else {
    cout << "Arguments incorrect" << endl;
    PrintHelp();
    return 1;
  }

}

void PrintHelp()
{
  // Prints help
  cout << " ----- GWTSplit ----- " << endl;
  cout << " Read 128bit GWT format, split into SPP packets and add ASIC ID to each SPP" << endl;
  cout << " GWT format = 4 bits (fixed pattern, e.g. 0101) + 4 bits (parity bits) + 4 x 30 bits (Super Pixel Packets) " << endl;
  cout << " Run with the following arguments: " << endl;
  cout << " argv[1] -> path to input data file " << endl;
  cout << " argv[2] -> name of input data file, e.g. for desync90.txt argv[2] = desync " << endl;
  cout << " argv[3] -> BCID - something between 0 and 511 " << endl;
  cout << " argv[4] -> number of module, e.g. 15 for files 180-191 " << endl;
  cout << " ----- Try again! ----- " << endl;

}

