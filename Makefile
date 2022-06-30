SRC_DIR = ./src
BUILD_DIR = ./build

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

obj_dir/V$(TOP_MODULE): $(ARTIFACT) $(VERILATOR_INPUT)
	verilator $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	$(MAKE) -j -C obj_dir -f V$(TOP_MODULE).mk

sim: obj_dir/V$(TOP_MODULE) $(ROUTING_INPUT)
	cp $(ROUTING_INPUT) $(BUILD_DIR)
	cp obj_dir/V$(TOP_MODULE) $(BUILD_DIR)
	cd $(BUILD_DIR) && ./V$(TOP_MODULE) +trace

clean:
	-rm -rf obj_dir
	-rm -rf $(BUILD_DIR)

.PHONY: all sim clean
