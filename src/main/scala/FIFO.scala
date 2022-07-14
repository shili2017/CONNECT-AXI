package connect_axi

import chisel3._
import chisel3.util._
import java.io.File

class scfifo(
  lpm_width:               Int    = 1,
  lpm_widthu:              Int    = 1,
  lpm_numwords:            Int    = 2,
  lpm_showahead:           String = "OFF",
  lpm_type:                String = "scfifo",
  lpm_hint:                String = "USE_EAB=ON",
  intended_device_family:  String = "Stratix",
  underflow_checking:      String = "ON",
  overflow_checking:       String = "ON",
  allow_rwcycle_when_full: String = "OFF",
  use_eab:                 String = "ON",
  add_ram_output_register: String = "OFF",
  almost_full_value:       Int    = 0,
  almost_empty_value:      Int    = 0,
  maximum_depth:           Int    = 0,
  enable_ecc:              String = "FALSE")
    extends BlackBox(
      Map(
        "lpm_width"               -> lpm_width,
        "lpm_widthu"              -> lpm_widthu,
        "lpm_numwords"            -> lpm_numwords,
        "lpm_showahead"           -> lpm_showahead,
        "lpm_type"                -> lpm_type,
        "lpm_hint"                -> lpm_hint,
        "intended_device_family"  -> intended_device_family,
        "underflow_checking"      -> underflow_checking,
        "overflow_checking"       -> overflow_checking,
        "allow_rwcycle_when_full" -> allow_rwcycle_when_full,
        "use_eab"                 -> use_eab,
        "add_ram_output_register" -> add_ram_output_register,
        "almost_full_value"       -> almost_full_value,
        "almost_empty_value"      -> almost_empty_value,
        "maximum_depth"           -> maximum_depth,
        "enable_ecc"              -> enable_ecc
      )
    )
    with HasBlackBoxPath {
  val io = IO(new Bundle {
    val clock = Input(Clock())
    val sclr  = Input(Bool())
    val aclr  = Input(Bool())

    val data        = Input(UInt(lpm_width.W))
    val wrreq       = Input(Bool())
    val full        = Output(Bool())
    val almost_full = Output(Bool())

    val q            = Output(UInt(lpm_width.W))
    val rdreq        = Input(Bool())
    val empty        = Output(Bool())
    val almost_empty = Output(Bool())

    val eccstatus = Output(UInt(2.W))
    val usedw     = Output(UInt(lpm_widthu.W))
  })

  addPath(new File(Config.ALTERA_MF_V).getCanonicalPath)
}

class dcfifo(
  lpm_width:               Int    = 1,
  lpm_widthu:              Int    = 1,
  lpm_numwords:            Int    = 2,
  delay_rdusedw:           Int    = 1,
  delay_wrusedw:           Int    = 1,
  rdsync_delaypipe:        Int    = 0,
  wrsync_delaypipe:        Int    = 0,
  intended_device_family:  String = "Stratix",
  lpm_showahead:           String = "OFF",
  underflow_checking:      String = "ON",
  overflow_checking:       String = "ON",
  clocks_are_synchronized: String = "FALSE",
  use_eab:                 String = "ON",
  add_ram_output_register: String = "OFF",
  lpm_hint:                String = "USE_EAB=ON",
  lpm_type:                String = "dcfifo",
  add_usedw_msb_bit:       String = "OFF",
  read_aclr_synch:         String = "OFF",
  write_aclr_synch:        String = "OFF",
  enable_ecc:              String = "FALSE")
    extends BlackBox(
      Map(
        "lpm_width"               -> lpm_width,
        "lpm_widthu"              -> lpm_widthu,
        "lpm_numwords"            -> lpm_numwords,
        "delay_rdusedw"           -> delay_rdusedw,
        "delay_wrusedw"           -> delay_wrusedw,
        "rdsync_delaypipe"        -> rdsync_delaypipe,
        "wrsync_delaypipe"        -> wrsync_delaypipe,
        "intended_device_family"  -> intended_device_family,
        "lpm_showahead"           -> lpm_showahead,
        "underflow_checking"      -> underflow_checking,
        "overflow_checking"       -> overflow_checking,
        "clocks_are_synchronized" -> clocks_are_synchronized,
        "use_eab"                 -> use_eab,
        "add_ram_output_register" -> add_ram_output_register,
        "lpm_hint"                -> lpm_hint,
        "lpm_type"                -> lpm_type,
        "add_usedw_msb_bit"       -> add_usedw_msb_bit,
        "read_aclr_synch"         -> read_aclr_synch,
        "write_aclr_synch"        -> write_aclr_synch,
        "enable_ecc"              -> enable_ecc
      )
    )
    with HasBlackBoxPath {
  val io = IO(new Bundle {
    val aclr = Input(Bool())

    val wrclk   = Input(Clock())
    val data    = Input(UInt(lpm_width.W))
    val wrreq   = Input(Bool())
    val wrfull  = Output(Bool())
    val wrempty = Output(Bool())

    val rdclk   = Input(Clock())
    val q       = Output(UInt(lpm_width.W))
    val rdreq   = Input(Bool())
    val rdfull  = Output(Bool())
    val rdempty = Output(Bool())

    val eccstatus = Output(UInt(2.W))
    val wrusedw   = Output(UInt(lpm_widthu.W))
    val rdusedw   = Output(UInt(lpm_widthu.W))
  })

  addPath(new File(Config.ALTERA_MF_V).getCanonicalPath)
}
