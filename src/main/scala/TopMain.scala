package connect_axi

object TopMain extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Top, args)
}
