package connect_axi

import chisel3.util.log2Up

trait Config {
  // CONNECT parameters
  val NUM_USER_SEND_PORTS = 4
  val NUM_USER_RECV_PORTS = 4
  val NUM_VCS             = 2
  val FLIT_DATA_WIDTH     = 34 - log2Up(NUM_USER_SEND_PORTS)
  val FLIT_BUFFER_DEPTH   = 4

  // CONNECT AXI wrapper parameters
  val PROTOCOL           = "AXI4"
  val NUM_MASTER_DEVICES = 2
  val NUM_SLAVE_DEVICES  = 2

  // Induced parameters
  val SRC_BITS   = log2Up(NUM_USER_SEND_PORTS)
  val DEST_BITS  = log2Up(NUM_USER_RECV_PORTS)
  val VC_BITS    = log2Up(NUM_VCS)
  val FLIT_WIDTH = FLIT_DATA_WIDTH + SRC_BITS + DEST_BITS + VC_BITS + 2

  // Debug messages
  val DEBUG_AXI4_BRIDGE  = false
  val DEBUG_SERIALIZER   = false
  val DEBUG_DESERIALIZER = false
  val DEBUG_NETWORK      = false
}

object Config extends Config {}
