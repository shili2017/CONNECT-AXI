package connect_axi

import chipsalliance.rocketchip.config._

object TopMain extends App {
  implicit val p: Config = (new MyConfig).toInstance

  if (p(PROTOCOL) == "AXI4" || p(PROTOCOL) == "AXI4-Lite") {
    (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4Wrapper, args)
  } else if (p(PROTOCOL) == "AXI4-Stream") {
    (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4StreamWrapper, args)
  } else {
    (new chisel3.stage.ChiselStage).emitVerilog(new NetworkSimpleWrapper(80), args)
  }
}
