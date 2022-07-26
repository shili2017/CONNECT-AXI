package connect_axi

import chisel3.util.log2Up
import chipsalliance.rocketchip.config._
import os.truncate

case object NUM_USER_SEND_PORTS extends Field[Int]
case object NUM_USER_RECV_PORTS extends Field[Int]
case object NUM_VCS extends Field[Int]
case object REAL_FLIT_DATA_WIDTH extends Field[Int]
case object FLIT_BUFFER_DEPTH extends Field[Int]
case object FLIT_DATA_WIDTH extends Field[Int]
case object SRC_BITS extends Field[Int]
case object DEST_BITS extends Field[Int]
case object VC_BITS extends Field[Int]
case object META_WIDTH extends Field[Int]
case object FLIT_WIDTH extends Field[Int]
case object PACKET_DATA_WIDTH extends Field[Int]

// CONNECT network parameters, change these values after re-generating the network
class ConnectConfig
    extends Config((site, here, up) => {
      case NUM_USER_SEND_PORTS  => 4
      case NUM_USER_RECV_PORTS  => 4
      case NUM_VCS              => 3
      case REAL_FLIT_DATA_WIDTH => 34
      case FLIT_BUFFER_DEPTH    => 4

      // Induced parameters, DO NOT CHANGE
      case FLIT_DATA_WIDTH   => site(REAL_FLIT_DATA_WIDTH) - log2Up(site(NUM_USER_SEND_PORTS))
      case SRC_BITS          => log2Up(site(NUM_USER_SEND_PORTS))
      case DEST_BITS         => log2Up(site(NUM_USER_RECV_PORTS))
      case VC_BITS           => log2Up(site(NUM_VCS))
      case META_WIDTH        => site(SRC_BITS) + site(DEST_BITS) + site(VC_BITS) + 2
      case FLIT_WIDTH        => site(FLIT_DATA_WIDTH) + site(META_WIDTH)
      case PACKET_DATA_WIDTH => site(PACKET_WIDTH) - site(META_WIDTH)
    })

case object PROTOCOL extends Field[String]
case object NUM_MASTER_DEVICES extends Field[Int]
case object NUM_SLAVE_DEVICES extends Field[Int]
case object WRITE_INTERLEAVE extends Field[Boolean]
case object AXI4_MAX_BURST_LEN extends Field[Int]
case object PACKET_WIDTH extends Field[Int]

class AXI4WrapperConfig
    extends Config((site, here, up) => {
      case PROTOCOL           => "AXI4"
      case NUM_MASTER_DEVICES => site(NUM_USER_SEND_PORTS) / 2
      case NUM_SLAVE_DEVICES  => site(NUM_USER_RECV_PORTS) / 2
      case WRITE_INTERLEAVE   => true
      case AXI4_MAX_BURST_LEN => 16
    })

class AXI4LiteWrapperConfig
    extends Config((site, here, up) => {
      case PROTOCOL           => "AXI4-Lite"
      case NUM_MASTER_DEVICES => site(NUM_USER_SEND_PORTS) / 2
      case NUM_SLAVE_DEVICES  => site(NUM_USER_RECV_PORTS) / 2
      case WRITE_INTERLEAVE   => true
    })

class AXI4StreamWrapperConfig
    extends Config((site, here, up) => {
      case PROTOCOL           => "AXI4-Stream"
      case NUM_MASTER_DEVICES => site(NUM_USER_SEND_PORTS)
      case NUM_SLAVE_DEVICES  => site(NUM_USER_RECV_PORTS)
    })

class SimpleWrapperConfig
    extends Config((site, here, up) => {
      case PROTOCOL           => "Simple"
      case NUM_MASTER_DEVICES => site(NUM_USER_SEND_PORTS)
      case NUM_SLAVE_DEVICES  => site(NUM_USER_RECV_PORTS)
      case PACKET_WIDTH       => 80
    })

case object USE_FIFO_IP extends Field[Boolean]
case object ALTERA_MF_V extends Field[String]

class LibraryConfig
    extends Config((site, here, up) => {
      case USE_FIFO_IP => true
      case ALTERA_MF_V => "/afs/ece.cmu.edu/support/altera/release/pro-19.3.0.222/quartus/eda/sim_lib/altera_mf.v"
    })

case object DEBUG_BRIDGE extends Field[Boolean]
case object DEBUG_SERIALIZER extends Field[Boolean]
case object DEBUG_DESERIALIZER extends Field[Boolean]
case object DEBUG_NETWORK_FLIT extends Field[Boolean]
case object DEBUG_NETWORK_CREDIT extends Field[Boolean]

class DebugConfig
    extends Config((site, here, up) => {
      case DEBUG_BRIDGE         => false
      case DEBUG_SERIALIZER     => false
      case DEBUG_DESERIALIZER   => false
      case DEBUG_NETWORK_FLIT   => false
      case DEBUG_NETWORK_CREDIT => false
    })

case object DEVICE_ID extends Field[Int]
case object FIFO_VC extends Field[Int]
case object AXI4_BUS_IO extends Field[AXI4LiteIO]

class AXI4Config extends Config(new ConnectConfig ++ new AXI4WrapperConfig ++ new LibraryConfig ++ new DebugConfig)

class AXI4LiteConfig
    extends Config(new ConnectConfig ++ new AXI4LiteWrapperConfig ++ new LibraryConfig ++ new DebugConfig)

class AXI4StreamConfig
    extends Config(new ConnectConfig ++ new AXI4StreamWrapperConfig ++ new LibraryConfig ++ new DebugConfig)

class SimpleConfig extends Config(new ConnectConfig ++ new SimpleWrapperConfig ++ new LibraryConfig ++ new DebugConfig)
