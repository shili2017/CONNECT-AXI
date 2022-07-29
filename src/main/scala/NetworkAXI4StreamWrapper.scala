package connect_axi

import chisel3._

class NetworkAXI4StreamWrapper(implicit p: NetworkConfigs) extends Module {
  // p.PROTOCOL specification
  assert(p.PROTOCOL == "AXI4-Stream")

  val io = IO(new Bundle {
    val master    = Vec(p.NUM_MASTER_DEVICES, Flipped(new AXI4StreamIO))
    val slave     = Vec(p.NUM_SLAVE_DEVICES, new AXI4StreamIO)
    val clock_noc = Input(Clock())
  })

  // Each AXI4-Stream master device requires a send port
  assert(p.NUM_MASTER_DEVICES == p.NUM_USER_SEND_PORTS)

  // Each AXI4-Stream slave device requires a recv port
  assert(p.NUM_SLAVE_DEVICES == p.NUM_USER_RECV_PORTS)

  val simple_wrapper = Module(new NetworkSimpleWrapper())
  simple_wrapper.io.clock_noc := io.clock_noc

  for (i <- 0 until p.NUM_MASTER_DEVICES) {
    val bridge = Module(new AXI4StreamMasterBridge(i))
    bridge.io.axi      <> io.master(i)
    bridge.io.t_packet <> simple_wrapper.io.send(i)
  }

  for (i <- 0 until p.NUM_SLAVE_DEVICES) {
    val bridge = Module(new AXI4StreamSlaveBridge(i))
    bridge.io.axi      <> io.slave(i)
    bridge.io.t_packet <> simple_wrapper.io.recv(i)
  }
}
