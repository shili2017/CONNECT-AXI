package connect_axi

import chisel3._

class Top extends Module with Config {
  val io = IO(new Bundle {
    val send_ports_putFlit_flit_in  = Vec(NUM_USER_SEND_PORTS, Input(UInt(FLIT_WIDTH.W)))
    val EN_send_ports_putFlit       = Vec(NUM_USER_SEND_PORTS, Input(Bool()))
    val send_ports_getCredits       = Vec(NUM_USER_SEND_PORTS, Output(UInt((VC_BITS + 1).W)))
    val EN_send_ports_getCredits    = Vec(NUM_USER_SEND_PORTS, Input(Bool()))
    val recv_ports_getFlit          = Vec(NUM_USER_RECV_PORTS, Output(UInt(FLIT_WIDTH.W)))
    val EN_recv_ports_getFlit       = Vec(NUM_USER_RECV_PORTS, Input(Bool()))
    val recv_ports_putCredits_cr_in = Vec(NUM_USER_RECV_PORTS, Input(UInt((VC_BITS + 1).W)))
    val EN_recv_ports_putCredits    = Vec(NUM_USER_RECV_PORTS, Input(Bool()))
  })

  val network = Module(new Network)
  network.io.send_ports_putFlit_flit_in  := io.send_ports_putFlit_flit_in
  network.io.EN_send_ports_putFlit       := io.EN_send_ports_putFlit
  io.send_ports_getCredits               := network.io.send_ports_getCredits
  network.io.EN_send_ports_getCredits    := io.EN_send_ports_getCredits
  io.recv_ports_getFlit                  := network.io.recv_ports_getFlit
  network.io.EN_recv_ports_getFlit       := io.EN_recv_ports_getFlit
  network.io.recv_ports_putCredits_cr_in := io.recv_ports_putCredits_cr_in
  network.io.EN_recv_ports_putCredits    := io.EN_recv_ports_putCredits
}
