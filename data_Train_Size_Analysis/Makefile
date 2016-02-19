ROOTFLAGS = -pthread -std=c++0x -Wno-deprecated-declarations -m64 -I/home/velo/Downloads/root/include
ROOTLIBS  = $(shell root-config --libs)

all: size_analysis.h size_analysis.cpp sensor_and_half_module_train_size.h sensor_and_half_module_train_size.cpp
	@ g++ -o size_analysis $(ROOTLIBS) $(ROOTFLAGS) size_analysis.cpp
	@ g++ -o full_analysis -std=c++11 sensor_and_half_module_train_size.cpp

clean:
	rm -f size_analysis *.root
