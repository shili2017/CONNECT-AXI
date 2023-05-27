import sys

if len(sys.argv) != 3:
  print("Usage: python3 generateNetworkScala.py <NUM_USER_SEND_PORTS> <NUM_USER_RECV_PORTS>")
  exit(1)

send = int(sys.argv[1])
recv = int(sys.argv[2])

print("""package connect_axi

import chisel3._
import chisel3.util._

class mkNetwork(implicit p: NetworkConfigs) extends BlackBox with HasBlackBoxResource {
  val io = IO(new Bundle {
    val CLK   = Input(Clock())
    val RST_N = Input(Bool())
""")

for i in range(send):
  print("    val send_ports_%d_putFlit_flit_in = Input(UInt(p.FLIT_WIDTH.W))" % i)
  print("    val EN_send_ports_%d_putFlit      = Input(Bool())" % i)
  print("    val send_ports_%d_getCredits      = Output(UInt((p.VC_BITS + 1).W))" % i)
  print("    val EN_send_ports_%d_getCredits   = Input(Bool())" % i)

print()

for i in range(recv):
  print("    val recv_ports_%d_getFlit          = Output(UInt(p.FLIT_WIDTH.W))" % i)
  print("    val EN_recv_ports_%d_getFlit       = Input(Bool())" % i)
  print("    val recv_ports_%d_putCredits_cr_in = Input(UInt((p.VC_BITS + 1).W))" % i)
  print("    val EN_recv_ports_%d_putCredits    = Input(Bool())" % i)
    
print()

for i in range(recv):
  print("    val recv_ports_info_%d_getRecvPortID = Output(UInt(p.DEST_BITS.W))" % i)

print("""
  })

  addResource("/vsrc/mkNetwork.v")
}

class NetworkSendInterface(implicit p: NetworkConfigs) extends Bundle {
  val put_flit      = Input(UInt(p.FLIT_WIDTH.W))
  val EN_put_flit   = Input(Bool())
  val get_credit    = Output(UInt((p.VC_BITS + 1).W))
  val EN_get_credit = Input(Bool())
}

class NetworkRecvInterface(implicit p: NetworkConfigs) extends Bundle {
  val get_flit      = Output(UInt(p.FLIT_WIDTH.W))
  val EN_get_flit   = Input(Bool())
  val put_credit    = Input(UInt((p.VC_BITS + 1).W))
  val EN_put_credit = Input(Bool())
}

class Network(implicit p: NetworkConfigs) extends Module {
  val io = IO(new Bundle {
    val send = Vec(p.NUM_USER_SEND_PORTS, new NetworkSendInterface)
    val recv = Vec(p.NUM_USER_RECV_PORTS, new NetworkRecvInterface)
  })

  val network = Module(new mkNetwork)

  val recv_ports_info_getRecvPortID = Wire(Vec(p.NUM_USER_RECV_PORTS, UInt(p.DEST_BITS.W)))

  if (p.DEBUG_NETWORK_FLIT) {
    for (i <- 0 until p.NUM_USER_SEND_PORTS) {
      when(io.send(i).put_flit(p.FLIT_WIDTH - 1)) {
        printf("%d: [Network send %d] put_flit=%b\\n", DebugTimer(), i.U, io.send(i).put_flit)
      }
    }
    for (i <- 0 until p.NUM_USER_RECV_PORTS) {
      when(io.recv(i).get_flit(p.FLIT_WIDTH - 1)) {
        printf("%d: [Network recv %d] get_flit=%b\\n", DebugTimer(), i.U, io.recv(i).get_flit)
      }
    }
  }

  if (p.DEBUG_NETWORK_CREDIT) {
    for (i <- 0 until p.NUM_USER_SEND_PORTS) {
      when(io.send(i).get_credit(p.VC_BITS)) {
        printf("%d: [Network send %d] get_credit=%b\\n", DebugTimer(), i.U, io.send(i).get_credit)
      }
    }
    for (i <- 0 until p.NUM_USER_RECV_PORTS) {
      when(io.recv(i).put_credit(p.VC_BITS)) {
        printf("%d: [Network recv %d] put_credit=%b\\n", DebugTimer(), i.U, io.recv(i).put_credit)
      }
    }
  }

  network.io.CLK   := clock
  network.io.RST_N := reset
""")

for i in range(send):
  print("  network.io.send_ports_%d_putFlit_flit_in  := io.send(%d).put_flit" % (i, i))
  print("  network.io.EN_send_ports_%d_putFlit       := io.send(%d).EN_put_flit" % (i, i))
  print("  io.send(%d).get_credit                    := network.io.send_ports_%d_getCredits" % (i, i))
  print("  network.io.EN_send_ports_%d_getCredits    := io.send(%d).EN_get_credit" % (i, i))

for i in range(recv):
  print("  io.recv(%d).get_flit                      := network.io.recv_ports_%d_getFlit" % (i, i))
  print("  network.io.EN_recv_ports_%d_getFlit       := io.recv(%d).EN_get_flit" % (i, i))
  print("  network.io.recv_ports_%d_putCredits_cr_in := io.recv(%d).put_credit" % (i, i))
  print("  network.io.EN_recv_ports_%d_putCredits    := io.recv(%d).EN_put_credit" % (i, i))

for i in range(recv):
  print("  recv_ports_info_getRecvPortID(%d)         := network.io.recv_ports_info_%d_getRecvPortID" % (i, i))

print("}")
