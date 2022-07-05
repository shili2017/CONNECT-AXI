package connect_axi

import chisel3._
import chisel3.util._

trait AXI4Parameters {
  val AXI4AddrWidth = 32
  val AXI4DataWidth = 64
  val AXI4IdWidth   = 8
  val AXI4UserWidth = 8
}

object AXI4Parameters extends AXI4Parameters {}

trait AXI4Id extends Bundle with AXI4Parameters {
  val id = UInt(AXI4IdWidth.W)
}

trait AXI4User extends Bundle with AXI4Parameters {
  val user = UInt(AXI4UserWidth.W)
}

class AXI4ChannelA extends Bundle with AXI4Id {
  val addr   = UInt(AXI4AddrWidth.W)
  val len    = UInt(8.W)
  val size   = UInt(3.W)
  val burst  = UInt(2.W)
  val lock   = Bool()
  val cache  = UInt(4.W)
  val prot   = UInt(3.W)
  val qos    = UInt(4.W)
  val region = UInt(4.W)
}

class AXI4ChannelW extends Bundle with AXI4Parameters {
  val data = UInt(AXI4DataWidth.W)
  val strb = UInt((AXI4DataWidth / 8).W)
  val last = Bool()
}

class AXI4ChannelB extends Bundle with AXI4Id {
  val resp = UInt(2.W)
}

class AXI4ChannelR extends Bundle with AXI4Id {
  val data = UInt(AXI4DataWidth.W)
  val resp = UInt(2.W)
  val last = Bool()
}

class AXI4IO extends Bundle {
  val aw = Decoupled(new AXI4ChannelA)
  val w  = Decoupled(new AXI4ChannelW)
  val b  = Flipped(Decoupled(new AXI4ChannelB))
  val ar = Decoupled(new AXI4ChannelA)
  val r  = Flipped(Decoupled(new AXI4ChannelR))
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
