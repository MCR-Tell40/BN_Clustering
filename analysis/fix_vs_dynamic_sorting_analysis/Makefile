TARGET = fix_dyn_analysis
FLAGS= -std=c++11 -pthread
CPP=${wildcard *.cpp}
OBJ=$(CPP:%.cpp=%.o)

.PHONY: clean

.SUFFIXES: .cpp .h .o

$(TARGET): $(OBJ)
	g++ $(FLAGS) -o $@ $^ 

%.o: %.cpp
	g++ $(FLAGS) -c $< -o $@

clean:
	rm -fv $(TARGET) *.o