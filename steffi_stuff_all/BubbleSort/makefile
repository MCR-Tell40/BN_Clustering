run: 	
	g++ ../GWTSplit/GWTSplit.cpp BubbleSort.cpp ExecuteBubbleSort.cpp -Wall -o BubbleSort.o `root-config --cflags --libs`
python: 
	g++ -shared -fPIC BubbleSort.cpp -Wall -o `root-config --cflags --libs`
