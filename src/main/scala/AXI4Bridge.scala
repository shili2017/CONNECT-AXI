package connect_axi

import chisel3._
import chisel3.util._

class AXI4MasterBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi = Flipped(new AXI4IO)
    // Response (b/r) channel at VC0, input
    val br_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    // Write (w) channel at VC1, output
    val w_packet = Decoupled(UInt(AXI4PacketWidth().W))
    // Address (aw/ar) channel at VC2, output
    val a_packet = Decoupled(UInt(AXI4PacketWidth().W))
  })

  val stage1 = Module(new AXI4MasterBridgeStage1(ID))
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
  if (DEBUG_AXI4_BRIDGE) {
    when(io.axi.aw.fire) {
      printf("%d: [AXI4 Bridge-M%d] aw addr=%b\n", DebugTimer(), ID.U, io.axi.aw.bits.addr)
    }
    when(io.axi.w.fire) {
      printf("%d: [AXI4 Bridge-M%d] w  data=%b last=%b\n", DebugTimer(), ID.U, io.axi.w.bits.data, io.axi.w.bits.last)
    }
    when(io.axi.b.fire) {
      printf("%d: [AXI4 Bridge-M%d] b\n", DebugTimer(), ID.U)
    }
    when(io.axi.ar.fire) {
      printf("%d: [AXI4 Bridge-M%d] ar addr=%b\n", DebugTimer(), ID.U, io.axi.ar.bits.addr)
    }
    when(io.axi.r.fire) {
      printf("%d: [AXI4 Bridge-M%d] r  data=%b last=%b\n", DebugTimer(), ID.U, io.axi.r.bits.data, io.axi.r.bits.last)
    }
    when(io.a_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] a_packet =%b\n", DebugTimer(), ID.U, io.a_packet.bits)
    }
    when(io.w_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] w_packet =%b\n", DebugTimer(), ID.U, io.w_packet.bits)
    }
    when(io.br_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] br_packet=%b\n", DebugTimer(), ID.U, io.br_packet.bits)
    }
  }
}

