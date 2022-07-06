package connect_axi

import chisel3._
import chisel3.util._

class FlitSerializer(val ID: Int, val IN_PACKET_WIDTH: Int, val OUT_FLIT_WIDTH: Int) extends Module with Config {
  val io = IO(new Bundle {
    val in_packet = Flipped(Decoupled(UInt(IN_PACKET_WIDTH.W)))
    val out_flit  = Decoupled(UInt(OUT_FLIT_WIDTH.W))
  })

  val META_WIDTH           = 2 + DEST_BITS + VC_BITS + SRC_BITS
  val IN_PACKET_DATA_WIDTH = IN_PACKET_WIDTH - META_WIDTH
  val OUT_FLIT_DATA_WIDTH  = OUT_FLIT_WIDTH - META_WIDTH
  val LEN                  = (IN_PACKET_DATA_WIDTH + OUT_FLIT_DATA_WIDTH - 1) / OUT_FLIT_DATA_WIDTH

  val len = RegInit(0.U(log2Up(LEN).W))

  // FSM to receive flits from device and send flits to network
  val s_idle :: s_send :: Nil = Enum(2)
  val state                   = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      len := 0.U
      when(io.in_packet.fire) {
        state := s_send
      }
    }
    is(s_send) {
      when(io.out_flit.fire) {
        len := len + 1.U
        when(len === (LEN - 1).U) {
          state := s_idle
        }
      }
    }
  }

  val meta_reg = RegInit(0.U(META_WIDTH.W))
  val data_reg = RegInit(0.U(IN_PACKET_DATA_WIDTH.W))
  when(io.in_packet.fire) {
    meta_reg := io.in_packet.bits(IN_PACKET_WIDTH - 1, IN_PACKET_DATA_WIDTH)
    data_reg := io.in_packet.bits(IN_PACKET_DATA_WIDTH - 1, 0)
  }
  when(io.out_flit.fire) {
    data_reg := data_reg >> OUT_FLIT_DATA_WIDTH
  }

  // In flit output signals
  io.in_packet.ready := (state === s_idle)

  // Out flit output signals
  io.out_flit.valid := (state === s_send)
  io.out_flit.bits := Cat(
    meta_reg(META_WIDTH - 1).asUInt,
    (meta_reg(META_WIDTH - 2) && (len === (LEN - 1).U)).asUInt, // update tail
    meta_reg(META_WIDTH - 3, 0),
    data_reg(OUT_FLIT_DATA_WIDTH - 1, 0)
  )

  if (DEBUG_SERIALIZER) {
    val cnt = RegInit(0.U((log2Up(LEN) + 1).W))
    when(io.in_packet.fire) {
      cnt := 0.U
    }
    when(io.out_flit.fire) {
      cnt := cnt + 1.U
      printf("%d: [Serializer   %d] out_flit=%b (%d/%d)\n", DebugTimer(), ID.U, io.out_flit.bits, cnt + 1.U, LEN.U)
    }
  }
}
