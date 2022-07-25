package connect_axi

import chisel3._
import chisel3.util._
import chipsalliance.rocketchip.config._

class AXI4MasterBridge(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(p(AXI4_BUS_IO))
    // Response (b/r) channel at VC0, input
    val br_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    // Write (w) channel at VC1, output
    val w_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    // Address (aw/ar) channel at VC2, output
    val a_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
  })

  val stage1 = Module(new AXI4MasterBridgeStage1)
  val stage2 = Module(new AXI4MasterBridgeStage2)

  stage1.io.axi          <> io.axi
  stage2.io.in_aw_packet <> stage1.io.aw_packet
  stage2.io.in_w_packet  <> stage1.io.w_packet
  stage2.io.in_b_packet  <> stage1.io.b_packet
  stage2.io.in_ar_packet <> stage1.io.ar_packet
  stage2.io.in_r_packet  <> stage1.io.r_packet
  io.br_packet           <> stage2.io.out_br_packet
  io.w_packet            <> stage2.io.out_w_packet
  io.a_packet            <> stage2.io.out_a_packet

  // Debug
  if (p(DEBUG_BRIDGE)) {
    when(io.axi.aw.fire) {
      printf("%d: [AXI4 Bridge-M%d] aw addr=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.aw.bits.addr)
    }
    when(io.axi.w.fire) {
      printf("%d: [AXI4 Bridge-M%d] w  data=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.w.bits.data)
    }
    when(io.axi.b.fire) {
      printf("%d: [AXI4 Bridge-M%d] b\n", DebugTimer(), p(DEVICE_ID).U)
    }
    when(io.axi.ar.fire) {
      printf("%d: [AXI4 Bridge-M%d] ar addr=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.ar.bits.addr)
    }
    when(io.axi.r.fire) {
      printf("%d: [AXI4 Bridge-M%d] r  data=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.r.bits.data)
    }
    when(io.a_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] a_packet =%b\n", DebugTimer(), p(DEVICE_ID).U, io.a_packet.bits)
    }
    when(io.w_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] w_packet =%b\n", DebugTimer(), p(DEVICE_ID).U, io.w_packet.bits)
    }
    when(io.br_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] br_packet=%b\n", DebugTimer(), p(DEVICE_ID).U, io.br_packet.bits)
    }
  }
}

