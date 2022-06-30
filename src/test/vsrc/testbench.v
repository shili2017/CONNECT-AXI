// `timescale 1ns / 1ps

`define NUM_USER_SEND_PORTS 4
`define NUM_USER_RECV_PORTS 4
`define NUM_VCS 2
`define FLIT_DATA_WIDTH 40

module Testbench (
    input clock,
    input reset
  );

  // non-VC routers still reeserve 1 dummy bit for VC.
  localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  localparam credit_port_width = 1 + vc_bits; // 1 valid bit
  localparam test_cycles = 200;

  // input regs
  reg send_flit [0:`NUM_USER_SEND_PORTS-1]; // enable sending flits
  reg [flit_port_width-1:0] flit_in [0:`NUM_USER_SEND_PORTS-1]; // send port inputs

  reg send_credit [0:`NUM_USER_RECV_PORTS-1]; // enable sending credits
  reg [credit_port_width-1:0] credit_in [0:`NUM_USER_RECV_PORTS-1]; //recv port credits

  // output wires
  wire [credit_port_width-1:0] credit_out [0:`NUM_USER_SEND_PORTS-1];
  wire [flit_port_width-1:0] flit_out [0:`NUM_USER_RECV_PORTS-1];

  reg [31:0] cycle;
  integer i;

  // packet fields
  reg is_valid;
  reg is_tail;
  reg [dest_bits-1:0] dest;
  reg [vc_bits-1:0]   vc;
  reg [`FLIT_DATA_WIDTH-1:0] data;

  // Run simulation 
  initial begin 
    for (i = 0; i < `NUM_USER_SEND_PORTS; i = i + 1) begin
      flit_in[i] = 0;
      send_flit[i] = 0;
    end
    for (i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin 
      credit_in[i] = 0;
      send_credit[i] = 0;
    end
  end

  always @( * ) begin
    send_flit[0] = 0;
    dest = 0;
    vc = 0;
    data = 0;
    flit_in[0] = 0;

    if (cycle == 4) begin
      send_flit[0] = 1'b1;
      dest = 1;
      data = 'ha;
      flit_in[0] = {1'b1 /*valid*/, 1'b0 /*tail*/, dest, vc, data};
      $display("@%3d: Injecting flit %x into send port %0d", cycle, flit_in[0], 0);
    end else if (cycle == 5) begin
      send_flit[0] = 1'b1;
      dest = 1;
      data = 'hb;
      flit_in[0] = {1'b1 /*valid*/, 1'b1 /*tail*/, dest, vc, data};
      $display("@%3d: Injecting flit %x into send port %0d", cycle, flit_in[0], 0);
    end
  end

  // Monitor arriving flits
  always @ (posedge clock) begin
    if (reset) begin
      cycle <= 0;
    end else begin
      cycle <= cycle + 1;
      // terminate simulation
      if (cycle > test_cycles)
        $finish();
    end

    for (i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin
      if (flit_out[i][flit_port_width-1]) begin // valid flit
        $display("@%3d: Ejecting flit %x at receive port %0d", cycle, flit_out[i], i);
      end
    end
  end

  // Instantiate CONNECT network
  Top dut
  (.clock(clock)
  ,.reset(reset)

  ,.io_send_ports_putFlit_flit_in_0(flit_in[0])
  ,.io_EN_send_ports_putFlit_0(send_flit[0])
  ,.io_EN_send_ports_getCredits_0(1'b1) // drain credits
  ,.io_send_ports_getCredits_0(credit_out[0])
  ,.io_EN_recv_ports_getFlit_0(1'b1) // drain flits
  ,.io_recv_ports_getFlit_0(flit_out[0])
  ,.io_recv_ports_putCredits_cr_in_0(credit_in[0])
  ,.io_EN_recv_ports_putCredits_0(send_credit[0])

  ,.io_send_ports_putFlit_flit_in_1(flit_in[1])
  ,.io_EN_send_ports_putFlit_1(send_flit[1])
  ,.io_EN_send_ports_getCredits_1(1'b1) // drain credits
  ,.io_send_ports_getCredits_1(credit_out[1])
  ,.io_EN_recv_ports_getFlit_1(1'b1) // drain flits
  ,.io_recv_ports_getFlit_1(flit_out[1])
  ,.io_recv_ports_putCredits_cr_in_1(credit_in[1])
  ,.io_EN_recv_ports_putCredits_1(send_credit[1])

  ,.io_send_ports_putFlit_flit_in_2(flit_in[2])
  ,.io_EN_send_ports_putFlit_2(send_flit[2])
  ,.io_EN_send_ports_getCredits_2(1'b1) // drain credits
  ,.io_send_ports_getCredits_2(credit_out[2])
  ,.io_EN_recv_ports_getFlit_2(1'b1) // drain flits
  ,.io_recv_ports_getFlit_2(flit_out[2])
  ,.io_recv_ports_putCredits_cr_in_2(credit_in[2])
  ,.io_EN_recv_ports_putCredits_2(send_credit[2])

  ,.io_send_ports_putFlit_flit_in_3(flit_in[3])
  ,.io_EN_send_ports_putFlit_3(send_flit[3])
  ,.io_EN_send_ports_getCredits_3(1'b1) // drain credits
  ,.io_send_ports_getCredits_3(credit_out[3])
  ,.io_EN_recv_ports_getFlit_3(1'b1) // drain flits
  ,.io_recv_ports_getFlit_3(flit_out[3])
  ,.io_recv_ports_putCredits_cr_in_3(credit_in[3])
  ,.io_EN_recv_ports_putCredits_3(send_credit[3])
  );

endmodule
