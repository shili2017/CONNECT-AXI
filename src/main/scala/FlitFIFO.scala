package connect_axi

import chisel3._
import chisel3.util._

class BasicFIFO(
  val DEPTH:              Int,
  val DATA_WIDTH:         Int
)(val ALMOST_FULL_VALUE:  Int = DEPTH - 1,
  val ALMOST_EMPTY_VALUE: Int = 1)
    extends Module {
  val io = IO(new Bundle {
    val enq          = Flipped(Decoupled(UInt(DATA_WIDTH.W)))
    val deq          = Decoupled(UInt(DATA_WIDTH.W))
    val full         = Output(Bool())
    val almost_full  = Output(Bool())
    val empty        = Output(Bool())
    val almost_empty = Output(Bool())
  })

  if (Config.USE_FIFO_IP) {
    val fifo = Module(
      new scfifo(
        lpm_width          = DATA_WIDTH,
        lpm_widthu         = log2Up(DEPTH),
        lpm_numwords       = DEPTH,
        lpm_showahead      = "ON",
        almost_full_value  = ALMOST_FULL_VALUE,
        almost_empty_value = ALMOST_EMPTY_VALUE
      )
    )

    fifo.io.clock   := clock
    fifo.io.sclr    := reset
    fifo.io.aclr    := reset
    fifo.io.data    := io.enq.bits
    fifo.io.wrreq   := io.enq.valid
    io.full         := fifo.io.full
    io.almost_full  := fifo.io.almost_full
    io.deq.bits     := fifo.io.q
    fifo.io.rdreq   := io.deq.ready
    io.empty        := fifo.io.empty
    io.almost_empty := fifo.io.almost_empty

    io.enq.ready := !fifo.io.full
    io.deq.valid := !fifo.io.empty
  } else {
    val fifo = Module(new Queue(UInt(DATA_WIDTH.W), DEPTH, true, true))

    fifo.io.enq <> io.enq
    fifo.io.deq <> io.deq

    io.full         := (fifo.io.count === DEPTH.U)
    io.almost_full  := (fifo.io.count >= ALMOST_FULL_VALUE.U)
    io.empty        := (fifo.io.count === 0.U)
    io.almost_empty := (fifo.io.count <= ALMOST_EMPTY_VALUE.U)
  }
}

class InPortFIFO(VC: Int) extends Module with Config {
  val io = IO(new Bundle {
    // Device
    val device_flit = Flipped(Decoupled(UInt(FLIT_WIDTH.W)))
    // Network
    val network_flit   = Decoupled(UInt(FLIT_WIDTH.W))
    val network_credit = Flipped(Decoupled(UInt(VC_BITS.W)))
  })

  val fifo = Module(new BasicFIFO(FLIT_BUFFER_DEPTH, FLIT_WIDTH)())
  fifo.io.enq <> io.device_flit

  // Check whether incoming credit matches VC
  when(io.network_credit.fire) {
    assert(io.network_credit.bits === VC.U)
  }

  // Credit
  val credit_counter = RegInit(FLIT_BUFFER_DEPTH.U((log2Up(FLIT_BUFFER_DEPTH) + 1).W))
  when(fifo.io.deq.fire && !io.network_credit.fire) {
    credit_counter := credit_counter - 1.U
  }.elsewhen(io.network_credit.fire && !fifo.io.deq.fire) {
    credit_counter := credit_counter + 1.U
  }
  io.network_credit.ready := true.B

  // Flit output
  fifo.io.deq.ready     := io.network_flit.ready && (credit_counter =/= 0.U)
  io.network_flit.valid := fifo.io.deq.valid && (credit_counter =/= 0.U)
  io.network_flit.bits  := fifo.io.deq.bits
}

class OutPortFIFO(VC: Int) extends Module with Config {
  val io = IO(new Bundle {
    // Device
    val device_flit = Decoupled(UInt(FLIT_WIDTH.W)) // Output to device
    // Network
    val network_flit   = Flipped(Decoupled(UInt(FLIT_WIDTH.W)))
    val network_credit = Decoupled(UInt(VC_BITS.W))
  })

  val fifo = Module(new BasicFIFO(FLIT_BUFFER_DEPTH, FLIT_WIDTH)())

  // Flit output to device
  fifo.io.deq          <> io.device_flit
  io.device_flit.bits  := fifo.io.deq.bits
  io.device_flit.valid := fifo.io.deq.valid && io.network_credit.ready
  fifo.io.deq.ready    := io.device_flit.ready && io.network_credit.ready

  // Credit
  io.network_credit.bits  := VC.U(VC_BITS.W)
  io.network_credit.valid := io.device_flit.fire

  // Flit input from network
  fifo.io.enq <> io.network_flit
}
