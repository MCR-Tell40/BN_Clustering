TARGET = fix_dyn_analysis
ROOTFLAGS = $(shell root-config --cflags)
ROOTLIBS  = $(shell root-config --libs)

all: velo.o dynamic_sorter.o fix_dyn_analysis.o
	g++ -o $(TARGET) -std=c++11 fix_dyn_analysis.o velo.o dynamic_sorter.o -pthread

fix_dyn_analysis.o: fix_dyn_analysis.cpp
	g++ -c -std=c++11 fix_dyn_analysis.cpp

velo.o: velo.cpp velo.h
	g++ -c -std=c++11 velo.cpp

dynamic_sorter.o: dynamic_sorter.cpp dynamic_sorter.h
	g++ -c -std=c++11 dynamic_sorter.cpp

clean:
	rm -f $(TARGET)


unused:

	# g++ -c $(ROOTFLAGS) $(ROOTLIBS) fix_dyn_analysis.cpp

	# g++ -o $(TARGET) $(ROOTFLAGS) $(ROOTLIBS) fix_dyn_analysis.o velo.o dynamic_sorter.o