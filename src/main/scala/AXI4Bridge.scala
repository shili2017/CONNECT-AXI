package connect_axi

import chisel3._
import chisel3.util._

class AXI4MasterBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi        = Flipped(new AXI4IO)
    val put_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val get_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
  })

  // State definitions
  val s_idle :: s_wdata :: s_wresp1 :: s_wresp2 :: s_rdata1 :: s_rdata2 :: Nil = Enum(6)

  // FSM to handle AXI master device request & response
  val state = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(io.axi.aw.fire) {
        state := s_wdata
      }.elsewhen(io.axi.ar.fire) {
        state := s_rdata1
      }
    }
    is(s_wdata) {
      when(io.axi.w.fire && io.axi.w.bits.last) {
        state := s_wresp1
      }
    }
    is(s_wresp1) {
      when(io.get_packet.fire) {
        state := s_wresp2
      }
    }
    is(s_wresp2) {
      when(io.axi.b.fire) {
        state := s_idle
      }
    }
    is(s_rdata1) {
      when(io.get_packet.fire) {
        state := s_rdata2
      }
    }
    is(s_rdata2) {
      when(io.axi.r.fire) {
        when(io.axi.r.bits.last) {
          state := s_idle
        }.otherwise {
          state := s_rdata1
        }
      }
    }
  }

  // Put packet destination
  val put_packet_dst_reg = RegInit(0.U(DEST_BITS.W))
  when(io.axi.aw.fire) {
    put_packet_dst_reg := GetDestFromAXI4ChannelA(io.axi.aw.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_packet_dst_reg := GetDestFromAXI4ChannelA(io.axi.ar.bits)
  }
  val put_packet_dst = Wire(UInt(DEST_BITS.W))
  when(io.axi.aw.fire) {
    put_packet_dst := GetDestFromAXI4ChannelA(io.axi.aw.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_packet_dst := GetDestFromAXI4ChannelA(io.axi.ar.bits)
  }.otherwise {
    put_packet_dst := put_packet_dst_reg
  }

  // Put packet data
  val put_packet_data = WireInit(0.U(AXI4PacketDataWidth().W))
  when(io.axi.aw.fire) {
    put_packet_data := AXI4ChannelA2PacketData(io.axi.aw.bits, true.B)
  }.elsewhen(io.axi.w.fire) {
    put_packet_data := AXI4ChannelW2PacketData(io.axi.w.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_packet_data := AXI4ChannelA2PacketData(io.axi.ar.bits, false.B)
  }

  // Get packet register
  val get_packet = RegInit(0.U(AXI4PacketWidth().W))
  when(io.get_packet.fire) {
    get_packet := io.get_packet.bits
  }

  // AXI4 output signals
  io.axi.aw.ready := (state === s_idle) && io.put_packet.ready
  io.axi.w.ready  := (state === s_wdata) && io.put_packet.ready
  io.axi.b.bits   := Packet2AXI4ChannelB(get_packet)
  io.axi.b.valid  := (state === s_wresp2)
  io.axi.ar.ready := (state === s_idle) && io.put_packet.ready
  io.axi.r.bits   := Packet2AXI4ChannelR(get_packet)
  io.axi.r.valid  := (state === s_rdata2)

  // InPort output signals, use VC 1
  io.put_packet.bits := AssemblePacket(
    put_packet_data,
    ID.U(SRC_BITS.W),
    1.U(VC_BITS.W),
    put_packet_dst,
    true.B,
    io.put_packet.valid
  )
  io.put_packet.valid := io.axi.aw.fire || io.axi.w.fire || io.axi.ar.fire

  // OutPort output signals
  io.get_packet.ready := (state === s_wresp1) || (state === s_rdata1)

  // Debug
  if (DEBUG_AXI4_BRIDGE) {
    when(io.put_packet.fire) {
      printf("%d: [AXI4 Bridge  %d] put_packet=%b\n", DebugTimer(), ID.U, io.put_packet.bits)
    }
    when(io.get_packet.fire) {
      printf("%d: [AXI4 Bridge  %d] get_packet=%b\n", DebugTimer(), ID.U, io.get_packet.bits)
    }
  }
}

class AXI4SlaveBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi        = new AXI4IO
    val put_packet = Decoupled(UInt(AXI4PacketWidth().W))
    val get_packet = Flipped(Decoupled(UInt(AXI4PacketWidth().W)))
  })

  // State definitions
  val s_idle :: s_waddr :: s_wdata1 :: s_wdata2 :: s_wresp :: s_raddr :: s_rdata :: Nil = Enum(7)

  // FSM to handle AXI master device request & response
  val state = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(io.get_packet.fire) {
        when(GetIsWFromPacket(io.get_packet.bits)) {
          state := s_waddr
        }.otherwise {
          state := s_raddr
        }
      }
    }
    is(s_waddr) {
      when(io.axi.aw.fire) {
        state := s_wdata1
      }
    }
    is(s_wdata1) {
      when(io.get_packet.valid) {
        state := s_wdata2
      }
    }
    is(s_wdata2) {
      when(io.axi.w.fire) {
        when(io.axi.w.bits.last) {
          state := s_wresp
        }.otherwise {
          state := s_wdata1
        }
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
      when(io.axi.r.fire && io.axi.r.bits.last) {
        state := s_idle
      }
    }
  }

  // Put packet data
  val put_packet_data = WireInit(0.U(AXI4PacketDataWidth().W))
  when(io.axi.b.fire) {
    put_packet_data := AXI4ChannelB2PacketData(io.axi.b.bits)
  }.elsewhen(io.axi.r.fire) {
    put_packet_data := AXI4ChannelR2PacketData(io.axi.r.bits)
  }

  // Get packet register
  val get_packet = RegInit(0.U(AXI4PacketWidth().W))
  when(io.get_packet.fire) {
    get_packet := io.get_packet.bits
  }

  // AXI4 output signals
  io.axi.aw.bits  := Packet2AXI4ChannelA(get_packet)
  io.axi.aw.valid := (state === s_waddr)
  io.axi.w.bits   := Packet2AXI4ChannelW(get_packet)
  io.axi.w.valid  := (state === s_wdata2)
  io.axi.b.ready  := (state === s_wresp) && io.put_packet.ready
  io.axi.ar.bits  := Packet2AXI4ChannelA(get_packet)
  io.axi.ar.valid := (state === s_raddr)
  io.axi.r.ready  := (state === s_rdata) && io.put_packet.ready

  // InPort output signals, use VC 0
  io.put_packet.bits := AssemblePacket(
    put_packet_data,
    ID.U(SRC_BITS.W),
    0.U(VC_BITS.W),
    GetSrcFromPacket(get_packet),
    true.B,
    io.put_packet.valid
  )
  io.put_packet.valid := io.axi.b.fire || io.axi.r.fire

  // OutPort output signals
  io.get_packet.ready := (state === s_idle) || (state === s_wdata1)

  // Debug
  if (DEBUG_AXI4_BRIDGE) {
    when(io.put_packet.fire) {
      printf("%d: [AXI4 Bridge  %d] put_packet=%b\n", DebugTimer(), ID.U, io.put_packet.bits)
    }
    when(io.get_packet.fire) {
      printf("%d: [AXI4 Bridge  %d] get_packet=%b\n", DebugTimer(), ID.U, io.get_packet.bits)
    }
  }
}
