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
  ).max + AXI4ChannelID.AW.getWidth
}

object AXI4LitePacketDataWidth {
  def apply(): Int = List(
    (new AXI4LiteIO).aw.bits.getWidth,
    (new AXI4LiteIO).w.bits.getWidth,
    (new AXI4LiteIO).b.bits.getWidth,
    (new AXI4LiteIO).ar.bits.getWidth,
    (new AXI4LiteIO).r.bits.getWidth
  ).max + AXI4ChannelID.AW.getWidth
}

object AXI4StreamPacketDataWidth {
  def apply(): Int = (new AXI4StreamIO).t.bits.getWidth
}

// Customized by user
object GetDestFromAXI4ChannelA {
  def apply(a: AXI4LiteChannelA)(implicit p: NetworkConfigs): UInt = {
    if (a.getClass == classOf[AXI4ChannelA]) {
      val a_ = a.asInstanceOf[AXI4ChannelA]
      assert(p.DEST_BITS <= a_.user.getWidth)
      a_.user(p.DEST_BITS - 1, 0)
    } else {
      assert(p.DEST_BITS <= a.addr.getWidth)
      a.addr(p.DEST_BITS - 1, 0)
    }
  }
}

object GetDestFromAXI4StreamChannelT {
  def apply(t: AXI4StreamChannelT)(implicit p: NetworkConfigs): UInt = {
    assert(p.DEST_BITS <= t.dest.getWidth)
    t.dest(p.DEST_BITS - 1, 0)
  }
}

object GetChannelIDFromAXI4Packet {
  def apply(packet: UInt)(implicit p: NetworkConfigs): UInt = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    packet(2, 0)
  }
}

object GetSrcFromPacket {
  def apply(packet: UInt)(implicit p: NetworkConfigs): UInt = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    packet(p.PACKET_WIDTH - p.META_WIDTH + p.SRC_BITS - 1, p.PACKET_WIDTH - p.META_WIDTH)
  }
}

object AXI4ChannelA2PacketData {
  def apply[C <: AXI4LiteChannelA](a: C, is_w: Bool): UInt = {
    if (a.getClass == classOf[AXI4ChannelA]) {
      val a_ = a.asInstanceOf[AXI4ChannelA]
      Cat(
        a_.user,
        a_.id,
        a_.addr,
        a_.region,
        a_.qos,
        a_.prot,
        a_.cache,
        a_.lock.asUInt,
        a_.burst,
        a_.size,
        a_.len,
        Mux(is_w, AXI4ChannelID.AW, AXI4ChannelID.AR)
      )
    } else {
      Cat(
        a.addr,
        a.prot,
        Mux(is_w, AXI4ChannelID.AW, AXI4ChannelID.AR)
      )
    }
  }
}

object AXI4ChannelW2PacketData {
  def apply[C <: AXI4LiteChannelW](w: C): UInt = {
    if (w.getClass == classOf[AXI4ChannelW]) {
      val w_ = w.asInstanceOf[AXI4ChannelW]
      Cat(
        w_.user,
        w_.strb,
        w_.data,
        w_.last.asUInt,
        AXI4ChannelID.W
      )
    } else {
      Cat(
        w.strb,
        w.data,
        AXI4ChannelID.W
      )
    }
  }
}

object AXI4ChannelB2PacketData {
  def apply[C <: AXI4LiteChannelB](b: C): UInt = {
    if (b.getClass == classOf[AXI4ChannelB]) {
      val b_ = b.asInstanceOf[AXI4ChannelB]
      Cat(
        b_.user,
        b_.id,
        b_.resp,
        AXI4ChannelID.B
      )
    } else {
      Cat(
        b.resp,
        AXI4ChannelID.B
      )
    }
  }
}

object AXI4ChannelR2PacketData {
  def apply[C <: AXI4LiteChannelR](r: C): UInt = {
    if (r.getClass == classOf[AXI4ChannelR]) {
      val r_ = r.asInstanceOf[AXI4ChannelR]
      Cat(
        r_.user,
        r_.id,
        r_.data,
        r_.last.asUInt,
        r_.resp,
        AXI4ChannelID.R
      )
    } else {
      Cat(
        r.data,
        r.resp,
        AXI4ChannelID.R
      )
    }
  }
}

