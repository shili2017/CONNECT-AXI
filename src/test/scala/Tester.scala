package connect_axi

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class NetworkAXI4WrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  behavior.of("NetworkAXI4WrapperTester")

  it should "test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    val TEST_LEN = 8

    test(new AXI4Testbench(TEST_LEN)).withAnnotations(annotation) { tb =>
      tb.clock.step()

      tb.io.start_write(0).poke(false)
      tb.io.start_write(1).poke(false)
      tb.io.start_read(0).poke(false)
      tb.io.start_read(1).poke(false)
      tb.clock.step()
      tb.io.start_write(0).poke(true)
      tb.clock.step()
      tb.io.start_write(0).poke(false)
      tb.io.start_read(1).poke(true)
      tb.clock.step()
      tb.io.start_read(1).poke(false)
      tb.clock.step(200)

      for (i <- 0 until TEST_LEN) {
        tb.io.master_buffer_peek(1)(i).expect(i.U)
        tb.io.slave_buffer_peek(0)(i).expect((BigInt("deadbeefdeadbeef", 16) + i).U)
      }
    }
  }
}
