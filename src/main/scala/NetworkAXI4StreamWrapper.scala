package connect_axi

import chisel3._
import chipsalliance.rocketchip.config._

class NetworkAXI4StreamWrapper(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val master = Vec(p(NUM_MASTER_DEVICES), Flipped(new AXI4StreamIO))
    val slave  = Vec(p(NUM_SLAVE_DEVICES), new AXI4StreamIO)
  })

  // Each AXI4-Stream master device requires a send port
  assert(p(NUM_MASTER_DEVICES) == p(NUM_USER_SEND_PORTS))

  // Each AXI4-Stream slave device requires a recv port
  assert(p(NUM_SLAVE_DEVICES) == p(NUM_USER_RECV_PORTS))

  val simple_wrapper = Module(new NetworkSimpleWrapper()(p.alterPartial({
    case SIMPLE_PACKET_WIDTH => AXI4StreamPacketWidth()
  })))

  for (i <- 0 until p(NUM_MASTER_DEVICES)) {
    val p_     = p.alterPartial({ case DEVICE_ID => i })
    val bridge = Module(new AXI4StreamMasterBridge()(p_))
    bridge.io.axi      <> io.master(i)
    bridge.io.t_packet <> simple_wrapper.io.send(i)
  }

  for (i <- 0 until p(NUM_SLAVE_DEVICES)) {
    val p_     = p.alterPartial({ case DEVICE_ID => i })
    val bridge = Module(new AXI4StreamSlaveBridge()(p_))
    bridge.io.axi      <> io.slave(i)
    bridge.io.t_packet <> simple_wrapper.io.recv(i)
  }
}
