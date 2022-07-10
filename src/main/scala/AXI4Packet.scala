package connect_axi

import chisel3._
import chisel3.util._

object AXI4ChannelID {
  val AW = 0.U(3.W)
  val W  = 1.U(3.W)
  val B  = 2.U(3.W)
  val AR = 3.U(3.W)
  val R  = 4.U(3.W)
}

object AXI4PacketDataWidth {
  def apply(): Int = List(
    (new AXI4IO).aw.bits.getWidth,
    (new AXI4IO).w.bits.getWidth,
    (new AXI4IO).b.bits.getWidth,
    (new AXI4IO).ar.bits.getWidth,
    (new AXI4IO).r.bits.getWidth
  ).max + 1
}

object AXI4PacketWidth extends Config {
  def apply(): Int = AXI4PacketDataWidth() + SRC_BITS + DEST_BITS + VC_BITS + 2
}

object AXI4StreamPacketDataWidth {
  def apply(): Int = (new AXI4StreamIO).t.bits.getWidth
}

object AXI4StreamPacketWidth extends Config {
  def apply(): Int = AXI4StreamPacketDataWidth() + SRC_BITS + DEST_BITS + VC_BITS + 2
}
object GetDestFromAXI4ChannelA extends Config {
  def apply(a: AXI4ChannelA): UInt = a.addr(DEST_BITS - 1, 0)
}

object GetChannelIDFromPacket {
  def apply(packet: UInt): UInt = {
    assert(packet.getWidth == AXI4PacketWidth())
    packet(2, 0)
  }
}

object GetSrcFromPacket extends Config {
  def apply(packet: UInt): UInt = {
    assert(packet.getWidth == AXI4PacketWidth())
    packet(AXI4PacketDataWidth() + SRC_BITS - 1, AXI4PacketDataWidth())
  }
}

object AXI4ChannelA2PacketData {
  def apply(a: AXI4ChannelA, is_w: Bool): UInt = Cat(
    a.id,
    a.addr,
    a.region,
    a.qos,
    a.prot,
    a.cache,
    a.lock.asUInt,
    a.burst,
    a.size,
    a.len,
    Mux(is_w, AXI4ChannelID.AW, AXI4ChannelID.AR)
  )
}

object AXI4ChannelW2PacketData {
  def apply(w: AXI4ChannelW): UInt = Cat(
    w.strb,
    w.data,
    w.last.asUInt,
    AXI4ChannelID.W
  )
}

object AXI4ChannelB2PacketData {
  def apply(b: AXI4ChannelB): UInt = Cat(
    b.id,
    b.resp,
    AXI4ChannelID.B
  )
}

object AXI4ChannelR2PacketData {
  def apply(r: AXI4ChannelR): UInt = Cat(
    r.id,
    r.data,
    r.last.asUInt,
    r.resp,
    AXI4ChannelID.R
  )
}

object Packet2AXI4ChannelA {
  def apply(packet: UInt): AXI4ChannelA = {
    assert(packet.getWidth == AXI4PacketWidth())
    val a = Wire(new AXI4ChannelA)
    a.id := packet(
      31 + AXI4Parameters.AXI4AddrWidth + AXI4Parameters.AXI4IdWidth,
      32 + AXI4Parameters.AXI4AddrWidth
    )
    a.addr   := packet(31 + AXI4Parameters.AXI4AddrWidth, 32)
    a.region := packet(31, 28)
    a.qos    := packet(27, 24)
    a.prot   := packet(23, 21)
    a.cache  := packet(20, 17)
    a.lock   := packet(16).asBool
    a.burst  := packet(15, 14)
    a.size   := packet(13, 11)
    a.len    := packet(10, 3)
    a
  }
}

object Packet2AXI4ChannelW {
  def apply(packet: UInt): AXI4ChannelW = {
    assert(packet.getWidth == AXI4PacketWidth())
    val w = Wire(new AXI4ChannelW)
    w.strb := packet(
      3 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8,
      4 + AXI4Parameters.AXI4DataWidth
    )
    w.data := packet(3 + AXI4Parameters.AXI4DataWidth, 4)
    w.last := packet(3).asBool
    w
  }
}

object Packet2AXI4ChannelB {
  def apply(packet: UInt): AXI4ChannelB = {
    assert(packet.getWidth == AXI4PacketWidth())
    val b = Wire(new AXI4ChannelB)
    b.id   := packet(4 + AXI4Parameters.AXI4IdWidth, 5)
    b.resp := packet(4, 3)
    b
  }
}

object Packet2AXI4ChannelR {
  def apply(packet: UInt): AXI4ChannelR = {
    assert(packet.getWidth == AXI4PacketWidth())
    val r = Wire(new AXI4ChannelR)
    r.id := packet(
      5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4IdWidth,
      6 + AXI4Parameters.AXI4DataWidth
    )
    r.data := packet(5 + AXI4Parameters.AXI4DataWidth, 6)
    r.last := packet(5).asBool
    r.resp := packet(4, 3)
    r
  }
}
