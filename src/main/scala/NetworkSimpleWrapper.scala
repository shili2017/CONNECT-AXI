package connect_axi

import chisel3._
import chisel3.util._
import chipsalliance.rocketchip.config._

class NetworkSimpleWrapper(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val send      = Vec(p(NUM_USER_SEND_PORTS), Flipped(Decoupled(UInt(p(PACKET_WIDTH).W))))
    val recv      = Vec(p(NUM_USER_RECV_PORTS), Decoupled(UInt(p(PACKET_WIDTH).W)))
    val clock_noc = Input(Clock())
  })

  val network = Module(new Network)
  network.clock := io.clock_noc

  for (i <- 0 until p(NUM_USER_SEND_PORTS)) {
    val p_ = p.alterPartial({
      case DEVICE_ID => i
    })

    val serializer        = Module(new FlitSerializer()(p_.alterPartial({ case FIFO_VC => 0 })))
    val flow_control_send = Module(new FlitFlowControlSend)

    serializer.io.clock_noc      := io.clock_noc
    flow_control_send.clock      := io.clock_noc
    serializer.io.in_packet      <> io.send(i)
    flow_control_send.io.flit(0) <> serializer.io.out_flit

    for (j <- 1 until p(NUM_VCS)) {
      flow_control_send.io.flit(j).bits  := 0.U
      flow_control_send.io.flit(j).valid := false.B
    }
    network.io.send(i) <> flow_control_send.io.send
  }

  for (i <- 0 until p(NUM_USER_RECV_PORTS)) {
    val p_ = p.alterPartial({
      case DEVICE_ID => i
    })

    val deserializer      = Module(new FlitDeserializer()(p_.alterPartial({ case FIFO_VC => 0 })))
    val flow_control_recv = Module(new FlitFlowControlRecv)

    deserializer.io.clock_noc    := io.clock_noc
    flow_control_recv.clock      := io.clock_noc
    deserializer.io.out_packet   <> io.recv(i)
    flow_control_recv.io.flit(0) <> deserializer.io.in_flit

    for (j <- 1 until p(NUM_VCS)) {
      flow_control_recv.io.flit(j).ready := false.B
    }
    network.io.recv(i) <> flow_control_recv.io.recv
  }
}
