package connect_axi

object TopMain extends App with Config {
  if (PROTOCOL == "AXI4" || PROTOCOL == "AXI4-Lite") {
    (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4Wrapper, args)
  } else {
    (new chisel3.stage.ChiselStage).emitVerilog(new NetworkSimpleWrapper, args)
  }
}