class AXI4MasterBridgeStage1(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi = Flipped(new AXI4IO)
    // Response (b/r) channel at VC0, input
    val b_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val r_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    // Write (w) channel at VC1, output
    val w_packet = Decoupled(UInt(AXI4PacketWidth().W))
    // Address (aw/ar) channel at VC2, output
    val aw_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val ar_packet = Decoupled(UInt(AXI4PacketWidth().W))
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
      when(io.axi.w.fire && io.axi.w.bits.last) {
        w_state := w_resp
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
      when(io.axi.r.fire && io.axi.r.bits.last) {
        r_state := r_addr
      }
    }
  }

  // Write packet destination
  val w_packet_dst = RegEnable(
    GetDestFromAXI4ChannelA(io.axi.aw.bits),
    0.U.asTypeOf(UInt(DEST_BITS.W)),
    io.axi.aw.fire
  )

  // Channel AW packet
  io.aw_packet.bits := Assemble(
    AXI4ChannelA2PacketData(io.axi.aw.bits, true.B).asTypeOf(UInt(AXI4PacketDataWidth().W)),
    ID.U(SRC_BITS.W),
    2.U(VC_BITS.W),
    GetDestFromAXI4ChannelA(io.axi.aw.bits),
    true.B,
    io.aw_packet.valid
  )
  io.aw_packet.valid := io.axi.aw.valid && (w_state === w_addr)
  io.axi.aw.ready    := io.aw_packet.ready && (w_state === w_addr)

  // Channel AR packet
  io.ar_packet.bits := Assemble(
    AXI4ChannelA2PacketData(io.axi.ar.bits, false.B).asTypeOf(UInt(AXI4PacketDataWidth().W)),
    ID.U(SRC_BITS.W),
    2.U(VC_BITS.W),
    GetDestFromAXI4ChannelA(io.axi.ar.bits),
    true.B,
    io.ar_packet.valid
  )
  io.ar_packet.valid := io.axi.ar.valid && (r_state === r_addr)
  io.axi.ar.ready    := io.ar_packet.ready && (r_state === r_addr)

  // Channel W packet
  io.w_packet.bits := Assemble(
    AXI4ChannelW2PacketData(io.axi.w.bits).asTypeOf(UInt(AXI4PacketDataWidth().W)),
    ID.U(SRC_BITS.W),
    1.U(VC_BITS.W),
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

class AXI4MasterBridgeStage2 extends Module with Config {
  val io = IO(new Bundle {
    // From stage 1
    val in_aw_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val in_w_packet  = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val in_b_packet  = Decoupled(UInt(AXI4PacketWidth().W))
    val in_ar_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val in_r_packet  = Decoupled(UInt(AXI4PacketWidth().W))
    // To network
    val out_a_packet  = Decoupled(UInt(AXI4PacketWidth().W))
    val out_w_packet  = Decoupled(UInt(AXI4PacketWidth().W))
    val out_br_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
  })

  // Round-robin arbiter for address channel (aw/ar) packet
  val arbiter = Module(new RRArbiter(UInt(AXI4PacketWidth().W), 2))
  arbiter.io.in(0) <> io.in_aw_packet
  arbiter.io.in(1) <> io.in_ar_packet
  io.out_a_packet  <> arbiter.io.out

  // Write channel
  io.out_w_packet <> io.in_w_packet

  // Response channel (b/r)
  io.in_b_packet.bits    := io.out_br_packet.bits
  io.in_b_packet.valid   := io.out_br_packet.valid && (GetChannelIDFromPacket(io.out_br_packet.bits) === AXI4ChannelID.B)
  io.out_br_packet.ready := io.in_b_packet.ready && (GetChannelIDFromPacket(io.out_br_packet.bits) === AXI4ChannelID.B)
  io.in_r_packet.bits    := io.out_br_packet.bits
  io.in_r_packet.valid   := io.out_br_packet.valid && (GetChannelIDFromPacket(io.out_br_packet.bits) === AXI4ChannelID.R)
  io.out_br_packet.ready := io.in_r_packet.ready && (GetChannelIDFromPacket(io.out_br_packet.bits) === AXI4ChannelID.R)
}

class AXI4SlaveBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi = new AXI4IO
    // Response (b/r) channel at VC0, output
    val br_packet = Decoupled(UInt(AXI4PacketWidth().W))
    // Write (w) channel at VC1, input
    val w_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    // Address (aw/ar) channel at VC2, input
    val a_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
  })

  val stage1 = Module(new AXI4SlaveBridgeStage1(ID))
  val stage2 = Module(new AXI4SlaveBridgeStage2)

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
  if (DEBUG_AXI4_BRIDGE) {
    when(io.axi.aw.fire) {
      printf("%d: [AXI4 Bridge-S%d] aw addr=%b\n", DebugTimer(), ID.U, io.axi.aw.bits.addr)
    }
    when(io.axi.w.fire) {
      printf("%d: [AXI4 Bridge-S%d] w  data=%b last=%b\n", DebugTimer(), ID.U, io.axi.w.bits.data, io.axi.w.bits.last)
    }
    when(io.axi.b.fire) {
      printf("%d: [AXI4 Bridge-S%d] b\n", DebugTimer(), ID.U)
    }
    when(io.axi.ar.fire) {
      printf("%d: [AXI4 Bridge-S%d] ar addr=%b\n", DebugTimer(), ID.U, io.axi.ar.bits.addr)
    }
    when(io.axi.r.fire) {
      printf("%d: [AXI4 Bridge-S%d] r  data=%b last=%b\n", DebugTimer(), ID.U, io.axi.r.bits.data, io.axi.r.bits.last)
    }
    when(io.a_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] a_packet =%b\n", DebugTimer(), ID.U, io.a_packet.bits)
    }
    when(io.w_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] w_packet =%b\n", DebugTimer(), ID.U, io.w_packet.bits)
    }
    when(io.br_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] br_packet=%b\n", DebugTimer(), ID.U, io.br_packet.bits)
    }
  }
}

