package connect_axi

import chisel3._
import chisel3.util._

object DebugTimer {
  def apply() = {
    val c = RegInit(0.U(64.W))
    c := c + 1.U
    c
  }
}

object AXI4FlitDataWidth {
  def apply(): Int = List(
    (new AXI4IO).aw.bits.getWidth,
    (new AXI4IO).w.bits.getWidth,
    (new AXI4IO).b.bits.getWidth,
    (new AXI4IO).ar.bits.getWidth,
    (new AXI4IO).r.bits.getWidth
  ).max + 1
}

object AXI4FlitWidth extends Config {
  def apply(): Int = AXI4FlitDataWidth() + SRC_BITS + DEST_BITS + VC_BITS + 2
}

object AXI4StreamFlitDataWidth {
  def apply(): Int = (new AXI4StreamIO).t.bits.getWidth
}

object AXI4StreamFlitWidth extends Config {
  def apply(): Int = AXI4StreamFlitDataWidth() + SRC_BITS + DEST_BITS + VC_BITS + 2
}

object ZeroExt32_64 {
  def apply(x: UInt): UInt = Cat(Fill(32, 0.U), x)
}

object HoldUnless {
  def apply[T <: Data](x: T, en: Bool): T = {
    Mux(en, x, RegEnable(x, 0.U.asTypeOf(x), en))
  }
}

object GetDestFromAXI4ChannelA extends Config {
  def apply(a: AXI4ChannelA): UInt = a.addr(DEST_BITS - 1, 0)
}

object GetIsWFromFlit {
  def apply(flit: UInt): Bool = {
    assert(flit.getWidth == AXI4FlitWidth())
    flit(AXI4FlitDataWidth() - 1).asBool
  }
}

object GetSrcFromFlit extends Config {
  def apply(flit: UInt): UInt = {
    assert(flit.getWidth == AXI4FlitWidth())
    flit(AXI4FlitDataWidth() + SRC_BITS - 1, AXI4FlitDataWidth())
  }
}

object AXI4ChannelA2FlitData {
  def apply(a: AXI4ChannelA, is_w: Bool): UInt = Cat(
    is_w.asUInt,
    a.id,
    Fill(6, 0.U),
    a.region,
    a.qos,
    a.prot,
    a.cache,
    a.lock.asUInt,
    a.burst,
    a.size,
    a.len,
    a.addr
  )
}

object AXI4ChannelW2FlitData {
  def apply(w: AXI4ChannelW): UInt = Cat(
    1.U,
    Fill(2, 0.U),
    w.last.asUInt,
    w.strb,
    w.data
  )
}

object AXI4ChannelB2FlitData {
  def apply(b: AXI4ChannelB): UInt = Cat(
    1.U,
    b.id,
    0.U,
    b.resp,
    Fill(64, 0.U)
  )
}

object AXI4ChannelR2FlitData {
  def apply(r: AXI4ChannelR): UInt = Cat(
    0.U,
    r.id,
    r.last.asUInt,
    r.resp,
    r.data
  )
}

object Flit2AXI4ChannelA {
  def apply(flit: UInt): AXI4ChannelA = {
    assert(flit.getWidth == AXI4FlitWidth())
    val a = Wire(new AXI4ChannelA)
    a.id     := flit(74, 67)
    a.region := flit(60, 57)
    a.qos    := flit(56, 53)
    a.prot   := flit(52, 50)
    a.cache  := flit(49, 46)
    a.lock   := flit(45).asBool
    a.burst  := flit(44, 43)
    a.size   := flit(42, 40)
    a.len    := flit(39, 32)
    a.addr   := flit(31, 0)
    a
  }
}

object Flit2AXI4ChannelW {
  def apply(flit: UInt): AXI4ChannelW = {
    assert(flit.getWidth == AXI4FlitWidth())
    val w = Wire(new AXI4ChannelW)
    w.last := flit(72).asBool
    w.strb := flit(71, 64)
    w.data := flit(63, 0)
    w
  }
}

object Flit2AXI4ChannelB {
  def apply(flit: UInt): AXI4ChannelB = {
    assert(flit.getWidth == AXI4FlitWidth())
    val b = Wire(new AXI4ChannelB)
    b.id   := flit(74, 67)
    b.resp := flit(65, 64)
    b
  }
}

object Flit2AXI4ChannelR {
  def apply(flit: UInt): AXI4ChannelR = {
    assert(flit.getWidth == AXI4FlitWidth())
    val r = Wire(new AXI4ChannelR)
    r.id   := flit(74, 67)
    r.last := flit(66).asBool
    r.resp := flit(65, 64)
    r.data := flit(63, 0)
    r
  }
}

object AssembleFlit {
  def apply(data: UInt, src: UInt, vc: UInt, dst: UInt, tail: Bool, valid: Bool): UInt = Cat(
    valid.asUInt,
    tail.asUInt,
    dst,
    vc,
    src,
    data
  )
}
