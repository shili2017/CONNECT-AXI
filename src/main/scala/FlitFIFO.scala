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

  val fifo = Module(new Queue(UInt(DATA_WIDTH.W), DEPTH, true, true))

  fifo.io.enq <> io.enq
  fifo.io.deq <> io.deq

  io.full         := (fifo.io.count === DEPTH.U)
  io.almost_full  := (fifo.io.count >= ALMOST_FULL_VALUE.U)
  io.empty        := (fifo.io.count === 0.U)
  io.almost_empty := (fifo.io.count <= ALMOST_EMPTY_VALUE.U)
}

class InPortFIFO(val DEVICE_TYPE: String = "SYMMETRIC") extends Module with Config {
  val io = IO(new Bundle {
    val put_flit = Flipped(Decoupled(UInt(FLIT_WIDTH.W))) // Input from device
    val send     = Flipped(new NetworkSendInterface) // Output to network
  })

  val fifo = Module(new BasicFIFO(FLIT_BUFFER_DEPTH, FLIT_WIDTH)())
  fifo.io.enq <> io.put_flit

  /* device_type can be "MASTER", "SLAVE" or "SYMMETRIC"
   * MASTER: InPortFIFO sends requests and uses VC 1
   * SLAVE:  InPortFIFO sends responses and uses VC 0
   * SYMMETRIC: InPortFIFO uses VC 0
   */
  val vc = Wire(UInt(VC_BITS.W))
  if (DEVICE_TYPE == "MASTER") {
    vc := 1.U
  } else {
    vc := 0.U
  }

  val get_credit_valid = Wire(Bool())
  get_credit_valid := io.send.get_credit(VC_BITS) && (io.send.get_credit(VC_BITS - 1, 0) === vc)

  val credit_counter = RegInit(FLIT_BUFFER_DEPTH.U((log2Up(FLIT_BUFFER_DEPTH) + 1).W))
  when(fifo.io.deq.fire && !get_credit_valid) {
    credit_counter := credit_counter - 1.U
  }.elsewhen(get_credit_valid && !fifo.io.deq.fire) {
    credit_counter := credit_counter + 1.U
  }

  fifo.io.deq.ready     := (credit_counter =/= 0.U)
  io.send.put_flit      := Cat(fifo.io.deq.fire.asUInt, fifo.io.deq.bits(FLIT_WIDTH - 2, 0))
  io.send.EN_put_flit   := fifo.io.deq.fire
  io.send.EN_get_credit := true.B
}

class OutPortFIFO(val DEVICE_TYPE: String = "SYMMETRIC") extends Module with Config {
  val io = IO(new Bundle {
    val get_flit = Decoupled(UInt(FLIT_WIDTH.W)) // Output to device
    val recv     = Flipped(new NetworkRecvInterface) // Input from network
  })

  val fifo = Module(new BasicFIFO(FLIT_BUFFER_DEPTH, FLIT_WIDTH)())
  fifo.io.deq <> io.get_flit

  /* device_type can be "MASTER", "SLAVE" or "SYMMETRIC"
   * MASTER: OutPortFIFO receives responses and uses VC 0
   * SLAVE:  OutPortFIFO receives requests and uses VC 1
   * SYMMETRIC: OutPortFIFO uses VC 0
   */
  val vc = Wire(UInt(VC_BITS.W))
  if (DEVICE_TYPE == "SLAVE") {
    vc := 1.U
  } else {
    vc := 0.U
  }

  fifo.io.enq.bits      := io.recv.get_flit
  fifo.io.enq.valid     := io.recv.get_flit(FLIT_WIDTH - 1).asBool
  io.recv.EN_get_flit   := fifo.io.enq.ready
  io.recv.put_credit    := Cat(io.recv.EN_put_credit, vc)
  io.recv.EN_put_credit := io.get_flit.fire

}