class AXI4MasterBridgeStage1(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(p(AXI4_BUS_IO))
    // Response (b/r) channel at VC0, input
    val b_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val r_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    // Write (w) channel at VC1, output
    val w_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    // Address (aw/ar) channel at VC2, output
    val aw_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    val ar_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
  })

  // State for write
  val w_addr :: w_data :: w_resp :: Nil = Enum(3)
  val w_state                           = RegInit(w_addr)

  // State for read
  val r_addr :: r_data :: Nil = Enum(2)
  val r_state                 = RegInit(r_addr)

  // FSM to handle AXI master device write
  switch(w_state) {
    is(w_addr) {
      when(io.axi.aw.fire) {
        w_state := w_data
      }
    }
    is(w_data) {
      if (io.axi.w.bits.getClass == classOf[AXI4ChannelW]) {
        when(io.axi.w.fire && io.axi.w.bits.asInstanceOf[AXI4ChannelW].last) {
          w_state := w_resp
        }
      } else {
        when(io.axi.w.fire) {
          w_state := w_resp
        }
      }
    }
    is(w_resp) {
      when(io.axi.b.fire) {
        w_state := w_addr
      }
    }
  }

  // FSM to handle AXI master device read
  switch(r_state) {
    is(r_addr) {
      when(io.axi.ar.fire) {
        r_state := r_data
      }
    }
    is(r_data) {
      if (io.axi.r.bits.getClass == classOf[AXI4ChannelR]) {
        when(io.axi.r.fire && io.axi.r.bits.asInstanceOf[AXI4ChannelR].last) {
          r_state := r_addr
        }
      } else {
        when(io.axi.r.fire) {
          r_state := r_addr
        }
      }
    }
  }

  // Write packet destination
  val w_packet_dst = RegEnable(
    GetDestFromAXI4ChannelA(io.axi.aw.bits),
    0.U(p(DEST_BITS).W),
    io.axi.aw.fire
  )

  // Channel AW packet
  io.aw_packet.bits := Assemble(p(PACKET_DATA_WIDTH))(
    AXI4ChannelA2PacketData(io.axi.aw.bits, true.B).asTypeOf(UInt(p(PACKET_DATA_WIDTH).W)),
    p(DEVICE_ID).U(p(SRC_BITS).W),
    2.U(p(VC_BITS).W),
    GetDestFromAXI4ChannelA(io.axi.aw.bits),
    true.B,
    io.aw_packet.valid
  )
  io.aw_packet.valid := io.axi.aw.valid && (w_state === w_addr)
  io.axi.aw.ready    := io.aw_packet.ready && (w_state === w_addr)

  // Channel AR packet
  io.ar_packet.bits := Assemble(p(PACKET_DATA_WIDTH))(
    AXI4ChannelA2PacketData(io.axi.ar.bits, false.B).asTypeOf(UInt(p(PACKET_DATA_WIDTH).W)),
    p(DEVICE_ID).U(p(SRC_BITS).W),
    2.U(p(VC_BITS).W),
    GetDestFromAXI4ChannelA(io.axi.ar.bits),
    true.B,
    io.ar_packet.valid
  )
  io.ar_packet.valid := io.axi.ar.valid && (r_state === r_addr)
  io.axi.ar.ready    := io.ar_packet.ready && (r_state === r_addr)

  // Channel W packet
  io.w_packet.bits := Assemble(p(PACKET_DATA_WIDTH))(
    AXI4ChannelW2PacketData(io.axi.w.bits).asTypeOf(UInt(p(PACKET_DATA_WIDTH).W)),
    p(DEVICE_ID).U(p(SRC_BITS).W),
    1.U(p(VC_BITS).W),
    w_packet_dst,
    true.B,
    io.w_packet.valid
  )
  io.w_packet.valid := io.axi.w.valid && (w_state === w_data)
  io.axi.w.ready    := io.w_packet.ready && (w_state === w_data)

  // Channel B packet
  io.axi.b.bits     := Packet2AXI4ChannelB(io.b_packet.bits)
  io.axi.b.valid    := io.b_packet.valid && (w_state === w_resp)
  io.b_packet.ready := io.axi.b.ready && (w_state === w_resp)

  // Channel R packet
  io.axi.r.bits     := Packet2AXI4ChannelR(io.r_packet.bits)
  io.axi.r.valid    := io.r_packet.valid && (r_state === r_data)
  io.r_packet.ready := io.axi.r.ready && (r_state === r_data)
}

class AXI4MasterBridgeStage2(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    // From stage 1
    val in_aw_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val in_w_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val in_b_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    val in_ar_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val in_r_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    // To network
    val out_a_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    val out_w_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    val out_br_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
  })

  // Round-robin arbiter for address channel (aw/ar) packet
  val arbiter = Module(new RRArbiter(UInt(p(PACKET_WIDTH).W), 2))
  arbiter.io.in(0) <> io.in_aw_packet
  arbiter.io.in(1) <> io.in_ar_packet
  io.out_a_packet  <> arbiter.io.out

  // Write channel
  io.out_w_packet <> io.in_w_packet

  // Response channel (b/r)
  io.in_b_packet.bits := io.out_br_packet.bits
  io.in_b_packet.valid := io.out_br_packet.valid &&
    (GetChannelIDFromAXI4Packet(io.out_br_packet.bits) === AXI4ChannelID.B)
  io.out_br_packet.ready := io.in_b_packet.ready &&
    (GetChannelIDFromAXI4Packet(io.out_br_packet.bits) === AXI4ChannelID.B)
  io.in_r_packet.bits := io.out_br_packet.bits
  io.in_r_packet.valid := io.out_br_packet.valid &&
    (GetChannelIDFromAXI4Packet(io.out_br_packet.bits) === AXI4ChannelID.R)
  io.out_br_packet.ready := io.in_r_packet.ready &&
    (GetChannelIDFromAXI4Packet(io.out_br_packet.bits) === AXI4ChannelID.R)
}

