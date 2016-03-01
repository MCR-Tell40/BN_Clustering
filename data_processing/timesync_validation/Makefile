TARGET = timesyncAnalysis
ROOTFLAGS = $(shell root-config --cflags)
ROOTLIBS  = $(shell root-config --libs)

all: main_analysis.h main_analysis.cpp
	g++ -o $(TARGET) $(ROOTLIBS) $(ROOTFLAGS) main_analysis.cpp

clean:
	rm -f $(TARGET)