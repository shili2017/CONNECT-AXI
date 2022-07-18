package connect_axi

import chisel3._
import chisel3.util._

class AXI4StreamMasterDevice(val ID: Int, val LEN: Int) extends Module {
  val io = IO(new Bundle {
    val axi         = new AXI4StreamIO
    val start       = Input(Bool())
    val target_dest = Input(UInt(4.W))
    val buffer_peek = Vec(LEN, Output(UInt(AXI4Parameters.AXI4DataWidth.W)))
  })

  val DATA = "hdeadbeefdeadbeef".U

  val dest   = RegInit(0.U(4.W))
  val wlen   = RegInit(0.U(8.W))
  val buffer = RegInit(VecInit(Seq.fill(LEN)(0.U(AXI4Parameters.AXI4DataWidth.W))))

  io.buffer_peek := buffer

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
    val axi         = Flipped(new AXI4StreamIO)
    val buffer_peek = Vec(LEN, Output(UInt(AXI4Parameters.AXI4DataWidth.W)))
  })

  val wlen   = RegInit(0.U(8.W))
  val buffer = RegInit(VecInit((0 until LEN).map(_.U(AXI4Parameters.AXI4DataWidth.W))))

  io.buffer_peek := buffer

  when(io.axi.t.fire) {
    buffer(wlen) := io.axi.t.bits.data
    wlen         := wlen + 1.U
    when(io.axi.t.bits.last) {
      wlen := 0.U
    }
  }

  io.axi.t.ready := true.B
}

class AXI4StreamTestbench(LEN: Int) extends Module with Config {
  val io = IO(new Bundle {
    val start              = Vec(NUM_MASTER_DEVICES, Input(Bool()))
    val target_dest        = Vec(NUM_MASTER_DEVICES, Input(UInt(4.W)))
    val master_buffer_peek = Vec(NUM_MASTER_DEVICES, Vec(LEN, Output(UInt(AXI4Parameters.AXI4DataWidth.W))))
    val slave_buffer_peek  = Vec(NUM_SLAVE_DEVICES, Vec(LEN, Output(UInt(AXI4Parameters.AXI4DataWidth.W))))
  })

  dontTouch(io.target_dest)

  val dut = Module(new NetworkAXI4StreamWrapper)

  val master = for (i <- 0 until NUM_MASTER_DEVICES) yield {
    val device = Module(new AXI4StreamMasterDevice(i, LEN))
    device
  }
  for (i <- 0 until NUM_MASTER_DEVICES) {
    master(i).io.axi         <> dut.io.master(i)
    master(i).io.start       := io.start(i)
    master(i).io.target_dest := io.target_dest(i)
    io.master_buffer_peek(i) := master(i).io.buffer_peek
  }

  val slave = for (i <- 0 until NUM_SLAVE_DEVICES) yield {
    val device = Module(new AXI4StreamSlaveDevice(i + NUM_MASTER_DEVICES, LEN))
    device
  }
  for (i <- 0 until NUM_SLAVE_DEVICES) {
    slave(i).io.axi         <> dut.io.slave(i)
    io.slave_buffer_peek(i) := slave(i).io.buffer_peek
  }
}