class AXI4SlaveBridge(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(Flipped(p(AXI4_BUS_IO)))
    // Response (b/r) channel at VC0, output
    val br_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    // Write (w) channel at VC1, input
    val w_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    // Address (aw/ar) channel at VC2, input
    val a_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
  })

  val stage1 = Module(new AXI4SlaveBridgeStage1)
  val stage2 = Module(new AXI4SlaveBridgeStage2)

  stage1.io.axi <> io.axi
  if (p(WRITE_INTERLEAVE)) {
    val buffer = Module(new AXI4SlaveBridgeWriteBuffer)
    buffer.io.stage1_aw_packet <> stage1.io.aw_packet
    buffer.io.stage1_w_packet  <> stage1.io.w_packet
    buffer.io.stage2_aw_packet <> stage2.io.in_aw_packet
    buffer.io.stage2_w_packet  <> stage2.io.in_w_packet
  } else {
    stage2.io.in_aw_packet <> stage1.io.aw_packet
    stage2.io.in_w_packet  <> stage1.io.w_packet
  }
  stage2.io.in_b_packet  <> stage1.io.b_packet
  stage2.io.in_ar_packet <> stage1.io.ar_packet
  stage2.io.in_r_packet  <> stage1.io.r_packet
  io.br_packet           <> stage2.io.out_br_packet
  io.w_packet            <> stage2.io.out_w_packet
  io.a_packet            <> stage2.io.out_a_packet

  // Debug
  if (p(DEBUG_BRIDGE)) {
    when(io.axi.aw.fire) {
      printf("%d: [AXI4 Bridge-S%d] aw addr=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.aw.bits.addr)
    }
    when(io.axi.w.fire) {
      printf("%d: [AXI4 Bridge-S%d] w  data=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.w.bits.data)
    }
    when(io.axi.b.fire) {
      printf("%d: [AXI4 Bridge-S%d] b\n", DebugTimer(), p(DEVICE_ID).U)
    }
    when(io.axi.ar.fire) {
      printf("%d: [AXI4 Bridge-S%d] ar addr=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.ar.bits.addr)
    }
    when(io.axi.r.fire) {
      printf("%d: [AXI4 Bridge-S%d] r  data=%b\n", DebugTimer(), p(DEVICE_ID).U, io.axi.r.bits.data)
    }
    when(io.a_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] a_packet =%b\n", DebugTimer(), p(DEVICE_ID).U, io.a_packet.bits)
    }
    when(io.w_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] w_packet =%b\n", DebugTimer(), p(DEVICE_ID).U, io.w_packet.bits)
    }
    when(io.br_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] br_packet=%b\n", DebugTimer(), p(DEVICE_ID).U, io.br_packet.bits)
    }
  }
}

