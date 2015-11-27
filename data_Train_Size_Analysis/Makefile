ROOTFLAGS = $(shell root-config --cflags)
ROOTLIBS  = $(shell root-config --libs)

all: size_analysis.h size_analysis.cpp
	@ g++ -o size_analysis $(ROOTLIBS) $(ROOTFLAGS) size_analysis.cpp

clean:
	rm -f size_analysis
