package connect_axi

object TopMain extends App with Config {
  val wrapper =
    if (PROTOCOL == "AXI4" || PROTOCOL == "AXI4-Lite") {
      new NetworkAXI4Wrapper
    } else {
      new NetworkSimpleWrapper
    }
  (new chisel3.stage.ChiselStage).emitVerilog(wrapper, args)
}