class AXI4SlaveBridgeStage1(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(Flipped(p(AXI4_BUS_IO)))
    // Response (b/r) channel at VC0, output
    val b_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    val r_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    // Write (w) channel at VC1, input
    val w_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    // Address (aw/ar) channel at VC2, input
    val aw_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val ar_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
  })

  // State for write
  val w_addr :: w_data :: w_resp :: Nil = Enum(3)
  val w_state                           = RegInit(w_addr)

  // State for read
  val r_addr :: r_data :: Nil = Enum(2)
  val r_state                 = RegInit(r_addr)

  // FSM to handle AXI master device write
  switch(w_state) {
    is(w_addr) {
      when(io.axi.aw.fire) {
        w_state := w_data
      }
    }
    is(w_data) {
      if (io.axi.w.bits.getClass == classOf[AXI4ChannelW]) {
        when(io.axi.w.fire && io.axi.w.bits.asInstanceOf[AXI4ChannelW].last) {
          w_state := w_resp
        }
      } else {
        when(io.axi.w.fire) {
          w_state := w_resp
        }
      }
    }
    is(w_resp) {
      when(io.axi.b.fire) {
        w_state := w_addr
      }
    }
  }

  // FSM to handle AXI master device read
  switch(r_state) {
    is(r_addr) {
      when(io.axi.ar.fire) {
        r_state := r_data
      }
    }
    is(r_data) {
      if (io.axi.r.bits.getClass == classOf[AXI4ChannelR]) {
        when(io.axi.r.fire && io.axi.r.bits.asInstanceOf[AXI4ChannelR].last) {
          r_state := r_addr
        }
      } else {
        when(io.axi.r.fire) {
          r_state := r_addr
        }
      }
    }
  }

  // Write response packet destination
  val b_packet_dst = RegEnable(
    GetSrcFromPacket(io.aw_packet.bits),
    0.U(p(DEST_BITS).W),
    io.aw_packet.fire
  )

  // Read response packet destination
  val r_packet_dst = RegEnable(
    GetSrcFromPacket(io.ar_packet.bits),
    0.U(p(DEST_BITS).W),
    io.ar_packet.fire
  )

  // Channel AW packet
  io.axi.aw.bits     := Packet2AXI4ChannelA(io.aw_packet.bits)
  io.axi.aw.valid    := io.aw_packet.valid && (w_state === w_addr)
  io.aw_packet.ready := io.axi.aw.ready && (w_state === w_addr)

  // Channel AW packet
  io.axi.ar.bits     := Packet2AXI4ChannelA(io.ar_packet.bits)
  io.axi.ar.valid    := io.ar_packet.valid && (r_state === r_addr)
  io.ar_packet.ready := io.axi.ar.ready && (r_state === r_addr)

  // Channel W packet
  io.axi.w.bits     := Packet2AXI4ChannelW(io.w_packet.bits)
  io.axi.w.valid    := io.w_packet.valid && (w_state === w_data)
  io.w_packet.ready := io.axi.w.ready && (w_state === w_data)

  // Channel B packet
  io.b_packet.bits := Assemble(p(PACKET_DATA_WIDTH))(
    AXI4ChannelB2PacketData(io.axi.b.bits).asTypeOf(UInt(p(PACKET_DATA_WIDTH).W)),
    p(DEVICE_ID).U(p(SRC_BITS).W),
    0.U(p(VC_BITS).W),
    b_packet_dst,
    true.B,
    io.b_packet.valid
  )
  io.b_packet.valid := io.axi.b.valid && (w_state === w_resp)
  io.axi.b.ready    := io.b_packet.ready && (w_state === w_resp)

  // Channel R packet
  io.r_packet.bits := Assemble(p(PACKET_DATA_WIDTH))(
    AXI4ChannelR2PacketData(io.axi.r.bits).asTypeOf(UInt(p(PACKET_DATA_WIDTH).W)),
    p(DEVICE_ID).U(p(SRC_BITS).W),
    0.U(p(VC_BITS).W),
    r_packet_dst,
    true.B,
    io.r_packet.valid
  )
  io.r_packet.valid := io.axi.r.valid && (r_state === r_data)
  io.axi.r.ready    := io.r_packet.ready && (r_state === r_data)
}

