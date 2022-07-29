package connect_axi

import chisel3.util._

// CONNECT network parameters, change these values after re-generating the network
object ConnectConfig {
  def apply() = Map(
    "NUM_USER_SEND_PORTS"  -> 4,
    "NUM_USER_RECV_PORTS"  -> 4,
    "NUM_VCS"              -> 3,
    "REAL_FLIT_DATA_WIDTH" -> 34,
    "FLIT_BUFFER_DEPTH"    -> 4
  )
}

object AXI4WrapperConfig {
  def apply(configs: Configs) = Map(
    "PROTOCOL"              -> "AXI4",
    "NUM_MASTER_DEVICES"    -> configs.getInt("NUM_USER_SEND_PORTS") / 2,
    "NUM_SLAVE_DEVICES"     -> configs.getInt("NUM_USER_RECV_PORTS") / 2,
    "AXI4_WRITE_INTERLEAVE" -> true,
    "AXI4_MAX_BURST_LEN"    -> 16
  )
}

object AXI4LiteWrapperConfig {
  def apply(configs: Configs) = Map(
    "PROTOCOL"              -> "AXI4-Lite",
    "NUM_MASTER_DEVICES"    -> configs.getInt("NUM_USER_SEND_PORTS") / 2,
    "NUM_SLAVE_DEVICES"     -> configs.getInt("NUM_USER_RECV_PORTS") / 2,
    "AXI4_WRITE_INTERLEAVE" -> true
  )
}

object AXI4StreamWrapperConfig {
  def apply(configs: Configs) = Map(
    "PROTOCOL"           -> "AXI4-Stream",
    "NUM_MASTER_DEVICES" -> configs.getInt("NUM_USER_SEND_PORTS"),
    "NUM_SLAVE_DEVICES"  -> configs.getInt("NUM_USER_RECV_PORTS")
  )
}

object SimpleWrapperConfig {
  def apply(configs: Configs) = Map(
    "PROTOCOL"           -> "Simple",
    "NUM_MASTER_DEVICES" -> configs.getInt("NUM_USER_SEND_PORTS"),
    "NUM_SLAVE_DEVICES"  -> configs.getInt("NUM_USER_RECV_PORTS"),
    "PACKET_WIDTH"       -> 72
  )
}

object LibraryConfig {
  def apply() = Map(
    "USE_FIFO_IP" -> true,
    "ALTERA_MF_V" -> "/afs/ece.cmu.edu/support/altera/release/pro-19.3.0.222/quartus/eda/sim_lib/altera_mf.v"
  )
}

class Configs(configs: Map[String, Any]) {
  def getBoolean(field: String, default: Boolean = false) = configs.getOrElse(field, default).asInstanceOf[Boolean]
  def getInt(field:     String, default: Int     = 0)     = configs.getOrElse(field, default).asInstanceOf[Int]
  def getString(field:  String, default: String  = "")    = configs.getOrElse(field, default).asInstanceOf[String]
}

class NetworkConfigs(configs: Configs) {
  val NUM_USER_SEND_PORTS  = configs.getInt("NUM_USER_SEND_PORTS")
  val NUM_USER_RECV_PORTS  = configs.getInt("NUM_USER_RECV_PORTS")
  val NUM_VCS              = configs.getInt("NUM_VCS")
  val REAL_FLIT_DATA_WIDTH = configs.getInt("REAL_FLIT_DATA_WIDTH")
  val FLIT_BUFFER_DEPTH    = configs.getInt("FLIT_BUFFER_DEPTH")

  val FLIT_DATA_WIDTH = REAL_FLIT_DATA_WIDTH - log2Up(NUM_USER_SEND_PORTS)
  val SRC_BITS        = log2Up(NUM_USER_SEND_PORTS)
  val DEST_BITS       = log2Up(NUM_USER_RECV_PORTS)
  val VC_BITS         = log2Up(NUM_VCS)
  val META_WIDTH      = SRC_BITS + DEST_BITS + VC_BITS + 2
  val FLIT_WIDTH      = FLIT_DATA_WIDTH + META_WIDTH

  val PROTOCOL           = configs.getString("PROTOCOL")
  val NUM_MASTER_DEVICES = configs.getInt("NUM_MASTER_DEVICES")
  val NUM_SLAVE_DEVICES  = configs.getInt("NUM_SLAVE_DEVICES")

  val PACKET_WIDTH = PROTOCOL match {
    case "AXI4"        => AXI4PacketDataWidth() + META_WIDTH
    case "AXI4-Lite"   => AXI4LitePacketDataWidth() + META_WIDTH
    case "AXI4-Stream" => AXI4StreamPacketDataWidth() + META_WIDTH
    case _             => configs.getInt("PACKET_WIDTH")
  }
  val PACKET_DATA_WIDTH = PACKET_WIDTH - META_WIDTH

  val AXI4_WRITE_INTERLEAVE = configs.getBoolean("AXI4_WRITE_INTERLEAVE", false)
  val AXI4_MAX_BURST_LEN    = configs.getInt("AXI4_MAX_BURST_LEN", 1)
  val AXI4_BUS_IO           = if (PROTOCOL == "AXI4") new AXI4IO else new AXI4LiteIO

  val USE_FIFO_IP = configs.getBoolean("USE_FIFO_IP")
  val ALTERA_MF_V = configs.getString("ALTERA_MF_V")

  val DEBUG_BRIDGE         = false
  val DEBUG_SERIALIZER     = false
  val DEBUG_DESERIALIZER   = false
  val DEBUG_NETWORK_FLIT   = false
  val DEBUG_NETWORK_CREDIT = false
}
