package connect_axi

import chisel3._
import chisel3.util._
import chipsalliance.rocketchip.config._

class AXI4StreamMasterBridge(val ID: Int)(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = Flipped(new AXI4StreamIO)
    // T channel at VC0, output
    val t_packet = Decoupled(UInt(AXI4StreamPacketWidth().W))
  })

  // Channel T packet
  io.t_packet.bits := Assemble(AXI4StreamPacketDataWidth())(
    AXI4StreamChannelT2PacketData(io.axi.t.bits).asTypeOf(UInt(AXI4StreamPacketDataWidth().W)),
    ID.U(p(SRC_BITS).W),
    0.U(p(VC_BITS).W),
    GetDestFromAXI4StreamChannelT(io.axi.t.bits),
    true.B,
    io.t_packet.valid
  )
  io.t_packet.valid := io.axi.t.valid
  io.axi.t.ready    := io.t_packet.ready

  // Debug
  if (p(DEBUG_AXI4_BRIDGE)) {
    when(io.axi.t.fire) {
      printf("%d: [AXI4 Bridge-M%d] t  data=%b\n", DebugTimer(), ID.U, io.axi.t.bits.data)
    }
    when(io.t_packet.fire) {
      printf("%d: [AXI4 Bridge-M%d] t_packet =%b\n", DebugTimer(), ID.U, io.t_packet.bits)
    }
  }
}

class AXI4StreamSlaveBridge(val ID: Int)(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val axi = new AXI4StreamIO
    // T channel at VC0, input
    val t_packet = Flipped(Decoupled(UInt(AXI4StreamPacketWidth().W)))
  })

  // Channel W packet
  io.axi.t.bits     := Packet2AXI4StreamChannelT(io.t_packet.bits)
  io.axi.t.valid    := io.t_packet.valid
  io.t_packet.ready := io.axi.t.ready

  // Debug
  if (p(DEBUG_AXI4_BRIDGE)) {
    when(io.axi.t.fire) {
      printf("%d: [AXI4 Bridge-S%d] t  data=%b\n", DebugTimer(), ID.U, io.axi.t.bits.data)
    }
    when(io.t_packet.fire) {
      printf("%d: [AXI4 Bridge-S%d] t_packet =%b\n", DebugTimer(), ID.U, io.t_packet.bits)
    }
  }
}
