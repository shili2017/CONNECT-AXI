package connect_axi

import chisel3._
import chisel3.util._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import chipsalliance.rocketchip.config._

class NetworkAXI4WrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  implicit val p: Parameters = (new AXI4Config).toInstance

  it should "pass AXI4 test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    val CLOCK_DIVIDER_FACTOR = 4
    val TEST_LEN             = 16

    test(new AXI4Testbench(CLOCK_DIVIDER_FACTOR, TEST_LEN)).withAnnotations(annotation) { tb =>
      tb.clock.step()
      for (i <- 0 until p(NUM_MASTER_DEVICES)) {
        tb.io.start_write(i).poke(false)
        tb.io.start_read(i).poke(false)
        tb.io.target_dest(i).poke(2.U)
      }
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_write(0).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_write(0).poke(false)
      tb.io.start_write(1).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_write(1).poke(false)
      tb.clock.step(100 * CLOCK_DIVIDER_FACTOR)

      for (i <- 0 until TEST_LEN) {
        tb.io.slave_buffer_peek(0)(i).expect((BigInt("deadbeefdeadbeef", 16) + i))
      }
    }
  }
}

class NetworkAXI4LiteWrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  implicit val p: Parameters = (new AXI4LiteConfig).toInstance

  it should "pass AXI4-Lite test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation
    )

    val CLOCK_DIVIDER_FACTOR = 4

    test(new AXI4LiteTestbench(CLOCK_DIVIDER_FACTOR)).withAnnotations(annotation) { tb =>
      tb.clock.step()
      for (i <- 0 until p(NUM_MASTER_DEVICES)) {
        tb.io.start_write(i).poke(false)
        tb.io.start_read(i).poke(false)
        tb.io.target_addr(i).poke((i + p(NUM_MASTER_DEVICES)).U)
      }
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_write(0).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_write(0).poke(false)
      tb.io.start_read(1).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start_read(1).poke(false)
      tb.clock.step(100 * CLOCK_DIVIDER_FACTOR)

      tb.io.master_buffer_peek(1).expect(BigInt("1234567812345678", 16))
      tb.io.slave_buffer_peek(0).expect(BigInt("deadbeefdeadbeef", 16))
    }
  }
}

class NetworkSimpleWrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  // Test simple wrapper with packet width = 72
  implicit val p: Parameters = (new SimpleConfig).toInstance.alterPartial({
    case PACKET_WIDTH => 72
  })

  it should "pass simple test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    val CLOCK_DIVIDER_FACTOR = 4

    test(new SimpleTestbench(CLOCK_DIVIDER_FACTOR)).withAnnotations(annotation) { tb =>
      val packet_0_2 = BigInt("e01234567812345678", 16)
      val packet_1_3 = BigInt("f1deadbeefdeadbeef", 16)

      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      for (i <- 0 until p(NUM_USER_SEND_PORTS)) {
        tb.io.send(i).bits.poke(0.U)
        tb.io.send(i).valid.poke(false.B)
      }
      for (i <- 0 until p(NUM_USER_RECV_PORTS)) {
        tb.io.recv(i).ready.poke(false.B)
      }
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.send(0).bits.poke(packet_0_2.asUInt)
      tb.io.send(0).valid.poke(true.B)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.send(0).bits.poke(0.U)
      tb.io.send(0).valid.poke(false.B)
      tb.io.send(1).bits.poke(packet_1_3.asUInt)
      tb.io.send(1).valid.poke(true.B)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.send(1).bits.poke(0.U)
      tb.io.send(1).valid.poke(false.B)
      tb.clock.step(50 * CLOCK_DIVIDER_FACTOR)

      tb.io.recv(2).bits.expect(packet_0_2)
      tb.io.recv(2).valid.expect(true)
      tb.io.recv(3).bits.expect(packet_1_3)
      tb.io.recv(3).valid.expect(true)
    }
  }
}

class NetworkAXI4StreamWrapperTester extends AnyFlatSpec with ChiselScalatestTester {
  implicit val p: Parameters = (new AXI4StreamConfig).toInstance

  it should "pass AXI4-Stream test" in {
    val annotation = Seq(
      VerilatorBackendAnnotation,
      WriteVcdAnnotation
    )

    val CLOCK_DIVIDER_FACTOR = 4
    val TEST_LEN             = 16

    test(new AXI4StreamTestbench(CLOCK_DIVIDER_FACTOR, TEST_LEN)).withAnnotations(annotation) { tb =>
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      for (i <- 0 until p(NUM_MASTER_DEVICES)) {
        tb.io.start(i).poke(false)
        tb.io.target_dest(i).poke(((i + p(NUM_MASTER_DEVICES) / 2) % p(NUM_MASTER_DEVICES)).U)
      }
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start(0).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start(0).poke(false)
      // tb.io.start(1).poke(true)
      tb.clock.step(CLOCK_DIVIDER_FACTOR)
      tb.io.start(1).poke(false)
      tb.clock.step(150 * CLOCK_DIVIDER_FACTOR)

      for (i <- 0 until TEST_LEN) {
        tb.io.slave_buffer_peek(2)(i).expect((BigInt("deadbeefdeadbeef", 16) + i))
        // tb.io.slave_buffer_peek(3)(i).expect((BigInt("deadbeefdeadbeef", 16) + i))
      }
    }
  }
}
