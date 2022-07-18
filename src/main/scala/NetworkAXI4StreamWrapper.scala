package connect_axi

import chisel3._

class NetworkAXI4StreamWrapper extends Module with Config {
  val io = IO(new Bundle {
    val master = Vec(NUM_MASTER_DEVICES, Flipped(new AXI4StreamIO))
    val slave  = Vec(NUM_SLAVE_DEVICES, new AXI4StreamIO)
  })

  // Each AXI4-Stream master device requires a send port
  assert(NUM_MASTER_DEVICES == NUM_USER_SEND_PORTS)

  // Each AXI4-Stream slave device requires a recv port
  assert(NUM_SLAVE_DEVICES == NUM_USER_RECV_PORTS)

  val simple_wrapper = Module(new NetworkSimpleWrapper(AXI4StreamPacketWidth()))

  for (i <- 0 until NUM_MASTER_DEVICES) {
    val bridge = Module(new AXI4StreamMasterBridge(i))
    bridge.io.axi      <> io.master(i)
    bridge.io.t_packet <> simple_wrapper.io.send(i)
  }

  for (i <- 0 until NUM_SLAVE_DEVICES) {
    val bridge = Module(new AXI4StreamSlaveBridge(i))
    bridge.io.axi      <> io.slave(i)
    bridge.io.t_packet <> simple_wrapper.io.recv(i)
  }
}
