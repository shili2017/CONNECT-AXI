package connect_axi

import chisel3.util.log2Up

trait Config {
  // CONNECT parameters
  val NUM_USER_SEND_PORTS = 4
  val NUM_USER_RECV_PORTS = 4
  val NUM_VCS             = 2
  val FLIT_DATA_WIDTH     = 40 - log2Up(NUM_USER_SEND_PORTS)
  val FLIT_BUFFER_DEPTH   = 4

  // Induced parameters
  val SRC_BITS   = log2Up(NUM_USER_SEND_PORTS)
  val DEST_BITS  = log2Up(NUM_USER_RECV_PORTS)
  val VC_BITS    = log2Up(NUM_VCS)
  val FLIT_WIDTH = FLIT_DATA_WIDTH + SRC_BITS + DEST_BITS + VC_BITS + 2
}

object Config extends Config {}
