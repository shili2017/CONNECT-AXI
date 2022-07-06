package connect_axi

import chisel3._
import chisel3.util._

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

object GetIsWFromPacket {
  def apply(packet: UInt): Bool = {
    assert(packet.getWidth == AXI4PacketWidth())
    packet(0).asBool
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
    is_w.asUInt
  )
}

object AXI4ChannelW2PacketData {
  def apply(w: AXI4ChannelW): UInt = Cat(
    w.strb,
    w.data,
    w.last.asUInt
  )
}

object AXI4ChannelB2PacketData {
  def apply(b: AXI4ChannelB): UInt = Cat(
    b.id,
    b.resp
  )
}

object AXI4ChannelR2PacketData {
  def apply(r: AXI4ChannelR): UInt = Cat(
    r.id,
    r.data,
    r.last.asUInt,
    r.resp
  )
}

object Packet2AXI4ChannelA {
  def apply(packet: UInt): AXI4ChannelA = {
    assert(packet.getWidth == AXI4PacketWidth())
    val a = Wire(new AXI4ChannelA)
    a.id     := packet(28 + AXI4Parameters.AXI4AddrWidth + AXI4Parameters.AXI4IdWidth, 29 + AXI4Parameters.AXI4AddrWidth)
    a.addr   := packet(28 + AXI4Parameters.AXI4AddrWidth, 29)
    a.region := packet(28, 25)
    a.qos    := packet(24, 21)
    a.prot   := packet(20, 18)
    a.cache  := packet(17, 14)
    a.lock   := packet(13).asBool
    a.burst  := packet(12, 11)
    a.size   := packet(10, 8)
    a.len    := packet(7, 0)
    a
  }
}

object Packet2AXI4ChannelW {
  def apply(packet: UInt): AXI4ChannelW = {
    assert(packet.getWidth == AXI4PacketWidth())
    val w = Wire(new AXI4ChannelW)
    w.strb := packet(AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8, 1 + AXI4Parameters.AXI4DataWidth)
    w.data := packet(AXI4Parameters.AXI4DataWidth, 1)
    w.last := packet(0).asBool
    w
  }
}

object Packet2AXI4ChannelB {
  def apply(packet: UInt): AXI4ChannelB = {
    assert(packet.getWidth == AXI4PacketWidth())
    val b = Wire(new AXI4ChannelB)
    b.id   := packet(1 + AXI4Parameters.AXI4IdWidth, 2)
    b.resp := packet(1, 0)
    b
  }
}

object Packet2AXI4ChannelR {
  def apply(packet: UInt): AXI4ChannelR = {
    assert(packet.getWidth == AXI4PacketWidth())
    val r = Wire(new AXI4ChannelR)
    r.id   := packet(2 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4IdWidth, 3 + AXI4Parameters.AXI4DataWidth)
    r.data := packet(2 + AXI4Parameters.AXI4DataWidth, 3)
    r.last := packet(2).asBool
    r.resp := packet(1, 0)
    r
  }
}

object AssemblePacket {
  def apply(data: UInt, src: UInt, vc: UInt, dst: UInt, tail: Bool, valid: Bool): UInt = Cat(
    valid.asUInt,
    tail.asUInt,
    dst,
    vc,
    src,
    data
  )
}
