package connect_axi

import chisel3._
import chisel3.util._
import chipsalliance.rocketchip.config._

class NetworkSimpleWrapper(implicit p: Parameters) extends Module {
  val io = IO(new Bundle {
    val send = Vec(p(NUM_USER_SEND_PORTS), Flipped(Decoupled(UInt(p(SIMPLE_PACKET_WIDTH).W))))
    val recv = Vec(p(NUM_USER_RECV_PORTS), Decoupled(UInt(p(SIMPLE_PACKET_WIDTH).W)))
  })

  val network = Module(new Network)

  for (i <- 0 until p(NUM_USER_SEND_PORTS)) {
    val p_                = p.alterPartial({ case DEVICE_ID => i })
    val serializer        = Module(new FlitSerializer(p(SIMPLE_PACKET_WIDTH), p(FLIT_WIDTH), 0)(p_))
    val flow_control_send = Module(new FlitFlowControlSend)
    serializer.io.in_packet      <> io.send(i)
    serializer.io.clock_noc      := clock
    flow_control_send.io.flit(0) <> serializer.io.out_flit
    for (j <- 1 until p(NUM_VCS)) {
      flow_control_send.io.flit(j).bits  := 0.U
      flow_control_send.io.flit(j).valid := false.B
    }
    network.io.send(i) <> flow_control_send.io.send
  }

  for (i <- 0 until p(NUM_USER_RECV_PORTS)) {
    val p_                = p.alterPartial({ case DEVICE_ID => i })
    val deserializer      = Module(new FlitDeserializer(p(FLIT_WIDTH), p(SIMPLE_PACKET_WIDTH), 0)(p_))
    val flow_control_recv = Module(new FlitFlowControlRecv)
    io.recv(i)                <> deserializer.io.out_packet
    deserializer.io.clock_noc := clock
    deserializer.io.in_flit   <> flow_control_recv.io.flit(0)
    for (j <- 1 until p(NUM_VCS)) {
      flow_control_recv.io.flit(j).ready := false.B
    }
    flow_control_recv.io.recv <> network.io.recv(i)
  }
}
