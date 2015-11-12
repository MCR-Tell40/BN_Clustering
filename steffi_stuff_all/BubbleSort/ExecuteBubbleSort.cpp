#include "ExecuteBubbleSort.h"
#include "BubbleSort.h"
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <sstream>

using namespace std;

int main(int argc, const char * argv[])
{
  if ( argc > 3){
    for (int i = 1; i <= argc; i++){
      if (strcmp( argv[i], "--help") == 0 || strcmp( argv[i], "-h") == 0){ 
        PrintHelp();
        return 1;
      }
      BubbleSort *bubble = new BubbleSort(argv[1], argv[2], argv[3], argv[4]);
      bubble->ParallelSorting();
      bubble->Plot();
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
  // //./BubbleSort.o ../../data/ desync 15 100
  cout << " ----- BubbleSort ----- " << endl;
  cout << " Parallel bubble sort of SPPs for a single BCID and a single module " << endl; 
  cout << " Run with the following arguments: " << endl;
  cout << " argv[1] -> path to input data file " << endl;
  cout << " argv[2] -> name of input data file, e.g. for desync90.txt argv[2] = desync " << endl;
  cout << " argv[3] -> number of module, e.g. 15 for files 180-191 " << endl;
  cout << " argv[4] -> Cutoff for SPP train " << endl;
  cout << " ----- Try again! ----- " << endl;
}


