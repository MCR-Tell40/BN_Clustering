TARGET = timesyncAnalysis
ROOTFLAGS = $(shell root-config --cflags)
ROOTLIBS  = $(shell root-config --libs)
FLAGS = '-std=c++11'

all: main_analysis.h main_analysis.cpp
	g++ -o $(TARGET) $(ROOTLIBS) $(ROOTFLAGS) main_analysis.cpp

clear:
	rm -f $(TARGET)