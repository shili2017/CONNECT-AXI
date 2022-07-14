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

object ZeroExtend {
  def apply(x: UInt, width: Int): UInt = {
    if (x.getWidth > width) {
      assert(false, "Truncate x in ZeroExtend\n")
      x(width - 1, 0)
    } else if (x.getWidth == width) {
      x
    } else {
      Cat(Fill(width - x.getWidth, 0.U), x)
    }
  }
}

object HoldUnless {
  def apply[T <: Data](x: T, en: Bool): T = {
    Mux(en, x, RegEnable(x, 0.U.asTypeOf(x), en))
  }
}

object Assemble {
  def apply(data_width: Int)(data: UInt, src: UInt, vc: UInt, dst: UInt, tail: Bool, valid: Bool): UInt = {
    assert(src.getWidth == Config.SRC_BITS)
    assert(vc.getWidth == Config.VC_BITS)
    assert(dst.getWidth == Config.DEST_BITS)
    Cat(
      valid.asUInt,
      tail.asUInt,
      dst,
      vc,
      src,
      ZeroExtend(data, data_width)
    )
  }
}

object GetVC {
  def apply(flit: UInt): UInt = {
    assert(flit.getWidth == Config.FLIT_WIDTH)
    flit(Config.FLIT_DATA_WIDTH + Config.SRC_BITS + Config.VC_BITS - 1, Config.FLIT_DATA_WIDTH + Config.SRC_BITS)
  }
}
