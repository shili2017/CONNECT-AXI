# Example usage: make -B NUM_USER_SEND_PORTS=4 NUM_USER_RECV_PORTS=4

CHISEL_SRC = ../src/main/scala/Network.scala

NUM_USER_SEND_PORTS ?= 4
NUM_USER_RECV_PORTS ?= 4

default: $(CHISEL_SRC)

$(CHISEL_SRC):
	python3 generateNetworkScala.py $(NUM_USER_RECV_PORTS) $(NUM_USER_RECV_PORTS) > $@

.PHONY: default
