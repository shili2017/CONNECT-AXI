package connect_axi

import chisel3._
import chisel3.util._

class AXI4StreamMasterDevice(val ID: Int, val LEN: Int) extends Module {
  val io = IO(new Bundle {
    val axi         = new AXI4StreamIO
    val start       = Input(Bool())
    val target_dest = Input(UInt(4.W))
  })

  val DATA = "hdeadbeefdeadbeef".U

  val dest = RegInit(0.U(4.W))
  val wlen = RegInit(0.U(8.W))

  val s_idle :: s_data :: Nil = Enum(2)

  val state = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(io.start) {
        state := s_data
        dest  := io.target_dest
      }
    }
    is(s_data) {
      when(io.axi.t.fire && io.axi.t.bits.last) {
        state := s_idle
      }
    }
  }

  when(state === s_data && io.axi.t.fire) {
    wlen := wlen + 1.U
  }
  when(state === s_idle) {
    wlen := 0.U
  }

  io.axi.t.bits      := 0.U.asTypeOf(new AXI4StreamChannelT)
  io.axi.t.bits.data := DATA + wlen
  io.axi.t.bits.strb := "hff".U
  io.axi.t.bits.last := (state === s_data) && (wlen === (LEN - 1).U)
  io.axi.t.bits.dest := dest
  io.axi.t.valid     := (state === s_data)
}

class AXI4StreamSlaveDevice(val ID: Int, val LEN: Int) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(new AXI4StreamIO)
  })

  val wlen   = RegInit(0.U(8.W))
  val buffer = Module(new on_chip_ram(AXI4Parameters.AXI4DataWidth, LEN))

  dontTouch(wlen)
  dontTouch(buffer.io)

  buffer.io.address := wlen
  buffer.io.data    := io.axi.t.bits.data
  buffer.io.wren    := io.axi.t.fire

  when(io.axi.t.fire) {
    wlen := wlen + 1.U
    when(io.axi.t.bits.last) {
      wlen := 0.U
    }
  }

  io.axi.t.ready := true.B
}

class AXI4StreamTestbench(val CLOCK_DIVIDER_FACTOR: Int, val LEN: Int)(implicit p: NetworkConfigs) extends Module {
  val io = IO(new Bundle {
    val start       = Vec(p.NUM_MASTER_DEVICES, Input(Bool()))
    val target_dest = Vec(p.NUM_MASTER_DEVICES, Input(UInt(4.W)))
  })

  dontTouch(io.target_dest)

  val dut = Module(new NetworkAXI4StreamWrapper)
  if (p.USE_FIFO_IP) {
    dut.io.clock_noc := clock
    dut.clock        := ClockDivider(clock, CLOCK_DIVIDER_FACTOR)
  } else {
    dut.io.clock_noc := clock
  }

  withClock(dut.clock) {
    val master = for (i <- 0 until p.NUM_MASTER_DEVICES) yield {
      val device = Module(new AXI4StreamMasterDevice(i, LEN))
      device
    }
    for (i <- 0 until p.NUM_MASTER_DEVICES) {
      master(i).io.axi         <> dut.io.master(i)
      master(i).io.start       := io.start(i)
      master(i).io.target_dest := io.target_dest(i)
    }

    val slave = for (i <- 0 until p.NUM_SLAVE_DEVICES) yield {
      val device = Module(new AXI4StreamSlaveDevice(i + p.NUM_MASTER_DEVICES, LEN))
      device
    }
    for (i <- 0 until p.NUM_SLAVE_DEVICES) {
      slave(i).io.axi <> dut.io.slave(i)
      dontTouch(slave(i).io.axi)
    }
  }
}
