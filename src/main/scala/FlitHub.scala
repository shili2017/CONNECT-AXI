package connect_axi

import chisel3._
import chisel3.util._

// InPort side flit hub
class FlitHubNTo1 extends Module with Config {
  val io = IO(new Bundle {
    // Device
    val device_flit   = Vec(NUM_VCS, Flipped(Decoupled(UInt(FLIT_WIDTH.W))))
    val device_credit = Vec(NUM_VCS, Decoupled(UInt(VC_BITS.W)))
    // Network
    val network_flit   = Decoupled(UInt(FLIT_WIDTH.W))
    val network_credit = Flipped(Decoupled(UInt(VC_BITS.W)))
  })

  // Flit arbiter
  val arbiter = Module(new Arbiter(UInt(FLIT_WIDTH.W), NUM_VCS))
  for (i <- 0 until NUM_VCS) {
    arbiter.io.in(i) <> io.device_flit(i)
  }
  io.network_flit <> arbiter.io.out

  // Credit
  val vc = Wire(UInt(VC_BITS.W))
  vc := io.network_credit.bits
  for (i <- 0 until NUM_VCS) {
    io.device_credit(i).bits  := io.network_credit.bits // Payload is set to be VC
    io.device_credit(i).valid := io.network_credit.valid && (vc === i.U)
  }
  io.network_credit.ready := io.device_credit(vc).ready
}

// Network send interface converter (Chisel Decoupled -> BSV interface)
class FlitSendInterface extends Module with Config {
  val io = IO(new Bundle {
    val put_flit   = Flipped(Decoupled(UInt(FLIT_WIDTH.W)))
    val get_credit = Decoupled(UInt(VC_BITS.W))
    val send       = Flipped(new NetworkSendInterface)
  })

  // Flit
  io.send.put_flit    := Cat(io.put_flit.fire, io.put_flit.bits(FLIT_WIDTH - 2, 0))
  io.send.EN_put_flit := io.put_flit.fire
  io.put_flit.ready   := true.B

  // Credit
  io.get_credit.bits    := io.send.get_credit(VC_BITS - 1, 0)
  io.get_credit.valid   := io.send.get_credit(VC_BITS).asBool
  io.send.EN_get_credit := io.get_credit.ready
}

// OutPort side flit hub
class FlitHub1ToN extends Module with Config {
  val io = IO(new Bundle {
    // Network
    val network_flit   = Flipped(Decoupled(UInt(FLIT_WIDTH.W)))
    val network_credit = Decoupled(UInt(VC_BITS.W))
    // Device
    val device_flit   = Vec(NUM_VCS, Decoupled(UInt(FLIT_WIDTH.W)))
    val device_credit = Vec(NUM_VCS, Flipped(Decoupled(UInt(VC_BITS.W))))
  })

  // Flit
  val vc = Wire(UInt(VC_BITS.W))
  vc                    := GetVC(io.network_flit.bits)
  io.network_flit.ready := false.B
  for (i <- 0 until NUM_VCS) {
    io.device_flit(i).bits  := 0.U
    io.device_flit(i).valid := false.B
    when(vc === i.U(NUM_VCS.W)) {
      io.device_flit(i).bits  := io.network_flit.bits
      io.device_flit(i).valid := io.network_flit.valid
      io.network_flit.ready   := io.device_flit(i).ready
    }
  }

  // Credit arbiter
  val arbiter = Module(new Arbiter(UInt(VC_BITS.W), NUM_VCS))
  for (i <- 0 until NUM_VCS) {
    arbiter.io.in(i) <> io.device_credit(i)
  }
  io.network_credit <> arbiter.io.out // Payload is set to be VC
}

// Network recv interface converter (Chisel Decoupled -> BSV interface)
class FlitRecvInterface extends Module with Config {
  val io = IO(new Bundle {
    val get_flit   = Decoupled(UInt(FLIT_WIDTH.W))
    val put_credit = Flipped(Decoupled(UInt(VC_BITS.W)))
    val recv       = Flipped(new NetworkRecvInterface)
  })

  // Flit
  io.get_flit.bits    := io.recv.get_flit
  io.get_flit.valid   := io.recv.get_flit(FLIT_WIDTH - 1).asBool
  io.recv.EN_get_flit := io.get_flit.ready

  // Credit
  io.recv.put_credit    := Cat(io.put_credit.valid.asUInt, io.put_credit.bits)
  io.recv.EN_put_credit := io.put_credit.valid
  io.put_credit.ready   := true.B
}