class AXI4SlaveBridgeStage1(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi = new AXI4IO
    // Response (b/r) channel at VC0, output
    val b_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val r_packet = Decoupled(UInt(AXI4PacketWidth().W))
    // Write (w) channel at VC1, input
    val w_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    // Address (aw/ar) channel at VC2, input
    val aw_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val ar_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
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
      when(io.axi.w.fire && io.axi.w.bits.last) {
        w_state := w_resp
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
      when(io.axi.r.fire && io.axi.r.bits.last) {
        r_state := r_addr
      }
    }
  }

  // Write response packet destination
  val b_packet_dst = RegEnable(
    GetSrcFromPacket(io.aw_packet.bits),
    0.U.asTypeOf(UInt(DEST_BITS.W)),
    io.aw_packet.fire
  )

  // Read response packet destination
  val r_packet_dst = RegEnable(
    GetSrcFromPacket(io.ar_packet.bits),
    0.U.asTypeOf(UInt(DEST_BITS.W)),
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
  io.b_packet.bits := Assemble(
    AXI4ChannelB2PacketData(io.axi.b.bits).asTypeOf(UInt(AXI4PacketDataWidth().W)),
    ID.U(SRC_BITS.W),
    0.U(VC_BITS.W),
    b_packet_dst,
    true.B,
    io.b_packet.valid
  )
  io.b_packet.valid := io.axi.b.valid && (w_state === w_resp)
  io.axi.b.ready    := io.b_packet.ready && (w_state === w_resp)

  // Channel R packet
  io.r_packet.bits := Assemble(
    AXI4ChannelR2PacketData(io.axi.r.bits).asTypeOf(UInt(AXI4PacketDataWidth().W)),
    ID.U(SRC_BITS.W),
    0.U(VC_BITS.W),
    r_packet_dst,
    true.B,
    io.r_packet.valid
  )
  io.r_packet.valid := io.axi.r.valid && (r_state === r_data)
  io.axi.r.ready    := io.r_packet.ready && (r_state === r_data)
}

class AXI4SlaveBridgeStage2 extends Module with Config {
  val io = IO(new Bundle {
    // To stage 1
    val in_aw_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val in_w_packet  = Decoupled(UInt(AXI4PacketWidth().W))
    val in_b_packet  = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val in_ar_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val in_r_packet  = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    // From network
    val out_a_packet  = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val out_w_packet  = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
    val out_br_packet = Decoupled(UInt(AXI4PacketWidth().W))
  })

  // Address channel (aw/ar)
  io.in_aw_packet.bits  := io.out_a_packet.bits
  io.in_aw_packet.valid := io.out_a_packet.valid && (GetChannelIDFromPacket(io.out_a_packet.bits) === AXI4ChannelID.AW)
  io.in_ar_packet.bits  := io.out_a_packet.bits
  io.in_ar_packet.valid := io.out_a_packet.valid && (GetChannelIDFromPacket(io.out_a_packet.bits) === AXI4ChannelID.AR)
  io.out_a_packet.ready := false.B
  when(GetChannelIDFromPacket(io.out_a_packet.bits) === AXI4ChannelID.AW) {
    io.out_a_packet.ready := io.in_aw_packet.ready
  }.elsewhen(GetChannelIDFromPacket(io.out_a_packet.bits) === AXI4ChannelID.AR) {
    io.out_a_packet.ready := io.in_ar_packet.ready
  }

  // Write channel
  io.in_w_packet <> io.out_w_packet

  // Round-robin arbiter for response channel (b/r) packet
  val arbiter = Module(new RRArbiter(UInt(AXI4PacketWidth().W), 2))
  arbiter.io.in(0) <> io.in_b_packet
  arbiter.io.in(1) <> io.in_r_packet
  io.out_br_packet <> arbiter.io.out
}
