package connect_axi

import chisel3._
import chisel3.util._

trait AXI4Parameters {
  val AXI4AddrWidth = 32
  val AXI4DataWidth = 64
  val AXI4IdWidth   = 8
  val AXI4UserWidth = 8 // Not used
}

object AXI4Parameters extends AXI4Parameters {}

trait AXI4Id extends Bundle with AXI4Parameters {
  val id = UInt(AXI4IdWidth.W)
}

trait AXI4User extends Bundle with AXI4Parameters {
  val user = UInt(AXI4UserWidth.W)
}

class AXI4LiteChannelA extends Bundle with AXI4Parameters {
  val addr = UInt(AXI4AddrWidth.W)
  val prot = UInt(3.W)
}

class AXI4ChannelA extends AXI4LiteChannelA with AXI4Id {
  val len    = UInt(8.W)
  val size   = UInt(3.W)
  val burst  = UInt(2.W)
  val lock   = Bool()
  val cache  = UInt(4.W)
  val qos    = UInt(4.W)
  val region = UInt(4.W)
}

class AXI4LiteChannelW extends Bundle with AXI4Parameters {
  val data = UInt(AXI4DataWidth.W)
  val strb = UInt((AXI4DataWidth / 8).W)
}

class AXI4ChannelW extends AXI4LiteChannelW {
  val last = Bool()
}

class AXI4LiteChannelB extends Bundle {
  val resp = UInt(2.W)
}

class AXI4ChannelB extends AXI4LiteChannelB with AXI4Id {}

class AXI4LiteChannelR extends Bundle with AXI4Parameters {
  val data = UInt(AXI4DataWidth.W)
  val resp = UInt(2.W)
}

class AXI4ChannelR extends AXI4LiteChannelR with AXI4Id {
  val last = Bool()
}

class AXI4LiteIO extends Bundle {
  val aw = Decoupled(new AXI4LiteChannelA)
  val w  = Decoupled(new AXI4LiteChannelW)
  val b  = Flipped(Decoupled(new AXI4LiteChannelB))
  val ar = Decoupled(new AXI4LiteChannelA)
  val r  = Flipped(Decoupled(new AXI4LiteChannelR))
}

class AXI4IO extends AXI4LiteIO {
  override val aw = Decoupled(new AXI4ChannelA)
  override val w  = Decoupled(new AXI4ChannelW)
  override val b  = Flipped(Decoupled(new AXI4ChannelB))
  override val ar = Decoupled(new AXI4ChannelA)
  override val r  = Flipped(Decoupled(new AXI4ChannelR))
}

class AXI4StreamChannelT extends Bundle with AXI4Id {
  val data = UInt(AXI4DataWidth.W)
  val strb = UInt((AXI4DataWidth / 8).W)
  val keep = UInt((AXI4DataWidth / 8).W)
  val last = Bool()
  val dest = UInt(4.W)
}

class AXI4StreamIO extends Bundle {
  val t = Decoupled(new AXI4StreamChannelT)
}
