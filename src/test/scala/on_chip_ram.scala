package connect_axi

import chisel3._
import chisel3.util._

class on_chip_ram(val DATA_WIDTH: Int, val NUM_WORDS: Int) extends Module {
  val io = IO(new Bundle {
    val data    = Input(UInt(DATA_WIDTH.W))
    val q       = Output(UInt(DATA_WIDTH.W))
    val address = Input(UInt(log2Up(NUM_WORDS).W))
    val wren    = Input(Bool())
  })

  val buffer = RegInit(VecInit(Seq.fill(NUM_WORDS)(0.U(DATA_WIDTH.W))))
  when(io.wren) {
    buffer(io.address) := io.data
  }
  io.q := buffer(io.address)
}
