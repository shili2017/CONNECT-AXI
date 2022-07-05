package connect_axi

import chisel3._
import chisel3.util._

class AXI4MasterBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi      = Flipped(new AXI4IO)
    val put_flit = Decoupled(UInt(AXI4FlitWidth().W))
    val get_flit = Flipped(Decoupled(UInt(AXI4FlitWidth().W)))
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
      when(io.get_flit.fire) {
        state := s_wresp2
      }
    }
    is(s_wresp2) {
      when(io.axi.b.fire) {
        state := s_idle
      }
    }
    is(s_rdata1) {
      when(io.get_flit.fire) {
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

  // Put flit destination
  val put_flit_dst_reg = RegInit(0.U(DEST_BITS.W))
  when(io.axi.aw.fire) {
    put_flit_dst_reg := GetDestFromAXI4ChannelA(io.axi.aw.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_flit_dst_reg := GetDestFromAXI4ChannelA(io.axi.ar.bits)
  }
  val put_flit_dst = Wire(UInt(DEST_BITS.W))
  when(io.axi.aw.fire) {
    put_flit_dst := GetDestFromAXI4ChannelA(io.axi.aw.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_flit_dst := GetDestFromAXI4ChannelA(io.axi.ar.bits)
  }.otherwise {
    put_flit_dst := put_flit_dst_reg
  }

  // Put flit data
  val put_flit_data = WireInit(0.U(AXI4FlitDataWidth().W))
  when(io.axi.aw.fire) {
    put_flit_data := AXI4ChannelA2FlitData(io.axi.aw.bits, true.B)
  }.elsewhen(io.axi.w.fire) {
    put_flit_data := AXI4ChannelW2FlitData(io.axi.w.bits)
  }.elsewhen(io.axi.ar.fire) {
    put_flit_data := AXI4ChannelA2FlitData(io.axi.ar.bits, false.B)
  }

  // Get flit register
  val get_flit = RegInit(0.U(AXI4FlitWidth().W))
  when(io.get_flit.fire) {
    get_flit := io.get_flit.bits
  }

  // AXI4 output signals
  io.axi.aw.ready := (state === s_idle) && io.put_flit.ready
  io.axi.w.ready  := (state === s_wdata) && io.put_flit.ready
  io.axi.b.bits   := Flit2AXI4ChannelB(get_flit)
  io.axi.b.valid  := (state === s_wresp2)
  io.axi.ar.ready := (state === s_idle) && io.put_flit.ready
  io.axi.r.bits   := Flit2AXI4ChannelR(get_flit)
  io.axi.r.valid  := (state === s_rdata2)

  // InPort output signals, use VC 1
  io.put_flit.bits := AssembleFlit(
    put_flit_data,
    ID.U(SRC_BITS.W),
    1.U(VC_BITS.W),
    put_flit_dst,
    true.B,
    io.put_flit.valid
  )
  io.put_flit.valid := io.axi.aw.fire || io.axi.w.fire || io.axi.ar.fire

  // OutPort output signals
  io.get_flit.ready := (state === s_wresp1) || (state === s_rdata1)

  // Debug
  if (DEBUG_AXI4_BRIDGE) {
    when(io.put_flit.fire) {
      printf("%d: [AXI4 Bridge  %d] put_flit=%b\n", DebugTimer(), ID.U, io.put_flit.bits)
    }
    when(io.get_flit.fire) {
      printf("%d: [AXI4 Bridge  %d] get_flit=%b\n", DebugTimer(), ID.U, io.get_flit.bits)
    }
  }
}

class AXI4SlaveBridge(val ID: Int) extends Module with Config {
  val io = IO(new Bundle {
    val axi      = new AXI4IO
    val put_flit = Decoupled(UInt(AXI4FlitWidth().W))
    val get_flit = Flipped(Decoupled(UInt(AXI4FlitWidth().W)))
  })

  // State definitions
  val s_idle :: s_waddr :: s_wdata1 :: s_wdata2 :: s_wresp :: s_raddr :: s_rdata :: Nil = Enum(7)

  // FSM to handle AXI master device request & response
  val state = RegInit(s_idle)
  switch(state) {
    is(s_idle) {
      when(io.get_flit.fire) {
        when(GetIsWFromFlit(io.get_flit.bits)) {
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
      when(io.get_flit.valid) {
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

  // Put flit data
  val put_flit_data = WireInit(0.U(AXI4FlitDataWidth().W))
  when(io.axi.b.fire) {
    put_flit_data := AXI4ChannelB2FlitData(io.axi.b.bits)
  }.elsewhen(io.axi.r.fire) {
    put_flit_data := AXI4ChannelR2FlitData(io.axi.r.bits)
  }

  // Get flit register
  val get_flit = RegInit(0.U(AXI4FlitWidth().W))
  when(io.get_flit.fire) {
    get_flit := io.get_flit.bits
  }

  // AXI4 output signals
  io.axi.aw.bits  := Flit2AXI4ChannelA(get_flit)
  io.axi.aw.valid := (state === s_waddr)
  io.axi.w.bits   := Flit2AXI4ChannelW(get_flit)
  io.axi.w.valid  := (state === s_wdata2)
  io.axi.b.ready  := (state === s_wresp) && io.put_flit.ready
  io.axi.ar.bits  := Flit2AXI4ChannelA(get_flit)
  io.axi.ar.valid := (state === s_raddr)
  io.axi.r.ready  := (state === s_rdata) && io.put_flit.ready

  // InPort output signals, use VC 0
  io.put_flit.bits := AssembleFlit(
    put_flit_data,
    ID.U(SRC_BITS.W),
    0.U(VC_BITS.W),
    GetSrcFromFlit(get_flit),
    true.B,
    io.put_flit.valid
  )
  io.put_flit.valid := io.axi.b.fire || io.axi.r.fire

  // OutPort output signals
  io.get_flit.ready := (state === s_idle) || (state === s_wdata1)

  // Debug
  if (DEBUG_AXI4_BRIDGE) {
    when(io.put_flit.fire) {
      printf("%d: [AXI4 Bridge  %d] put_flit=%b\n", DebugTimer(), ID.U, io.put_flit.bits)
    }
    when(io.get_flit.fire) {
      printf("%d: [AXI4 Bridge  %d] get_flit=%b\n", DebugTimer(), ID.U, io.get_flit.bits)
    }
  }
}
