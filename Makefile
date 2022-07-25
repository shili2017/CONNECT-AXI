SRC_DIR = ./src
BUILD_DIR = ./build
TEST_DIR = ./test_run_dir

CHISEL_SRC = $(SRC_DIR)/main/scala/*.scala

PROTOCOL ?= AXI4

all: $(CHISEL_SRC)
	@mkdir -p $(BUILD_DIR)
	sbt "run $(PROTOCOL) -td $(BUILD_DIR)"

test: $(CHISEL_SRC)
	@-rm -rf $(TEST_DIR)
	sbt test

clean:
	-rm -rf $(BUILD_DIR)
	-rm -rf $(TEST_DIR)

.PHONY: all test clean
