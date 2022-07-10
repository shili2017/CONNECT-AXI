package connect_axi

import chisel3._
import chisel3.util._

class FlitDeserializer(val ID: Int, val IN_FLIT_WIDTH: Int, val OUT_PACKET_WIDTH: Int) extends Module with Config {
  val io = IO(new Bundle {
    val in_flit    = Flipped(Decoupled(UInt(IN_FLIT_WIDTH.W)))
    val out_packet = Decoupled(UInt(OUT_PACKET_WIDTH.W))
  })

  val META_WIDTH            = 2 + DEST_BITS + VC_BITS + SRC_BITS
  val IN_FLIT_DATA_WIDTH    = IN_FLIT_WIDTH - META_WIDTH
  val OUT_PACKET_DATA_WIDTH = OUT_PACKET_WIDTH - META_WIDTH
  val LEN                   = (OUT_PACKET_DATA_WIDTH + IN_FLIT_DATA_WIDTH - 1) / IN_FLIT_DATA_WIDTH

  val in_flit_src = Wire(UInt(SRC_BITS.W))
  in_flit_src := io.in_flit.bits(IN_FLIT_DATA_WIDTH + SRC_BITS - 1, IN_FLIT_DATA_WIDTH)

  // Length counter for each source
  val len = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(0.U(log2Up(LEN).W))))

  // FSM to receive flits from network and send flits to device
  val s_recv :: s_data :: Nil = Enum(2)
  val state                   = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(s_recv)))

  // valid & ready signals for each source
  val in_flit_valid_vec    = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val in_flit_ready_vec    = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val out_packet_valid_vec = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val out_packet_ready_vec = WireDefault(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(false.B)))
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    in_flit_valid_vec(i)    := io.in_flit.valid && (in_flit_src === i.U)
    in_flit_ready_vec(i)    := (state(i) === s_recv)
    out_packet_valid_vec(i) := (state(i) === s_data)
  }

  // FSM for each source
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    switch(state(i)) {
      is(s_recv) {
        when(in_flit_valid_vec(i) && in_flit_ready_vec(i)) {
          len(i) := len(i) + 1.U
          when(len(i) === (LEN - 1).U) {
            state(i) := s_data
          }
        }
      }
      is(s_data) {
        len(i) := 0.U
        when(out_packet_valid_vec(i) && out_packet_ready_vec(i)) {
          state(i) := s_recv
        }
      }
    }
  }

  // In flit register for each source
  val flit_meta_reg = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(0.U(META_WIDTH.W))))
  val flit_data_reg = Wire(Vec(NUM_USER_SEND_PORTS, UInt(OUT_PACKET_DATA_WIDTH.W)))
  val flit_data_reg_vec = RegInit(
    VecInit(Seq.fill(NUM_USER_SEND_PORTS)(VecInit(Seq.fill(LEN)(0.U(IN_FLIT_DATA_WIDTH.W)))))
  )
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    when(in_flit_valid_vec(i) && in_flit_ready_vec(i)) {
      flit_meta_reg(i)             := io.in_flit.bits(IN_FLIT_WIDTH - 1, IN_FLIT_DATA_WIDTH)
      flit_data_reg_vec(i)(len(i)) := io.in_flit.bits(IN_FLIT_DATA_WIDTH - 1, 0)
    }
    flit_data_reg(i) := flit_data_reg_vec(i).reduce((x, y) => Cat(y, x))(OUT_PACKET_DATA_WIDTH - 1, 0)
  }

  // In flit output signals
  io.in_flit.ready := in_flit_ready_vec(in_flit_src)

  // Priority encoder to decide which flit to out
  val out_packet_idx = WireDefault(0.U(SRC_BITS.W))
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    when(out_packet_valid_vec(i)) {
      out_packet_idx := i.U(SRC_BITS.W)
    }
  }
  out_packet_ready_vec(out_packet_idx) := io.out_packet.ready

  // Out flit output signals
  io.out_packet.valid := out_packet_valid_vec.reduce(_ || _)
  io.out_packet.bits  := Cat(flit_meta_reg(out_packet_idx), flit_data_reg(out_packet_idx))

  if (DEBUG_DESERIALIZER) {
    when(io.in_flit.fire) {
      printf("%d: [Deserializer %d]  in_flit=%b\n", DebugTimer(), ID.U, io.in_flit.bits)
    }
    when(io.out_packet.fire) {
      printf(
        "%d: [Deserializer %d] out_packet=%b\n",
        DebugTimer(),
        ID.U,
        io.out_packet.bits
      )
    }
  }
}
