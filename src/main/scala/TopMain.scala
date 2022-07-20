package connect_axi

import chipsalliance.rocketchip.config._

object TopMain extends App {
  // Pass protocol parameter from sbt command line interface
  val protocol = args(0)
  assert(Seq("AXI4", "AXI4-Lite", "AXI4-Stream", "Simple").contains(protocol))

  // Implicit parameters
  implicit val p: Config = (protocol match {
    case "AXI4"        => new AXI4Config
    case "AXI4-Lite"   => new AXI4LiteConfig
    case "AXI4-Stream" => new AXI4StreamConfig
    case "Simple"      => new SimpleConfig
  }).toInstance

  protocol match {
    case "AXI4" | "AXI4-Lite" => (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4Wrapper, args)
    case "AXI4-Stream"        => (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4StreamWrapper, args)
    case "Simple"             => (new chisel3.stage.ChiselStage).emitVerilog(new NetworkSimpleWrapper, args)
  }
}
