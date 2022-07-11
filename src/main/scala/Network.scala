package connect_axi

import chisel3._
import chisel3.withClockAndReset
import chisel3.util.HasBlackBoxResource

class mkNetwork extends BlackBox with HasBlackBoxResource with Config {
  val io = IO(new Bundle {
    val CLK   = Input(Clock())
    val RST_N = Input(Bool())

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

  addResource("/vsrc/mkNetwork.v")
}

class NetworkSendInterface extends Bundle with Config {
  val put_flit      = Input(UInt(FLIT_WIDTH.W))
  val EN_put_flit   = Input(Bool())
  val get_credit    = Output(UInt((VC_BITS + 1).W))
  val EN_get_credit = Input(Bool())
}

class NetworkRecvInterface extends Bundle with Config {
  val get_flit      = Output(UInt(FLIT_WIDTH.W))
  val EN_get_flit   = Input(Bool())
  val put_credit    = Input(UInt((VC_BITS + 1).W))
  val EN_put_credit = Input(Bool())
}

class Network extends Module with Config {
  val io = IO(new Bundle {
    val send = Vec(NUM_USER_SEND_PORTS, new NetworkSendInterface)
    val recv = Vec(NUM_USER_RECV_PORTS, new NetworkRecvInterface)
  })

  val network = Module(new mkNetwork)

  val recv_ports_info_getRecvPortID = Wire(Vec(NUM_USER_RECV_PORTS, UInt(DEST_BITS.W)))

  if (DEBUG_NETWORK_FLIT) {
    for (i <- 0 until NUM_USER_SEND_PORTS) {
      when(io.send(i).put_flit(FLIT_WIDTH - 1)) {
        printf("%d: [Network send %d] put_flit=%b\n", DebugTimer(), i.U, io.send(i).put_flit)
      }
    }
    for (i <- 0 until NUM_USER_RECV_PORTS) {
      when(io.recv(i).get_flit(FLIT_WIDTH - 1)) {
        printf("%d: [Network recv %d] get_flit=%b\n", DebugTimer(), i.U, io.recv(i).get_flit)
      }
    }
  }

  if (DEBUG_NETWORK_CREDIT) {
    for (i <- 0 until NUM_USER_SEND_PORTS) {
      when(io.send(i).get_credit(VC_BITS)) {
        printf("%d: [Network send %d] get_credit=%b\n", DebugTimer(), i.U, io.send(i).get_credit)
      }
    }
    for (i <- 0 until NUM_USER_RECV_PORTS) {
      when(io.recv(i).put_credit(VC_BITS)) {
        printf("%d: [Network recv %d] put_credit=%b\n", DebugTimer(), i.U, io.recv(i).put_credit)
      }
    }
  }

  network.io.CLK                           := clock
  network.io.RST_N                         := reset
  network.io.send_ports_0_putFlit_flit_in  := io.send(0).put_flit
  network.io.send_ports_1_putFlit_flit_in  := io.send(1).put_flit
  network.io.send_ports_2_putFlit_flit_in  := io.send(2).put_flit
  network.io.send_ports_3_putFlit_flit_in  := io.send(3).put_flit
  network.io.EN_send_ports_0_putFlit       := io.send(0).EN_put_flit
  network.io.EN_send_ports_1_putFlit       := io.send(1).EN_put_flit
  network.io.EN_send_ports_2_putFlit       := io.send(2).EN_put_flit
  network.io.EN_send_ports_3_putFlit       := io.send(3).EN_put_flit
  io.send(0).get_credit                    := network.io.send_ports_0_getCredits
  io.send(1).get_credit                    := network.io.send_ports_1_getCredits
  io.send(2).get_credit                    := network.io.send_ports_2_getCredits
  io.send(3).get_credit                    := network.io.send_ports_3_getCredits
  network.io.EN_send_ports_0_getCredits    := io.send(0).EN_get_credit
  network.io.EN_send_ports_1_getCredits    := io.send(1).EN_get_credit
  network.io.EN_send_ports_2_getCredits    := io.send(2).EN_get_credit
  network.io.EN_send_ports_3_getCredits    := io.send(3).EN_get_credit
  io.recv(0).get_flit                      := network.io.recv_ports_0_getFlit
  io.recv(1).get_flit                      := network.io.recv_ports_1_getFlit
  io.recv(2).get_flit                      := network.io.recv_ports_2_getFlit
  io.recv(3).get_flit                      := network.io.recv_ports_3_getFlit
  network.io.EN_recv_ports_0_getFlit       := io.recv(0).EN_get_flit
  network.io.EN_recv_ports_1_getFlit       := io.recv(1).EN_get_flit
  network.io.EN_recv_ports_2_getFlit       := io.recv(2).EN_get_flit
  network.io.EN_recv_ports_3_getFlit       := io.recv(3).EN_get_flit
  network.io.recv_ports_0_putCredits_cr_in := io.recv(0).put_credit
  network.io.recv_ports_1_putCredits_cr_in := io.recv(1).put_credit
  network.io.recv_ports_2_putCredits_cr_in := io.recv(2).put_credit
  network.io.recv_ports_3_putCredits_cr_in := io.recv(3).put_credit
  network.io.EN_recv_ports_0_putCredits    := io.recv(0).EN_put_credit
  network.io.EN_recv_ports_1_putCredits    := io.recv(1).EN_put_credit
  network.io.EN_recv_ports_2_putCredits    := io.recv(2).EN_put_credit
  network.io.EN_recv_ports_3_putCredits    := io.recv(3).EN_put_credit
  recv_ports_info_getRecvPortID(0)         := network.io.recv_ports_info_0_getRecvPortID
  recv_ports_info_getRecvPortID(1)         := network.io.recv_ports_info_1_getRecvPortID
  recv_ports_info_getRecvPortID(2)         := network.io.recv_ports_info_2_getRecvPortID
  recv_ports_info_getRecvPortID(3)         := network.io.recv_ports_info_3_getRecvPortID

}
