package connect_axi

object TopMain extends App {
  // Pass protocol parameter from sbt command line interface
  val protocol = args(0)
  assert(Seq("AXI4", "AXI4-Lite", "AXI4-Stream", "Simple").contains(protocol))

  // Configs
  val network_configs = GetImplicitNetworkConfigs(protocol)

  // Emit Verilog RTL
  protocol match {
    case "AXI4" | "AXI4-Lite" =>
      (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4Wrapper()(network_configs), args)
    case "AXI4-Stream" =>
      (new chisel3.stage.ChiselStage).emitVerilog(new NetworkAXI4StreamWrapper()(network_configs), args)
    case "Simple" => (new chisel3.stage.ChiselStage).emitVerilog(new NetworkSimpleWrapper()(network_configs), args)
  }
}

object GetImplicitNetworkConfigs {
  def apply(protocol: String): NetworkConfigs = {
    val connect_configs = new Configs(ConnectConfig())
    new NetworkConfigs(new Configs(ConnectConfig() ++ LibraryConfig() ++ (protocol match {
      case "AXI4"        => AXI4WrapperConfig(connect_configs)
      case "AXI4-Lite"   => AXI4LiteWrapperConfig(connect_configs)
      case "AXI4-Stream" => AXI4StreamWrapperConfig(connect_configs)
      case "Simple"      => SimpleWrapperConfig(connect_configs)
    })))
  }
}
