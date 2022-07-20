package connect_axi

import chisel3._
import chipsalliance.rocketchip.config._

class NetworkAXI4StreamWrapper(implicit p: Parameters) extends Module {
  // Protocol specification
  assert(p(PROTOCOL) == "AXI4-Stream")

  val p_ = p.alterPartial({
    case PACKET_WIDTH => AXI4StreamPacketWidth()
  })

  val io = IO(new Bundle {
    val master = Vec(p_(NUM_MASTER_DEVICES), Flipped(new AXI4StreamIO))
    val slave  = Vec(p_(NUM_SLAVE_DEVICES), new AXI4StreamIO)
  })

  // Each AXI4-Stream master device requires a send port
  assert(p_(NUM_MASTER_DEVICES) == p_(NUM_USER_SEND_PORTS))

  // Each AXI4-Stream slave device requires a recv port
  assert(p_(NUM_SLAVE_DEVICES) == p_(NUM_USER_RECV_PORTS))

  val simple_wrapper = Module(new NetworkSimpleWrapper()(p_))

  for (i <- 0 until p_(NUM_MASTER_DEVICES)) {
    val bridge = Module(new AXI4StreamMasterBridge()(p_.alterPartial({
      case DEVICE_ID => i
    })))
    bridge.io.axi      <> io.master(i)
    bridge.io.t_packet <> simple_wrapper.io.send(i)
  }

  for (i <- 0 until p_(NUM_SLAVE_DEVICES)) {
    val bridge = Module(new AXI4StreamSlaveBridge()(p_.alterPartial({
      case DEVICE_ID => i
    })))
    bridge.io.axi      <> io.slave(i)
    bridge.io.t_packet <> simple_wrapper.io.recv(i)
  }
}
