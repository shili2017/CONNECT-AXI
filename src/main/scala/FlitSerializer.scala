package connect_axi

import chisel3._
import chisel3.util._

class FlitSerializer(val ID: Int, val IN_FLIT_WIDTH: Int, val OUT_FLIT_WIDTH: Int) extends Module with Config {
  val io = IO(new Bundle {
    val in_flit  = Flipped(Decoupled(UInt(IN_FLIT_WIDTH.W)))
    val out_flit = Decoupled(UInt(OUT_FLIT_WIDTH.W))
  })

  val FLIT_META_WIDTH     = 2 + DEST_BITS + VC_BITS + SRC_BITS
  val IN_FLIT_DATA_WIDTH  = IN_FLIT_WIDTH - FLIT_META_WIDTH
  val OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH
  val LEN                 = (IN_FLIT_DATA_WIDTH + OUT_FLIT_DATA_WIDTH - 1) / OUT_FLIT_DATA_WIDTH

  val len = RegInit(0.U(log2Up(LEN).W))

  // FSM to receive flits from device and send flits to network
  val s_idle :: s_send :: Nil = Enum(2)
  val state                   = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      len := 0.U
      when(io.in_flit.fire) {
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

  val flit_meta_reg = RegInit(0.U(FLIT_META_WIDTH.W))
  val flit_data_reg = RegInit(0.U(IN_FLIT_DATA_WIDTH.W))
  when(io.in_flit.fire) {
    flit_meta_reg := io.in_flit.bits(IN_FLIT_WIDTH - 1, IN_FLIT_DATA_WIDTH)
    flit_data_reg := io.in_flit.bits(IN_FLIT_DATA_WIDTH - 1, 0)
  }
  when(io.out_flit.fire) {
    flit_data_reg := flit_data_reg >> OUT_FLIT_DATA_WIDTH
  }

  // In flit output signals
  io.in_flit.ready := (state === s_idle)

  // Out flit output signals
  io.out_flit.valid := (state === s_send)
  io.out_flit.bits := Cat(
    flit_meta_reg(FLIT_META_WIDTH - 1).asUInt,
    (flit_meta_reg(FLIT_META_WIDTH - 2) && (len === (LEN - 1).U)).asUInt, // update tail
    flit_meta_reg(FLIT_META_WIDTH - 3, 0),
    flit_data_reg(OUT_FLIT_DATA_WIDTH - 1, 0)
  )

  if (DEBUG_SERIALIZER) {
    val cnt = RegInit(0.U((log2Up(LEN) + 1).W))
    when(io.in_flit.fire) {
      cnt := 0.U
    }
    when(io.out_flit.fire) {
      cnt := cnt + 1.U
      printf("%d: [Serializer   %d] out_flit=%b (%d/%d)\n", DebugTimer(), ID.U, io.out_flit.bits, cnt + 1.U, LEN.U)
    }
  }
}

class FlitDeserializer(val ID: Int, val IN_FLIT_WIDTH: Int, val OUT_FLIT_WIDTH: Int) extends Module with Config {
  val io = IO(new Bundle {
    val in_flit  = Flipped(Decoupled(UInt(IN_FLIT_WIDTH.W)))
    val out_flit = Decoupled(UInt(OUT_FLIT_WIDTH.W))
  })

  val FLIT_META_WIDTH     = 2 + DEST_BITS + VC_BITS + SRC_BITS
  val IN_FLIT_DATA_WIDTH  = IN_FLIT_WIDTH - FLIT_META_WIDTH
  val OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH
  val LEN                 = (OUT_FLIT_DATA_WIDTH + IN_FLIT_DATA_WIDTH - 1) / IN_FLIT_DATA_WIDTH

  val in_flit_src = Wire(UInt(SRC_BITS.W))
  in_flit_src := io.in_flit.bits(IN_FLIT_DATA_WIDTH + SRC_BITS - 1, IN_FLIT_DATA_WIDTH)

  // Length counter for each source
  val len = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(0.U(log2Up(LEN).W))))

  // FSM to receive flits from network and send flits to device
  val s_recv :: s_data :: Nil = Enum(2)
  val state                   = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(s_recv)))

  // valid & ready signals for each source
  val in_flit_valid_vec  = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val in_flit_ready_vec  = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val out_flit_valid_vec = Wire(Vec(NUM_USER_SEND_PORTS, Bool()))
  val out_flit_ready_vec = WireInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(false.B)))
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    in_flit_valid_vec(i)  := io.in_flit.valid && (in_flit_src === i.U)
    in_flit_ready_vec(i)  := (state(i) === s_recv)
    out_flit_valid_vec(i) := (state(i) === s_data)
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
        when(out_flit_valid_vec(i) && out_flit_ready_vec(i)) {
          state(i) := s_recv
        }
      }
    }
  }

  // In flit register for each source
  val flit_meta_reg = RegInit(VecInit(Seq.fill(NUM_USER_SEND_PORTS)(0.U(FLIT_META_WIDTH.W))))
  val flit_data_reg = Wire(Vec(NUM_USER_SEND_PORTS, UInt(OUT_FLIT_DATA_WIDTH.W)))
  val flit_data_reg_vec = RegInit(
    VecInit(Seq.fill(NUM_USER_SEND_PORTS)(VecInit(Seq.fill(LEN)(0.U(IN_FLIT_DATA_WIDTH.W)))))
  )
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    when(in_flit_valid_vec(i) && in_flit_ready_vec(i)) {
      flit_meta_reg(i)             := io.in_flit.bits(IN_FLIT_WIDTH - 1, IN_FLIT_DATA_WIDTH)
      flit_data_reg_vec(i)(len(i)) := io.in_flit.bits(IN_FLIT_DATA_WIDTH - 1, 0)
    }
    flit_data_reg(i) := flit_data_reg_vec(i).reduce((x, y) => Cat(y, x))(OUT_FLIT_DATA_WIDTH - 1, 0)
  }

  // In flit output signals
  io.in_flit.ready := in_flit_ready_vec(in_flit_src)

  // Priority encoder to decide which flit to out
  val out_flit_idx = WireInit(0.U(SRC_BITS.W))
  for (i <- 0 until NUM_USER_SEND_PORTS) {
    when(out_flit_valid_vec(i)) {
      out_flit_idx := i.U(SRC_BITS.W)
    }
  }
  out_flit_ready_vec(out_flit_idx) := io.out_flit.ready

  // Out flit output signals
  io.out_flit.valid := out_flit_valid_vec.reduce(_ || _)
  io.out_flit.bits  := Cat(flit_meta_reg(out_flit_idx), flit_data_reg(out_flit_idx))

  if (DEBUG_DESERIALIZER) {
    when(io.in_flit.fire) {
      printf("%d: [Deserializer %d]  in_flit=%b\n", DebugTimer(), ID.U, io.in_flit.bits)
    }
    when(io.out_flit.fire) {
      printf(
        "%d: [Deserializer %d] out_flit=%b\n",
        DebugTimer(),
        ID.U,
        io.out_flit.bits
      )
    }
  }
}
