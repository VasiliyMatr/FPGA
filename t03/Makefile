
INCLUDE_PATH_ = -Iheaders -I../DSL
SOURCE_PATH_  =  source/

GPP_FLAGS_    = -g -O0
BUILD_NAME_   =  compiler
IN_NAME_      = data/asm.txt
OUT_NAME_     = out


.PHONY: all build valg run cleanup

all: build

build: $(wildcard $(SOURCE_PATH_)*.cpp)
	g++ $(SOURCE_PATH_)*.cpp $(GPP_FLAGS_) $(INCLUDE_PATH_) -o $(BUILD_NAME_)

run:
	./$(BUILD_NAME_) $(IN_NAME_) -o $(OUT_NAME_)

valg:
	valgrind --leak-check=full ./$(BUILD_NAME_) $(IN_NAME_) -o $(OUT_NAME_)