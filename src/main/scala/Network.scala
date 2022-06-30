package connect_axi

import chisel3._
import chisel3.withClockAndReset
import chisel3.util.HasBlackBoxResource

class ConnectNetwork extends BlackBox with HasBlackBoxResource with Config {
  val io = IO(new Bundle {
    val clock = Input(Clock())
    val reset = Input(Bool())

    val send_ports_0_putFlit_flit_in = Input(UInt(FLIT_WIDTH.W))
    val EN_send_ports_0_putFlit      = Input(Bool())
    val send_ports_0_getCredits      = Output(UInt((VC_BITS + 1).W))
    val EN_send_ports_0_getCredits   = Input(Bool())
    val send_ports_1_putFlit_flit_in = Input(UInt(FLIT_WIDTH.W))
    val EN_send_ports_1_putFlit      = Input(Bool())
    val send_ports_1_getCredits      = Output(UInt((VC_BITS + 1).W))
    val EN_send_ports_1_getCredits   = Input(Bool())
    val send_ports_2_putFlit_flit_in = Input(UInt(FLIT_WIDTH.W))
    val EN_send_ports_2_putFlit      = Input(Bool())
    val send_ports_2_getCredits      = Output(UInt((VC_BITS + 1).W))
    val EN_send_ports_2_getCredits   = Input(Bool())
    val send_ports_3_putFlit_flit_in = Input(UInt(FLIT_WIDTH.W))
    val EN_send_ports_3_putFlit      = Input(Bool())
    val send_ports_3_getCredits      = Output(UInt((VC_BITS + 1).W))
    val EN_send_ports_3_getCredits   = Input(Bool())

    val recv_ports_0_getFlit          = Output(UInt(FLIT_WIDTH.W))
    val EN_recv_ports_0_getFlit       = Input(Bool())
    val recv_ports_0_putCredits_cr_in = Input(UInt((VC_BITS + 1).W))
    val EN_recv_ports_0_putCredits    = Input(Bool())
    val recv_ports_1_getFlit          = Output(UInt(FLIT_WIDTH.W))
    val EN_recv_ports_1_getFlit       = Input(Bool())
    val recv_ports_1_putCredits_cr_in = Input(UInt((VC_BITS + 1).W))
    val EN_recv_ports_1_putCredits    = Input(Bool())
    val recv_ports_2_getFlit          = Output(UInt(FLIT_WIDTH.W))
    val EN_recv_ports_2_getFlit       = Input(Bool())
    val recv_ports_2_putCredits_cr_in = Input(UInt((VC_BITS + 1).W))
    val EN_recv_ports_2_putCredits    = Input(Bool())
    val recv_ports_3_getFlit          = Output(UInt(FLIT_WIDTH.W))
    val EN_recv_ports_3_getFlit       = Input(Bool())
    val recv_ports_3_putCredits_cr_in = Input(UInt((VC_BITS + 1).W))
    val EN_recv_ports_3_putCredits    = Input(Bool())

    val recv_ports_info_0_getRecvPortID = Output(UInt(DEST_BITS.W))
    val recv_ports_info_1_getRecvPortID = Output(UInt(DEST_BITS.W))
    val recv_ports_info_2_getRecvPortID = Output(UInt(DEST_BITS.W))
    val recv_ports_info_3_getRecvPortID = Output(UInt(DEST_BITS.W))
  })

  addResource("/vsrc/ConnectNetwork.v")
}

class Network extends Module with Config {
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

  val network = Module(new ConnectNetwork)

  val recv_ports_info_getRecvPortID = Wire(Vec(NUM_USER_RECV_PORTS, UInt(DEST_BITS.W)))

  network.io.clock                         := clock
  network.io.reset                         := reset
  network.io.send_ports_0_putFlit_flit_in  := io.send_ports_putFlit_flit_in(0)
  network.io.send_ports_1_putFlit_flit_in  := io.send_ports_putFlit_flit_in(1)
  network.io.send_ports_2_putFlit_flit_in  := io.send_ports_putFlit_flit_in(2)
  network.io.send_ports_3_putFlit_flit_in  := io.send_ports_putFlit_flit_in(3)
  network.io.EN_send_ports_0_putFlit       := io.EN_send_ports_putFlit(0)
  network.io.EN_send_ports_1_putFlit       := io.EN_send_ports_putFlit(1)
  network.io.EN_send_ports_2_putFlit       := io.EN_send_ports_putFlit(2)
  network.io.EN_send_ports_3_putFlit       := io.EN_send_ports_putFlit(3)
  io.send_ports_getCredits(0)              := network.io.send_ports_0_getCredits
  io.send_ports_getCredits(1)              := network.io.send_ports_1_getCredits
  io.send_ports_getCredits(2)              := network.io.send_ports_2_getCredits
  io.send_ports_getCredits(3)              := network.io.send_ports_3_getCredits
  network.io.EN_send_ports_0_getCredits    := io.EN_send_ports_getCredits(0)
  network.io.EN_send_ports_1_getCredits    := io.EN_send_ports_getCredits(1)
  network.io.EN_send_ports_2_getCredits    := io.EN_send_ports_getCredits(2)
  network.io.EN_send_ports_3_getCredits    := io.EN_send_ports_getCredits(3)
  io.recv_ports_getFlit(0)                 := network.io.recv_ports_0_getFlit
  io.recv_ports_getFlit(1)                 := network.io.recv_ports_1_getFlit
  io.recv_ports_getFlit(2)                 := network.io.recv_ports_2_getFlit
  io.recv_ports_getFlit(3)                 := network.io.recv_ports_3_getFlit
  network.io.EN_recv_ports_0_getFlit       := io.EN_recv_ports_getFlit(0)
  network.io.EN_recv_ports_1_getFlit       := io.EN_recv_ports_getFlit(1)
  network.io.EN_recv_ports_2_getFlit       := io.EN_recv_ports_getFlit(2)
  network.io.EN_recv_ports_3_getFlit       := io.EN_recv_ports_getFlit(3)
  network.io.recv_ports_0_putCredits_cr_in := io.recv_ports_putCredits_cr_in(0)
  network.io.recv_ports_1_putCredits_cr_in := io.recv_ports_putCredits_cr_in(1)
  network.io.recv_ports_2_putCredits_cr_in := io.recv_ports_putCredits_cr_in(2)
  network.io.recv_ports_3_putCredits_cr_in := io.recv_ports_putCredits_cr_in(3)
  network.io.EN_recv_ports_0_putCredits    := io.EN_recv_ports_putCredits(0)
  network.io.EN_recv_ports_1_putCredits    := io.EN_recv_ports_putCredits(1)
  network.io.EN_recv_ports_2_putCredits    := io.EN_recv_ports_putCredits(2)
  network.io.EN_recv_ports_3_putCredits    := io.EN_recv_ports_putCredits(3)
  recv_ports_info_getRecvPortID(0)         := network.io.recv_ports_info_0_getRecvPortID
  recv_ports_info_getRecvPortID(1)         := network.io.recv_ports_info_1_getRecvPortID
  recv_ports_info_getRecvPortID(2)         := network.io.recv_ports_info_2_getRecvPortID
  recv_ports_info_getRecvPortID(3)         := network.io.recv_ports_info_3_getRecvPortID

}
