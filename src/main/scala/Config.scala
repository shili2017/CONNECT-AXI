package connect_axi

import chisel3.util.log2Up

trait Config {
  // CONNECT parameters
  val NUM_USER_SEND_PORTS  = 4
  val NUM_USER_RECV_PORTS  = 4
  val NUM_VCS              = 3
  val REAL_FLIT_DATA_WIDTH = 34
  val FLIT_BUFFER_DEPTH    = 4

  // CONNECT AXI wrapper parameters
  val PROTOCOL            = "AXI4" // should be in ["AXI4", "AXI4-Lite", "Simple"]
  val NUM_MASTER_DEVICES  = 2
  val NUM_SLAVE_DEVICES   = 2
  val SIMPLE_PACKET_WIDTH = 80

  // Induced parameters
  val FLIT_DATA_WIDTH = REAL_FLIT_DATA_WIDTH - log2Up(NUM_USER_SEND_PORTS)
  val SRC_BITS        = log2Up(NUM_USER_SEND_PORTS)
  val DEST_BITS       = log2Up(NUM_USER_RECV_PORTS)
  val VC_BITS         = log2Up(NUM_VCS)
  val FLIT_WIDTH      = FLIT_DATA_WIDTH + SRC_BITS + DEST_BITS + VC_BITS + 2

  // Debug messages
  val DEBUG_AXI4_BRIDGE    = false
  val DEBUG_SERIALIZER     = false
  val DEBUG_DESERIALIZER   = false
  val DEBUG_NETWORK_FLIT   = false
  val DEBUG_NETWORK_CREDIT = false

  // Library
  val USE_FIFO_IP = false
  val ALTERA_MF_V = "/afs/ece.cmu.edu/support/altera/release/pro-19.3.0.222/quartus/eda/sim_lib/altera_mf.v"
}

object Config extends Config {}