object Packet2AXI4ChannelA {
  def apply(packet: UInt)(implicit p: NetworkConfigs): AXI4LiteChannelA = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    if (p.PROTOCOL == "AXI4") {
      val a = Wire(new AXI4ChannelA)
      a.user := packet(
        31 + AXI4Parameters.AXI4AddrWidth + AXI4Parameters.AXI4IdWidth + AXI4Parameters.AXI4UserWidth,
        32 + AXI4Parameters.AXI4AddrWidth + AXI4Parameters.AXI4IdWidth
      )
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
    } else {
      val a = Wire(new AXI4LiteChannelA)
      a.addr := packet(5 + AXI4Parameters.AXI4AddrWidth, 6)
      a.prot := packet(5, 3)
      a
    }
  }
}

object Packet2AXI4ChannelW {
  def apply(packet: UInt)(implicit p: NetworkConfigs): AXI4LiteChannelW = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    if (p.PROTOCOL == "AXI4") {
      val w = Wire(new AXI4ChannelW)
      w.user := packet(
        3 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8 + AXI4Parameters.AXI4UserWidth,
        4 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8
      )
      w.strb := packet(
        3 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8,
        4 + AXI4Parameters.AXI4DataWidth
      )
      w.data := packet(3 + AXI4Parameters.AXI4DataWidth, 4)
      w.last := packet(3).asBool
      w
    } else {
      val w = Wire(new AXI4LiteChannelW)
      w.strb := packet(
        2 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8,
        3 + AXI4Parameters.AXI4DataWidth
      )
      w.data := packet(2 + AXI4Parameters.AXI4DataWidth, 3)
      w
    }
  }
}

object Packet2AXI4ChannelB {
  def apply(packet: UInt)(implicit p: NetworkConfigs): AXI4LiteChannelB = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    if (p.PROTOCOL == "AXI4") {
      val b = Wire(new AXI4ChannelB)
      b.user := packet(4 + AXI4Parameters.AXI4IdWidth + AXI4Parameters.AXI4UserWidth, 5 + AXI4Parameters.AXI4IdWidth)
      b.id   := packet(4 + AXI4Parameters.AXI4IdWidth, 5)
      b.resp := packet(4, 3)
      b
    } else {
      val b = Wire(new AXI4LiteChannelB)
      b.resp := packet(4, 3)
      b
    }
  }
}

object Packet2AXI4ChannelR {
  def apply(packet: UInt)(implicit p: NetworkConfigs): AXI4LiteChannelR = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    if (p.PROTOCOL == "AXI4") {
      val r = Wire(new AXI4ChannelR)
      r.user := packet(
        5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4IdWidth + AXI4Parameters.AXI4UserWidth,
        6 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4IdWidth
      )
      r.id := packet(
        5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4IdWidth,
        6 + AXI4Parameters.AXI4DataWidth
      )
      r.data := packet(5 + AXI4Parameters.AXI4DataWidth, 6)
      r.last := packet(5).asBool
      r.resp := packet(4, 3)
      r
    } else {
      val r = Wire(new AXI4LiteChannelR)
      r.data := packet(4 + AXI4Parameters.AXI4DataWidth, 5)
      r.resp := packet(4, 3)
      r
    }
  }
}

object AXI4StreamChannelT2PacketData {
  def apply(t: AXI4StreamChannelT): UInt = {
    Cat(t.user, t.id, t.keep, t.strb, t.data, t.last.asUInt, t.dest)
  }
}

object Packet2AXI4StreamChannelT {
  def apply(packet: UInt)(implicit p: NetworkConfigs): AXI4StreamChannelT = {
    assert(packet.getWidth == p.PACKET_WIDTH)
    val t = Wire(new AXI4StreamChannelT)
    t.user := packet(
      4 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 4 + AXI4Parameters.AXI4IdWidth + AXI4Parameters.AXI4UserWidth,
      5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 4 + AXI4Parameters.AXI4IdWidth
    )
    t.id := packet(
      4 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 4 + AXI4Parameters.AXI4IdWidth,
      5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 4
    )
    t.keep := packet(
      4 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 4,
      5 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8
    )
    t.strb := packet(
      4 + AXI4Parameters.AXI4DataWidth + AXI4Parameters.AXI4DataWidth / 8,
      5 + AXI4Parameters.AXI4DataWidth
    )
    t.data := packet(4 + AXI4Parameters.AXI4DataWidth, 5)
    t.last := packet(4).asBool
    t.dest := packet(3, 0)
    t
  }
}
