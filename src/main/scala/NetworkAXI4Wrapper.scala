package connect_axi

import chisel3._

class NetworkAXI4Wrapper(AXI4_PROTOCOL: String = Config.PROTOCOL) extends Module with Config {
  // Protocol specification
  assert(AXI4_PROTOCOL == "AXI4" || AXI4_PROTOCOL == "AXI4-Lite")

  val bus_io = if (AXI4_PROTOCOL == "AXI4") new AXI4IO else new AXI4LiteIO

  val io = IO(new Bundle {
    val master = Vec(NUM_MASTER_DEVICES, Flipped(bus_io))
    val slave  = Vec(NUM_SLAVE_DEVICES, bus_io)
  })

  // Each AXI4 device need to have a send port and a recv port
  assert(NUM_USER_SEND_PORTS == NUM_USER_RECV_PORTS)
  assert(NUM_MASTER_DEVICES + NUM_SLAVE_DEVICES <= NUM_USER_SEND_PORTS)

  // AXI4 protocol requires at least 3 virtual channels
  assert(NUM_VCS >= 3)

  // AXI4 burst len & size check for write interleaving buffer
  if (AXI4_PROTOCOL == "AXI4" && WRITE_INTERLEAVE) {
    assert(1 to 256 contains AXI4_MAX_BURST_LEN)
    for (i <- 0 until NUM_MASTER_DEVICES) {
      val axi = io.master(i).asInstanceOf[AXI4IO]
      when(axi.aw.fire) {
        assert(axi.aw.bits.len <= (AXI4_MAX_BURST_LEN - 1).U)
      }
    }
    for (i <- 0 until NUM_SLAVE_DEVICES) {
      val axi = io.slave(i).asInstanceOf[AXI4IO]
      when(axi.aw.fire) {
        assert(axi.aw.bits.len <= (AXI4_MAX_BURST_LEN - 1).U)
      }
    }
  }

  val network = Module(new Network)

  for (i <- 0 until NUM_MASTER_DEVICES) {
    val bridge            = Module(new AXI4MasterBridge(bus_io)(i))
    val serializer_a      = Module(new FlitSerializer(i, AXI4PacketWidth(bus_io), FLIT_WIDTH, 2))
    val serializer_w      = Module(new FlitSerializer(i, AXI4PacketWidth(bus_io), FLIT_WIDTH, 1))
    val deserializer_br   = Module(new FlitDeserializer(i, FLIT_WIDTH, AXI4PacketWidth(bus_io), 0))
    val flow_control_send = Module(new FlitFlowControlSend)
    val flow_control_recv = Module(new FlitFlowControlRecv)

    bridge.io.axi                      <> io.master(i)
    serializer_a.io.in_packet          <> bridge.io.a_packet
    serializer_a.io.clock_noc          := clock
    serializer_w.io.in_packet          <> bridge.io.w_packet
    serializer_w.io.clock_noc          := clock
    deserializer_br.io.out_packet      <> bridge.io.br_packet
    deserializer_br.io.clock_noc       := clock
    flow_control_send.io.flit(2)       <> serializer_a.io.out_flit
    flow_control_send.io.flit(1)       <> serializer_w.io.out_flit
    flow_control_send.io.flit(0).bits  := 0.U
    flow_control_send.io.flit(0).valid := false.B
    flow_control_recv.io.flit(2).ready := false.B
    flow_control_recv.io.flit(1).ready := false.B
    flow_control_recv.io.flit(0)       <> deserializer_br.io.in_flit
    network.io.send(i)                 <> flow_control_send.io.send
    network.io.recv(i)                 <> flow_control_recv.io.recv
  }

  for (i <- NUM_MASTER_DEVICES until NUM_MASTER_DEVICES + NUM_SLAVE_DEVICES) {
    val bridge            = Module(new AXI4SlaveBridge(bus_io)(i))
    val deserializer_a    = Module(new FlitDeserializer(i, FLIT_WIDTH, AXI4PacketWidth(bus_io), 2))
    val deserializer_w    = Module(new FlitDeserializer(i, FLIT_WIDTH, AXI4PacketWidth(bus_io), 1))
    val serializer_br     = Module(new FlitSerializer(i, AXI4PacketWidth(bus_io), FLIT_WIDTH, 0))
    val flow_control_send = Module(new FlitFlowControlSend)
    val flow_control_recv = Module(new FlitFlowControlRecv)

    bridge.io.axi                      <> io.slave(i - NUM_MASTER_DEVICES)
    deserializer_a.io.out_packet       <> bridge.io.a_packet
    deserializer_a.io.clock_noc        := clock
    deserializer_w.io.out_packet       <> bridge.io.w_packet
    deserializer_w.io.clock_noc        := clock
    serializer_br.io.in_packet         <> bridge.io.br_packet
    serializer_br.io.clock_noc         := clock
    flow_control_send.io.flit(2).bits  := 0.U
    flow_control_send.io.flit(2).valid := false.B
    flow_control_send.io.flit(1).bits  := 0.U
    flow_control_send.io.flit(1).valid := false.B
    flow_control_send.io.flit(0)       <> serializer_br.io.out_flit
    flow_control_recv.io.flit(2)       <> deserializer_a.io.in_flit
    flow_control_recv.io.flit(1)       <> deserializer_w.io.in_flit
    flow_control_recv.io.flit(0).ready := false.B
    network.io.send(i)                 <> flow_control_send.io.send
    network.io.recv(i)                 <> flow_control_recv.io.recv
  }
}
