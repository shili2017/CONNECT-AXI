SRC_DIR = ./src
BUILD_DIR = ./build
TEST_DIR = ./test_run_dir

CHISEL_SRC = $(SRC_DIR)/main/scala/*.scala
ARTIFACT = $(BUILD_DIR)/Top.v

VERILATOR_FLAGS = -cc --exe -x-assign 0 --assert --trace --top-module Testbench
VERILATOR_INPUT = $(BUILD_DIR)/*.v \
									$(SRC_DIR)/test/vsrc/testbench.v \
									$(SRC_DIR)/test/csrc/main.cpp
ROUTING_INPUT = $(SRC_DIR)/test/vsrc/*.hex

TOP_MODULE = Testbench

all: $(ARTIFACT)

$(ARTIFACT): $(CHISEL_SRC)
	@mkdir -p $(BUILD_DIR)
	sbt "run -td $(BUILD_DIR)"

test: $(CHISEL_SRC)
	sbt test

clean:
	-rm -rf $(BUILD_DIR)
	-rm -rf $(TEST_DIR)

.PHONY: all test clean
