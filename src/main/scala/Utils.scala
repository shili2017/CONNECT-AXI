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

object ZeroExt32_64 {
  def apply(x: UInt): UInt = Cat(Fill(32, 0.U), x)
}

object HoldUnless {
  def apply[T <: Data](x: T, en: Bool): T = {
    Mux(en, x, RegEnable(x, 0.U.asTypeOf(x), en))
  }
}

object Assemble {
  def apply(data: UInt, src: UInt, vc: UInt, dst: UInt, tail: Bool, valid: Bool): UInt = Cat(
    valid.asUInt,
    tail.asUInt,
    dst,
    vc,
    src,
    data
  )
}

object GetVC {
  def apply(flit: UInt): UInt = {
    assert(flit.getWidth == Config.FLIT_WIDTH)
    flit(Config.FLIT_DATA_WIDTH + Config.SRC_BITS + Config.VC_BITS - 1, Config.FLIT_DATA_WIDTH + Config.SRC_BITS)
  }
}
