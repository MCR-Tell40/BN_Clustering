ROOTFLAGS = -pthread -std=c++0x -Wno-deprecated-declarations -m64 -I/home/velo/Downloads/root/include
ROOTLIBS  = $(shell root-config --libs)

all: size_analysis.h size_analysis.cpp
	g++ -o size_analysis $(ROOTLIBS) $(ROOTFLAGS) size_analysis.cpp

debug:
	g++ -o size_analysis $(ROOTLIBS) $(ROOTFLAGS) size_analysis.cpp -__DEBUG__=0

clean:
	rm -f size_analysis
