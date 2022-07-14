package connect_axi

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

class NetworkAXI4WrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  it should "pass AXI4 test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    val TEST_LEN = 2

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
        tb.io.master_buffer_peek(1)(i).expect(i)
        tb.io.slave_buffer_peek(0)(i).expect((BigInt("deadbeefdeadbeef", 16) + i))
      }
    }
  }
}

class NetworkAXI4LiteWrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  it should "pass AXI4-Lite test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    test(new AXI4LiteTestbench).withAnnotations(annotation) { tb =>
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

      tb.io.master_buffer_peek(1).expect(BigInt("1234567812345678", 16))
      tb.io.slave_buffer_peek(0).expect(BigInt("deadbeefdeadbeef", 16))
    }
  }
}

class NetworkSimpleWrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  it should "pass simple test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    test(new NetworkSimpleWrapper(72)).withAnnotations(annotation) { tb =>
      val packet_0_2 = BigInt("e01234567812345678", 16)
      val packet_1_3 = BigInt("f1deadbeefdeadbeef", 16)

      tb.clock.step()
      for (i <- 0 until Config.NUM_USER_SEND_PORTS) {
        tb.io.send(i).bits.poke(0.U)
        tb.io.send(i).valid.poke(false.B)
      }
      for (i <- 0 until Config.NUM_USER_RECV_PORTS) {
        tb.io.recv(i).ready.poke(false.B)
      }
      tb.clock.step()
      tb.io.send(0).bits.poke(packet_0_2.asUInt)
      tb.io.send(0).valid.poke(true.B)
      tb.clock.step()
      tb.io.send(0).bits.poke(0.U)
      tb.io.send(0).valid.poke(false.B)
      tb.io.send(1).bits.poke(packet_1_3.asUInt)
      tb.io.send(1).valid.poke(true.B)
      tb.clock.step()
      tb.io.send(1).bits.poke(0.U)
      tb.io.send(1).valid.poke(false.B)
      tb.clock.step(50)

      tb.io.recv(2).bits.expect(packet_0_2)
      tb.io.recv(2).valid.expect(true)
      tb.io.recv(3).bits.expect(packet_1_3)
      tb.io.recv(3).valid.expect(true)
    }
  }
}
