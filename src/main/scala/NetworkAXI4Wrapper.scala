package connect_axi

import chisel3._

class NetworkAXI4Wrapper extends Module with Config {
  val io = IO(new Bundle {
    val master = Vec(NUM_MASTER_DEVICES, Flipped(new AXI4IO))
    val slave  = Vec(NUM_SLAVE_DEVICES, new AXI4IO)
  })

  // Each AXI4 device need to have a send port and a recv port
  assert(NUM_USER_SEND_PORTS == NUM_USER_RECV_PORTS)
  assert(NUM_MASTER_DEVICES + NUM_SLAVE_DEVICES <= NUM_USER_SEND_PORTS)

  val network = Module(new Network)

  for (i <- 0 until NUM_MASTER_DEVICES) {
    val bridge        = Module(new AXI4MasterBridge(i))
    val serializer    = Module(new FlitSerializer(i, AXI4PacketWidth(), FLIT_WIDTH))
    val deserializer  = Module(new FlitDeserializer(i, FLIT_WIDTH, AXI4PacketWidth()))
    val in_port_fifo  = Module(new InPortFIFO("MASTER"))
    val out_port_fifo = Module(new OutPortFIFO("MASTER"))

    bridge.io.axi              <> io.master(i)
    serializer.io.in_packet    <> bridge.io.put_packet
    deserializer.io.out_packet <> bridge.io.get_packet
    in_port_fifo.io.put_flit   <> serializer.io.out_flit
    out_port_fifo.io.get_flit  <> deserializer.io.in_flit
    network.io.send(i)         <> in_port_fifo.io.send
    network.io.recv(i)         <> out_port_fifo.io.recv
  }

  for (i <- NUM_MASTER_DEVICES until NUM_MASTER_DEVICES + NUM_SLAVE_DEVICES) {
    val bridge        = Module(new AXI4SlaveBridge(i))
    val serializer    = Module(new FlitSerializer(i, AXI4PacketWidth(), FLIT_WIDTH))
    val deserializer  = Module(new FlitDeserializer(i, FLIT_WIDTH, AXI4PacketWidth()))
    val in_port_fifo  = Module(new InPortFIFO("SLAVE"))
    val out_port_fifo = Module(new OutPortFIFO("SLAVE"))

    bridge.io.axi              <> io.slave(i - NUM_MASTER_DEVICES)
    serializer.io.in_packet    <> bridge.io.put_packet
    deserializer.io.out_packet <> bridge.io.get_packet
    in_port_fifo.io.put_flit   <> serializer.io.out_flit
    out_port_fifo.io.get_flit  <> deserializer.io.in_flit
    network.io.send(i)         <> in_port_fifo.io.send
    network.io.recv(i)         <> out_port_fifo.io.recv
  }
}
