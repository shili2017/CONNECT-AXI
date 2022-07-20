package connect_axi

import chisel3._
import chisel3.util._
import chipsalliance.rocketchip.config._

class FlitFlowControlSend(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Device
    val flit = Vec(p(NUM_VCS), Flipped(Decoupled(UInt(p(FLIT_WIDTH).W))))
    // Network
    val send = Flipped(new NetworkSendInterface)
  })

  val hub            = Module(new FlitHubNTo1)
  val send_interface = Module(new FlitSendInterface)

  val fifo = for (i <- 0 until p(NUM_VCS)) yield {
    val p_    = p.alterPartial({ case FIFO_VC => i })
    val _fifo = Module(new InPortFIFO()(p_))
    _fifo
  }

  for (i <- 0 until p(NUM_VCS)) {
    fifo(i).io.device_flit  <> io.flit(i)
    hub.io.device_flit(i)   <> fifo(i).io.network_flit
    hub.io.device_credit(i) <> fifo(i).io.network_credit
  }

  send_interface.io.put_flit   <> hub.io.network_flit
  send_interface.io.get_credit <> hub.io.network_credit
  io.send                      <> send_interface.io.send
}

class FlitFlowControlRecv(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    // Device
    val flit = Vec(p(NUM_VCS), Decoupled(UInt(p(FLIT_WIDTH).W)))
    // Network
    val recv = Flipped(new NetworkRecvInterface)
  })

  val hub            = Module(new FlitHub1ToN)
  val recv_interface = Module(new FlitRecvInterface)

  val fifo = for (i <- 0 until p(NUM_VCS)) yield {
    val p_    = p.alterPartial({ case FIFO_VC => i })
    val _fifo = Module(new OutPortFIFO()(p_))
    _fifo
  }

  for (i <- 0 until p(NUM_VCS)) {
    io.flit(i)                <> fifo(i).io.device_flit
    fifo(i).io.network_flit   <> hub.io.device_flit(i)
    fifo(i).io.network_credit <> hub.io.device_credit(i)
  }

  hub.io.network_flit    <> recv_interface.io.get_flit
  hub.io.network_credit  <> recv_interface.io.put_credit
  recv_interface.io.recv <> io.recv
}
