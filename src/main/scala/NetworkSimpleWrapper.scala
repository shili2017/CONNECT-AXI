package connect_axi

import chisel3._
import chisel3.util.Decoupled

class NetworkSimpleWrapper(PACKET_WIDTH: Int = Config.SIMPLE_PACKET_WIDTH) extends Module with Config {
  val io = IO(new Bundle {
    val send = Vec(NUM_USER_SEND_PORTS, Flipped(Decoupled(UInt(PACKET_WIDTH.W))))
    val recv = Vec(NUM_USER_RECV_PORTS, Decoupled(UInt(PACKET_WIDTH.W)))
  })

  val network = Module(new Network)

  for (i <- 0 until NUM_USER_SEND_PORTS) {
    val serializer        = Module(new FlitSerializer(i, PACKET_WIDTH, FLIT_WIDTH, 0))
    val flow_control_send = Module(new FlitFlowControlSend)
    serializer.io.in_packet      <> io.send(i)
    serializer.io.clock_noc      := clock
    flow_control_send.io.flit(0) <> serializer.io.out_flit
    for (j <- 1 until NUM_VCS) {
      flow_control_send.io.flit(j).bits  := 0.U
      flow_control_send.io.flit(j).valid := false.B
    }
    network.io.send(i) <> flow_control_send.io.send
  }

  for (i <- 0 until NUM_USER_RECV_PORTS) {
    val deserializer      = Module(new FlitDeserializer(i, FLIT_WIDTH, PACKET_WIDTH, 0))
    val flow_control_recv = Module(new FlitFlowControlRecv)
    io.recv(i)                <> deserializer.io.out_packet
    deserializer.io.clock_noc := clock
    deserializer.io.in_flit   <> flow_control_recv.io.flit(0)
    for (j <- 1 until NUM_VCS) {
      flow_control_recv.io.flit(j).ready := false.B
    }
    flow_control_recv.io.recv <> network.io.recv(i)
  }
}
