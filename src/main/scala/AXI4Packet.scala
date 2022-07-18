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
  def apply[B <: AXI4LiteIO](bus_io: B): Int = List(
    bus_io.aw.bits.getWidth,
    bus_io.w.bits.getWidth,
    bus_io.b.bits.getWidth,
    bus_io.ar.bits.getWidth,
    bus_io.r.bits.getWidth
  ).max + AXI4ChannelID.AW.getWidth
}

object AXI4PacketWidth extends Config {
  def apply[B <: AXI4LiteIO](bus_io: B): Int = AXI4PacketDataWidth(bus_io) + SRC_BITS + DEST_BITS + VC_BITS + 2
}

object AXI4StreamPacketDataWidth {
  def apply(): Int = (new AXI4StreamIO).t.bits.getWidth
}

object AXI4StreamPacketWidth extends Config {
  def apply(): Int = AXI4StreamPacketDataWidth() + SRC_BITS + DEST_BITS + VC_BITS + 2
}

// Customized by user
object GetDestFromAXI4ChannelA extends Config {
  def apply(a: AXI4LiteChannelA): UInt = {
    assert(DEST_BITS <= a.addr.getWidth)
    a.addr(DEST_BITS - 1, 0)
  }
}

object GetDestFromAXI4StreamChannelT extends Config {
  def apply(t: AXI4StreamChannelT): UInt = {
    assert(DEST_BITS <= t.dest.getWidth)
    t.dest(DEST_BITS - 1, 0)
  }
}

object GetChannelIDFromAXI4Packet {
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): UInt = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    packet(2, 0)
  }
}

object GetSrcFromPacket extends Config {
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): UInt = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    packet(AXI4PacketDataWidth(bus_io) + SRC_BITS - 1, AXI4PacketDataWidth(bus_io))
  }
}

object AXI4ChannelA2PacketData {
  def apply[C <: AXI4LiteChannelA](a: C, is_w: Bool): UInt = {
    if (a.getClass == classOf[AXI4ChannelA]) {
      val a_ = a.asInstanceOf[AXI4ChannelA]
      Cat(
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
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): AXI4LiteChannelA = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    if (bus_io.getClass == classOf[AXI4IO]) {
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
    } else {
      val a = Wire(new AXI4LiteChannelA)
      a.addr := packet(5 + AXI4Parameters.AXI4AddrWidth, 6)
      a.prot := packet(5, 3)
      a
    }
  }
}

object Packet2AXI4ChannelW {
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): AXI4LiteChannelW = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    if (bus_io.getClass == classOf[AXI4IO]) {
      val w = Wire(new AXI4ChannelW)
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
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): AXI4LiteChannelB = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    if (bus_io.getClass == classOf[AXI4IO]) {
      val b = Wire(new AXI4ChannelB)
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
  def apply[B <: AXI4LiteIO](bus_io: B)(packet: UInt): AXI4LiteChannelR = {
    assert(packet.getWidth == AXI4PacketWidth(bus_io))
    if (bus_io.getClass == classOf[AXI4IO]) {
      val r = Wire(new AXI4ChannelR)
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
    Cat(t.id, t.keep, t.strb, t.data, t.last.asUInt, t.dest)
  }
}

object Packet2AXI4StreamChannelT {
  def apply(packet: UInt): AXI4StreamChannelT = {
    assert(packet.getWidth == AXI4StreamPacketWidth())
    val t = Wire(new AXI4StreamChannelT)
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
