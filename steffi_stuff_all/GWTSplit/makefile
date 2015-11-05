run: 	
	g++ GWTSplit.cpp ExecuteGWTSplit.cpp  -Wall -o GWTSplit.o `root-config --cflags --libs`
python: 
	g++ -shared -fPIC GWTSplit.cpp -Wall -o `root-config --cflags --libs`
