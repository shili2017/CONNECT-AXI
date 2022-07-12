package connect_axi

import chisel3._
import chisel3.util._

class AXI4LiteMasterDevice(val ID: Int, val DEST: Int) extends Module {
  val io = IO(new Bundle {
    val axi         = new AXI4LiteIO
    val start_read  = Input(Bool())
    val start_write = Input(Bool())
    val buffer_peek = Output(UInt(AXI4Parameters.AXI4DataWidth.W))
  })

  val DATA = "hdeadbeefdeadbeef".U

  val buffer = RegInit(0.U(AXI4Parameters.AXI4DataWidth.W))

  io.buffer_peek := buffer

  val s_idle :: s_waddr :: s_wdata :: s_wresp :: s_raddr :: s_rdata :: Nil = Enum(6)

  val state = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(RegNext(io.start_write)) {
        state := s_waddr
      }
      when(RegNext(io.start_read)) {
        state := s_raddr
      }
    }
    is(s_waddr) {
      when(io.axi.aw.fire) {
        state := s_wdata
      }
    }
    is(s_wdata) {
      when(io.axi.w.fire) {
        state := s_wresp
      }
    }
    is(s_wresp) {
      when(io.axi.b.fire) {
        state := s_idle
      }
    }
    is(s_raddr) {
      when(io.axi.ar.fire) {
        state := s_rdata
      }
    }
    is(s_rdata) {
      when(io.axi.r.fire) {
        state := s_idle
      }
    }
  }

  when(state === s_rdata && io.axi.r.fire) {
    buffer := io.axi.r.bits.data
  }

  io.axi.aw.bits      := 0.U.asTypeOf(new AXI4LiteChannelA)
  io.axi.aw.bits.addr := DEST.U
  io.axi.aw.valid     := (state === s_waddr)
  io.axi.w.bits       := 0.U.asTypeOf(new AXI4LiteChannelW)
  io.axi.w.bits.data  := DATA
  io.axi.w.bits.strb  := "hff".U
  io.axi.w.valid      := (state === s_wdata)
  io.axi.b.ready      := (state === s_wresp)
  io.axi.ar.bits      := 0.U.asTypeOf(new AXI4LiteChannelA)
  io.axi.ar.bits.addr := DEST.U
  io.axi.ar.valid     := (state === s_raddr)
  io.axi.r.ready      := (state === s_rdata)
}

class AXI4LiteSlaveDevice(val ID: Int) extends Module {
  val io = IO(new Bundle {
    val axi         = Flipped(new AXI4LiteIO)
    val buffer_peek = Output(UInt(AXI4Parameters.AXI4DataWidth.W))
  })

  val buffer = RegInit("h1234567812345678".U(AXI4Parameters.AXI4DataWidth.W))

  io.buffer_peek := buffer

  val s_idle :: s_waddr :: s_wdata :: s_wresp :: s_raddr :: s_rdata :: Nil = Enum(6)
  val state                                                                = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(io.axi.aw.valid) {
        state := s_waddr
      }
      when(io.axi.ar.valid) {
        state := s_raddr
      }
    }
    is(s_waddr) {
      when(io.axi.aw.fire) {
        state := s_wdata
      }
    }
    is(s_wdata) {
      when(io.axi.w.fire) {
        state := s_wresp
      }
    }
    is(s_wresp) {
      when(io.axi.b.fire) {
        state := s_idle
      }
    }
    is(s_raddr) {
      when(io.axi.ar.fire) {
        state := s_rdata
      }
    }
    is(s_rdata) {
      when(io.axi.r.fire) {
        state := s_idle
      }
    }
  }

  when((state === s_wdata) && io.axi.w.fire) {
    buffer := io.axi.w.bits.data
  }

  io.axi.aw.ready    := (state === s_waddr)
  io.axi.w.ready     := (state === s_wdata)
  io.axi.b.bits      := 0.U.asTypeOf(new AXI4ChannelB)
  io.axi.b.valid     := (state === s_wresp)
  io.axi.ar.ready    := (state === s_raddr)
  io.axi.r.bits      := 0.U.asTypeOf(new AXI4ChannelR)
  io.axi.r.bits.data := buffer
  io.axi.r.valid     := (state === s_rdata)
}

class AXI4LiteTestbench extends Module with Config {
  val io = IO(new Bundle {
    val start_write        = Vec(NUM_MASTER_DEVICES, Input(Bool()))
    val start_read         = Vec(NUM_MASTER_DEVICES, Input(Bool()))
    val master_buffer_peek = Vec(NUM_MASTER_DEVICES, Output(UInt(AXI4Parameters.AXI4DataWidth.W)))
    val slave_buffer_peek  = Vec(NUM_SLAVE_DEVICES, Output(UInt(AXI4Parameters.AXI4DataWidth.W)))
  })

  val dut = Module(new NetworkAXI4Wrapper("AXI4-Lite"))

  val master = for (i <- 0 until NUM_MASTER_DEVICES) yield {
    val device = Module(new AXI4LiteMasterDevice(i, i + NUM_MASTER_DEVICES))
    device
  }
  for (i <- 0 until NUM_MASTER_DEVICES) {
    master(i).io.axi         <> dut.io.master(i)
    master(i).io.start_write := io.start_write(i)
    master(i).io.start_read  := io.start_read(i)
    io.master_buffer_peek(i) := master(i).io.buffer_peek
  }

  val slave = for (i <- 0 until NUM_SLAVE_DEVICES) yield {
    val device = Module(new AXI4LiteSlaveDevice(i + NUM_MASTER_DEVICES))
    device
  }
  for (i <- 0 until NUM_SLAVE_DEVICES) {
    slave(i).io.axi         <> dut.io.slave(i)
    io.slave_buffer_peek(i) := slave(i).io.buffer_peek
  }
}