class AXI4SlaveBridgeStage2(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    // To stage 1
    val in_aw_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    val in_w_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    val in_b_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val in_ar_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    val in_r_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    // From network
    val out_a_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val out_w_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val out_br_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
  })

  // Address channel (aw/ar)
  io.in_aw_packet.bits := io.out_a_packet.bits
  io.in_aw_packet.valid := io.out_a_packet.valid &&
    (GetChannelIDFromAXI4Packet(io.out_a_packet.bits) === AXI4ChannelID.AW)
  io.in_ar_packet.bits := io.out_a_packet.bits
  io.in_ar_packet.valid := io.out_a_packet.valid &&
    (GetChannelIDFromAXI4Packet(io.out_a_packet.bits) === AXI4ChannelID.AR)
  io.out_a_packet.ready := false.B
  when(GetChannelIDFromAXI4Packet(io.out_a_packet.bits) === AXI4ChannelID.AW) {
    io.out_a_packet.ready := io.in_aw_packet.ready
  }.elsewhen(GetChannelIDFromAXI4Packet(io.out_a_packet.bits) === AXI4ChannelID.AR) {
    io.out_a_packet.ready := io.in_ar_packet.ready
  }

  // Write channel
  io.in_w_packet <> io.out_w_packet

  // Round-robin arbiter for response channel (b/r) packet
  val arbiter = Module(new RRArbiter(UInt(p(PACKET_WIDTH).W), 2))
  arbiter.io.in(0) <> io.in_b_packet
  arbiter.io.in(1) <> io.in_r_packet
  io.out_br_packet <> arbiter.io.out
}

class AXI4SlaveBridgeWriteBuffer(implicit p: Parameters) extends Module {
  val WRITE_BUFFER_DEPTH = if (p(PROTOCOL) == "AXI4") p(AXI4_MAX_BURST_LEN) else 1

  val io = IO(new Bundle {
    // To stage 1
    val stage1_aw_packet = Decoupled(UInt(p(PACKET_WIDTH).W))
    val stage1_w_packet  = Decoupled(UInt(p(PACKET_WIDTH).W))
    // From stage 2
    val stage2_aw_packet = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
    val stage2_w_packet  = Flipped(Decoupled(UInt(p(PACKET_WIDTH).W)))
  })

  // TODO: map master device ID with buffer index, currently using identical mapping
  val buffer = for (i <- 0 until p(NUM_MASTER_DEVICES)) yield {
    val _buffer = Module(new BasicFIFO(WRITE_BUFFER_DEPTH, p(PACKET_WIDTH))())
    _buffer
  }

  // Handle incoming write packets from stage 2
  val src = Wire(UInt(p(SRC_BITS).W))
  src                      := GetSrcFromPacket(io.stage2_w_packet.bits)
  io.stage2_w_packet.ready := false.B
  for (i <- 0 until p(NUM_MASTER_DEVICES)) {
    buffer(i).io.enq.bits  := io.stage2_w_packet.bits
    buffer(i).io.enq.valid := io.stage2_w_packet.valid && (src === i.U)
    when(src === i.U) {
      io.stage2_w_packet.ready := buffer(i).io.enq.ready
    }
  }

  // Find the master device from incoming aw packets from stage 2
  io.stage1_aw_packet <> io.stage2_aw_packet
  val device = RegInit(0.U(log2Up(p(NUM_MASTER_DEVICES)).W))
  when(io.stage2_aw_packet.fire) {
    device := GetSrcFromPacket(io.stage2_aw_packet.bits)
  }

  // Send write packets to stage 1
  // Note that the correctness of this part is guaranteed by write buffer and stage 1 together
  io.stage1_w_packet.bits  := 0.U
  io.stage1_w_packet.valid := false.B
  for (i <- 0 until p(NUM_MASTER_DEVICES)) {
    when(device === i.U) {
      io.stage1_w_packet.bits  := buffer(i).io.deq.bits
      io.stage1_w_packet.valid := buffer(i).io.deq.valid
    }
    buffer(i).io.deq.ready := io.stage1_w_packet.ready && (device === i.U)
  }
}
