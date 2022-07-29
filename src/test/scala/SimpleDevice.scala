package connect_axi

import chisel3._
import chisel3.util._

class SimpleTestbench(val CLOCK_DIVIDER_FACTOR: Int)(implicit p: NetworkConfigs) extends Module {
  val io = IO(new Bundle {
    val send = Vec(p.NUM_USER_SEND_PORTS, Flipped(Decoupled(UInt(p.PACKET_WIDTH.W))))
    val recv = Vec(p.NUM_USER_RECV_PORTS, Decoupled(UInt(p.PACKET_WIDTH.W)))
  })

  val dut = Module(new NetworkSimpleWrapper)
  if (p.USE_FIFO_IP) {
    dut.io.clock_noc := clock
    dut.clock        := ClockDivider(clock, CLOCK_DIVIDER_FACTOR)
  } else {
    dut.io.clock_noc := clock
  }

  dut.io.send <> io.send
  dut.io.recv <> io.recv
}
