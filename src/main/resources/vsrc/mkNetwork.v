`define BSV_POSITIVE_RESET
// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 17872 $
// $Date: 2009-09-18 14:32:56 +0000 (Fri, 18 Sep 2009) $

`ifdef BSV_ASSIGNMENT_DELAY
`else
 `define BSV_ASSIGNMENT_DELAY
`endif

// Single-Ported BRAM
module BRAM1(CLK,
             EN,
             WE,
             ADDR,
             DI,
             DO
             );

   // synopsys template
   parameter                      PIPELINED  = 0;
   parameter                      ADDR_WIDTH = 1;
   parameter                      DATA_WIDTH = 1;
   parameter                      MEMSIZE    = 1;

   
   input                          CLK;
   input                          EN;
   input                          WE;
   input [ADDR_WIDTH-1:0]         ADDR;
   input [DATA_WIDTH-1:0]         DI;
   output [DATA_WIDTH-1:0]        DO;

   reg [DATA_WIDTH-1:0]           RAM[0:MEMSIZE-1];
   reg [ADDR_WIDTH-1:0]           ADDR_R;
   reg [DATA_WIDTH-1:0]           DO_R;

`ifdef BSV_NO_INITIAL_BLOCKS
`else
   // synopsys translate_off
   integer                        i;
   initial
   begin : init_block
      for (i = 0; i < MEMSIZE; i = i + 1) begin
         RAM[i] = { ((DATA_WIDTH+1)/2) { 2'b10 } };
      end
      ADDR_R = { ((ADDR_WIDTH+1)/2) { 2'b10 } };
      DO_R = { ((DATA_WIDTH+1)/2) { 2'b10 } };
   end
   // synopsys translate_on
`endif // !`ifdef BSV_NO_INITIAL_BLOCKS

   always @(posedge CLK) begin
      if (EN) begin
         if (WE)
           RAM[ADDR] <= `BSV_ASSIGNMENT_DELAY DI;
         ADDR_R    <= `BSV_ASSIGNMENT_DELAY ADDR;
      end
      DO_R      <= `BSV_ASSIGNMENT_DELAY RAM[ADDR_R];
   end

   assign DO = (PIPELINED) ? DO_R : RAM[ADDR_R];

endmodule // BRAM1



// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 17872 $
// $Date: 2009-09-18 14:32:56 +0000 (Fri, 18 Sep 2009) $

`ifdef BSV_ASSIGNMENT_DELAY
`else
 `define BSV_ASSIGNMENT_DELAY
`endif

// Dual-Ported BRAM
module BRAM2(CLKA,
             ENA,
             WEA,
             ADDRA,
             DIA,
             DOA,
             CLKB,
             ENB,
             WEB,
             ADDRB,
             DIB,
             DOB
             );

   // synopsys template
   parameter                      PIPELINED  = 0;
   parameter                      ADDR_WIDTH = 1;
   parameter                      DATA_WIDTH = 1;
   parameter                      MEMSIZE    = 1;

   input                          CLKA;
   input                          ENA;
   input                          WEA;
   input [ADDR_WIDTH-1:0]         ADDRA;
   input [DATA_WIDTH-1:0]         DIA;
   output [DATA_WIDTH-1:0]        DOA;

   input                          CLKB;
   input                          ENB;
   input                          WEB;
   input [ADDR_WIDTH-1:0]         ADDRB;
   input [DATA_WIDTH-1:0]         DIB;
   output [DATA_WIDTH-1:0]        DOB;

   reg [DATA_WIDTH-1:0]           RAM[0:MEMSIZE-1] /* synthesis syn_ramstyle="no_rw_check" */ ;
   reg [ADDR_WIDTH-1:0]           ADDRA_R;
   reg [ADDR_WIDTH-1:0]           ADDRB_R;
   reg [DATA_WIDTH-1:0]           DOA_R;
   reg [DATA_WIDTH-1:0]           DOB_R;

   wire [DATA_WIDTH-1:0] 	  DOA_noreg;
   wire [DATA_WIDTH-1:0] 	  DOB_noreg;

   wire [ADDR_WIDTH-1:0] 	  ADDRA_muxed;
   wire [ADDR_WIDTH-1:0] 	  ADDRB_muxed;


`ifdef BSV_NO_INITIAL_BLOCKS
`else
   // synopsys translate_off
   integer                        i;
   initial
   begin : init_block
      for (i = 0; i < MEMSIZE; i = i + 1) begin
         RAM[i] = { ((DATA_WIDTH+1)/2) { 2'b10 } };
      end
      ADDRA_R = { ((ADDR_WIDTH+1)/2) { 2'b10 } };
      ADDRB_R = { ((ADDR_WIDTH+1)/2) { 2'b10 } };
      DOA_R = { ((DATA_WIDTH+1)/2) { 2'b10 } };
      DOB_R = { ((DATA_WIDTH+1)/2) { 2'b10 } };
   end
   // synopsys translate_on
`endif // !`ifdef BSV_NO_INITIAL_BLOCKS


   always @(posedge CLKA) begin
      ADDRA_R <= `BSV_ASSIGNMENT_DELAY ADDRA_muxed;
      if (ENA) begin
         if (WEA)
           RAM[ADDRA_muxed] <= `BSV_ASSIGNMENT_DELAY DIA;
      end
   end

   always @(posedge CLKB) begin
      ADDRB_R <= `BSV_ASSIGNMENT_DELAY ADDRB_muxed;
      if (ENB) begin
         if (WEB)
           RAM[ADDRB_muxed] <= `BSV_ASSIGNMENT_DELAY DIB;
      end
   end


   // ENA workaround for Synplify
   assign ADDRA_muxed = (ENA) ? ADDRA : ADDRA_R;
   assign ADDRB_muxed = (ENB) ? ADDRB : ADDRB_R;

   // Memory read
   assign DOA_noreg = RAM[ADDRA_R];
   assign DOB_noreg = RAM[ADDRB_R];

   // Pipeline
   always @(posedge CLKA)
      DOA_R <= DOA_noreg;

   always @(posedge CLKB)
      DOB_R <= DOB_noreg;

   // Output drivers
   assign DOA = (PIPELINED) ? DOA_R : DOA_noreg;
   assign DOB = (PIPELINED) ? DOB_R : DOB_noreg;

endmodule // BRAM2

// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 17872 $
// $Date: 2009-09-18 14:32:56 +0000 (Fri, 18 Sep 2009) $


module BypassWire(WGET, WVAL);

   // synopsys template
   
   parameter width = 1;
            
   input [width - 1 : 0]    WVAL;

   output [width - 1 : 0]   WGET;

   assign WGET = WVAL;

endmodule
/*
 * =========================================================================
 *
 * Filename:            RegFile_16ports.v
 * Date created:        03-29-2011
 * Last modified:       03-29-2011
 * Authors:		Michael Papamichael <papamixATcs.cmu.edu>
 *
 * Description:
 * 16-ported register file that maps to LUT RAM. Implements double-buffering
 * internally. Automatically switches to other array when last address is
 * written.
 * 
 */

// Multi-ported Register File
module DoubleBufferedRegFile_16ports(CLK, rst_n,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5,
               ADDR_6, D_OUT_6,
               ADDR_7, D_OUT_7,
               ADDR_8, D_OUT_8,
               ADDR_9, D_OUT_9,
               ADDR_10, D_OUT_10,
               ADDR_11, D_OUT_11,
               ADDR_12, D_OUT_12,
               ADDR_13, D_OUT_13,
               ADDR_14, D_OUT_14,
               ADDR_15, D_OUT_15,
               ADDR_16, D_OUT_16
               );

   // synopsys template   
   parameter                   data_width = 208;
   parameter                   addr_width = 8;
   parameter                   depth = 1<<addr_width;
   //parameter                   lo = 0;
   //parameter                   hi = 1;
   
   input                       CLK;
   input                       rst_n;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;
   
   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;
   
   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;
   
   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   input [addr_width - 1 : 0]  ADDR_6;
   output [data_width - 1 : 0] D_OUT_6;
   
   input [addr_width - 1 : 0]  ADDR_7;
   output [data_width - 1 : 0] D_OUT_7;
   
   input [addr_width - 1 : 0]  ADDR_8;
   output [data_width - 1 : 0] D_OUT_8;
   
   input [addr_width - 1 : 0]  ADDR_9;
   output [data_width - 1 : 0] D_OUT_9;
   
   input [addr_width - 1 : 0]  ADDR_10;
   output [data_width - 1 : 0] D_OUT_10;

   input [addr_width - 1 : 0]  ADDR_11;
   output [data_width - 1 : 0] D_OUT_11;
   
   input [addr_width - 1 : 0]  ADDR_12;
   output [data_width - 1 : 0] D_OUT_12;
   
   input [addr_width - 1 : 0]  ADDR_13;
   output [data_width - 1 : 0] D_OUT_13;
   
   input [addr_width - 1 : 0]  ADDR_14;
   output [data_width - 1 : 0] D_OUT_14;
   
   input [addr_width - 1 : 0]  ADDR_15;
   output [data_width - 1 : 0] D_OUT_15;

   input [addr_width - 1 : 0]  ADDR_16;
   output [data_width - 1 : 0] D_OUT_16;

   // synthesis attribute ram_style of arr is distributed

   //reg [data_width - 1 : 0]    arr[lo:hi];
   reg [data_width - 1 : 0]    arr[0 : depth-1];
   reg [data_width - 1 : 0]    arr_staging[0 : depth-1];
   reg current_arr;
   
   
//`ifdef BSV_NO_INITIAL_BLOCKS
//`else // not BSV_NO_INITIAL_BLOCKS
//   // synopsys translate_off
//   initial
//     begin : init_block
//        integer                     i; 		// temporary for generate reset value
//        for (i = lo; i <= hi; i = i + 1) begin
//           arr[i] = {((data_width + 1)/2){2'b10}} ;
//        end 
//     end // initial begin   
//   // synopsys translate_on
//`endif // BSV_NO_INITIAL_BLOCKS

// initialize
   integer 	       i;
   initial begin
      for(i=0;i<depth;i=i+1) begin
	 arr[i]=0;
      end
      current_arr = 0;
   end

   always@(posedge CLK)
     begin
       if (WE) begin
	  if(current_arr) begin
            arr_staging[ADDR_IN] <= D_IN;
	  end else begin
            arr[ADDR_IN] <= D_IN;
	  end
          //arr_staging[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
	  if(ADDR_IN == depth-1) begin // switch buffers
	    current_arr = ~current_arr;
	  end
       end
     end // always@ (posedge CLK)

   assign D_OUT_1  = current_arr ? arr[ADDR_1 ] : arr_staging[ADDR_1 ];
   assign D_OUT_2  = current_arr ? arr[ADDR_2 ] : arr_staging[ADDR_2 ];
   assign D_OUT_3  = current_arr ? arr[ADDR_3 ] : arr_staging[ADDR_3 ];
   assign D_OUT_4  = current_arr ? arr[ADDR_4 ] : arr_staging[ADDR_4 ];
   assign D_OUT_5  = current_arr ? arr[ADDR_5 ] : arr_staging[ADDR_5 ];
   assign D_OUT_6  = current_arr ? arr[ADDR_6 ] : arr_staging[ADDR_6 ];
   assign D_OUT_7  = current_arr ? arr[ADDR_7 ] : arr_staging[ADDR_7 ];
   assign D_OUT_8  = current_arr ? arr[ADDR_8 ] : arr_staging[ADDR_8 ];
   assign D_OUT_9  = current_arr ? arr[ADDR_9 ] : arr_staging[ADDR_9 ];
   assign D_OUT_10 = current_arr ? arr[ADDR_10] : arr_staging[ADDR_10];
   assign D_OUT_11 = current_arr ? arr[ADDR_11] : arr_staging[ADDR_11];
   assign D_OUT_12 = current_arr ? arr[ADDR_12] : arr_staging[ADDR_12];
   assign D_OUT_13 = current_arr ? arr[ADDR_13] : arr_staging[ADDR_13];
   assign D_OUT_14 = current_arr ? arr[ADDR_14] : arr_staging[ADDR_14];
   assign D_OUT_15 = current_arr ? arr[ADDR_15] : arr_staging[ADDR_15];
   assign D_OUT_16 = current_arr ? arr[ADDR_16] : arr_staging[ADDR_16];


endmodule



// Multi-ported Register File
module newDoubleBufferedRegFile_16ports(CLK, rst_n,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5,
               ADDR_6, D_OUT_6,
               ADDR_7, D_OUT_7,
               ADDR_8, D_OUT_8,
               ADDR_9, D_OUT_9,
               ADDR_10, D_OUT_10,
               ADDR_11, D_OUT_11,
               ADDR_12, D_OUT_12,
               ADDR_13, D_OUT_13,
               ADDR_14, D_OUT_14,
               ADDR_15, D_OUT_15,
               ADDR_16, D_OUT_16
               );

   // synopsys template   
   parameter                   data_width = 208;
   parameter                   addr_width = 8;
   parameter                   depth = 1<<addr_width;
   //parameter                   lo = 0;
   //parameter                   hi = 1;
   
   input                       CLK;
   input                       rst_n;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;
   
   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;
   
   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;
   
   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   input [addr_width - 1 : 0]  ADDR_6;
   output [data_width - 1 : 0] D_OUT_6;
   
   input [addr_width - 1 : 0]  ADDR_7;
   output [data_width - 1 : 0] D_OUT_7;
   
   input [addr_width - 1 : 0]  ADDR_8;
   output [data_width - 1 : 0] D_OUT_8;
   
   input [addr_width - 1 : 0]  ADDR_9;
   output [data_width - 1 : 0] D_OUT_9;
   
   input [addr_width - 1 : 0]  ADDR_10;
   output [data_width - 1 : 0] D_OUT_10;

   input [addr_width - 1 : 0]  ADDR_11;
   output [data_width - 1 : 0] D_OUT_11;
   
   input [addr_width - 1 : 0]  ADDR_12;
   output [data_width - 1 : 0] D_OUT_12;
   
   input [addr_width - 1 : 0]  ADDR_13;
   output [data_width - 1 : 0] D_OUT_13;
   
   input [addr_width - 1 : 0]  ADDR_14;
   output [data_width - 1 : 0] D_OUT_14;
   
   input [addr_width - 1 : 0]  ADDR_15;
   output [data_width - 1 : 0] D_OUT_15;

   input [addr_width - 1 : 0]  ADDR_16;
   output [data_width - 1 : 0] D_OUT_16;

   // synthesis attribute ram_style of arr is distributed

   //reg [data_width - 1 : 0]    arr[lo:hi];
   reg [data_width - 1 : 0]    arr[0 : depth-1];
   reg [data_width - 1 : 0]    arr_staging[0 : depth-1];
   
   
//`ifdef BSV_NO_INITIAL_BLOCKS
//`else // not BSV_NO_INITIAL_BLOCKS
//   // synopsys translate_off
//   initial
//     begin : init_block
//        integer                     i; 		// temporary for generate reset value
//        for (i = lo; i <= hi; i = i + 1) begin
//           arr[i] = {((data_width + 1)/2){2'b10}} ;
//        end 
//     end // initial begin   
//   // synopsys translate_on
//`endif // BSV_NO_INITIAL_BLOCKS

// initialize
   integer 	       i;
   initial begin
      for(i=0;i<depth;i=i+1) begin
	 arr[i]=0;
      end
   end

   always@(posedge CLK)
     begin
       if (WE) begin
	  if(ADDR_IN == depth-1) begin // switch buffers
            for(i=0;i<depth-1;i=i+1) begin
	      arr[i] <= arr_staging[i];
	    end
	    arr[depth-1] <= D_IN;
	    // copy arr_staging to arr
	  end else begin
            arr_staging[ADDR_IN] <= D_IN;
	  end

       end
     end // always@ (posedge CLK)

   assign D_OUT_1  = arr[ADDR_1 ];
   assign D_OUT_2  = arr[ADDR_2 ];
   assign D_OUT_3  = arr[ADDR_3 ];
   assign D_OUT_4  = arr[ADDR_4 ];
   assign D_OUT_5  = arr[ADDR_5 ];
   assign D_OUT_6  = arr[ADDR_6 ];
   assign D_OUT_7  = arr[ADDR_7 ];
   assign D_OUT_8  = arr[ADDR_8 ];
   assign D_OUT_9  = arr[ADDR_9 ];
   assign D_OUT_10 = arr[ADDR_10];
   assign D_OUT_11 = arr[ADDR_11];
   assign D_OUT_12 = arr[ADDR_12];
   assign D_OUT_13 = arr[ADDR_13];
   assign D_OUT_14 = arr[ADDR_14];
   assign D_OUT_15 = arr[ADDR_15];
   assign D_OUT_16 = arr[ADDR_16];


endmodule

module DPSRAM (
			      Rd,
						IdxR,
			      DoutR, 

     			  We,
			      IdxW,
			      DinW, 
				    clk,
			      rst_n
		      );

	// synthesis attribute BRAM_MAP of DPSRAM is "yes";

   parameter 	WIDTH = 1;
   parameter    ADDR_BITS = 9;
   parameter	DEPTH = 1<<ADDR_BITS; 
   
	 input									Rd;
   input [ADDR_BITS-1 : 0]  IdxR;
   output [WIDTH-1 : 0] DoutR; 

   input 	                We;
   input [ADDR_BITS-1 : 0]  IdxW;
   input [WIDTH-1 : 0]      DinW; 

   input 	       clk;
   input 	       rst_n;

   reg [WIDTH-1 : 0]     mem[0 : DEPTH-1];

//   reg 		            forward;
//   reg [WIDTH-1 : 0]    forwardData;
   reg [WIDTH-1 : 0]    sramData;

   integer 	       i;
   
   initial begin
      for(i=0;i<DEPTH;i=i+1) begin
				mem[i]=0;
      end
   end
   
	always @(posedge clk) begin
		sramData <= mem[IdxR];
		//forwardData <= DinW;
		//forward <= We && (IdxR==IdxW);
	end
	//assign DoutR = forward?forwardData:sramData;
	assign DoutR = sramData;

	always @(posedge clk) begin
		/*if(!rst_n) begin
			for(i=0;i<DEPTH;i=i+1) begin
				mem[i]<=0;
			end
		end else*/ begin
			if (We) begin
				mem[IdxW] <= DinW;
			end
		end
	end
endmodule


module DPSRAM_w_forward (
			      Rd,
						IdxR,
			      DoutR, 

     			  We,
			      IdxW,
			      DinW, 
				    clk,
			      rst_n
		      );

	// synthesis attribute BRAM_MAP of dpsram_withforward is "yes";

   parameter 	WIDTH = 1;
   parameter    ADDR_BITS = 9;
   parameter	DEPTH = 1<<ADDR_BITS; 
   
	 input									Rd;
   input [ADDR_BITS-1 : 0]  IdxR;
   output [WIDTH-1 : 0] DoutR; 

   input 	                We;
   input [ADDR_BITS-1 : 0]  IdxW;
   input [WIDTH-1 : 0]      DinW; 

   input 	       clk;
   input 	       rst_n;

   reg [WIDTH-1 : 0]     mem[0 : DEPTH-1];

   reg 		            forward;
   reg [WIDTH-1 : 0]    forwardData;
   reg [WIDTH-1 : 0]    sramData;

   integer 	       i;
   
   initial begin
      for(i=0;i<DEPTH;i=i+1) begin
				mem[i]=0;
      end
   end
   

	always @(posedge clk) begin
		sramData <= mem[IdxR];
		forwardData <= DinW;
		forward <= We && (IdxR==IdxW);
	end
	assign DoutR = forward?forwardData:sramData;

	always @(posedge clk) begin
		/*if(!rst_n) begin
			for(i=0;i<DEPTH;i=i+1) begin
				mem[i]<=0;
			end
		end else*/ begin
			if (We) begin
				mem[IdxW] <= DinW;
			end
		end
	end
endmodule


//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// select                         O     3
// CLK                            I     1 clock
// RST_N                          I     1 reset
// select_requests                I     3
// EN_next                        I     1
//
// Combinational paths from inputs to outputs:
//   select_requests -> select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkInputArbiter(CLK,
		      RST_N,

		      select_requests,
		      select,

		      EN_next);
  input  CLK;
  input  RST_N;

  // value method select
  input  [2 : 0] select_requests;
  output [2 : 0] select;

  // action method next
  input  EN_next;

  // signals for module outputs
  wire [2 : 0] select;

  // register arb_token
  reg [2 : 0] arb_token;
  wire [2 : 0] arb_token$D_IN;
  wire arb_token$EN;

  // remaining internal signals
  wire [1 : 0] gen_grant_carry___d12,
	       gen_grant_carry___d15,
	       gen_grant_carry___d17,
	       gen_grant_carry___d19,
	       gen_grant_carry___d4,
	       gen_grant_carry___d8;
  wire NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36,
       arb_token_BIT_0___h1109,
       arb_token_BIT_1___h1175,
       arb_token_BIT_2___h1241;

  // value method select
  assign select =
	     { gen_grant_carry___d12[1] || gen_grant_carry___d19[1],
	       !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	       (gen_grant_carry___d8[1] || gen_grant_carry___d17[1]),
	       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 } ;

  // register arb_token
  assign arb_token$D_IN = { arb_token[0], arb_token[2:1] } ;
  assign arb_token$EN = EN_next ;

  // remaining internal signals
  module_gen_grant_carry instance_gen_grant_carry_5(.gen_grant_carry_c(1'd0),
						    .gen_grant_carry_r(select_requests[0]),
						    .gen_grant_carry_p(arb_token_BIT_0___h1109),
						    .gen_grant_carry(gen_grant_carry___d4));
  module_gen_grant_carry instance_gen_grant_carry_1(.gen_grant_carry_c(gen_grant_carry___d4[0]),
						    .gen_grant_carry_r(select_requests[1]),
						    .gen_grant_carry_p(arb_token_BIT_1___h1175),
						    .gen_grant_carry(gen_grant_carry___d8));
  module_gen_grant_carry instance_gen_grant_carry_0(.gen_grant_carry_c(gen_grant_carry___d8[0]),
						    .gen_grant_carry_r(select_requests[2]),
						    .gen_grant_carry_p(arb_token_BIT_2___h1241),
						    .gen_grant_carry(gen_grant_carry___d12));
  module_gen_grant_carry instance_gen_grant_carry_2(.gen_grant_carry_c(gen_grant_carry___d12[0]),
						    .gen_grant_carry_r(select_requests[0]),
						    .gen_grant_carry_p(arb_token_BIT_0___h1109),
						    .gen_grant_carry(gen_grant_carry___d15));
  module_gen_grant_carry instance_gen_grant_carry_3(.gen_grant_carry_c(gen_grant_carry___d15[0]),
						    .gen_grant_carry_r(select_requests[1]),
						    .gen_grant_carry_p(arb_token_BIT_1___h1175),
						    .gen_grant_carry(gen_grant_carry___d17));
  module_gen_grant_carry instance_gen_grant_carry_4(.gen_grant_carry_c(gen_grant_carry___d17[0]),
						    .gen_grant_carry_r(select_requests[2]),
						    .gen_grant_carry_p(arb_token_BIT_2___h1241),
						    .gen_grant_carry(gen_grant_carry___d19));
  assign NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 =
	     !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	     !gen_grant_carry___d8[1] &&
	     !gen_grant_carry___d17[1] &&
	     (gen_grant_carry___d4[1] || gen_grant_carry___d15[1]) ;
  assign arb_token_BIT_0___h1109 = arb_token[0] ;
  assign arb_token_BIT_1___h1175 = arb_token[1] ;
  assign arb_token_BIT_2___h1241 = arb_token[2] ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        arb_token <= `BSV_ASSIGNMENT_DELAY 3'd1;
      end
    else
      begin
        if (arb_token$EN) arb_token <= `BSV_ASSIGNMENT_DELAY arb_token$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    arb_token = 3'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkInputArbiter

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:18 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// deq                            O    38
// notEmpty                       O     2 reg
// notFull                        O     2 reg
// CLK                            I     1 clock
// RST_N                          I     1 reset
// enq_fifo_in                    I     1
// enq_data_in                    I    38
// deq_fifo_out                   I     1
// EN_enq                         I     1
// EN_deq                         I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkInputVCQueues(CLK,
		       RST_N,

		       enq_fifo_in,
		       enq_data_in,
		       EN_enq,

		       deq_fifo_out,
		       EN_deq,
		       deq,

		       notEmpty,

		       notFull);
  input  CLK;
  input  RST_N;

  // action method enq
  input  enq_fifo_in;
  input  [37 : 0] enq_data_in;
  input  EN_enq;

  // actionvalue method deq
  input  deq_fifo_out;
  input  EN_deq;
  output [37 : 0] deq;

  // value method notEmpty
  output [1 : 0] notEmpty;

  // value method notFull
  output [1 : 0] notFull;

  // signals for module outputs
  wire [37 : 0] deq;
  wire [1 : 0] notEmpty, notFull;

  // inlined wires
  wire [1 : 0] inputVCQueues_ifc_mf_ifc_rdFIFO$wget,
	       inputVCQueues_ifc_mf_ifc_wrFIFO$wget;

  // register inputVCQueues_ifc_mf_ifc_heads_0
  reg [1 : 0] inputVCQueues_ifc_mf_ifc_heads_0;
  wire [1 : 0] inputVCQueues_ifc_mf_ifc_heads_0$D_IN;
  wire inputVCQueues_ifc_mf_ifc_heads_0$EN;

  // register inputVCQueues_ifc_mf_ifc_heads_1
  reg [1 : 0] inputVCQueues_ifc_mf_ifc_heads_1;
  wire [1 : 0] inputVCQueues_ifc_mf_ifc_heads_1$D_IN;
  wire inputVCQueues_ifc_mf_ifc_heads_1$EN;

  // register inputVCQueues_ifc_mf_ifc_not_empty_0
  reg inputVCQueues_ifc_mf_ifc_not_empty_0;
  wire inputVCQueues_ifc_mf_ifc_not_empty_0$D_IN,
       inputVCQueues_ifc_mf_ifc_not_empty_0$EN;

  // register inputVCQueues_ifc_mf_ifc_not_empty_1
  reg inputVCQueues_ifc_mf_ifc_not_empty_1;
  wire inputVCQueues_ifc_mf_ifc_not_empty_1$D_IN,
       inputVCQueues_ifc_mf_ifc_not_empty_1$EN;

  // register inputVCQueues_ifc_mf_ifc_not_full_0
  reg inputVCQueues_ifc_mf_ifc_not_full_0;
  wire inputVCQueues_ifc_mf_ifc_not_full_0$D_IN,
       inputVCQueues_ifc_mf_ifc_not_full_0$EN;

  // register inputVCQueues_ifc_mf_ifc_not_full_1
  reg inputVCQueues_ifc_mf_ifc_not_full_1;
  wire inputVCQueues_ifc_mf_ifc_not_full_1$D_IN,
       inputVCQueues_ifc_mf_ifc_not_full_1$EN;

  // register inputVCQueues_ifc_mf_ifc_tails_0
  reg [1 : 0] inputVCQueues_ifc_mf_ifc_tails_0;
  wire [1 : 0] inputVCQueues_ifc_mf_ifc_tails_0$D_IN;
  wire inputVCQueues_ifc_mf_ifc_tails_0$EN;

  // register inputVCQueues_ifc_mf_ifc_tails_1
  reg [1 : 0] inputVCQueues_ifc_mf_ifc_tails_1;
  wire [1 : 0] inputVCQueues_ifc_mf_ifc_tails_1$D_IN;
  wire inputVCQueues_ifc_mf_ifc_tails_1$EN;

  // ports of submodule inputVCQueues_ifc_mf_ifc_fifoMem
  wire [37 : 0] inputVCQueues_ifc_mf_ifc_fifoMem$D_IN,
		inputVCQueues_ifc_mf_ifc_fifoMem$D_OUT;
  wire [2 : 0] inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_IN,
	       inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_OUT;
  wire inputVCQueues_ifc_mf_ifc_fifoMem$WE;

  // remaining internal signals
  reg [1 : 0] fifoRdPtr__h3222, new_value__h3090, y__h2189, y__h2570;
  reg CASE_deq_fifo_out_0_inputVCQueues_ifc_mf_ifc_n_ETC__q2,
      CASE_enq_fifo_in_0_inputVCQueues_ifc_mf_ifc_no_ETC__q1,
      SEL_ARR_NOT_inputVCQueues_ifc_mf_ifc_not_full__ETC___d68;
  wire [1 : 0] x__h1614, x__h1841, x_wget__h1040, x_wget__h969;
  wire IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d43,
       IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d44,
       NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_empty_ETC___d82,
       NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_full__ETC___d71,
       NOT_inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_7__ETC___d41,
       NOT_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_5_OR__ETC___d59,
       _dfoo5,
       _dfoo7,
       inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_AND_in_ETC___d51,
       inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33;

  // actionvalue method deq
  assign deq = inputVCQueues_ifc_mf_ifc_fifoMem$D_OUT ;

  // value method notEmpty
  assign notEmpty =
	     { inputVCQueues_ifc_mf_ifc_not_empty_1,
	       inputVCQueues_ifc_mf_ifc_not_empty_0 } ;

  // value method notFull
  assign notFull =
	     { inputVCQueues_ifc_mf_ifc_not_full_1,
	       inputVCQueues_ifc_mf_ifc_not_full_0 } ;

  // submodule inputVCQueues_ifc_mf_ifc_fifoMem
  RegFile_1port #( /*data_width*/ 32'd38,
		   /*addr_width*/ 32'd3) inputVCQueues_ifc_mf_ifc_fifoMem(.CLK(CLK),
									  .rst_n(RST_N),
									  .ADDR_IN(inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_IN),
									  .ADDR_OUT(inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_OUT),
									  .D_IN(inputVCQueues_ifc_mf_ifc_fifoMem$D_IN),
									  .WE(inputVCQueues_ifc_mf_ifc_fifoMem$WE),
									  .D_OUT(inputVCQueues_ifc_mf_ifc_fifoMem$D_OUT));

  // inlined wires
  assign inputVCQueues_ifc_mf_ifc_wrFIFO$wget = { 1'd1, enq_fifo_in } ;
  assign inputVCQueues_ifc_mf_ifc_rdFIFO$wget = { 1'd1, deq_fifo_out } ;

  // register inputVCQueues_ifc_mf_ifc_heads_0
  assign inputVCQueues_ifc_mf_ifc_heads_0$D_IN = x__h1841 ;
  assign inputVCQueues_ifc_mf_ifc_heads_0$EN =
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd0 && EN_deq &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] ;

  // register inputVCQueues_ifc_mf_ifc_heads_1
  assign inputVCQueues_ifc_mf_ifc_heads_1$D_IN = x__h1841 ;
  assign inputVCQueues_ifc_mf_ifc_heads_1$EN =
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd1 && EN_deq &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] ;

  // register inputVCQueues_ifc_mf_ifc_not_empty_0
  assign inputVCQueues_ifc_mf_ifc_not_empty_0$D_IN =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd0 &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33 ;
  assign inputVCQueues_ifc_mf_ifc_not_empty_0$EN = _dfoo7 ;

  // register inputVCQueues_ifc_mf_ifc_not_empty_1
  assign inputVCQueues_ifc_mf_ifc_not_empty_1$D_IN =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd1 &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33 ;
  assign inputVCQueues_ifc_mf_ifc_not_empty_1$EN = _dfoo5 ;

  // register inputVCQueues_ifc_mf_ifc_not_full_0
  assign inputVCQueues_ifc_mf_ifc_not_full_0$D_IN =
	     !IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d43 ;
  assign inputVCQueues_ifc_mf_ifc_not_full_0$EN =
	     IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d43 ||
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd0 &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_AND_in_ETC___d51 ;

  // register inputVCQueues_ifc_mf_ifc_not_full_1
  assign inputVCQueues_ifc_mf_ifc_not_full_1$D_IN =
	     !IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d44 ;
  assign inputVCQueues_ifc_mf_ifc_not_full_1$EN =
	     IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d44 ||
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd1 &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_AND_in_ETC___d51 ;

  // register inputVCQueues_ifc_mf_ifc_tails_0
  assign inputVCQueues_ifc_mf_ifc_tails_0$D_IN = x__h1614 ;
  assign inputVCQueues_ifc_mf_ifc_tails_0$EN =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd0 && EN_enq &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] ;

  // register inputVCQueues_ifc_mf_ifc_tails_1
  assign inputVCQueues_ifc_mf_ifc_tails_1$D_IN = x__h1614 ;
  assign inputVCQueues_ifc_mf_ifc_tails_1$EN =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd1 && EN_enq &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] ;

  // submodule inputVCQueues_ifc_mf_ifc_fifoMem
  assign inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_IN =
	     { enq_fifo_in, new_value__h3090 } ;
  assign inputVCQueues_ifc_mf_ifc_fifoMem$ADDR_OUT =
	     { deq_fifo_out, fifoRdPtr__h3222 } ;
  assign inputVCQueues_ifc_mf_ifc_fifoMem$D_IN = enq_data_in ;
  assign inputVCQueues_ifc_mf_ifc_fifoMem$WE = EN_enq ;

  // remaining internal signals
  assign IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d43 =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd0 && EN_enq &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] &&
	     NOT_inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_7__ETC___d41 ;
  assign IF_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_in_ETC___d44 =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd1 && EN_enq &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] &&
	     NOT_inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_7__ETC___d41 ;
  assign NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_empty_ETC___d82 =
	     !CASE_deq_fifo_out_0_inputVCQueues_ifc_mf_ifc_n_ETC__q2 ;
  assign NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_full__ETC___d71 =
	     !CASE_enq_fifo_in_0_inputVCQueues_ifc_mf_ifc_no_ETC__q1 ;
  assign NOT_inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_7__ETC___d41 =
	     (!EN_deq || !inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] ||
	      inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] !=
	      inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0]) &&
	     x__h1614 == y__h2189 ;
  assign NOT_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_5_OR__ETC___d59 =
	     (!EN_enq || !inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] ||
	      inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] !=
	      inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0]) &&
	     x__h1841 == y__h2570 ;
  assign _dfoo5 =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd1 &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33 ||
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd1 && EN_deq &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] &&
	     NOT_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_5_OR__ETC___d59 ;
  assign _dfoo7 =
	     inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] == 1'd0 &&
	     inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33 ||
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] == 1'd0 && EN_deq &&
	     inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] &&
	     NOT_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_5_OR__ETC___d59 ;
  assign inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_AND_in_ETC___d51 =
	     EN_deq && inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] &&
	     (!EN_enq || !inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] ||
	      inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0] !=
	      inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0]) ;
  assign inputVCQueues_ifc_mf_ifc_wrFIFO_whas_AND_input_ETC___d33 =
	     EN_enq && inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] &&
	     (!EN_deq || !inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] ||
	      inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0] !=
	      inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0]) ;
  assign x__h1614 = EN_enq ? x_wget__h969 : 2'd0 ;
  assign x__h1841 = EN_deq ? x_wget__h1040 : 2'd0 ;
  assign x_wget__h1040 = fifoRdPtr__h3222 + 2'd1 ;
  assign x_wget__h969 = new_value__h3090 + 2'd1 ;
  always@(enq_fifo_in or
	  inputVCQueues_ifc_mf_ifc_tails_0 or
	  inputVCQueues_ifc_mf_ifc_tails_1)
  begin
    case (enq_fifo_in)
      1'd0: new_value__h3090 = inputVCQueues_ifc_mf_ifc_tails_0;
      1'd1: new_value__h3090 = inputVCQueues_ifc_mf_ifc_tails_1;
    endcase
  end
  always@(deq_fifo_out or
	  inputVCQueues_ifc_mf_ifc_heads_0 or
	  inputVCQueues_ifc_mf_ifc_heads_1)
  begin
    case (deq_fifo_out)
      1'd0: fifoRdPtr__h3222 = inputVCQueues_ifc_mf_ifc_heads_0;
      1'd1: fifoRdPtr__h3222 = inputVCQueues_ifc_mf_ifc_heads_1;
    endcase
  end
  always@(enq_fifo_in or
	  inputVCQueues_ifc_mf_ifc_not_full_0 or
	  inputVCQueues_ifc_mf_ifc_not_full_1)
  begin
    case (enq_fifo_in)
      1'd0:
	  SEL_ARR_NOT_inputVCQueues_ifc_mf_ifc_not_full__ETC___d68 =
	      !inputVCQueues_ifc_mf_ifc_not_full_0;
      1'd1:
	  SEL_ARR_NOT_inputVCQueues_ifc_mf_ifc_not_full__ETC___d68 =
	      !inputVCQueues_ifc_mf_ifc_not_full_1;
    endcase
  end
  always@(enq_fifo_in or
	  inputVCQueues_ifc_mf_ifc_not_full_0 or
	  inputVCQueues_ifc_mf_ifc_not_full_1)
  begin
    case (enq_fifo_in)
      1'd0:
	  CASE_enq_fifo_in_0_inputVCQueues_ifc_mf_ifc_no_ETC__q1 =
	      inputVCQueues_ifc_mf_ifc_not_full_0;
      1'd1:
	  CASE_enq_fifo_in_0_inputVCQueues_ifc_mf_ifc_no_ETC__q1 =
	      inputVCQueues_ifc_mf_ifc_not_full_1;
    endcase
  end
  always@(deq_fifo_out or
	  inputVCQueues_ifc_mf_ifc_not_empty_0 or
	  inputVCQueues_ifc_mf_ifc_not_empty_1)
  begin
    case (deq_fifo_out)
      1'd0:
	  CASE_deq_fifo_out_0_inputVCQueues_ifc_mf_ifc_n_ETC__q2 =
	      inputVCQueues_ifc_mf_ifc_not_empty_0;
      1'd1:
	  CASE_deq_fifo_out_0_inputVCQueues_ifc_mf_ifc_n_ETC__q2 =
	      inputVCQueues_ifc_mf_ifc_not_empty_1;
    endcase
  end
  always@(inputVCQueues_ifc_mf_ifc_wrFIFO$wget or
	  inputVCQueues_ifc_mf_ifc_heads_0 or
	  inputVCQueues_ifc_mf_ifc_heads_1)
  begin
    case (inputVCQueues_ifc_mf_ifc_wrFIFO$wget[0])
      1'd0: y__h2189 = inputVCQueues_ifc_mf_ifc_heads_0;
      1'd1: y__h2189 = inputVCQueues_ifc_mf_ifc_heads_1;
    endcase
  end
  always@(inputVCQueues_ifc_mf_ifc_rdFIFO$wget or
	  inputVCQueues_ifc_mf_ifc_tails_0 or
	  inputVCQueues_ifc_mf_ifc_tails_1)
  begin
    case (inputVCQueues_ifc_mf_ifc_rdFIFO$wget[0])
      1'd0: y__h2570 = inputVCQueues_ifc_mf_ifc_tails_0;
      1'd1: y__h2570 = inputVCQueues_ifc_mf_ifc_tails_1;
    endcase
  end

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        inputVCQueues_ifc_mf_ifc_heads_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inputVCQueues_ifc_mf_ifc_heads_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inputVCQueues_ifc_mf_ifc_not_empty_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	inputVCQueues_ifc_mf_ifc_not_empty_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	inputVCQueues_ifc_mf_ifc_not_full_0 <= `BSV_ASSIGNMENT_DELAY 1'd1;
	inputVCQueues_ifc_mf_ifc_not_full_1 <= `BSV_ASSIGNMENT_DELAY 1'd1;
	inputVCQueues_ifc_mf_ifc_tails_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inputVCQueues_ifc_mf_ifc_tails_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
      end
    else
      begin
        if (inputVCQueues_ifc_mf_ifc_heads_0$EN)
	  inputVCQueues_ifc_mf_ifc_heads_0 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_heads_0$D_IN;
	if (inputVCQueues_ifc_mf_ifc_heads_1$EN)
	  inputVCQueues_ifc_mf_ifc_heads_1 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_heads_1$D_IN;
	if (inputVCQueues_ifc_mf_ifc_not_empty_0$EN)
	  inputVCQueues_ifc_mf_ifc_not_empty_0 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_not_empty_0$D_IN;
	if (inputVCQueues_ifc_mf_ifc_not_empty_1$EN)
	  inputVCQueues_ifc_mf_ifc_not_empty_1 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_not_empty_1$D_IN;
	if (inputVCQueues_ifc_mf_ifc_not_full_0$EN)
	  inputVCQueues_ifc_mf_ifc_not_full_0 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_not_full_0$D_IN;
	if (inputVCQueues_ifc_mf_ifc_not_full_1$EN)
	  inputVCQueues_ifc_mf_ifc_not_full_1 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_not_full_1$D_IN;
	if (inputVCQueues_ifc_mf_ifc_tails_0$EN)
	  inputVCQueues_ifc_mf_ifc_tails_0 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_tails_0$D_IN;
	if (inputVCQueues_ifc_mf_ifc_tails_1$EN)
	  inputVCQueues_ifc_mf_ifc_tails_1 <= `BSV_ASSIGNMENT_DELAY
	      inputVCQueues_ifc_mf_ifc_tails_1$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    inputVCQueues_ifc_mf_ifc_heads_0 = 2'h2;
    inputVCQueues_ifc_mf_ifc_heads_1 = 2'h2;
    inputVCQueues_ifc_mf_ifc_not_empty_0 = 1'h0;
    inputVCQueues_ifc_mf_ifc_not_empty_1 = 1'h0;
    inputVCQueues_ifc_mf_ifc_not_full_0 = 1'h0;
    inputVCQueues_ifc_mf_ifc_not_full_1 = 1'h0;
    inputVCQueues_ifc_mf_ifc_tails_0 = 2'h2;
    inputVCQueues_ifc_mf_ifc_tails_1 = 2'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && SEL_ARR_NOT_inputVCQueues_ifc_mf_ifc_not_full__ETC___d68)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && SEL_ARR_NOT_inputVCQueues_ifc_mf_ifc_not_full__ETC___d68)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_full__ETC___d71)
	$display("Dynamic assertion failed: \"MultiFIFOMem.bsv\", line 156, column 38\nEnqueing to full FIFO in MultiFIFOMem!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_full__ETC___d71)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE) if (EN_enq) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_empty_ETC___d82)
	$display("Dynamic assertion failed: \"MultiFIFOMem.bsv\", line 190, column 40\nDequeing from empty FIFO in MultiFIFOMem!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && NOT_SEL_ARR_inputVCQueues_ifc_mf_ifc_not_empty_ETC___d82)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE) if (EN_deq) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && inputVCQueues_ifc_mf_ifc_wrFIFO$wget[1] &&
	  NOT_inputVCQueues_ifc_mf_ifc_rdFIFO_whas__4_7__ETC___d41)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && inputVCQueues_ifc_mf_ifc_rdFIFO$wget[1] &&
	  NOT_inputVCQueues_ifc_mf_ifc_wrFIFO_whas_5_OR__ETC___d59)
	$write("");
  end
  // synopsys translate_on
endmodule  // mkInputVCQueues

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:16 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// deq                            O   128
// notEmpty                       O     1 reg
// notFull                        O     1 reg
// CLK                            I     1 clock
// RST_N                          I     1 reset
// enq_data_in                    I   128
// EN_enq                         I     1
// EN_deq                         I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkMultiFIFOMemSynth(CLK,
			   RST_N,

			   enq_data_in,
			   EN_enq,

			   EN_deq,
			   deq,

			   notEmpty,

			   notFull);
  input  CLK;
  input  RST_N;

  // action method enq
  input  [127 : 0] enq_data_in;
  input  EN_enq;

  // actionvalue method deq
  input  EN_deq;
  output [127 : 0] deq;

  // value method notEmpty
  output notEmpty;

  // value method notFull
  output notFull;

  // signals for module outputs
  wire [127 : 0] deq;
  wire notEmpty, notFull;

  // register mf_mf_ifc_heads_0
  reg [1 : 0] mf_mf_ifc_heads_0;
  wire [1 : 0] mf_mf_ifc_heads_0$D_IN;
  wire mf_mf_ifc_heads_0$EN;

  // register mf_mf_ifc_not_empty_0
  reg mf_mf_ifc_not_empty_0;
  wire mf_mf_ifc_not_empty_0$D_IN, mf_mf_ifc_not_empty_0$EN;

  // register mf_mf_ifc_not_full_0
  reg mf_mf_ifc_not_full_0;
  wire mf_mf_ifc_not_full_0$D_IN, mf_mf_ifc_not_full_0$EN;

  // register mf_mf_ifc_tails_0
  reg [1 : 0] mf_mf_ifc_tails_0;
  wire [1 : 0] mf_mf_ifc_tails_0$D_IN;
  wire mf_mf_ifc_tails_0$EN;

  // ports of submodule mf_mf_ifc_fifoMem
  wire [127 : 0] mf_mf_ifc_fifoMem$D_IN, mf_mf_ifc_fifoMem$D_OUT;
  wire [1 : 0] mf_mf_ifc_fifoMem$ADDR_IN, mf_mf_ifc_fifoMem$ADDR_OUT;
  wire mf_mf_ifc_fifoMem$WE;

  // remaining internal signals
  wire [1 : 0] x__h1354, x__h1530, x_wget__h738, x_wget__h809;
  wire mf_mf_ifc_rdFIFO_whas_AND_mf_mf_ifc_rdFIFO_wge_ETC___d28,
       mf_mf_ifc_wrFIFO_whas_AND_mf_mf_ifc_wrFIFO_wge_ETC___d20;

  // actionvalue method deq
  assign deq = mf_mf_ifc_fifoMem$D_OUT ;

  // value method notEmpty
  assign notEmpty = mf_mf_ifc_not_empty_0 ;

  // value method notFull
  assign notFull = mf_mf_ifc_not_full_0 ;

  // submodule mf_mf_ifc_fifoMem
  RegFile_1port #( /*data_width*/ 32'd128,
		   /*addr_width*/ 32'd2) mf_mf_ifc_fifoMem(.CLK(CLK),
							   .rst_n(RST_N),
							   .ADDR_IN(mf_mf_ifc_fifoMem$ADDR_IN),
							   .ADDR_OUT(mf_mf_ifc_fifoMem$ADDR_OUT),
							   .D_IN(mf_mf_ifc_fifoMem$D_IN),
							   .WE(mf_mf_ifc_fifoMem$WE),
							   .D_OUT(mf_mf_ifc_fifoMem$D_OUT));

  // register mf_mf_ifc_heads_0
  assign mf_mf_ifc_heads_0$D_IN = x__h1530 ;
  assign mf_mf_ifc_heads_0$EN = EN_deq ;

  // register mf_mf_ifc_not_empty_0
  assign mf_mf_ifc_not_empty_0$D_IN = EN_enq && !EN_deq ;
  assign mf_mf_ifc_not_empty_0$EN =
	     EN_enq && !EN_deq ||
	     mf_mf_ifc_rdFIFO_whas_AND_mf_mf_ifc_rdFIFO_wge_ETC___d28 ;

  // register mf_mf_ifc_not_full_0
  assign mf_mf_ifc_not_full_0$D_IN =
	     !mf_mf_ifc_wrFIFO_whas_AND_mf_mf_ifc_wrFIFO_wge_ETC___d20 ;
  assign mf_mf_ifc_not_full_0$EN =
	     mf_mf_ifc_wrFIFO_whas_AND_mf_mf_ifc_wrFIFO_wge_ETC___d20 ||
	     EN_deq && !EN_enq ;

  // register mf_mf_ifc_tails_0
  assign mf_mf_ifc_tails_0$D_IN = x__h1354 ;
  assign mf_mf_ifc_tails_0$EN = EN_enq ;

  // submodule mf_mf_ifc_fifoMem
  assign mf_mf_ifc_fifoMem$ADDR_IN = mf_mf_ifc_tails_0 ;
  assign mf_mf_ifc_fifoMem$ADDR_OUT = mf_mf_ifc_heads_0 ;
  assign mf_mf_ifc_fifoMem$D_IN = enq_data_in ;
  assign mf_mf_ifc_fifoMem$WE = EN_enq ;

  // remaining internal signals
  assign mf_mf_ifc_rdFIFO_whas_AND_mf_mf_ifc_rdFIFO_wge_ETC___d28 =
	     EN_deq && !EN_enq && x__h1530 == mf_mf_ifc_tails_0 ;
  assign mf_mf_ifc_wrFIFO_whas_AND_mf_mf_ifc_wrFIFO_wge_ETC___d20 =
	     EN_enq && !EN_deq && x__h1354 == mf_mf_ifc_heads_0 ;
  assign x__h1354 = EN_enq ? x_wget__h738 : 2'd0 ;
  assign x__h1530 = EN_deq ? x_wget__h809 : 2'd0 ;
  assign x_wget__h738 = mf_mf_ifc_tails_0 + 2'd1 ;
  assign x_wget__h809 = mf_mf_ifc_heads_0 + 2'd1 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        mf_mf_ifc_heads_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	mf_mf_ifc_not_empty_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	mf_mf_ifc_not_full_0 <= `BSV_ASSIGNMENT_DELAY 1'd1;
	mf_mf_ifc_tails_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
      end
    else
      begin
        if (mf_mf_ifc_heads_0$EN)
	  mf_mf_ifc_heads_0 <= `BSV_ASSIGNMENT_DELAY mf_mf_ifc_heads_0$D_IN;
	if (mf_mf_ifc_not_empty_0$EN)
	  mf_mf_ifc_not_empty_0 <= `BSV_ASSIGNMENT_DELAY
	      mf_mf_ifc_not_empty_0$D_IN;
	if (mf_mf_ifc_not_full_0$EN)
	  mf_mf_ifc_not_full_0 <= `BSV_ASSIGNMENT_DELAY
	      mf_mf_ifc_not_full_0$D_IN;
	if (mf_mf_ifc_tails_0$EN)
	  mf_mf_ifc_tails_0 <= `BSV_ASSIGNMENT_DELAY mf_mf_ifc_tails_0$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    mf_mf_ifc_heads_0 = 2'h2;
    mf_mf_ifc_not_empty_0 = 1'h0;
    mf_mf_ifc_not_full_0 = 1'h0;
    mf_mf_ifc_tails_0 = 2'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && !mf_mf_ifc_not_full_0) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && !mf_mf_ifc_not_full_0) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && !mf_mf_ifc_not_full_0)
	$display("Dynamic assertion failed: \"MultiFIFOMem.bsv\", line 156, column 38\nEnqueing to full FIFO in MultiFIFOMem!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && !mf_mf_ifc_not_full_0) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE) if (EN_enq) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && !mf_mf_ifc_not_empty_0)
	$display("Dynamic assertion failed: \"MultiFIFOMem.bsv\", line 190, column 40\nDequeing from empty FIFO in MultiFIFOMem!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && !mf_mf_ifc_not_empty_0) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE) if (EN_deq) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (mf_mf_ifc_wrFIFO_whas_AND_mf_mf_ifc_wrFIFO_wge_ETC___d20)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (mf_mf_ifc_rdFIFO_whas_AND_mf_mf_ifc_rdFIFO_wge_ETC___d28)
	$write("");
  end
  // synopsys translate_on
endmodule  // mkMultiFIFOMemSynth

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:20 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// send_ports_0_getCredits        O     2
// send_ports_1_getCredits        O     2
// send_ports_2_getCredits        O     2
// send_ports_3_getCredits        O     2
// recv_ports_0_getFlit           O    39
// recv_ports_1_getFlit           O    39
// recv_ports_2_getFlit           O    39
// recv_ports_3_getFlit           O    39
// recv_ports_info_0_getRecvPortID  O     2 const
// recv_ports_info_1_getRecvPortID  O     2 const
// recv_ports_info_2_getRecvPortID  O     2 const
// recv_ports_info_3_getRecvPortID  O     2 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// send_ports_0_putFlit_flit_in   I    39
// send_ports_1_putFlit_flit_in   I    39
// send_ports_2_putFlit_flit_in   I    39
// send_ports_3_putFlit_flit_in   I    39
// recv_ports_0_putCredits_cr_in  I     2
// recv_ports_1_putCredits_cr_in  I     2
// recv_ports_2_putCredits_cr_in  I     2
// recv_ports_3_putCredits_cr_in  I     2
// EN_send_ports_0_putFlit        I     1
// EN_send_ports_1_putFlit        I     1
// EN_send_ports_2_putFlit        I     1
// EN_send_ports_3_putFlit        I     1
// EN_recv_ports_0_putCredits     I     1
// EN_recv_ports_1_putCredits     I     1
// EN_recv_ports_2_putCredits     I     1
// EN_recv_ports_3_putCredits     I     1
// EN_send_ports_0_getCredits     I     1 unused
// EN_send_ports_1_getCredits     I     1 unused
// EN_send_ports_2_getCredits     I     1 unused
// EN_send_ports_3_getCredits     I     1 unused
// EN_recv_ports_0_getFlit        I     1
// EN_recv_ports_1_getFlit        I     1
// EN_recv_ports_2_getFlit        I     1
// EN_recv_ports_3_getFlit        I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkNetwork(CLK,
		 RST_N,

		 send_ports_0_putFlit_flit_in,
		 EN_send_ports_0_putFlit,

		 EN_send_ports_0_getCredits,
		 send_ports_0_getCredits,

		 send_ports_1_putFlit_flit_in,
		 EN_send_ports_1_putFlit,

		 EN_send_ports_1_getCredits,
		 send_ports_1_getCredits,

		 send_ports_2_putFlit_flit_in,
		 EN_send_ports_2_putFlit,

		 EN_send_ports_2_getCredits,
		 send_ports_2_getCredits,

		 send_ports_3_putFlit_flit_in,
		 EN_send_ports_3_putFlit,

		 EN_send_ports_3_getCredits,
		 send_ports_3_getCredits,

		 EN_recv_ports_0_getFlit,
		 recv_ports_0_getFlit,

		 recv_ports_0_putCredits_cr_in,
		 EN_recv_ports_0_putCredits,

		 EN_recv_ports_1_getFlit,
		 recv_ports_1_getFlit,

		 recv_ports_1_putCredits_cr_in,
		 EN_recv_ports_1_putCredits,

		 EN_recv_ports_2_getFlit,
		 recv_ports_2_getFlit,

		 recv_ports_2_putCredits_cr_in,
		 EN_recv_ports_2_putCredits,

		 EN_recv_ports_3_getFlit,
		 recv_ports_3_getFlit,

		 recv_ports_3_putCredits_cr_in,
		 EN_recv_ports_3_putCredits,

		 recv_ports_info_0_getRecvPortID,

		 recv_ports_info_1_getRecvPortID,

		 recv_ports_info_2_getRecvPortID,

		 recv_ports_info_3_getRecvPortID);
  input  CLK;
  input  RST_N;

  // action method send_ports_0_putFlit
  input  [38 : 0] send_ports_0_putFlit_flit_in;
  input  EN_send_ports_0_putFlit;

  // actionvalue method send_ports_0_getCredits
  input  EN_send_ports_0_getCredits;
  output [1 : 0] send_ports_0_getCredits;

  // action method send_ports_1_putFlit
  input  [38 : 0] send_ports_1_putFlit_flit_in;
  input  EN_send_ports_1_putFlit;

  // actionvalue method send_ports_1_getCredits
  input  EN_send_ports_1_getCredits;
  output [1 : 0] send_ports_1_getCredits;

  // action method send_ports_2_putFlit
  input  [38 : 0] send_ports_2_putFlit_flit_in;
  input  EN_send_ports_2_putFlit;

  // actionvalue method send_ports_2_getCredits
  input  EN_send_ports_2_getCredits;
  output [1 : 0] send_ports_2_getCredits;

  // action method send_ports_3_putFlit
  input  [38 : 0] send_ports_3_putFlit_flit_in;
  input  EN_send_ports_3_putFlit;

  // actionvalue method send_ports_3_getCredits
  input  EN_send_ports_3_getCredits;
  output [1 : 0] send_ports_3_getCredits;

  // actionvalue method recv_ports_0_getFlit
  input  EN_recv_ports_0_getFlit;
  output [38 : 0] recv_ports_0_getFlit;

  // action method recv_ports_0_putCredits
  input  [1 : 0] recv_ports_0_putCredits_cr_in;
  input  EN_recv_ports_0_putCredits;

  // actionvalue method recv_ports_1_getFlit
  input  EN_recv_ports_1_getFlit;
  output [38 : 0] recv_ports_1_getFlit;

  // action method recv_ports_1_putCredits
  input  [1 : 0] recv_ports_1_putCredits_cr_in;
  input  EN_recv_ports_1_putCredits;

  // actionvalue method recv_ports_2_getFlit
  input  EN_recv_ports_2_getFlit;
  output [38 : 0] recv_ports_2_getFlit;

  // action method recv_ports_2_putCredits
  input  [1 : 0] recv_ports_2_putCredits_cr_in;
  input  EN_recv_ports_2_putCredits;

  // actionvalue method recv_ports_3_getFlit
  input  EN_recv_ports_3_getFlit;
  output [38 : 0] recv_ports_3_getFlit;

  // action method recv_ports_3_putCredits
  input  [1 : 0] recv_ports_3_putCredits_cr_in;
  input  EN_recv_ports_3_putCredits;

  // value method recv_ports_info_0_getRecvPortID
  output [1 : 0] recv_ports_info_0_getRecvPortID;

  // value method recv_ports_info_1_getRecvPortID
  output [1 : 0] recv_ports_info_1_getRecvPortID;

  // value method recv_ports_info_2_getRecvPortID
  output [1 : 0] recv_ports_info_2_getRecvPortID;

  // value method recv_ports_info_3_getRecvPortID
  output [1 : 0] recv_ports_info_3_getRecvPortID;

  // signals for module outputs
  wire [38 : 0] recv_ports_0_getFlit,
		recv_ports_1_getFlit,
		recv_ports_2_getFlit,
		recv_ports_3_getFlit;
  wire [1 : 0] recv_ports_info_0_getRecvPortID,
	       recv_ports_info_1_getRecvPortID,
	       recv_ports_info_2_getRecvPortID,
	       recv_ports_info_3_getRecvPortID,
	       send_ports_0_getCredits,
	       send_ports_1_getCredits,
	       send_ports_2_getCredits,
	       send_ports_3_getCredits;

  // ports of submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf
  wire [1 : 0] net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1;
  wire net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$WE;

  // ports of submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf
  wire [1 : 0] net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1;
  wire net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$WE;

  // ports of submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf
  wire [1 : 0] net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1;
  wire net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$WE;

  // ports of submodule net_routers_0_router_core
  wire [40 : 0] net_routers_0_router_core$in_ports_0_putRoutedFlit_flit_in,
		net_routers_0_router_core$in_ports_1_putRoutedFlit_flit_in,
		net_routers_0_router_core$in_ports_2_putRoutedFlit_flit_in;
  wire [38 : 0] net_routers_0_router_core$out_ports_0_getFlit,
		net_routers_0_router_core$out_ports_1_getFlit,
		net_routers_0_router_core$out_ports_2_getFlit;
  wire [1 : 0] net_routers_0_router_core$in_ports_0_getCredits,
	       net_routers_0_router_core$in_ports_1_getCredits,
	       net_routers_0_router_core$in_ports_2_getCredits,
	       net_routers_0_router_core$out_ports_0_putCredits_cr_in,
	       net_routers_0_router_core$out_ports_1_putCredits_cr_in,
	       net_routers_0_router_core$out_ports_2_putCredits_cr_in;
  wire net_routers_0_router_core$EN_in_ports_0_getCredits,
       net_routers_0_router_core$EN_in_ports_0_putRoutedFlit,
       net_routers_0_router_core$EN_in_ports_1_getCredits,
       net_routers_0_router_core$EN_in_ports_1_putRoutedFlit,
       net_routers_0_router_core$EN_in_ports_2_getCredits,
       net_routers_0_router_core$EN_in_ports_2_putRoutedFlit,
       net_routers_0_router_core$EN_out_ports_0_getFlit,
       net_routers_0_router_core$EN_out_ports_0_putCredits,
       net_routers_0_router_core$EN_out_ports_1_getFlit,
       net_routers_0_router_core$EN_out_ports_1_putCredits,
       net_routers_0_router_core$EN_out_ports_2_getFlit,
       net_routers_0_router_core$EN_out_ports_2_putCredits;

  // ports of submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf
  wire [1 : 0] net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1;
  wire net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$WE;

  // ports of submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf
  wire [1 : 0] net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1;
  wire net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$WE;

  // ports of submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf
  wire [1 : 0] net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1;
  wire net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$WE;

  // ports of submodule net_routers_1_router_core
  wire [40 : 0] net_routers_1_router_core$in_ports_0_putRoutedFlit_flit_in,
		net_routers_1_router_core$in_ports_1_putRoutedFlit_flit_in,
		net_routers_1_router_core$in_ports_2_putRoutedFlit_flit_in;
  wire [38 : 0] net_routers_1_router_core$out_ports_0_getFlit,
		net_routers_1_router_core$out_ports_1_getFlit,
		net_routers_1_router_core$out_ports_2_getFlit;
  wire [1 : 0] net_routers_1_router_core$in_ports_0_getCredits,
	       net_routers_1_router_core$in_ports_1_getCredits,
	       net_routers_1_router_core$in_ports_2_getCredits,
	       net_routers_1_router_core$out_ports_0_putCredits_cr_in,
	       net_routers_1_router_core$out_ports_1_putCredits_cr_in,
	       net_routers_1_router_core$out_ports_2_putCredits_cr_in;
  wire net_routers_1_router_core$EN_in_ports_0_getCredits,
       net_routers_1_router_core$EN_in_ports_0_putRoutedFlit,
       net_routers_1_router_core$EN_in_ports_1_getCredits,
       net_routers_1_router_core$EN_in_ports_1_putRoutedFlit,
       net_routers_1_router_core$EN_in_ports_2_getCredits,
       net_routers_1_router_core$EN_in_ports_2_putRoutedFlit,
       net_routers_1_router_core$EN_out_ports_0_getFlit,
       net_routers_1_router_core$EN_out_ports_0_putCredits,
       net_routers_1_router_core$EN_out_ports_1_getFlit,
       net_routers_1_router_core$EN_out_ports_1_putCredits,
       net_routers_1_router_core$EN_out_ports_2_getFlit,
       net_routers_1_router_core$EN_out_ports_2_putCredits;

  // ports of submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf
  wire [1 : 0] net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1;
  wire net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$WE;

  // ports of submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf
  wire [1 : 0] net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1;
  wire net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$WE;

  // ports of submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf
  wire [1 : 0] net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1;
  wire net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$WE;

  // ports of submodule net_routers_2_router_core
  wire [40 : 0] net_routers_2_router_core$in_ports_0_putRoutedFlit_flit_in,
		net_routers_2_router_core$in_ports_1_putRoutedFlit_flit_in,
		net_routers_2_router_core$in_ports_2_putRoutedFlit_flit_in;
  wire [38 : 0] net_routers_2_router_core$out_ports_0_getFlit,
		net_routers_2_router_core$out_ports_1_getFlit,
		net_routers_2_router_core$out_ports_2_getFlit;
  wire [1 : 0] net_routers_2_router_core$in_ports_0_getCredits,
	       net_routers_2_router_core$in_ports_1_getCredits,
	       net_routers_2_router_core$in_ports_2_getCredits,
	       net_routers_2_router_core$out_ports_0_putCredits_cr_in,
	       net_routers_2_router_core$out_ports_1_putCredits_cr_in,
	       net_routers_2_router_core$out_ports_2_putCredits_cr_in;
  wire net_routers_2_router_core$EN_in_ports_0_getCredits,
       net_routers_2_router_core$EN_in_ports_0_putRoutedFlit,
       net_routers_2_router_core$EN_in_ports_1_getCredits,
       net_routers_2_router_core$EN_in_ports_1_putRoutedFlit,
       net_routers_2_router_core$EN_in_ports_2_getCredits,
       net_routers_2_router_core$EN_in_ports_2_putRoutedFlit,
       net_routers_2_router_core$EN_out_ports_0_getFlit,
       net_routers_2_router_core$EN_out_ports_0_putCredits,
       net_routers_2_router_core$EN_out_ports_1_getFlit,
       net_routers_2_router_core$EN_out_ports_1_putCredits,
       net_routers_2_router_core$EN_out_ports_2_getFlit,
       net_routers_2_router_core$EN_out_ports_2_putCredits;

  // ports of submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf
  wire [1 : 0] net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1;
  wire net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$WE;

  // ports of submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf
  wire [1 : 0] net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1;
  wire net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$WE;

  // ports of submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf
  wire [1 : 0] net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1;
  wire net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$WE;

  // ports of submodule net_routers_3_router_core
  wire [40 : 0] net_routers_3_router_core$in_ports_0_putRoutedFlit_flit_in,
		net_routers_3_router_core$in_ports_1_putRoutedFlit_flit_in,
		net_routers_3_router_core$in_ports_2_putRoutedFlit_flit_in;
  wire [38 : 0] net_routers_3_router_core$out_ports_0_getFlit,
		net_routers_3_router_core$out_ports_1_getFlit,
		net_routers_3_router_core$out_ports_2_getFlit;
  wire [1 : 0] net_routers_3_router_core$in_ports_0_getCredits,
	       net_routers_3_router_core$in_ports_1_getCredits,
	       net_routers_3_router_core$in_ports_2_getCredits,
	       net_routers_3_router_core$out_ports_0_putCredits_cr_in,
	       net_routers_3_router_core$out_ports_1_putCredits_cr_in,
	       net_routers_3_router_core$out_ports_2_putCredits_cr_in;
  wire net_routers_3_router_core$EN_in_ports_0_getCredits,
       net_routers_3_router_core$EN_in_ports_0_putRoutedFlit,
       net_routers_3_router_core$EN_in_ports_1_getCredits,
       net_routers_3_router_core$EN_in_ports_1_putRoutedFlit,
       net_routers_3_router_core$EN_in_ports_2_getCredits,
       net_routers_3_router_core$EN_in_ports_2_putRoutedFlit,
       net_routers_3_router_core$EN_out_ports_0_getFlit,
       net_routers_3_router_core$EN_out_ports_0_putCredits,
       net_routers_3_router_core$EN_out_ports_1_getFlit,
       net_routers_3_router_core$EN_out_ports_1_putCredits,
       net_routers_3_router_core$EN_out_ports_2_getFlit,
       net_routers_3_router_core$EN_out_ports_2_putCredits;

  // actionvalue method send_ports_0_getCredits
  assign send_ports_0_getCredits =
	     net_routers_0_router_core$in_ports_0_getCredits ;

  // actionvalue method send_ports_1_getCredits
  assign send_ports_1_getCredits =
	     net_routers_1_router_core$in_ports_0_getCredits ;

  // actionvalue method send_ports_2_getCredits
  assign send_ports_2_getCredits =
	     net_routers_2_router_core$in_ports_0_getCredits ;

  // actionvalue method send_ports_3_getCredits
  assign send_ports_3_getCredits =
	     net_routers_3_router_core$in_ports_0_getCredits ;

  // actionvalue method recv_ports_0_getFlit
  assign recv_ports_0_getFlit =
	     net_routers_0_router_core$out_ports_0_getFlit ;

  // actionvalue method recv_ports_1_getFlit
  assign recv_ports_1_getFlit =
	     net_routers_1_router_core$out_ports_0_getFlit ;

  // actionvalue method recv_ports_2_getFlit
  assign recv_ports_2_getFlit =
	     net_routers_2_router_core$out_ports_0_getFlit ;

  // actionvalue method recv_ports_3_getFlit
  assign recv_ports_3_getFlit =
	     net_routers_3_router_core$out_ports_0_getFlit ;

  // value method recv_ports_info_0_getRecvPortID
  assign recv_ports_info_0_getRecvPortID = 2'd0 ;

  // value method recv_ports_info_1_getRecvPortID
  assign recv_ports_info_1_getRecvPortID = 2'd1 ;

  // value method recv_ports_info_2_getRecvPortID
  assign recv_ports_info_2_getRecvPortID = 2'd2 ;

  // value method recv_ports_info_3_getRecvPortID
  assign recv_ports_info_3_getRecvPortID = 2'd3 ;

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_0.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1),
											 .ADDR_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN),
											 .D_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN),
											 .WE(net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$WE),
											 .D_OUT_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1));

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_0.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1),
											 .ADDR_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN),
											 .D_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN),
											 .WE(net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$WE),
											 .D_OUT_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1));

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_0.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1),
											 .ADDR_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN),
											 .D_IN(net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN),
											 .WE(net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$WE),
											 .D_OUT_1(net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1));

  // submodule net_routers_0_router_core
  mkRouterCore net_routers_0_router_core(.CLK(CLK),
					 .RST_N(RST_N),
					 .in_ports_0_putRoutedFlit_flit_in(net_routers_0_router_core$in_ports_0_putRoutedFlit_flit_in),
					 .in_ports_1_putRoutedFlit_flit_in(net_routers_0_router_core$in_ports_1_putRoutedFlit_flit_in),
					 .in_ports_2_putRoutedFlit_flit_in(net_routers_0_router_core$in_ports_2_putRoutedFlit_flit_in),
					 .out_ports_0_putCredits_cr_in(net_routers_0_router_core$out_ports_0_putCredits_cr_in),
					 .out_ports_1_putCredits_cr_in(net_routers_0_router_core$out_ports_1_putCredits_cr_in),
					 .out_ports_2_putCredits_cr_in(net_routers_0_router_core$out_ports_2_putCredits_cr_in),
					 .EN_in_ports_0_putRoutedFlit(net_routers_0_router_core$EN_in_ports_0_putRoutedFlit),
					 .EN_in_ports_0_getCredits(net_routers_0_router_core$EN_in_ports_0_getCredits),
					 .EN_in_ports_1_putRoutedFlit(net_routers_0_router_core$EN_in_ports_1_putRoutedFlit),
					 .EN_in_ports_1_getCredits(net_routers_0_router_core$EN_in_ports_1_getCredits),
					 .EN_in_ports_2_putRoutedFlit(net_routers_0_router_core$EN_in_ports_2_putRoutedFlit),
					 .EN_in_ports_2_getCredits(net_routers_0_router_core$EN_in_ports_2_getCredits),
					 .EN_out_ports_0_getFlit(net_routers_0_router_core$EN_out_ports_0_getFlit),
					 .EN_out_ports_0_putCredits(net_routers_0_router_core$EN_out_ports_0_putCredits),
					 .EN_out_ports_1_getFlit(net_routers_0_router_core$EN_out_ports_1_getFlit),
					 .EN_out_ports_1_putCredits(net_routers_0_router_core$EN_out_ports_1_putCredits),
					 .EN_out_ports_2_getFlit(net_routers_0_router_core$EN_out_ports_2_getFlit),
					 .EN_out_ports_2_putCredits(net_routers_0_router_core$EN_out_ports_2_putCredits),
					 .in_ports_0_getCredits(net_routers_0_router_core$in_ports_0_getCredits),
					 .in_ports_1_getCredits(net_routers_0_router_core$in_ports_1_getCredits),
					 .in_ports_2_getCredits(net_routers_0_router_core$in_ports_2_getCredits),
					 .out_ports_0_getFlit(net_routers_0_router_core$out_ports_0_getFlit),
					 .out_ports_1_getFlit(net_routers_0_router_core$out_ports_1_getFlit),
					 .out_ports_2_getFlit(net_routers_0_router_core$out_ports_2_getFlit));

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_1.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1),
											 .ADDR_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN),
											 .D_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN),
											 .WE(net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$WE),
											 .D_OUT_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1));

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_1.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1),
											 .ADDR_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN),
											 .D_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN),
											 .WE(net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$WE),
											 .D_OUT_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1));

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_1.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1),
											 .ADDR_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN),
											 .D_IN(net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN),
											 .WE(net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$WE),
											 .D_OUT_1(net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1));

  // submodule net_routers_1_router_core
  mkRouterCore net_routers_1_router_core(.CLK(CLK),
					 .RST_N(RST_N),
					 .in_ports_0_putRoutedFlit_flit_in(net_routers_1_router_core$in_ports_0_putRoutedFlit_flit_in),
					 .in_ports_1_putRoutedFlit_flit_in(net_routers_1_router_core$in_ports_1_putRoutedFlit_flit_in),
					 .in_ports_2_putRoutedFlit_flit_in(net_routers_1_router_core$in_ports_2_putRoutedFlit_flit_in),
					 .out_ports_0_putCredits_cr_in(net_routers_1_router_core$out_ports_0_putCredits_cr_in),
					 .out_ports_1_putCredits_cr_in(net_routers_1_router_core$out_ports_1_putCredits_cr_in),
					 .out_ports_2_putCredits_cr_in(net_routers_1_router_core$out_ports_2_putCredits_cr_in),
					 .EN_in_ports_0_putRoutedFlit(net_routers_1_router_core$EN_in_ports_0_putRoutedFlit),
					 .EN_in_ports_0_getCredits(net_routers_1_router_core$EN_in_ports_0_getCredits),
					 .EN_in_ports_1_putRoutedFlit(net_routers_1_router_core$EN_in_ports_1_putRoutedFlit),
					 .EN_in_ports_1_getCredits(net_routers_1_router_core$EN_in_ports_1_getCredits),
					 .EN_in_ports_2_putRoutedFlit(net_routers_1_router_core$EN_in_ports_2_putRoutedFlit),
					 .EN_in_ports_2_getCredits(net_routers_1_router_core$EN_in_ports_2_getCredits),
					 .EN_out_ports_0_getFlit(net_routers_1_router_core$EN_out_ports_0_getFlit),
					 .EN_out_ports_0_putCredits(net_routers_1_router_core$EN_out_ports_0_putCredits),
					 .EN_out_ports_1_getFlit(net_routers_1_router_core$EN_out_ports_1_getFlit),
					 .EN_out_ports_1_putCredits(net_routers_1_router_core$EN_out_ports_1_putCredits),
					 .EN_out_ports_2_getFlit(net_routers_1_router_core$EN_out_ports_2_getFlit),
					 .EN_out_ports_2_putCredits(net_routers_1_router_core$EN_out_ports_2_putCredits),
					 .in_ports_0_getCredits(net_routers_1_router_core$in_ports_0_getCredits),
					 .in_ports_1_getCredits(net_routers_1_router_core$in_ports_1_getCredits),
					 .in_ports_2_getCredits(net_routers_1_router_core$in_ports_2_getCredits),
					 .out_ports_0_getFlit(net_routers_1_router_core$out_ports_0_getFlit),
					 .out_ports_1_getFlit(net_routers_1_router_core$out_ports_1_getFlit),
					 .out_ports_2_getFlit(net_routers_1_router_core$out_ports_2_getFlit));

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_2.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1),
											 .ADDR_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN),
											 .D_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN),
											 .WE(net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$WE),
											 .D_OUT_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1));

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_2.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1),
											 .ADDR_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN),
											 .D_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN),
											 .WE(net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$WE),
											 .D_OUT_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1));

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_2.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1),
											 .ADDR_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN),
											 .D_IN(net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN),
											 .WE(net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$WE),
											 .D_OUT_1(net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1));

  // submodule net_routers_2_router_core
  mkRouterCore net_routers_2_router_core(.CLK(CLK),
					 .RST_N(RST_N),
					 .in_ports_0_putRoutedFlit_flit_in(net_routers_2_router_core$in_ports_0_putRoutedFlit_flit_in),
					 .in_ports_1_putRoutedFlit_flit_in(net_routers_2_router_core$in_ports_1_putRoutedFlit_flit_in),
					 .in_ports_2_putRoutedFlit_flit_in(net_routers_2_router_core$in_ports_2_putRoutedFlit_flit_in),
					 .out_ports_0_putCredits_cr_in(net_routers_2_router_core$out_ports_0_putCredits_cr_in),
					 .out_ports_1_putCredits_cr_in(net_routers_2_router_core$out_ports_1_putCredits_cr_in),
					 .out_ports_2_putCredits_cr_in(net_routers_2_router_core$out_ports_2_putCredits_cr_in),
					 .EN_in_ports_0_putRoutedFlit(net_routers_2_router_core$EN_in_ports_0_putRoutedFlit),
					 .EN_in_ports_0_getCredits(net_routers_2_router_core$EN_in_ports_0_getCredits),
					 .EN_in_ports_1_putRoutedFlit(net_routers_2_router_core$EN_in_ports_1_putRoutedFlit),
					 .EN_in_ports_1_getCredits(net_routers_2_router_core$EN_in_ports_1_getCredits),
					 .EN_in_ports_2_putRoutedFlit(net_routers_2_router_core$EN_in_ports_2_putRoutedFlit),
					 .EN_in_ports_2_getCredits(net_routers_2_router_core$EN_in_ports_2_getCredits),
					 .EN_out_ports_0_getFlit(net_routers_2_router_core$EN_out_ports_0_getFlit),
					 .EN_out_ports_0_putCredits(net_routers_2_router_core$EN_out_ports_0_putCredits),
					 .EN_out_ports_1_getFlit(net_routers_2_router_core$EN_out_ports_1_getFlit),
					 .EN_out_ports_1_putCredits(net_routers_2_router_core$EN_out_ports_1_putCredits),
					 .EN_out_ports_2_getFlit(net_routers_2_router_core$EN_out_ports_2_getFlit),
					 .EN_out_ports_2_putCredits(net_routers_2_router_core$EN_out_ports_2_putCredits),
					 .in_ports_0_getCredits(net_routers_2_router_core$in_ports_0_getCredits),
					 .in_ports_1_getCredits(net_routers_2_router_core$in_ports_1_getCredits),
					 .in_ports_2_getCredits(net_routers_2_router_core$in_ports_2_getCredits),
					 .out_ports_0_getFlit(net_routers_2_router_core$out_ports_0_getFlit),
					 .out_ports_1_getFlit(net_routers_2_router_core$out_ports_1_getFlit),
					 .out_ports_2_getFlit(net_routers_2_router_core$out_ports_2_getFlit));

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_3.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1),
											 .ADDR_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN),
											 .D_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN),
											 .WE(net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$WE),
											 .D_OUT_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1));

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_3.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1),
											 .ADDR_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN),
											 .D_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN),
											 .WE(net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$WE),
											 .D_OUT_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1));

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_3.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf(.CLK(CLK),
											 .RST_N(RST_N),
											 .ADDR_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1),
											 .ADDR_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN),
											 .D_IN(net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN),
											 .WE(net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$WE),
											 .D_OUT_1(net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1));

  // submodule net_routers_3_router_core
  mkRouterCore net_routers_3_router_core(.CLK(CLK),
					 .RST_N(RST_N),
					 .in_ports_0_putRoutedFlit_flit_in(net_routers_3_router_core$in_ports_0_putRoutedFlit_flit_in),
					 .in_ports_1_putRoutedFlit_flit_in(net_routers_3_router_core$in_ports_1_putRoutedFlit_flit_in),
					 .in_ports_2_putRoutedFlit_flit_in(net_routers_3_router_core$in_ports_2_putRoutedFlit_flit_in),
					 .out_ports_0_putCredits_cr_in(net_routers_3_router_core$out_ports_0_putCredits_cr_in),
					 .out_ports_1_putCredits_cr_in(net_routers_3_router_core$out_ports_1_putCredits_cr_in),
					 .out_ports_2_putCredits_cr_in(net_routers_3_router_core$out_ports_2_putCredits_cr_in),
					 .EN_in_ports_0_putRoutedFlit(net_routers_3_router_core$EN_in_ports_0_putRoutedFlit),
					 .EN_in_ports_0_getCredits(net_routers_3_router_core$EN_in_ports_0_getCredits),
					 .EN_in_ports_1_putRoutedFlit(net_routers_3_router_core$EN_in_ports_1_putRoutedFlit),
					 .EN_in_ports_1_getCredits(net_routers_3_router_core$EN_in_ports_1_getCredits),
					 .EN_in_ports_2_putRoutedFlit(net_routers_3_router_core$EN_in_ports_2_putRoutedFlit),
					 .EN_in_ports_2_getCredits(net_routers_3_router_core$EN_in_ports_2_getCredits),
					 .EN_out_ports_0_getFlit(net_routers_3_router_core$EN_out_ports_0_getFlit),
					 .EN_out_ports_0_putCredits(net_routers_3_router_core$EN_out_ports_0_putCredits),
					 .EN_out_ports_1_getFlit(net_routers_3_router_core$EN_out_ports_1_getFlit),
					 .EN_out_ports_1_putCredits(net_routers_3_router_core$EN_out_ports_1_putCredits),
					 .EN_out_ports_2_getFlit(net_routers_3_router_core$EN_out_ports_2_getFlit),
					 .EN_out_ports_2_putCredits(net_routers_3_router_core$EN_out_ports_2_putCredits),
					 .in_ports_0_getCredits(net_routers_3_router_core$in_ports_0_getCredits),
					 .in_ports_1_getCredits(net_routers_3_router_core$in_ports_1_getCredits),
					 .in_ports_2_getCredits(net_routers_3_router_core$in_ports_2_getCredits),
					 .out_ports_0_getFlit(net_routers_3_router_core$out_ports_0_getFlit),
					 .out_ports_1_getFlit(net_routers_3_router_core$out_ports_1_getFlit),
					 .out_ports_2_getFlit(net_routers_3_router_core$out_ports_2_getFlit));

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1 =
	     send_ports_0_putFlit_flit_in[36:35] ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$WE = 1'b0 ;

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1 =
	     net_routers_3_router_core$out_ports_1_getFlit[36:35] ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$WE = 1'b0 ;

  // submodule net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1 =
	     net_routers_1_router_core$out_ports_2_getFlit[36:35] ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN = 2'h0 ;
  assign net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$WE = 1'b0 ;

  // submodule net_routers_0_router_core
  assign net_routers_0_router_core$in_ports_0_putRoutedFlit_flit_in =
	     { send_ports_0_putFlit_flit_in,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1 } ;
  assign net_routers_0_router_core$in_ports_1_putRoutedFlit_flit_in =
	     { net_routers_3_router_core$out_ports_1_getFlit,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1 } ;
  assign net_routers_0_router_core$in_ports_2_putRoutedFlit_flit_in =
	     { net_routers_1_router_core$out_ports_2_getFlit,
	       net_routers_0_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1 } ;
  assign net_routers_0_router_core$out_ports_0_putCredits_cr_in =
	     recv_ports_0_putCredits_cr_in ;
  assign net_routers_0_router_core$out_ports_1_putCredits_cr_in =
	     net_routers_1_router_core$in_ports_1_getCredits ;
  assign net_routers_0_router_core$out_ports_2_putCredits_cr_in =
	     net_routers_3_router_core$in_ports_2_getCredits ;
  assign net_routers_0_router_core$EN_in_ports_0_putRoutedFlit =
	     EN_send_ports_0_putFlit ;
  assign net_routers_0_router_core$EN_in_ports_0_getCredits =
	     EN_send_ports_0_getCredits ;
  assign net_routers_0_router_core$EN_in_ports_1_putRoutedFlit = 1'd1 ;
  assign net_routers_0_router_core$EN_in_ports_1_getCredits = 1'd1 ;
  assign net_routers_0_router_core$EN_in_ports_2_putRoutedFlit = 1'd1 ;
  assign net_routers_0_router_core$EN_in_ports_2_getCredits = 1'd1 ;
  assign net_routers_0_router_core$EN_out_ports_0_getFlit =
	     EN_recv_ports_0_getFlit ;
  assign net_routers_0_router_core$EN_out_ports_0_putCredits =
	     EN_recv_ports_0_putCredits ;
  assign net_routers_0_router_core$EN_out_ports_1_getFlit = 1'd1 ;
  assign net_routers_0_router_core$EN_out_ports_1_putCredits = 1'd1 ;
  assign net_routers_0_router_core$EN_out_ports_2_getFlit = 1'd1 ;
  assign net_routers_0_router_core$EN_out_ports_2_putCredits = 1'd1 ;

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1 =
	     send_ports_1_putFlit_flit_in[36:35] ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$WE = 1'b0 ;

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1 =
	     net_routers_0_router_core$out_ports_1_getFlit[36:35] ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$WE = 1'b0 ;

  // submodule net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1 =
	     net_routers_2_router_core$out_ports_2_getFlit[36:35] ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN = 2'h0 ;
  assign net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$WE = 1'b0 ;

  // submodule net_routers_1_router_core
  assign net_routers_1_router_core$in_ports_0_putRoutedFlit_flit_in =
	     { send_ports_1_putFlit_flit_in,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1 } ;
  assign net_routers_1_router_core$in_ports_1_putRoutedFlit_flit_in =
	     { net_routers_0_router_core$out_ports_1_getFlit,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1 } ;
  assign net_routers_1_router_core$in_ports_2_putRoutedFlit_flit_in =
	     { net_routers_2_router_core$out_ports_2_getFlit,
	       net_routers_1_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1 } ;
  assign net_routers_1_router_core$out_ports_0_putCredits_cr_in =
	     recv_ports_1_putCredits_cr_in ;
  assign net_routers_1_router_core$out_ports_1_putCredits_cr_in =
	     net_routers_2_router_core$in_ports_1_getCredits ;
  assign net_routers_1_router_core$out_ports_2_putCredits_cr_in =
	     net_routers_0_router_core$in_ports_2_getCredits ;
  assign net_routers_1_router_core$EN_in_ports_0_putRoutedFlit =
	     EN_send_ports_1_putFlit ;
  assign net_routers_1_router_core$EN_in_ports_0_getCredits =
	     EN_send_ports_1_getCredits ;
  assign net_routers_1_router_core$EN_in_ports_1_putRoutedFlit = 1'd1 ;
  assign net_routers_1_router_core$EN_in_ports_1_getCredits = 1'd1 ;
  assign net_routers_1_router_core$EN_in_ports_2_putRoutedFlit = 1'd1 ;
  assign net_routers_1_router_core$EN_in_ports_2_getCredits = 1'd1 ;
  assign net_routers_1_router_core$EN_out_ports_0_getFlit =
	     EN_recv_ports_1_getFlit ;
  assign net_routers_1_router_core$EN_out_ports_0_putCredits =
	     EN_recv_ports_1_putCredits ;
  assign net_routers_1_router_core$EN_out_ports_1_getFlit = 1'd1 ;
  assign net_routers_1_router_core$EN_out_ports_1_putCredits = 1'd1 ;
  assign net_routers_1_router_core$EN_out_ports_2_getFlit = 1'd1 ;
  assign net_routers_1_router_core$EN_out_ports_2_putCredits = 1'd1 ;

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1 =
	     send_ports_2_putFlit_flit_in[36:35] ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$WE = 1'b0 ;

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1 =
	     net_routers_1_router_core$out_ports_1_getFlit[36:35] ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$WE = 1'b0 ;

  // submodule net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1 =
	     net_routers_3_router_core$out_ports_2_getFlit[36:35] ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN = 2'h0 ;
  assign net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$WE = 1'b0 ;

  // submodule net_routers_2_router_core
  assign net_routers_2_router_core$in_ports_0_putRoutedFlit_flit_in =
	     { send_ports_2_putFlit_flit_in,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1 } ;
  assign net_routers_2_router_core$in_ports_1_putRoutedFlit_flit_in =
	     { net_routers_1_router_core$out_ports_1_getFlit,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1 } ;
  assign net_routers_2_router_core$in_ports_2_putRoutedFlit_flit_in =
	     { net_routers_3_router_core$out_ports_2_getFlit,
	       net_routers_2_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1 } ;
  assign net_routers_2_router_core$out_ports_0_putCredits_cr_in =
	     recv_ports_2_putCredits_cr_in ;
  assign net_routers_2_router_core$out_ports_1_putCredits_cr_in =
	     net_routers_3_router_core$in_ports_1_getCredits ;
  assign net_routers_2_router_core$out_ports_2_putCredits_cr_in =
	     net_routers_1_router_core$in_ports_2_getCredits ;
  assign net_routers_2_router_core$EN_in_ports_0_putRoutedFlit =
	     EN_send_ports_2_putFlit ;
  assign net_routers_2_router_core$EN_in_ports_0_getCredits =
	     EN_send_ports_2_getCredits ;
  assign net_routers_2_router_core$EN_in_ports_1_putRoutedFlit = 1'd1 ;
  assign net_routers_2_router_core$EN_in_ports_1_getCredits = 1'd1 ;
  assign net_routers_2_router_core$EN_in_ports_2_putRoutedFlit = 1'd1 ;
  assign net_routers_2_router_core$EN_in_ports_2_getCredits = 1'd1 ;
  assign net_routers_2_router_core$EN_out_ports_0_getFlit =
	     EN_recv_ports_2_getFlit ;
  assign net_routers_2_router_core$EN_out_ports_0_putCredits =
	     EN_recv_ports_2_putCredits ;
  assign net_routers_2_router_core$EN_out_ports_1_getFlit = 1'd1 ;
  assign net_routers_2_router_core$EN_out_ports_1_putCredits = 1'd1 ;
  assign net_routers_2_router_core$EN_out_ports_2_getFlit = 1'd1 ;
  assign net_routers_2_router_core$EN_out_ports_2_putCredits = 1'd1 ;

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_1 =
	     send_ports_3_putFlit_flit_in[36:35] ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$ADDR_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$WE = 1'b0 ;

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_1 =
	     net_routers_2_router_core$out_ports_1_getFlit[36:35] ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$ADDR_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$WE = 1'b0 ;

  // submodule net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_1 =
	     net_routers_0_router_core$out_ports_2_getFlit[36:35] ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$ADDR_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_IN = 2'h0 ;
  assign net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$WE = 1'b0 ;

  // submodule net_routers_3_router_core
  assign net_routers_3_router_core$in_ports_0_putRoutedFlit_flit_in =
	     { send_ports_3_putFlit_flit_in,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_0_rf$D_OUT_1 } ;
  assign net_routers_3_router_core$in_ports_1_putRoutedFlit_flit_in =
	     { net_routers_2_router_core$out_ports_1_getFlit,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_1_rf$D_OUT_1 } ;
  assign net_routers_3_router_core$in_ports_2_putRoutedFlit_flit_in =
	     { net_routers_0_router_core$out_ports_2_getFlit,
	       net_routers_3_routeTable_rt_ifc_banks_0_banks_2_rf$D_OUT_1 } ;
  assign net_routers_3_router_core$out_ports_0_putCredits_cr_in =
	     recv_ports_3_putCredits_cr_in ;
  assign net_routers_3_router_core$out_ports_1_putCredits_cr_in =
	     net_routers_0_router_core$in_ports_1_getCredits ;
  assign net_routers_3_router_core$out_ports_2_putCredits_cr_in =
	     net_routers_2_router_core$in_ports_2_getCredits ;
  assign net_routers_3_router_core$EN_in_ports_0_putRoutedFlit =
	     EN_send_ports_3_putFlit ;
  assign net_routers_3_router_core$EN_in_ports_0_getCredits =
	     EN_send_ports_3_getCredits ;
  assign net_routers_3_router_core$EN_in_ports_1_putRoutedFlit = 1'd1 ;
  assign net_routers_3_router_core$EN_in_ports_1_getCredits = 1'd1 ;
  assign net_routers_3_router_core$EN_in_ports_2_putRoutedFlit = 1'd1 ;
  assign net_routers_3_router_core$EN_in_ports_2_getCredits = 1'd1 ;
  assign net_routers_3_router_core$EN_out_ports_0_getFlit =
	     EN_recv_ports_3_getFlit ;
  assign net_routers_3_router_core$EN_out_ports_0_putCredits =
	     EN_recv_ports_3_putCredits ;
  assign net_routers_3_router_core$EN_out_ports_1_getFlit = 1'd1 ;
  assign net_routers_3_router_core$EN_out_ports_1_putCredits = 1'd1 ;
  assign net_routers_3_router_core$EN_out_ports_2_getFlit = 1'd1 ;
  assign net_routers_3_router_core$EN_out_ports_2_putCredits = 1'd1 ;

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_send_ports_0_putFlit && send_ports_0_putFlit_flit_in[38])
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_send_ports_1_putFlit && send_ports_1_putFlit_flit_in[38])
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_send_ports_2_putFlit && send_ports_2_putFlit_flit_in[38])
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_send_ports_3_putFlit && send_ports_3_putFlit_flit_in[38])
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_0_router_core$out_ports_1_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_1_router_core$out_ports_1_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_2_router_core$out_ports_1_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_3_router_core$out_ports_1_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_0_router_core$out_ports_2_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_1_router_core$out_ports_2_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_2_router_core$out_ports_2_getFlit[38]) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (net_routers_3_router_core$out_ports_2_getFlit[38]) $write("");
  end
  // synopsys translate_on
endmodule  // mkNetwork

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:18 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// RDY_enq                        O     1 const
// RDY_deq                        O     1 const
// first                          O     2
// RDY_first                      O     1 const
// notFull                        O     1
// RDY_notFull                    O     1 const
// notEmpty                       O     1
// RDY_notEmpty                   O     1 const
// count                          O     3 reg
// RDY_count                      O     1 const
// RDY_clear                      O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// enq_sendData                   I     2 reg
// EN_enq                         I     1
// EN_deq                         I     1
// EN_clear                       I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkOutPortFIFO(CLK,
		     RST_N,

		     enq_sendData,
		     EN_enq,
		     RDY_enq,

		     EN_deq,
		     RDY_deq,

		     first,
		     RDY_first,

		     notFull,
		     RDY_notFull,

		     notEmpty,
		     RDY_notEmpty,

		     count,
		     RDY_count,

		     EN_clear,
		     RDY_clear);
  input  CLK;
  input  RST_N;

  // action method enq
  input  [1 : 0] enq_sendData;
  input  EN_enq;
  output RDY_enq;

  // action method deq
  input  EN_deq;
  output RDY_deq;

  // value method first
  output [1 : 0] first;
  output RDY_first;

  // value method notFull
  output notFull;
  output RDY_notFull;

  // value method notEmpty
  output notEmpty;
  output RDY_notEmpty;

  // value method count
  output [2 : 0] count;
  output RDY_count;

  // action method clear
  input  EN_clear;
  output RDY_clear;

  // signals for module outputs
  reg [1 : 0] first;
  wire [2 : 0] count;
  wire RDY_clear,
       RDY_count,
       RDY_deq,
       RDY_enq,
       RDY_first,
       RDY_notEmpty,
       RDY_notFull,
       notEmpty,
       notFull;

  // register outPortFIFO_ifc_fifo_almost_full
  reg outPortFIFO_ifc_fifo_almost_full;
  wire outPortFIFO_ifc_fifo_almost_full$D_IN,
       outPortFIFO_ifc_fifo_almost_full$EN;

  // register outPortFIFO_ifc_fifo_deq_cnt
  reg [63 : 0] outPortFIFO_ifc_fifo_deq_cnt;
  wire [63 : 0] outPortFIFO_ifc_fifo_deq_cnt$D_IN;
  wire outPortFIFO_ifc_fifo_deq_cnt$EN;

  // register outPortFIFO_ifc_fifo_empty
  reg outPortFIFO_ifc_fifo_empty;
  wire outPortFIFO_ifc_fifo_empty$D_IN, outPortFIFO_ifc_fifo_empty$EN;

  // register outPortFIFO_ifc_fifo_enq_cnt
  reg [63 : 0] outPortFIFO_ifc_fifo_enq_cnt;
  wire [63 : 0] outPortFIFO_ifc_fifo_enq_cnt$D_IN;
  wire outPortFIFO_ifc_fifo_enq_cnt$EN;

  // register outPortFIFO_ifc_fifo_full
  reg outPortFIFO_ifc_fifo_full;
  wire outPortFIFO_ifc_fifo_full$D_IN, outPortFIFO_ifc_fifo_full$EN;

  // register outPortFIFO_ifc_fifo_head
  reg [1 : 0] outPortFIFO_ifc_fifo_head;
  wire [1 : 0] outPortFIFO_ifc_fifo_head$D_IN;
  wire outPortFIFO_ifc_fifo_head$EN;

  // register outPortFIFO_ifc_fifo_mem_0
  reg [1 : 0] outPortFIFO_ifc_fifo_mem_0;
  wire [1 : 0] outPortFIFO_ifc_fifo_mem_0$D_IN;
  wire outPortFIFO_ifc_fifo_mem_0$EN;

  // register outPortFIFO_ifc_fifo_mem_1
  reg [1 : 0] outPortFIFO_ifc_fifo_mem_1;
  wire [1 : 0] outPortFIFO_ifc_fifo_mem_1$D_IN;
  wire outPortFIFO_ifc_fifo_mem_1$EN;

  // register outPortFIFO_ifc_fifo_mem_2
  reg [1 : 0] outPortFIFO_ifc_fifo_mem_2;
  wire [1 : 0] outPortFIFO_ifc_fifo_mem_2$D_IN;
  wire outPortFIFO_ifc_fifo_mem_2$EN;

  // register outPortFIFO_ifc_fifo_mem_3
  reg [1 : 0] outPortFIFO_ifc_fifo_mem_3;
  wire [1 : 0] outPortFIFO_ifc_fifo_mem_3$D_IN;
  wire outPortFIFO_ifc_fifo_mem_3$EN;

  // register outPortFIFO_ifc_fifo_size_cnt
  reg [2 : 0] outPortFIFO_ifc_fifo_size_cnt;
  wire [2 : 0] outPortFIFO_ifc_fifo_size_cnt$D_IN;
  wire outPortFIFO_ifc_fifo_size_cnt$EN;

  // register outPortFIFO_ifc_fifo_tail
  reg [1 : 0] outPortFIFO_ifc_fifo_tail;
  wire [1 : 0] outPortFIFO_ifc_fifo_tail$D_IN;
  wire outPortFIFO_ifc_fifo_tail$EN;

  // rule scheduling signals
  wire WILL_FIRE_RL_outPortFIFO_ifc_fifo_continuousAssert;

  // remaining internal signals
  wire [63 : 0] x__h1521, x__h938;
  wire [2 : 0] IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d48,
	       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d47;
  wire [1 : 0] outPortFIFO_ifc_fifo_head_PLUS_1___d5,
	       outPortFIFO_ifc_fifo_tail_PLUS_1___d10;
  wire IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d25,
       IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d33,
       IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d41,
       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d32,
       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d40,
       IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d23,
       IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d31,
       outPortFIFO_ifc_fifo_empty_6_EQ_outPortFIFO_if_ETC___d67;

  // action method enq
  assign RDY_enq = 1'd1 ;

  // action method deq
  assign RDY_deq = 1'd1 ;

  // value method first
  always@(outPortFIFO_ifc_fifo_head or
	  outPortFIFO_ifc_fifo_mem_0 or
	  outPortFIFO_ifc_fifo_mem_1 or
	  outPortFIFO_ifc_fifo_mem_2 or outPortFIFO_ifc_fifo_mem_3)
  begin
    case (outPortFIFO_ifc_fifo_head)
      2'd0: first = outPortFIFO_ifc_fifo_mem_0;
      2'd1: first = outPortFIFO_ifc_fifo_mem_1;
      2'd2: first = outPortFIFO_ifc_fifo_mem_2;
      2'd3: first = outPortFIFO_ifc_fifo_mem_3;
    endcase
  end
  assign RDY_first = 1'd1 ;

  // value method notFull
  assign notFull = !outPortFIFO_ifc_fifo_full ;
  assign RDY_notFull = 1'd1 ;

  // value method notEmpty
  assign notEmpty = !outPortFIFO_ifc_fifo_empty ;
  assign RDY_notEmpty = 1'd1 ;

  // value method count
  assign count = outPortFIFO_ifc_fifo_size_cnt ;
  assign RDY_count = 1'd1 ;

  // action method clear
  assign RDY_clear = 1'd1 ;

  // rule RL_outPortFIFO_ifc_fifo_continuousAssert
  assign WILL_FIRE_RL_outPortFIFO_ifc_fifo_continuousAssert =
	     outPortFIFO_ifc_fifo_empty &&
	     outPortFIFO_ifc_fifo_enq_cnt != outPortFIFO_ifc_fifo_deq_cnt ;

  // register outPortFIFO_ifc_fifo_almost_full
  assign outPortFIFO_ifc_fifo_almost_full$D_IN =
	     !EN_clear &&
	     (IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d33 ||
	      IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d25) ;
  assign outPortFIFO_ifc_fifo_almost_full$EN = 1'd1 ;

  // register outPortFIFO_ifc_fifo_deq_cnt
  assign outPortFIFO_ifc_fifo_deq_cnt$D_IN = EN_clear ? 64'd0 : x__h938 ;
  assign outPortFIFO_ifc_fifo_deq_cnt$EN = EN_clear || EN_deq ;

  // register outPortFIFO_ifc_fifo_empty
  assign outPortFIFO_ifc_fifo_empty$D_IN =
	     EN_clear ||
	     IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d41 ;
  assign outPortFIFO_ifc_fifo_empty$EN = 1'd1 ;

  // register outPortFIFO_ifc_fifo_enq_cnt
  assign outPortFIFO_ifc_fifo_enq_cnt$D_IN = EN_clear ? 64'd0 : x__h1521 ;
  assign outPortFIFO_ifc_fifo_enq_cnt$EN = EN_clear || EN_enq ;

  // register outPortFIFO_ifc_fifo_full
  assign outPortFIFO_ifc_fifo_full$D_IN =
	     !EN_clear &&
	     IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d25 ;
  assign outPortFIFO_ifc_fifo_full$EN = 1'd1 ;

  // register outPortFIFO_ifc_fifo_head
  assign outPortFIFO_ifc_fifo_head$D_IN =
	     EN_clear ? 2'd0 : outPortFIFO_ifc_fifo_head_PLUS_1___d5 ;
  assign outPortFIFO_ifc_fifo_head$EN = EN_clear || EN_deq ;

  // register outPortFIFO_ifc_fifo_mem_0
  assign outPortFIFO_ifc_fifo_mem_0$D_IN = enq_sendData ;
  assign outPortFIFO_ifc_fifo_mem_0$EN =
	     outPortFIFO_ifc_fifo_tail == 2'd0 && !EN_clear && EN_enq ;

  // register outPortFIFO_ifc_fifo_mem_1
  assign outPortFIFO_ifc_fifo_mem_1$D_IN = enq_sendData ;
  assign outPortFIFO_ifc_fifo_mem_1$EN =
	     outPortFIFO_ifc_fifo_tail == 2'd1 && !EN_clear && EN_enq ;

  // register outPortFIFO_ifc_fifo_mem_2
  assign outPortFIFO_ifc_fifo_mem_2$D_IN = enq_sendData ;
  assign outPortFIFO_ifc_fifo_mem_2$EN =
	     outPortFIFO_ifc_fifo_tail == 2'd2 && !EN_clear && EN_enq ;

  // register outPortFIFO_ifc_fifo_mem_3
  assign outPortFIFO_ifc_fifo_mem_3$D_IN = enq_sendData ;
  assign outPortFIFO_ifc_fifo_mem_3$EN =
	     outPortFIFO_ifc_fifo_tail == 2'd3 && !EN_clear && EN_enq ;

  // register outPortFIFO_ifc_fifo_size_cnt
  assign outPortFIFO_ifc_fifo_size_cnt$D_IN =
	     EN_clear ?
	       3'd0 :
	       IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d48 ;
  assign outPortFIFO_ifc_fifo_size_cnt$EN = 1'd1 ;

  // register outPortFIFO_ifc_fifo_tail
  assign outPortFIFO_ifc_fifo_tail$D_IN =
	     EN_clear ? 2'd0 : outPortFIFO_ifc_fifo_tail_PLUS_1___d10 ;
  assign outPortFIFO_ifc_fifo_tail$EN = EN_clear || EN_enq ;

  // remaining internal signals
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d25 =
	     (EN_deq && EN_enq) ?
	       outPortFIFO_ifc_fifo_full :
	       !EN_deq &&
	       IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d23 ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d33 =
	     (EN_deq && EN_enq) ?
	       outPortFIFO_ifc_fifo_almost_full :
	       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d32 ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d41 =
	     (EN_deq && EN_enq) ?
	       outPortFIFO_ifc_fifo_empty :
	       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d40 ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_AND_outPort_ETC___d48 =
	     (EN_deq && EN_enq) ?
	       outPortFIFO_ifc_fifo_size_cnt :
	       IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d47 ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d32 =
	     EN_deq ?
	       outPortFIFO_ifc_fifo_tail == outPortFIFO_ifc_fifo_head :
	       IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d31 ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d40 =
	     EN_deq ?
	       outPortFIFO_ifc_fifo_head_PLUS_1___d5 ==
	       outPortFIFO_ifc_fifo_tail :
	       !EN_enq && outPortFIFO_ifc_fifo_empty ;
  assign IF_outPortFIFO_ifc_fifo_w_deq_whas_THEN_outPor_ETC___d47 =
	     EN_deq ?
	       outPortFIFO_ifc_fifo_size_cnt - 3'd1 :
	       (EN_enq ?
		  outPortFIFO_ifc_fifo_size_cnt + 3'd1 :
		  outPortFIFO_ifc_fifo_size_cnt) ;
  assign IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d23 =
	     EN_enq ?
	       outPortFIFO_ifc_fifo_tail_PLUS_1___d10 ==
	       outPortFIFO_ifc_fifo_head :
	       outPortFIFO_ifc_fifo_full ;
  assign IF_outPortFIFO_ifc_fifo_w_enq_whas_THEN_outPor_ETC___d31 =
	     EN_enq ?
	       outPortFIFO_ifc_fifo_tail + 2'd2 == outPortFIFO_ifc_fifo_head :
	       outPortFIFO_ifc_fifo_almost_full ;
  assign outPortFIFO_ifc_fifo_empty_6_EQ_outPortFIFO_if_ETC___d67 =
	     outPortFIFO_ifc_fifo_empty ==
	     (outPortFIFO_ifc_fifo_head == outPortFIFO_ifc_fifo_tail &&
	      !outPortFIFO_ifc_fifo_full) ;
  assign outPortFIFO_ifc_fifo_head_PLUS_1___d5 =
	     outPortFIFO_ifc_fifo_head + 2'd1 ;
  assign outPortFIFO_ifc_fifo_tail_PLUS_1___d10 =
	     outPortFIFO_ifc_fifo_tail + 2'd1 ;
  assign x__h1521 = outPortFIFO_ifc_fifo_enq_cnt + 64'd1 ;
  assign x__h938 = outPortFIFO_ifc_fifo_deq_cnt + 64'd1 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        outPortFIFO_ifc_fifo_almost_full <= `BSV_ASSIGNMENT_DELAY 1'd0;
	outPortFIFO_ifc_fifo_deq_cnt <= `BSV_ASSIGNMENT_DELAY 64'd0;
	outPortFIFO_ifc_fifo_empty <= `BSV_ASSIGNMENT_DELAY 1'd1;
	outPortFIFO_ifc_fifo_enq_cnt <= `BSV_ASSIGNMENT_DELAY 64'd0;
	outPortFIFO_ifc_fifo_full <= `BSV_ASSIGNMENT_DELAY 1'd0;
	outPortFIFO_ifc_fifo_head <= `BSV_ASSIGNMENT_DELAY 2'd0;
	outPortFIFO_ifc_fifo_mem_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	outPortFIFO_ifc_fifo_mem_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	outPortFIFO_ifc_fifo_mem_2 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	outPortFIFO_ifc_fifo_mem_3 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	outPortFIFO_ifc_fifo_size_cnt <= `BSV_ASSIGNMENT_DELAY 3'd0;
	outPortFIFO_ifc_fifo_tail <= `BSV_ASSIGNMENT_DELAY 2'd0;
      end
    else
      begin
        if (outPortFIFO_ifc_fifo_almost_full$EN)
	  outPortFIFO_ifc_fifo_almost_full <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_almost_full$D_IN;
	if (outPortFIFO_ifc_fifo_deq_cnt$EN)
	  outPortFIFO_ifc_fifo_deq_cnt <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_deq_cnt$D_IN;
	if (outPortFIFO_ifc_fifo_empty$EN)
	  outPortFIFO_ifc_fifo_empty <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_empty$D_IN;
	if (outPortFIFO_ifc_fifo_enq_cnt$EN)
	  outPortFIFO_ifc_fifo_enq_cnt <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_enq_cnt$D_IN;
	if (outPortFIFO_ifc_fifo_full$EN)
	  outPortFIFO_ifc_fifo_full <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_full$D_IN;
	if (outPortFIFO_ifc_fifo_head$EN)
	  outPortFIFO_ifc_fifo_head <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_head$D_IN;
	if (outPortFIFO_ifc_fifo_mem_0$EN)
	  outPortFIFO_ifc_fifo_mem_0 <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_mem_0$D_IN;
	if (outPortFIFO_ifc_fifo_mem_1$EN)
	  outPortFIFO_ifc_fifo_mem_1 <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_mem_1$D_IN;
	if (outPortFIFO_ifc_fifo_mem_2$EN)
	  outPortFIFO_ifc_fifo_mem_2 <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_mem_2$D_IN;
	if (outPortFIFO_ifc_fifo_mem_3$EN)
	  outPortFIFO_ifc_fifo_mem_3 <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_mem_3$D_IN;
	if (outPortFIFO_ifc_fifo_size_cnt$EN)
	  outPortFIFO_ifc_fifo_size_cnt <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_size_cnt$D_IN;
	if (outPortFIFO_ifc_fifo_tail$EN)
	  outPortFIFO_ifc_fifo_tail <= `BSV_ASSIGNMENT_DELAY
	      outPortFIFO_ifc_fifo_tail$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    outPortFIFO_ifc_fifo_almost_full = 1'h0;
    outPortFIFO_ifc_fifo_deq_cnt = 64'hAAAAAAAAAAAAAAAA;
    outPortFIFO_ifc_fifo_empty = 1'h0;
    outPortFIFO_ifc_fifo_enq_cnt = 64'hAAAAAAAAAAAAAAAA;
    outPortFIFO_ifc_fifo_full = 1'h0;
    outPortFIFO_ifc_fifo_head = 2'h2;
    outPortFIFO_ifc_fifo_mem_0 = 2'h2;
    outPortFIFO_ifc_fifo_mem_1 = 2'h2;
    outPortFIFO_ifc_fifo_mem_2 = 2'h2;
    outPortFIFO_ifc_fifo_mem_3 = 2'h2;
    outPortFIFO_ifc_fifo_size_cnt = 3'h2;
    outPortFIFO_ifc_fifo_tail = 2'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && outPortFIFO_ifc_fifo_full)
	$display("location of dfifo: ",
		 "\"RegFIFO.bsv\", line 25, column 33\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && outPortFIFO_ifc_fifo_full)
	$display("Dynamic assertion failed: \"RegFIFO.bsv\", line 191, column 27\nouch, enqueuing to full FIFO");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && outPortFIFO_ifc_fifo_full) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && outPortFIFO_ifc_fifo_empty)
	$display("location of dfifo: ",
		 "\"RegFIFO.bsv\", line 25, column 33\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && outPortFIFO_ifc_fifo_empty)
	$display("Dynamic assertion failed: \"RegFIFO.bsv\", line 198, column 28\nouch, dequeueing from empty FIFO");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && outPortFIFO_ifc_fifo_empty) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_outPortFIFO_ifc_fifo_continuousAssert)
	$display("Continuous assertion failed: \"RegFIFO.bsv\", line 167, column 59\nmismatched in enq/deq count");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_outPortFIFO_ifc_fifo_continuousAssert) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (!outPortFIFO_ifc_fifo_empty_6_EQ_outPortFIFO_if_ETC___d67)
	$display("Continuous assertion failed: \"RegFIFO.bsv\", line 170, column 45\nerror in empty signals");
    if (RST_N != `BSV_RESET_VALUE)
      if (!outPortFIFO_ifc_fifo_empty_6_EQ_outPortFIFO_if_ETC___d67)
	$finish(32'd0);
  end
  // synopsys translate_on
endmodule  // mkOutPortFIFO

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// select                         O     3
// CLK                            I     1 clock
// RST_N                          I     1 reset
// select_requests                I     3
// EN_next                        I     1
//
// Combinational paths from inputs to outputs:
//   select_requests -> select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkOutputArbiter(CLK,
		       RST_N,

		       select_requests,
		       select,

		       EN_next);
  input  CLK;
  input  RST_N;

  // value method select
  input  [2 : 0] select_requests;
  output [2 : 0] select;

  // action method next
  input  EN_next;

  // signals for module outputs
  wire [2 : 0] select;

  // register arb_token
  reg [2 : 0] arb_token;
  wire [2 : 0] arb_token$D_IN;
  wire arb_token$EN;

  // remaining internal signals
  wire [1 : 0] gen_grant_carry___d12,
	       gen_grant_carry___d15,
	       gen_grant_carry___d17,
	       gen_grant_carry___d19,
	       gen_grant_carry___d4,
	       gen_grant_carry___d8;
  wire NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36,
       arb_token_BIT_0___h1109,
       arb_token_BIT_1___h1175,
       arb_token_BIT_2___h1241;

  // value method select
  assign select =
	     { gen_grant_carry___d12[1] || gen_grant_carry___d19[1],
	       !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	       (gen_grant_carry___d8[1] || gen_grant_carry___d17[1]),
	       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 } ;

  // register arb_token
  assign arb_token$D_IN = { arb_token[0], arb_token[2:1] } ;
  assign arb_token$EN = EN_next ;

  // remaining internal signals
  module_gen_grant_carry instance_gen_grant_carry_5(.gen_grant_carry_c(1'd0),
						    .gen_grant_carry_r(select_requests[0]),
						    .gen_grant_carry_p(arb_token_BIT_0___h1109),
						    .gen_grant_carry(gen_grant_carry___d4));
  module_gen_grant_carry instance_gen_grant_carry_1(.gen_grant_carry_c(gen_grant_carry___d4[0]),
						    .gen_grant_carry_r(select_requests[1]),
						    .gen_grant_carry_p(arb_token_BIT_1___h1175),
						    .gen_grant_carry(gen_grant_carry___d8));
  module_gen_grant_carry instance_gen_grant_carry_0(.gen_grant_carry_c(gen_grant_carry___d8[0]),
						    .gen_grant_carry_r(select_requests[2]),
						    .gen_grant_carry_p(arb_token_BIT_2___h1241),
						    .gen_grant_carry(gen_grant_carry___d12));
  module_gen_grant_carry instance_gen_grant_carry_2(.gen_grant_carry_c(gen_grant_carry___d12[0]),
						    .gen_grant_carry_r(select_requests[0]),
						    .gen_grant_carry_p(arb_token_BIT_0___h1109),
						    .gen_grant_carry(gen_grant_carry___d15));
  module_gen_grant_carry instance_gen_grant_carry_3(.gen_grant_carry_c(gen_grant_carry___d15[0]),
						    .gen_grant_carry_r(select_requests[1]),
						    .gen_grant_carry_p(arb_token_BIT_1___h1175),
						    .gen_grant_carry(gen_grant_carry___d17));
  module_gen_grant_carry instance_gen_grant_carry_4(.gen_grant_carry_c(gen_grant_carry___d17[0]),
						    .gen_grant_carry_r(select_requests[2]),
						    .gen_grant_carry_p(arb_token_BIT_2___h1241),
						    .gen_grant_carry(gen_grant_carry___d19));
  assign NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 =
	     !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	     !gen_grant_carry___d8[1] &&
	     !gen_grant_carry___d17[1] &&
	     (gen_grant_carry___d4[1] || gen_grant_carry___d15[1]) ;
  assign arb_token_BIT_0___h1109 = arb_token[0] ;
  assign arb_token_BIT_1___h1175 = arb_token[1] ;
  assign arb_token_BIT_2___h1241 = arb_token[2] ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        arb_token <= `BSV_ASSIGNMENT_DELAY 3'd1;
      end
    else
      begin
        if (arb_token$EN) arb_token <= `BSV_ASSIGNMENT_DELAY arb_token$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    arb_token = 3'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkOutputArbiter

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:15 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// RDY_enq                        O     1 const
// RDY_deq                        O     1 const
// first                          O    32
// RDY_first                      O     1 const
// notFull                        O     1
// RDY_notFull                    O     1 const
// notEmpty                       O     1
// RDY_notEmpty                   O     1 const
// count                          O     3 reg
// RDY_count                      O     1 const
// RDY_clear                      O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// enq_sendData                   I    32 reg
// EN_enq                         I     1
// EN_deq                         I     1
// EN_clear                       I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRegFIFOSynth(CLK,
		      RST_N,

		      enq_sendData,
		      EN_enq,
		      RDY_enq,

		      EN_deq,
		      RDY_deq,

		      first,
		      RDY_first,

		      notFull,
		      RDY_notFull,

		      notEmpty,
		      RDY_notEmpty,

		      count,
		      RDY_count,

		      EN_clear,
		      RDY_clear);
  input  CLK;
  input  RST_N;

  // action method enq
  input  [31 : 0] enq_sendData;
  input  EN_enq;
  output RDY_enq;

  // action method deq
  input  EN_deq;
  output RDY_deq;

  // value method first
  output [31 : 0] first;
  output RDY_first;

  // value method notFull
  output notFull;
  output RDY_notFull;

  // value method notEmpty
  output notEmpty;
  output RDY_notEmpty;

  // value method count
  output [2 : 0] count;
  output RDY_count;

  // action method clear
  input  EN_clear;
  output RDY_clear;

  // signals for module outputs
  reg [31 : 0] first;
  wire [2 : 0] count;
  wire RDY_clear,
       RDY_count,
       RDY_deq,
       RDY_enq,
       RDY_first,
       RDY_notEmpty,
       RDY_notFull,
       notEmpty,
       notFull;

  // register f_fifo_almost_full
  reg f_fifo_almost_full;
  wire f_fifo_almost_full$D_IN, f_fifo_almost_full$EN;

  // register f_fifo_deq_cnt
  reg [63 : 0] f_fifo_deq_cnt;
  wire [63 : 0] f_fifo_deq_cnt$D_IN;
  wire f_fifo_deq_cnt$EN;

  // register f_fifo_empty
  reg f_fifo_empty;
  wire f_fifo_empty$D_IN, f_fifo_empty$EN;

  // register f_fifo_enq_cnt
  reg [63 : 0] f_fifo_enq_cnt;
  wire [63 : 0] f_fifo_enq_cnt$D_IN;
  wire f_fifo_enq_cnt$EN;

  // register f_fifo_full
  reg f_fifo_full;
  wire f_fifo_full$D_IN, f_fifo_full$EN;

  // register f_fifo_head
  reg [1 : 0] f_fifo_head;
  wire [1 : 0] f_fifo_head$D_IN;
  wire f_fifo_head$EN;

  // register f_fifo_mem_0
  reg [31 : 0] f_fifo_mem_0;
  wire [31 : 0] f_fifo_mem_0$D_IN;
  wire f_fifo_mem_0$EN;

  // register f_fifo_mem_1
  reg [31 : 0] f_fifo_mem_1;
  wire [31 : 0] f_fifo_mem_1$D_IN;
  wire f_fifo_mem_1$EN;

  // register f_fifo_mem_2
  reg [31 : 0] f_fifo_mem_2;
  wire [31 : 0] f_fifo_mem_2$D_IN;
  wire f_fifo_mem_2$EN;

  // register f_fifo_mem_3
  reg [31 : 0] f_fifo_mem_3;
  wire [31 : 0] f_fifo_mem_3$D_IN;
  wire f_fifo_mem_3$EN;

  // register f_fifo_size_cnt
  reg [2 : 0] f_fifo_size_cnt;
  wire [2 : 0] f_fifo_size_cnt$D_IN;
  wire f_fifo_size_cnt$EN;

  // register f_fifo_tail
  reg [1 : 0] f_fifo_tail;
  wire [1 : 0] f_fifo_tail$D_IN;
  wire f_fifo_tail$EN;

  // rule scheduling signals
  wire WILL_FIRE_RL_f_fifo_continuousAssert;

  // remaining internal signals
  wire [63 : 0] x__h1535, x__h948;
  wire [2 : 0] IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d48,
	       IF_f_fifo_w_deq_whas_THEN_f_fifo_size_cnt_3_MI_ETC___d47;
  wire [1 : 0] x__h1700, x__h1776, x__h1833;
  wire IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d25,
       IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d33,
       IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d41,
       IF_f_fifo_w_deq_whas_THEN_f_fifo_head_PLUS_1_E_ETC___d40,
       IF_f_fifo_w_deq_whas_THEN_f_fifo_tail_EQ_f_fif_ETC___d32,
       IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_1_0_ETC___d23,
       IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_2_9_ETC___d31,
       f_fifo_empty_6_EQ_f_fifo_head_EQ_f_fifo_tail_4_ETC___d67;

  // action method enq
  assign RDY_enq = 1'd1 ;

  // action method deq
  assign RDY_deq = 1'd1 ;

  // value method first
  always@(f_fifo_head or
	  f_fifo_mem_0 or f_fifo_mem_1 or f_fifo_mem_2 or f_fifo_mem_3)
  begin
    case (f_fifo_head)
      2'd0: first = f_fifo_mem_0;
      2'd1: first = f_fifo_mem_1;
      2'd2: first = f_fifo_mem_2;
      2'd3: first = f_fifo_mem_3;
    endcase
  end
  assign RDY_first = 1'd1 ;

  // value method notFull
  assign notFull = !f_fifo_full ;
  assign RDY_notFull = 1'd1 ;

  // value method notEmpty
  assign notEmpty = !f_fifo_empty ;
  assign RDY_notEmpty = 1'd1 ;

  // value method count
  assign count = f_fifo_size_cnt ;
  assign RDY_count = 1'd1 ;

  // action method clear
  assign RDY_clear = 1'd1 ;

  // rule RL_f_fifo_continuousAssert
  assign WILL_FIRE_RL_f_fifo_continuousAssert =
	     f_fifo_empty && f_fifo_enq_cnt != f_fifo_deq_cnt ;

  // register f_fifo_almost_full
  assign f_fifo_almost_full$D_IN =
	     !EN_clear &&
	     (IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d33 ||
	      IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d25) ;
  assign f_fifo_almost_full$EN = 1'd1 ;

  // register f_fifo_deq_cnt
  assign f_fifo_deq_cnt$D_IN = EN_clear ? 64'd0 : x__h948 ;
  assign f_fifo_deq_cnt$EN = EN_clear || EN_deq ;

  // register f_fifo_empty
  assign f_fifo_empty$D_IN =
	     EN_clear ||
	     IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d41 ;
  assign f_fifo_empty$EN = 1'd1 ;

  // register f_fifo_enq_cnt
  assign f_fifo_enq_cnt$D_IN = EN_clear ? 64'd0 : x__h1535 ;
  assign f_fifo_enq_cnt$EN = EN_clear || EN_enq ;

  // register f_fifo_full
  assign f_fifo_full$D_IN =
	     !EN_clear &&
	     IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d25 ;
  assign f_fifo_full$EN = 1'd1 ;

  // register f_fifo_head
  assign f_fifo_head$D_IN = EN_clear ? 2'd0 : x__h1700 ;
  assign f_fifo_head$EN = EN_clear || EN_deq ;

  // register f_fifo_mem_0
  assign f_fifo_mem_0$D_IN = enq_sendData ;
  assign f_fifo_mem_0$EN = f_fifo_tail == 2'd0 && !EN_clear && EN_enq ;

  // register f_fifo_mem_1
  assign f_fifo_mem_1$D_IN = enq_sendData ;
  assign f_fifo_mem_1$EN = f_fifo_tail == 2'd1 && !EN_clear && EN_enq ;

  // register f_fifo_mem_2
  assign f_fifo_mem_2$D_IN = enq_sendData ;
  assign f_fifo_mem_2$EN = f_fifo_tail == 2'd2 && !EN_clear && EN_enq ;

  // register f_fifo_mem_3
  assign f_fifo_mem_3$D_IN = enq_sendData ;
  assign f_fifo_mem_3$EN = f_fifo_tail == 2'd3 && !EN_clear && EN_enq ;

  // register f_fifo_size_cnt
  assign f_fifo_size_cnt$D_IN =
	     EN_clear ?
	       3'd0 :
	       IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d48 ;
  assign f_fifo_size_cnt$EN = 1'd1 ;

  // register f_fifo_tail
  assign f_fifo_tail$D_IN = EN_clear ? 2'd0 : x__h1776 ;
  assign f_fifo_tail$EN = EN_clear || EN_enq ;

  // remaining internal signals
  assign IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d25 =
	     (EN_deq && EN_enq) ?
	       f_fifo_full :
	       !EN_deq &&
	       IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_1_0_ETC___d23 ;
  assign IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d33 =
	     (EN_deq && EN_enq) ?
	       f_fifo_almost_full :
	       IF_f_fifo_w_deq_whas_THEN_f_fifo_tail_EQ_f_fif_ETC___d32 ;
  assign IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d41 =
	     (EN_deq && EN_enq) ?
	       f_fifo_empty :
	       IF_f_fifo_w_deq_whas_THEN_f_fifo_head_PLUS_1_E_ETC___d40 ;
  assign IF_f_fifo_w_deq_whas_AND_f_fifo_w_enq_whas_9_T_ETC___d48 =
	     (EN_deq && EN_enq) ?
	       f_fifo_size_cnt :
	       IF_f_fifo_w_deq_whas_THEN_f_fifo_size_cnt_3_MI_ETC___d47 ;
  assign IF_f_fifo_w_deq_whas_THEN_f_fifo_head_PLUS_1_E_ETC___d40 =
	     EN_deq ? x__h1700 == f_fifo_tail : !EN_enq && f_fifo_empty ;
  assign IF_f_fifo_w_deq_whas_THEN_f_fifo_size_cnt_3_MI_ETC___d47 =
	     EN_deq ?
	       f_fifo_size_cnt - 3'd1 :
	       (EN_enq ? f_fifo_size_cnt + 3'd1 : f_fifo_size_cnt) ;
  assign IF_f_fifo_w_deq_whas_THEN_f_fifo_tail_EQ_f_fif_ETC___d32 =
	     EN_deq ?
	       f_fifo_tail == f_fifo_head :
	       IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_2_9_ETC___d31 ;
  assign IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_1_0_ETC___d23 =
	     EN_enq ? x__h1776 == f_fifo_head : f_fifo_full ;
  assign IF_f_fifo_w_enq_whas_THEN_f_fifo_tail_PLUS_2_9_ETC___d31 =
	     EN_enq ? x__h1833 == f_fifo_head : f_fifo_almost_full ;
  assign f_fifo_empty_6_EQ_f_fifo_head_EQ_f_fifo_tail_4_ETC___d67 =
	     f_fifo_empty == (f_fifo_head == f_fifo_tail && !f_fifo_full) ;
  assign x__h1535 = f_fifo_enq_cnt + 64'd1 ;
  assign x__h1700 = f_fifo_head + 2'd1 ;
  assign x__h1776 = f_fifo_tail + 2'd1 ;
  assign x__h1833 = f_fifo_tail + 2'd2 ;
  assign x__h948 = f_fifo_deq_cnt + 64'd1 ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        f_fifo_almost_full <= `BSV_ASSIGNMENT_DELAY 1'd0;
	f_fifo_deq_cnt <= `BSV_ASSIGNMENT_DELAY 64'd0;
	f_fifo_empty <= `BSV_ASSIGNMENT_DELAY 1'd1;
	f_fifo_enq_cnt <= `BSV_ASSIGNMENT_DELAY 64'd0;
	f_fifo_full <= `BSV_ASSIGNMENT_DELAY 1'd0;
	f_fifo_head <= `BSV_ASSIGNMENT_DELAY 2'd0;
	f_fifo_mem_0 <= `BSV_ASSIGNMENT_DELAY 32'd0;
	f_fifo_mem_1 <= `BSV_ASSIGNMENT_DELAY 32'd0;
	f_fifo_mem_2 <= `BSV_ASSIGNMENT_DELAY 32'd0;
	f_fifo_mem_3 <= `BSV_ASSIGNMENT_DELAY 32'd0;
	f_fifo_size_cnt <= `BSV_ASSIGNMENT_DELAY 3'd0;
	f_fifo_tail <= `BSV_ASSIGNMENT_DELAY 2'd0;
      end
    else
      begin
        if (f_fifo_almost_full$EN)
	  f_fifo_almost_full <= `BSV_ASSIGNMENT_DELAY f_fifo_almost_full$D_IN;
	if (f_fifo_deq_cnt$EN)
	  f_fifo_deq_cnt <= `BSV_ASSIGNMENT_DELAY f_fifo_deq_cnt$D_IN;
	if (f_fifo_empty$EN)
	  f_fifo_empty <= `BSV_ASSIGNMENT_DELAY f_fifo_empty$D_IN;
	if (f_fifo_enq_cnt$EN)
	  f_fifo_enq_cnt <= `BSV_ASSIGNMENT_DELAY f_fifo_enq_cnt$D_IN;
	if (f_fifo_full$EN)
	  f_fifo_full <= `BSV_ASSIGNMENT_DELAY f_fifo_full$D_IN;
	if (f_fifo_head$EN)
	  f_fifo_head <= `BSV_ASSIGNMENT_DELAY f_fifo_head$D_IN;
	if (f_fifo_mem_0$EN)
	  f_fifo_mem_0 <= `BSV_ASSIGNMENT_DELAY f_fifo_mem_0$D_IN;
	if (f_fifo_mem_1$EN)
	  f_fifo_mem_1 <= `BSV_ASSIGNMENT_DELAY f_fifo_mem_1$D_IN;
	if (f_fifo_mem_2$EN)
	  f_fifo_mem_2 <= `BSV_ASSIGNMENT_DELAY f_fifo_mem_2$D_IN;
	if (f_fifo_mem_3$EN)
	  f_fifo_mem_3 <= `BSV_ASSIGNMENT_DELAY f_fifo_mem_3$D_IN;
	if (f_fifo_size_cnt$EN)
	  f_fifo_size_cnt <= `BSV_ASSIGNMENT_DELAY f_fifo_size_cnt$D_IN;
	if (f_fifo_tail$EN)
	  f_fifo_tail <= `BSV_ASSIGNMENT_DELAY f_fifo_tail$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    f_fifo_almost_full = 1'h0;
    f_fifo_deq_cnt = 64'hAAAAAAAAAAAAAAAA;
    f_fifo_empty = 1'h0;
    f_fifo_enq_cnt = 64'hAAAAAAAAAAAAAAAA;
    f_fifo_full = 1'h0;
    f_fifo_head = 2'h2;
    f_fifo_mem_0 = 32'hAAAAAAAA;
    f_fifo_mem_1 = 32'hAAAAAAAA;
    f_fifo_mem_2 = 32'hAAAAAAAA;
    f_fifo_mem_3 = 32'hAAAAAAAA;
    f_fifo_size_cnt = 3'h2;
    f_fifo_tail = 2'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && f_fifo_full)
	$display("location of dfifo: ",
		 "\"RegFIFO.bsv\", line 25, column 33\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_enq && f_fifo_full)
	$display("Dynamic assertion failed: \"RegFIFO.bsv\", line 191, column 27\nouch, enqueuing to full FIFO");
    if (RST_N != `BSV_RESET_VALUE) if (EN_enq && f_fifo_full) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && f_fifo_empty)
	$display("location of dfifo: ",
		 "\"RegFIFO.bsv\", line 25, column 33\n");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_deq && f_fifo_empty)
	$display("Dynamic assertion failed: \"RegFIFO.bsv\", line 198, column 28\nouch, dequeueing from empty FIFO");
    if (RST_N != `BSV_RESET_VALUE) if (EN_deq && f_fifo_empty) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_f_fifo_continuousAssert)
	$display("Continuous assertion failed: \"RegFIFO.bsv\", line 167, column 59\nmismatched in enq/deq count");
    if (RST_N != `BSV_RESET_VALUE)
      if (WILL_FIRE_RL_f_fifo_continuousAssert) $finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (!f_fifo_empty_6_EQ_f_fifo_head_EQ_f_fifo_tail_4_ETC___d67)
	$display("Continuous assertion failed: \"RegFIFO.bsv\", line 170, column 45\nerror in empty signals");
    if (RST_N != `BSV_RESET_VALUE)
      if (!f_fifo_empty_6_EQ_f_fifo_head_EQ_f_fifo_tail_4_ETC___d67)
	$finish(32'd0);
  end
  // synopsys translate_on
endmodule  // mkRegFIFOSynth

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:19 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// in_ports_0_getCredits          O     2
// in_ports_1_getCredits          O     2
// in_ports_2_getCredits          O     2
// out_ports_0_getFlit            O    39
// out_ports_1_getFlit            O    39
// out_ports_2_getFlit            O    39
// CLK                            I     1 clock
// RST_N                          I     1 reset
// in_ports_0_putRoutedFlit_flit_in  I    41
// in_ports_1_putRoutedFlit_flit_in  I    41
// in_ports_2_putRoutedFlit_flit_in  I    41
// out_ports_0_putCredits_cr_in   I     2
// out_ports_1_putCredits_cr_in   I     2
// out_ports_2_putCredits_cr_in   I     2
// EN_in_ports_0_putRoutedFlit    I     1
// EN_in_ports_1_putRoutedFlit    I     1
// EN_in_ports_2_putRoutedFlit    I     1
// EN_out_ports_0_putCredits      I     1
// EN_out_ports_1_putCredits      I     1
// EN_out_ports_2_putCredits      I     1
// EN_in_ports_0_getCredits       I     1 unused
// EN_in_ports_1_getCredits       I     1 unused
// EN_in_ports_2_getCredits       I     1 unused
// EN_out_ports_0_getFlit         I     1
// EN_out_ports_1_getFlit         I     1
// EN_out_ports_2_getFlit         I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouterCore(CLK,
		    RST_N,

		    in_ports_0_putRoutedFlit_flit_in,
		    EN_in_ports_0_putRoutedFlit,

		    EN_in_ports_0_getCredits,
		    in_ports_0_getCredits,

		    in_ports_1_putRoutedFlit_flit_in,
		    EN_in_ports_1_putRoutedFlit,

		    EN_in_ports_1_getCredits,
		    in_ports_1_getCredits,

		    in_ports_2_putRoutedFlit_flit_in,
		    EN_in_ports_2_putRoutedFlit,

		    EN_in_ports_2_getCredits,
		    in_ports_2_getCredits,

		    EN_out_ports_0_getFlit,
		    out_ports_0_getFlit,

		    out_ports_0_putCredits_cr_in,
		    EN_out_ports_0_putCredits,

		    EN_out_ports_1_getFlit,
		    out_ports_1_getFlit,

		    out_ports_1_putCredits_cr_in,
		    EN_out_ports_1_putCredits,

		    EN_out_ports_2_getFlit,
		    out_ports_2_getFlit,

		    out_ports_2_putCredits_cr_in,
		    EN_out_ports_2_putCredits);
  input  CLK;
  input  RST_N;

  // action method in_ports_0_putRoutedFlit
  input  [40 : 0] in_ports_0_putRoutedFlit_flit_in;
  input  EN_in_ports_0_putRoutedFlit;

  // actionvalue method in_ports_0_getCredits
  input  EN_in_ports_0_getCredits;
  output [1 : 0] in_ports_0_getCredits;

  // action method in_ports_1_putRoutedFlit
  input  [40 : 0] in_ports_1_putRoutedFlit_flit_in;
  input  EN_in_ports_1_putRoutedFlit;

  // actionvalue method in_ports_1_getCredits
  input  EN_in_ports_1_getCredits;
  output [1 : 0] in_ports_1_getCredits;

  // action method in_ports_2_putRoutedFlit
  input  [40 : 0] in_ports_2_putRoutedFlit_flit_in;
  input  EN_in_ports_2_putRoutedFlit;

  // actionvalue method in_ports_2_getCredits
  input  EN_in_ports_2_getCredits;
  output [1 : 0] in_ports_2_getCredits;

  // actionvalue method out_ports_0_getFlit
  input  EN_out_ports_0_getFlit;
  output [38 : 0] out_ports_0_getFlit;

  // action method out_ports_0_putCredits
  input  [1 : 0] out_ports_0_putCredits_cr_in;
  input  EN_out_ports_0_putCredits;

  // actionvalue method out_ports_1_getFlit
  input  EN_out_ports_1_getFlit;
  output [38 : 0] out_ports_1_getFlit;

  // action method out_ports_1_putCredits
  input  [1 : 0] out_ports_1_putCredits_cr_in;
  input  EN_out_ports_1_putCredits;

  // actionvalue method out_ports_2_getFlit
  input  EN_out_ports_2_getFlit;
  output [38 : 0] out_ports_2_getFlit;

  // action method out_ports_2_putCredits
  input  [1 : 0] out_ports_2_putCredits_cr_in;
  input  EN_out_ports_2_putCredits;

  // signals for module outputs
  wire [38 : 0] out_ports_0_getFlit, out_ports_1_getFlit, out_ports_2_getFlit;
  wire [1 : 0] in_ports_0_getCredits,
	       in_ports_1_getCredits,
	       in_ports_2_getCredits;

  // inlined wires
  wire [38 : 0] hasFlitsToSend_perIn_0$wget,
		hasFlitsToSend_perIn_1$wget,
		hasFlitsToSend_perIn_2$wget;
  wire credits_clear_0_0$whas,
       credits_clear_0_1$whas,
       credits_clear_1_0$whas,
       credits_clear_1_1$whas,
       credits_clear_2_0$whas,
       credits_clear_2_1$whas,
       credits_set_0_0$whas,
       credits_set_0_1$whas,
       credits_set_1_0$whas,
       credits_set_1_1$whas,
       credits_set_2_0$whas,
       credits_set_2_1$whas;

  // register activeVC_perIn_reg_0
  reg [1 : 0] activeVC_perIn_reg_0;
  wire [1 : 0] activeVC_perIn_reg_0$D_IN;
  wire activeVC_perIn_reg_0$EN;

  // register activeVC_perIn_reg_1
  reg [1 : 0] activeVC_perIn_reg_1;
  wire [1 : 0] activeVC_perIn_reg_1$D_IN;
  wire activeVC_perIn_reg_1$EN;

  // register activeVC_perIn_reg_2
  reg [1 : 0] activeVC_perIn_reg_2;
  wire [1 : 0] activeVC_perIn_reg_2$D_IN;
  wire activeVC_perIn_reg_2$EN;

  // register credits_0_0
  reg [2 : 0] credits_0_0;
  wire [2 : 0] credits_0_0$D_IN;
  wire credits_0_0$EN;

  // register credits_0_1
  reg [2 : 0] credits_0_1;
  wire [2 : 0] credits_0_1$D_IN;
  wire credits_0_1$EN;

  // register credits_1_0
  reg [2 : 0] credits_1_0;
  wire [2 : 0] credits_1_0$D_IN;
  wire credits_1_0$EN;

  // register credits_1_1
  reg [2 : 0] credits_1_1;
  wire [2 : 0] credits_1_1$D_IN;
  wire credits_1_1$EN;

  // register credits_2_0
  reg [2 : 0] credits_2_0;
  wire [2 : 0] credits_2_0$D_IN;
  wire credits_2_0$EN;

  // register credits_2_1
  reg [2 : 0] credits_2_1;
  wire [2 : 0] credits_2_1$D_IN;
  wire credits_2_1$EN;

  // register inPortVL_0_0
  reg [1 : 0] inPortVL_0_0;
  wire [1 : 0] inPortVL_0_0$D_IN;
  wire inPortVL_0_0$EN;

  // register inPortVL_0_1
  reg [1 : 0] inPortVL_0_1;
  wire [1 : 0] inPortVL_0_1$D_IN;
  wire inPortVL_0_1$EN;

  // register inPortVL_1_0
  reg [1 : 0] inPortVL_1_0;
  wire [1 : 0] inPortVL_1_0$D_IN;
  wire inPortVL_1_0$EN;

  // register inPortVL_1_1
  reg [1 : 0] inPortVL_1_1;
  wire [1 : 0] inPortVL_1_1$D_IN;
  wire inPortVL_1_1$EN;

  // register inPortVL_2_0
  reg [1 : 0] inPortVL_2_0;
  wire [1 : 0] inPortVL_2_0$D_IN;
  wire inPortVL_2_0$EN;

  // register inPortVL_2_1
  reg [1 : 0] inPortVL_2_1;
  wire [1 : 0] inPortVL_2_1$D_IN;
  wire inPortVL_2_1$EN;

  // register lockedVL_0_0
  reg lockedVL_0_0;
  wire lockedVL_0_0$D_IN, lockedVL_0_0$EN;

  // register lockedVL_0_1
  reg lockedVL_0_1;
  wire lockedVL_0_1$D_IN, lockedVL_0_1$EN;

  // register lockedVL_1_0
  reg lockedVL_1_0;
  wire lockedVL_1_0$D_IN, lockedVL_1_0$EN;

  // register lockedVL_1_1
  reg lockedVL_1_1;
  wire lockedVL_1_1$D_IN, lockedVL_1_1$EN;

  // register lockedVL_2_0
  reg lockedVL_2_0;
  wire lockedVL_2_0$D_IN, lockedVL_2_0$EN;

  // register lockedVL_2_1
  reg lockedVL_2_1;
  wire lockedVL_2_1$D_IN, lockedVL_2_1$EN;

  // register selectedIO_reg_0_0
  reg selectedIO_reg_0_0;
  wire selectedIO_reg_0_0$D_IN, selectedIO_reg_0_0$EN;

  // register selectedIO_reg_0_1
  reg selectedIO_reg_0_1;
  wire selectedIO_reg_0_1$D_IN, selectedIO_reg_0_1$EN;

  // register selectedIO_reg_0_2
  reg selectedIO_reg_0_2;
  wire selectedIO_reg_0_2$D_IN, selectedIO_reg_0_2$EN;

  // register selectedIO_reg_1_0
  reg selectedIO_reg_1_0;
  wire selectedIO_reg_1_0$D_IN, selectedIO_reg_1_0$EN;

  // register selectedIO_reg_1_1
  reg selectedIO_reg_1_1;
  wire selectedIO_reg_1_1$D_IN, selectedIO_reg_1_1$EN;

  // register selectedIO_reg_1_2
  reg selectedIO_reg_1_2;
  wire selectedIO_reg_1_2$D_IN, selectedIO_reg_1_2$EN;

  // register selectedIO_reg_2_0
  reg selectedIO_reg_2_0;
  wire selectedIO_reg_2_0$D_IN, selectedIO_reg_2_0$EN;

  // register selectedIO_reg_2_1
  reg selectedIO_reg_2_1;
  wire selectedIO_reg_2_1$D_IN, selectedIO_reg_2_1$EN;

  // register selectedIO_reg_2_2
  reg selectedIO_reg_2_2;
  wire selectedIO_reg_2_2$D_IN, selectedIO_reg_2_2$EN;

  // ports of submodule flitBuffers_0
  wire [37 : 0] flitBuffers_0$deq, flitBuffers_0$enq_data_in;
  wire [1 : 0] flitBuffers_0$notEmpty;
  wire flitBuffers_0$EN_deq,
       flitBuffers_0$EN_enq,
       flitBuffers_0$deq_fifo_out,
       flitBuffers_0$enq_fifo_in;

  // ports of submodule flitBuffers_1
  wire [37 : 0] flitBuffers_1$deq, flitBuffers_1$enq_data_in;
  wire [1 : 0] flitBuffers_1$notEmpty;
  wire flitBuffers_1$EN_deq,
       flitBuffers_1$EN_enq,
       flitBuffers_1$deq_fifo_out,
       flitBuffers_1$enq_fifo_in;

  // ports of submodule flitBuffers_2
  wire [37 : 0] flitBuffers_2$deq, flitBuffers_2$enq_data_in;
  wire [1 : 0] flitBuffers_2$notEmpty;
  wire flitBuffers_2$EN_deq,
       flitBuffers_2$EN_enq,
       flitBuffers_2$deq_fifo_out,
       flitBuffers_2$enq_fifo_in;

  // ports of submodule outPortFIFOs_0_0
  wire [1 : 0] outPortFIFOs_0_0$enq_sendData, outPortFIFOs_0_0$first;
  wire outPortFIFOs_0_0$EN_clear,
       outPortFIFOs_0_0$EN_deq,
       outPortFIFOs_0_0$EN_enq;

  // ports of submodule outPortFIFOs_0_1
  wire [1 : 0] outPortFIFOs_0_1$enq_sendData, outPortFIFOs_0_1$first;
  wire outPortFIFOs_0_1$EN_clear,
       outPortFIFOs_0_1$EN_deq,
       outPortFIFOs_0_1$EN_enq;

  // ports of submodule outPortFIFOs_1_0
  wire [1 : 0] outPortFIFOs_1_0$enq_sendData, outPortFIFOs_1_0$first;
  wire outPortFIFOs_1_0$EN_clear,
       outPortFIFOs_1_0$EN_deq,
       outPortFIFOs_1_0$EN_enq;

  // ports of submodule outPortFIFOs_1_1
  wire [1 : 0] outPortFIFOs_1_1$enq_sendData, outPortFIFOs_1_1$first;
  wire outPortFIFOs_1_1$EN_clear,
       outPortFIFOs_1_1$EN_deq,
       outPortFIFOs_1_1$EN_enq;

  // ports of submodule outPortFIFOs_2_0
  wire [1 : 0] outPortFIFOs_2_0$enq_sendData, outPortFIFOs_2_0$first;
  wire outPortFIFOs_2_0$EN_clear,
       outPortFIFOs_2_0$EN_deq,
       outPortFIFOs_2_0$EN_enq;

  // ports of submodule outPortFIFOs_2_1
  wire [1 : 0] outPortFIFOs_2_1$enq_sendData, outPortFIFOs_2_1$first;
  wire outPortFIFOs_2_1$EN_clear,
       outPortFIFOs_2_1$EN_deq,
       outPortFIFOs_2_1$EN_enq;

  // ports of submodule routerAlloc
  wire [8 : 0] routerAlloc$allocate, routerAlloc$allocate_alloc_input;
  wire routerAlloc$EN_allocate, routerAlloc$EN_next;

  // remaining internal signals
  reg [33 : 0] CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8,
	       CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11,
	       CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14;
  reg [2 : 0] CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1,
	      CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6,
	      CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2,
	      CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5,
	      CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3,
	      CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4;
  reg [1 : 0] CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7,
	      CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10,
	      CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13;
  reg CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9,
      CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12,
      CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15,
      SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406,
      SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471,
      SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516,
      SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412,
      SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473,
      SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518,
      active_vc__h25157,
      active_vc__h26282,
      active_vc__h27407;
  wire [36 : 0] SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d439,
		SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d484,
		SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d529;
  wire [2 : 0] IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d33,
	       IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d59,
	       IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d85,
	       IF_flitBuffers_0_notEmpty__1_BIT_0_2_THEN_IF_S_ETC___d86,
	       IF_flitBuffers_1_notEmpty__5_BIT_0_6_THEN_IF_S_ETC___d60,
	       IF_flitBuffers_2_notEmpty_BIT_0_THEN_IF_SEL_AR_ETC___d34,
	       credits_0_0_read_PLUS_1___d200,
	       credits_0_1_read__1_PLUS_1___d223,
	       credits_1_0_read_PLUS_1___d246,
	       credits_1_1_read__2_PLUS_1___d269,
	       credits_2_0_read_PLUS_1___d292,
	       credits_2_1_read__3_PLUS_1___d315,
	       outport_encoder___d108,
	       outport_encoder___d137,
	       outport_encoder___d166,
	       x__h18076,
	       x__h18583,
	       x__h19283,
	       x__h19790,
	       x__h20490,
	       x__h20997;
  wire [1 : 0] IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d402,
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d467,
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d512,
	       active_in__h24741,
	       active_in__h25968,
	       active_in__h27093;
  wire IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d367,
       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d452,
       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d497,
       IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d376,
       IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d460,
       IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d505,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d379,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d463,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499,
       IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d508,
       NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d112,
       NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d141,
       NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d170,
       fifo_out__h15874,
       fifo_out__h16629,
       fifo_out__h16969,
       flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d111,
       flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d73,
       flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d76,
       flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d79,
       flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d140,
       flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d47,
       flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d50,
       flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d53,
       flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d169,
       flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d21,
       flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d24,
       flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d27,
       outport_encoder_08_BIT_2_09_AND_IF_flitBuffers_ETC___d333,
       outport_encoder_37_BIT_2_38_AND_IF_flitBuffers_ETC___d344,
       outport_encoder_66_BIT_2_67_AND_IF_flitBuffers_ETC___d355;

  // actionvalue method in_ports_0_getCredits
  assign in_ports_0_getCredits =
	     { outport_encoder_08_BIT_2_09_AND_IF_flitBuffers_ETC___d333,
	       fifo_out__h15874 } ;

  // actionvalue method in_ports_1_getCredits
  assign in_ports_1_getCredits =
	     { outport_encoder_37_BIT_2_38_AND_IF_flitBuffers_ETC___d344,
	       fifo_out__h16629 } ;

  // actionvalue method in_ports_2_getCredits
  assign in_ports_2_getCredits =
	     { outport_encoder_66_BIT_2_67_AND_IF_flitBuffers_ETC___d355,
	       fifo_out__h16969 } ;

  // actionvalue method out_ports_0_getFlit
  assign out_ports_0_getFlit =
	     { IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	       SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412,
	       CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9,
	       SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d439 } ;

  // actionvalue method out_ports_1_getFlit
  assign out_ports_1_getFlit =
	     { IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	       SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473,
	       CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12,
	       SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d484 } ;

  // actionvalue method out_ports_2_getFlit
  assign out_ports_2_getFlit =
	     { IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	       SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518,
	       CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15,
	       SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d529 } ;

  // submodule flitBuffers_0
  mkInputVCQueues flitBuffers_0(.CLK(CLK),
				.RST_N(RST_N),
				.deq_fifo_out(flitBuffers_0$deq_fifo_out),
				.enq_data_in(flitBuffers_0$enq_data_in),
				.enq_fifo_in(flitBuffers_0$enq_fifo_in),
				.EN_enq(flitBuffers_0$EN_enq),
				.EN_deq(flitBuffers_0$EN_deq),
				.deq(flitBuffers_0$deq),
				.notEmpty(flitBuffers_0$notEmpty),
				.notFull());

  // submodule flitBuffers_1
  mkInputVCQueues flitBuffers_1(.CLK(CLK),
				.RST_N(RST_N),
				.deq_fifo_out(flitBuffers_1$deq_fifo_out),
				.enq_data_in(flitBuffers_1$enq_data_in),
				.enq_fifo_in(flitBuffers_1$enq_fifo_in),
				.EN_enq(flitBuffers_1$EN_enq),
				.EN_deq(flitBuffers_1$EN_deq),
				.deq(flitBuffers_1$deq),
				.notEmpty(flitBuffers_1$notEmpty),
				.notFull());

  // submodule flitBuffers_2
  mkInputVCQueues flitBuffers_2(.CLK(CLK),
				.RST_N(RST_N),
				.deq_fifo_out(flitBuffers_2$deq_fifo_out),
				.enq_data_in(flitBuffers_2$enq_data_in),
				.enq_fifo_in(flitBuffers_2$enq_fifo_in),
				.EN_enq(flitBuffers_2$EN_enq),
				.EN_deq(flitBuffers_2$EN_deq),
				.deq(flitBuffers_2$deq),
				.notEmpty(flitBuffers_2$notEmpty),
				.notFull());

  // submodule outPortFIFOs_0_0
  mkOutPortFIFO outPortFIFOs_0_0(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_0_0$enq_sendData),
				 .EN_enq(outPortFIFOs_0_0$EN_enq),
				 .EN_deq(outPortFIFOs_0_0$EN_deq),
				 .EN_clear(outPortFIFOs_0_0$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_0_0$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule outPortFIFOs_0_1
  mkOutPortFIFO outPortFIFOs_0_1(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_0_1$enq_sendData),
				 .EN_enq(outPortFIFOs_0_1$EN_enq),
				 .EN_deq(outPortFIFOs_0_1$EN_deq),
				 .EN_clear(outPortFIFOs_0_1$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_0_1$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule outPortFIFOs_1_0
  mkOutPortFIFO outPortFIFOs_1_0(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_1_0$enq_sendData),
				 .EN_enq(outPortFIFOs_1_0$EN_enq),
				 .EN_deq(outPortFIFOs_1_0$EN_deq),
				 .EN_clear(outPortFIFOs_1_0$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_1_0$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule outPortFIFOs_1_1
  mkOutPortFIFO outPortFIFOs_1_1(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_1_1$enq_sendData),
				 .EN_enq(outPortFIFOs_1_1$EN_enq),
				 .EN_deq(outPortFIFOs_1_1$EN_deq),
				 .EN_clear(outPortFIFOs_1_1$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_1_1$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule outPortFIFOs_2_0
  mkOutPortFIFO outPortFIFOs_2_0(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_2_0$enq_sendData),
				 .EN_enq(outPortFIFOs_2_0$EN_enq),
				 .EN_deq(outPortFIFOs_2_0$EN_deq),
				 .EN_clear(outPortFIFOs_2_0$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_2_0$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule outPortFIFOs_2_1
  mkOutPortFIFO outPortFIFOs_2_1(.CLK(CLK),
				 .RST_N(RST_N),
				 .enq_sendData(outPortFIFOs_2_1$enq_sendData),
				 .EN_enq(outPortFIFOs_2_1$EN_enq),
				 .EN_deq(outPortFIFOs_2_1$EN_deq),
				 .EN_clear(outPortFIFOs_2_1$EN_clear),
				 .RDY_enq(),
				 .RDY_deq(),
				 .first(outPortFIFOs_2_1$first),
				 .RDY_first(),
				 .notFull(),
				 .RDY_notFull(),
				 .notEmpty(),
				 .RDY_notEmpty(),
				 .count(),
				 .RDY_count(),
				 .RDY_clear());

  // submodule routerAlloc
  mkSepRouterAllocator routerAlloc(.pipeline(1'd0),
				   .CLK(CLK),
				   .RST_N(RST_N),
				   .allocate_alloc_input(routerAlloc$allocate_alloc_input),
				   .EN_allocate(routerAlloc$EN_allocate),
				   .EN_next(routerAlloc$EN_next),
				   .allocate(routerAlloc$allocate));

  // inlined wires
  assign hasFlitsToSend_perIn_0$wget = { 1'd1, flitBuffers_0$deq } ;
  assign hasFlitsToSend_perIn_1$wget = { 1'd1, flitBuffers_1$deq } ;
  assign hasFlitsToSend_perIn_2$wget = { 1'd1, flitBuffers_2$deq } ;
  assign credits_set_0_0$whas =
	     EN_out_ports_0_putCredits &&
	     out_ports_0_putCredits_cr_in[0] == 1'd0 &&
	     out_ports_0_putCredits_cr_in[1] ;
  assign credits_set_0_1$whas =
	     EN_out_ports_0_putCredits &&
	     out_ports_0_putCredits_cr_in[0] == 1'd1 &&
	     out_ports_0_putCredits_cr_in[1] ;
  assign credits_clear_0_0$whas =
	     EN_out_ports_0_getFlit && active_vc__h25157 == 1'd0 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 ;
  assign credits_clear_0_1$whas =
	     EN_out_ports_0_getFlit && active_vc__h25157 == 1'd1 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 ;
  assign credits_set_1_0$whas =
	     EN_out_ports_1_putCredits &&
	     out_ports_1_putCredits_cr_in[0] == 1'd0 &&
	     out_ports_1_putCredits_cr_in[1] ;
  assign credits_set_1_1$whas =
	     EN_out_ports_1_putCredits &&
	     out_ports_1_putCredits_cr_in[0] == 1'd1 &&
	     out_ports_1_putCredits_cr_in[1] ;
  assign credits_clear_1_0$whas =
	     EN_out_ports_1_getFlit && active_vc__h26282 == 1'd0 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 ;
  assign credits_clear_1_1$whas =
	     EN_out_ports_1_getFlit && active_vc__h26282 == 1'd1 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 ;
  assign credits_set_2_0$whas =
	     EN_out_ports_2_putCredits &&
	     out_ports_2_putCredits_cr_in[0] == 1'd0 &&
	     out_ports_2_putCredits_cr_in[1] ;
  assign credits_set_2_1$whas =
	     EN_out_ports_2_putCredits &&
	     out_ports_2_putCredits_cr_in[0] == 1'd1 &&
	     out_ports_2_putCredits_cr_in[1] ;
  assign credits_clear_2_0$whas =
	     EN_out_ports_2_getFlit && active_vc__h27407 == 1'd0 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 ;
  assign credits_clear_2_1$whas =
	     EN_out_ports_2_getFlit && active_vc__h27407 == 1'd1 &&
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 ;

  // register activeVC_perIn_reg_0
  assign activeVC_perIn_reg_0$D_IN = 2'h0 ;
  assign activeVC_perIn_reg_0$EN = 1'b0 ;

  // register activeVC_perIn_reg_1
  assign activeVC_perIn_reg_1$D_IN = 2'h0 ;
  assign activeVC_perIn_reg_1$EN = 1'b0 ;

  // register activeVC_perIn_reg_2
  assign activeVC_perIn_reg_2$D_IN = 2'h0 ;
  assign activeVC_perIn_reg_2$EN = 1'b0 ;

  // register credits_0_0
  assign credits_0_0$D_IN =
	     (credits_set_0_0$whas && !credits_clear_0_0$whas) ?
	       credits_0_0_read_PLUS_1___d200 :
	       x__h18076 ;
  assign credits_0_0$EN =
	     credits_set_0_0$whas && !credits_clear_0_0$whas ||
	     !credits_set_0_0$whas && credits_clear_0_0$whas ;

  // register credits_0_1
  assign credits_0_1$D_IN =
	     (credits_set_0_1$whas && !credits_clear_0_1$whas) ?
	       credits_0_1_read__1_PLUS_1___d223 :
	       x__h18583 ;
  assign credits_0_1$EN =
	     credits_set_0_1$whas && !credits_clear_0_1$whas ||
	     !credits_set_0_1$whas && credits_clear_0_1$whas ;

  // register credits_1_0
  assign credits_1_0$D_IN =
	     (credits_set_1_0$whas && !credits_clear_1_0$whas) ?
	       credits_1_0_read_PLUS_1___d246 :
	       x__h19283 ;
  assign credits_1_0$EN =
	     credits_set_1_0$whas && !credits_clear_1_0$whas ||
	     !credits_set_1_0$whas && credits_clear_1_0$whas ;

  // register credits_1_1
  assign credits_1_1$D_IN =
	     (credits_set_1_1$whas && !credits_clear_1_1$whas) ?
	       credits_1_1_read__2_PLUS_1___d269 :
	       x__h19790 ;
  assign credits_1_1$EN =
	     credits_set_1_1$whas && !credits_clear_1_1$whas ||
	     !credits_set_1_1$whas && credits_clear_1_1$whas ;

  // register credits_2_0
  assign credits_2_0$D_IN =
	     (credits_set_2_0$whas && !credits_clear_2_0$whas) ?
	       credits_2_0_read_PLUS_1___d292 :
	       x__h20490 ;
  assign credits_2_0$EN =
	     credits_set_2_0$whas && !credits_clear_2_0$whas ||
	     !credits_set_2_0$whas && credits_clear_2_0$whas ;

  // register credits_2_1
  assign credits_2_1$D_IN =
	     (credits_set_2_1$whas && !credits_clear_2_1$whas) ?
	       credits_2_1_read__3_PLUS_1___d315 :
	       x__h20997 ;
  assign credits_2_1$EN =
	     credits_set_2_1$whas && !credits_clear_2_1$whas ||
	     !credits_set_2_1$whas && credits_clear_2_1$whas ;

  // register inPortVL_0_0
  assign inPortVL_0_0$D_IN = 2'h0 ;
  assign inPortVL_0_0$EN = 1'b0 ;

  // register inPortVL_0_1
  assign inPortVL_0_1$D_IN = 2'h0 ;
  assign inPortVL_0_1$EN = 1'b0 ;

  // register inPortVL_1_0
  assign inPortVL_1_0$D_IN = 2'h0 ;
  assign inPortVL_1_0$EN = 1'b0 ;

  // register inPortVL_1_1
  assign inPortVL_1_1$D_IN = 2'h0 ;
  assign inPortVL_1_1$EN = 1'b0 ;

  // register inPortVL_2_0
  assign inPortVL_2_0$D_IN = 2'h0 ;
  assign inPortVL_2_0$EN = 1'b0 ;

  // register inPortVL_2_1
  assign inPortVL_2_1$D_IN = 2'h0 ;
  assign inPortVL_2_1$EN = 1'b0 ;

  // register lockedVL_0_0
  assign lockedVL_0_0$D_IN = 1'b0 ;
  assign lockedVL_0_0$EN = 1'b0 ;

  // register lockedVL_0_1
  assign lockedVL_0_1$D_IN = 1'b0 ;
  assign lockedVL_0_1$EN = 1'b0 ;

  // register lockedVL_1_0
  assign lockedVL_1_0$D_IN = 1'b0 ;
  assign lockedVL_1_0$EN = 1'b0 ;

  // register lockedVL_1_1
  assign lockedVL_1_1$D_IN = 1'b0 ;
  assign lockedVL_1_1$EN = 1'b0 ;

  // register lockedVL_2_0
  assign lockedVL_2_0$D_IN = 1'b0 ;
  assign lockedVL_2_0$EN = 1'b0 ;

  // register lockedVL_2_1
  assign lockedVL_2_1$D_IN = 1'b0 ;
  assign lockedVL_2_1$EN = 1'b0 ;

  // register selectedIO_reg_0_0
  assign selectedIO_reg_0_0$D_IN = 1'b0 ;
  assign selectedIO_reg_0_0$EN = 1'b0 ;

  // register selectedIO_reg_0_1
  assign selectedIO_reg_0_1$D_IN = 1'b0 ;
  assign selectedIO_reg_0_1$EN = 1'b0 ;

  // register selectedIO_reg_0_2
  assign selectedIO_reg_0_2$D_IN = 1'b0 ;
  assign selectedIO_reg_0_2$EN = 1'b0 ;

  // register selectedIO_reg_1_0
  assign selectedIO_reg_1_0$D_IN = 1'b0 ;
  assign selectedIO_reg_1_0$EN = 1'b0 ;

  // register selectedIO_reg_1_1
  assign selectedIO_reg_1_1$D_IN = 1'b0 ;
  assign selectedIO_reg_1_1$EN = 1'b0 ;

  // register selectedIO_reg_1_2
  assign selectedIO_reg_1_2$D_IN = 1'b0 ;
  assign selectedIO_reg_1_2$EN = 1'b0 ;

  // register selectedIO_reg_2_0
  assign selectedIO_reg_2_0$D_IN = 1'b0 ;
  assign selectedIO_reg_2_0$EN = 1'b0 ;

  // register selectedIO_reg_2_1
  assign selectedIO_reg_2_1$D_IN = 1'b0 ;
  assign selectedIO_reg_2_1$EN = 1'b0 ;

  // register selectedIO_reg_2_2
  assign selectedIO_reg_2_2$D_IN = 1'b0 ;
  assign selectedIO_reg_2_2$EN = 1'b0 ;

  // submodule flitBuffers_0
  assign flitBuffers_0$deq_fifo_out = fifo_out__h15874 ;
  assign flitBuffers_0$enq_data_in = in_ports_0_putRoutedFlit_flit_in[39:2] ;
  assign flitBuffers_0$enq_fifo_in = in_ports_0_putRoutedFlit_flit_in[36] ;
  assign flitBuffers_0$EN_enq =
	     EN_in_ports_0_putRoutedFlit &&
	     in_ports_0_putRoutedFlit_flit_in[40] ;
  assign flitBuffers_0$EN_deq = outport_encoder___d108[2] ;

  // submodule flitBuffers_1
  assign flitBuffers_1$deq_fifo_out = fifo_out__h16629 ;
  assign flitBuffers_1$enq_data_in = in_ports_1_putRoutedFlit_flit_in[39:2] ;
  assign flitBuffers_1$enq_fifo_in = in_ports_1_putRoutedFlit_flit_in[36] ;
  assign flitBuffers_1$EN_enq =
	     EN_in_ports_1_putRoutedFlit &&
	     in_ports_1_putRoutedFlit_flit_in[40] ;
  assign flitBuffers_1$EN_deq = outport_encoder___d137[2] ;

  // submodule flitBuffers_2
  assign flitBuffers_2$deq_fifo_out = fifo_out__h16969 ;
  assign flitBuffers_2$enq_data_in = in_ports_2_putRoutedFlit_flit_in[39:2] ;
  assign flitBuffers_2$enq_fifo_in = in_ports_2_putRoutedFlit_flit_in[36] ;
  assign flitBuffers_2$EN_enq =
	     EN_in_ports_2_putRoutedFlit &&
	     in_ports_2_putRoutedFlit_flit_in[40] ;
  assign flitBuffers_2$EN_deq = outport_encoder___d166[2] ;

  // submodule outPortFIFOs_0_0
  assign outPortFIFOs_0_0$enq_sendData =
	     in_ports_0_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_0_0$EN_enq =
	     EN_in_ports_0_putRoutedFlit &&
	     in_ports_0_putRoutedFlit_flit_in[36] == 1'd0 &&
	     in_ports_0_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_0_0$EN_deq =
	     fifo_out__h15874 == 1'd0 && outport_encoder___d108[2] ;
  assign outPortFIFOs_0_0$EN_clear = 1'b0 ;

  // submodule outPortFIFOs_0_1
  assign outPortFIFOs_0_1$enq_sendData =
	     in_ports_0_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_0_1$EN_enq =
	     EN_in_ports_0_putRoutedFlit &&
	     in_ports_0_putRoutedFlit_flit_in[36] == 1'd1 &&
	     in_ports_0_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_0_1$EN_deq =
	     fifo_out__h15874 == 1'd1 && outport_encoder___d108[2] ;
  assign outPortFIFOs_0_1$EN_clear = 1'b0 ;

  // submodule outPortFIFOs_1_0
  assign outPortFIFOs_1_0$enq_sendData =
	     in_ports_1_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_1_0$EN_enq =
	     EN_in_ports_1_putRoutedFlit &&
	     in_ports_1_putRoutedFlit_flit_in[36] == 1'd0 &&
	     in_ports_1_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_1_0$EN_deq =
	     fifo_out__h16629 == 1'd0 && outport_encoder___d137[2] ;
  assign outPortFIFOs_1_0$EN_clear = 1'b0 ;

  // submodule outPortFIFOs_1_1
  assign outPortFIFOs_1_1$enq_sendData =
	     in_ports_1_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_1_1$EN_enq =
	     EN_in_ports_1_putRoutedFlit &&
	     in_ports_1_putRoutedFlit_flit_in[36] == 1'd1 &&
	     in_ports_1_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_1_1$EN_deq =
	     fifo_out__h16629 == 1'd1 && outport_encoder___d137[2] ;
  assign outPortFIFOs_1_1$EN_clear = 1'b0 ;

  // submodule outPortFIFOs_2_0
  assign outPortFIFOs_2_0$enq_sendData =
	     in_ports_2_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_2_0$EN_enq =
	     EN_in_ports_2_putRoutedFlit &&
	     in_ports_2_putRoutedFlit_flit_in[36] == 1'd0 &&
	     in_ports_2_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_2_0$EN_deq =
	     fifo_out__h16969 == 1'd0 && outport_encoder___d166[2] ;
  assign outPortFIFOs_2_0$EN_clear = 1'b0 ;

  // submodule outPortFIFOs_2_1
  assign outPortFIFOs_2_1$enq_sendData =
	     in_ports_2_putRoutedFlit_flit_in[1:0] ;
  assign outPortFIFOs_2_1$EN_enq =
	     EN_in_ports_2_putRoutedFlit &&
	     in_ports_2_putRoutedFlit_flit_in[36] == 1'd1 &&
	     in_ports_2_putRoutedFlit_flit_in[40] ;
  assign outPortFIFOs_2_1$EN_deq =
	     fifo_out__h16969 == 1'd1 && outport_encoder___d166[2] ;
  assign outPortFIFOs_2_1$EN_clear = 1'b0 ;

  // submodule routerAlloc
  assign routerAlloc$allocate_alloc_input =
	     { IF_flitBuffers_2_notEmpty_BIT_0_THEN_IF_SEL_AR_ETC___d34,
	       IF_flitBuffers_1_notEmpty__5_BIT_0_6_THEN_IF_S_ETC___d60,
	       IF_flitBuffers_0_notEmpty__1_BIT_0_2_THEN_IF_S_ETC___d86 } ;
  assign routerAlloc$EN_allocate = 1'd1 ;
  assign routerAlloc$EN_next = 1'd1 ;

  // remaining internal signals
  module_outport_encoder instance_outport_encoder_1(.outport_encoder_vec({ 1'd1 &&
									   routerAlloc$allocate[2],
									   1'd1 &&
									   routerAlloc$allocate[1],
									   1'd1 &&
									   routerAlloc$allocate[0] }),
						    .outport_encoder(outport_encoder___d108));
  module_outport_encoder instance_outport_encoder_0(.outport_encoder_vec({ 1'd1 &&
									   routerAlloc$allocate[5],
									   1'd1 &&
									   routerAlloc$allocate[4],
									   1'd1 &&
									   routerAlloc$allocate[3] }),
						    .outport_encoder(outport_encoder___d137));
  module_outport_encoder instance_outport_encoder_2(.outport_encoder_vec({ 1'd1 &&
									   routerAlloc$allocate[8],
									   1'd1 &&
									   routerAlloc$allocate[7],
									   1'd1 &&
									   routerAlloc$allocate[6] }),
						    .outport_encoder(outport_encoder___d166));
  assign IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d33 =
	     (CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 == 3'd0) ?
	       { flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d21,
		 flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d24,
		 flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d27 } :
	       { outPortFIFOs_2_0$first == 2'd2,
		 outPortFIFOs_2_0$first == 2'd1,
		 outPortFIFOs_2_0$first == 2'd0 } ;
  assign IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d59 =
	     (CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 == 3'd0) ?
	       { flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d47,
		 flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d50,
		 flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d53 } :
	       { outPortFIFOs_1_0$first == 2'd2,
		 outPortFIFOs_1_0$first == 2'd1,
		 outPortFIFOs_1_0$first == 2'd0 } ;
  assign IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d85 =
	     (CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 == 3'd0) ?
	       { flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d73,
		 flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d76,
		 flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d79 } :
	       { outPortFIFOs_0_0$first == 2'd2,
		 outPortFIFOs_0_0$first == 2'd1,
		 outPortFIFOs_0_0$first == 2'd0 } ;
  assign IF_flitBuffers_0_notEmpty__1_BIT_0_2_THEN_IF_S_ETC___d86 =
	     flitBuffers_0$notEmpty[0] ?
	       IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d85 :
	       { flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d73,
		 flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d76,
		 flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d79 } ;
  assign IF_flitBuffers_1_notEmpty__5_BIT_0_6_THEN_IF_S_ETC___d60 =
	     flitBuffers_1$notEmpty[0] ?
	       IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d59 :
	       { flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d47,
		 flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d50,
		 flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d53 } ;
  assign IF_flitBuffers_2_notEmpty_BIT_0_THEN_IF_SEL_AR_ETC___d34 =
	     flitBuffers_2$notEmpty[0] ?
	       IF_SEL_ARR_credits_0_0_read_credits_1_0_read_c_ETC___d33 :
	       { flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d21,
		 flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d24,
		 flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d27 } ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d402 =
	     outport_encoder___d137[2] ?
	       ((outport_encoder___d137[1:0] == 2'd0) ?
		  2'd1 :
		  outport_encoder___d108[1:0]) :
	       outport_encoder___d108[1:0] ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d467 =
	     outport_encoder___d137[2] ?
	       ((outport_encoder___d137[1:0] == 2'd1) ?
		  outport_encoder___d137[1:0] :
		  2'd0) :
	       2'd0 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d512 =
	     outport_encoder___d137[2] ?
	       ((outport_encoder___d137[1:0] == 2'd2) ? 2'd1 : 2'd0) :
	       2'd0 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d367 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] == 2'd0 ||
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd0 :
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd0 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d452 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] == 2'd1 ||
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd1 :
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd1 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d497 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] == 2'd2 ||
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd2 :
	       outport_encoder___d108[2] &&
	       outport_encoder___d108[1:0] == 2'd2 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d376 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] != 2'd0 &&
	       (!outport_encoder___d108[2] ||
		outport_encoder___d108[1:0] != 2'd0) :
	       !outport_encoder___d108[2] ||
	       outport_encoder___d108[1:0] != 2'd0 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d460 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] != 2'd1 &&
	       (!outport_encoder___d108[2] ||
		outport_encoder___d108[1:0] != 2'd1) :
	       !outport_encoder___d108[2] ||
	       outport_encoder___d108[1:0] != 2'd1 ;
  assign IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d505 =
	     outport_encoder___d137[2] ?
	       outport_encoder___d137[1:0] != 2'd2 &&
	       (!outport_encoder___d108[2] ||
		outport_encoder___d108[1:0] != 2'd2) :
	       !outport_encoder___d108[2] ||
	       outport_encoder___d108[1:0] != 2'd2 ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 =
	     outport_encoder___d166[2] ?
	       outport_encoder___d166[1:0] == 2'd0 ||
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d367 :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d367 ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d379 =
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	     (outport_encoder___d166[2] ?
		outport_encoder___d166[1:0] != 2'd0 &&
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d376 :
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d376) ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 =
	     outport_encoder___d166[2] ?
	       outport_encoder___d166[1:0] == 2'd1 ||
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d452 :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d452 ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d463 =
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	     (outport_encoder___d166[2] ?
		outport_encoder___d166[1:0] != 2'd1 &&
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d460 :
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d460) ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 =
	     outport_encoder___d166[2] ?
	       outport_encoder___d166[1:0] == 2'd2 ||
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d497 :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_outport_ETC___d497 ;
  assign IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d508 =
	     IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	     (outport_encoder___d166[2] ?
		outport_encoder___d166[1:0] != 2'd2 &&
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d505 :
		IF_outport_encoder_37_BIT_2_38_THEN_NOT_IF_out_ETC___d505) ;
  assign NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d112 =
	     CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 != 3'd0 ||
	     flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d111 ;
  assign NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d141 =
	     CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 != 3'd0 ||
	     flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d140 ;
  assign NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d170 =
	     CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 != 3'd0 ||
	     flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d169 ;
  assign SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d439 =
	     { CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7,
	       active_vc__h25157,
	       CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8 } ;
  assign SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d484 =
	     { CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10,
	       active_vc__h26282,
	       CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11 } ;
  assign SEL_ARR_hasFlitsToSend_perIn_0_wget__82_BITS_3_ETC___d529 =
	     { CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13,
	       active_vc__h27407,
	       CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14 } ;
  assign active_in__h24741 =
	     outport_encoder___d166[2] ?
	       ((outport_encoder___d166[1:0] == 2'd0) ?
		  2'd2 :
		  IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d402) :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d402 ;
  assign active_in__h25968 =
	     outport_encoder___d166[2] ?
	       ((outport_encoder___d166[1:0] == 2'd1) ?
		  2'd2 :
		  IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d467) :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d467 ;
  assign active_in__h27093 =
	     outport_encoder___d166[2] ?
	       ((outport_encoder___d166[1:0] == 2'd2) ?
		  outport_encoder___d166[1:0] :
		  IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d512) :
	       IF_outport_encoder_37_BIT_2_38_THEN_IF_IF_outp_ETC___d512 ;
  assign credits_0_0_read_PLUS_1___d200 = credits_0_0 + 3'd1 ;
  assign credits_0_1_read__1_PLUS_1___d223 = credits_0_1 + 3'd1 ;
  assign credits_1_0_read_PLUS_1___d246 = credits_1_0 + 3'd1 ;
  assign credits_1_1_read__2_PLUS_1___d269 = credits_1_1 + 3'd1 ;
  assign credits_2_0_read_PLUS_1___d292 = credits_2_0 + 3'd1 ;
  assign credits_2_1_read__3_PLUS_1___d315 = credits_2_1 + 3'd1 ;
  assign fifo_out__h15874 =
	     !flitBuffers_0$notEmpty[0] ||
	     CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 == 3'd0 ;
  assign fifo_out__h16629 =
	     !flitBuffers_1$notEmpty[0] ||
	     CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 == 3'd0 ;
  assign fifo_out__h16969 =
	     !flitBuffers_2$notEmpty[0] ||
	     CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 == 3'd0 ;
  assign flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d111 =
	     flitBuffers_0$notEmpty[1] &&
	     CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 != 3'd0 ;
  assign flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d73 =
	     flitBuffers_0$notEmpty[1] &&
	     CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 != 3'd0 &&
	     outPortFIFOs_0_1$first == 2'd2 ;
  assign flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d76 =
	     flitBuffers_0$notEmpty[1] &&
	     CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 != 3'd0 &&
	     outPortFIFOs_0_1$first == 2'd1 ;
  assign flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d79 =
	     flitBuffers_0$notEmpty[1] &&
	     CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 != 3'd0 &&
	     outPortFIFOs_0_1$first == 2'd0 ;
  assign flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d140 =
	     flitBuffers_1$notEmpty[1] &&
	     CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 != 3'd0 ;
  assign flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d47 =
	     flitBuffers_1$notEmpty[1] &&
	     CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 != 3'd0 &&
	     outPortFIFOs_1_1$first == 2'd2 ;
  assign flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d50 =
	     flitBuffers_1$notEmpty[1] &&
	     CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 != 3'd0 &&
	     outPortFIFOs_1_1$first == 2'd1 ;
  assign flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d53 =
	     flitBuffers_1$notEmpty[1] &&
	     CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 != 3'd0 &&
	     outPortFIFOs_1_1$first == 2'd0 ;
  assign flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d169 =
	     flitBuffers_2$notEmpty[1] &&
	     CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 != 3'd0 ;
  assign flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d21 =
	     flitBuffers_2$notEmpty[1] &&
	     CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 != 3'd0 &&
	     outPortFIFOs_2_1$first == 2'd2 ;
  assign flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d24 =
	     flitBuffers_2$notEmpty[1] &&
	     CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 != 3'd0 &&
	     outPortFIFOs_2_1$first == 2'd1 ;
  assign flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d27 =
	     flitBuffers_2$notEmpty[1] &&
	     CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 != 3'd0 &&
	     outPortFIFOs_2_1$first == 2'd0 ;
  assign outport_encoder_08_BIT_2_09_AND_IF_flitBuffers_ETC___d333 =
	     outport_encoder___d108[2] &&
	     (flitBuffers_0$notEmpty[0] ?
		NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d112 :
		flitBuffers_0_notEmpty__1_BIT_1_6_AND_NOT_SEL__ETC___d111) ;
  assign outport_encoder_37_BIT_2_38_AND_IF_flitBuffers_ETC___d344 =
	     outport_encoder___d137[2] &&
	     (flitBuffers_1$notEmpty[0] ?
		NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d141 :
		flitBuffers_1_notEmpty__5_BIT_1_0_AND_NOT_SEL__ETC___d140) ;
  assign outport_encoder_66_BIT_2_67_AND_IF_flitBuffers_ETC___d355 =
	     outport_encoder___d166[2] &&
	     (flitBuffers_2$notEmpty[0] ?
		NOT_SEL_ARR_credits_0_0_read_credits_1_0_read__ETC___d170 :
		flitBuffers_2_notEmpty_BIT_1_0_AND_NOT_SEL_ARR_ETC___d169) ;
  assign x__h18076 = credits_0_0 - 3'd1 ;
  assign x__h18583 = credits_0_1 - 3'd1 ;
  assign x__h19283 = credits_1_0 - 3'd1 ;
  assign x__h19790 = credits_1_1 - 3'd1 ;
  assign x__h20490 = credits_2_0 - 3'd1 ;
  assign x__h20997 = credits_2_1 - 3'd1 ;
  always@(outPortFIFOs_0_0$first or credits_0_0 or credits_1_0 or credits_2_0)
  begin
    case (outPortFIFOs_0_0$first)
      2'd0:
	  CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 = credits_0_0;
      2'd1:
	  CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 = credits_1_0;
      2'd2:
	  CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 = credits_2_0;
      2'd3:
	  CASE_outPortFIFOs_0_0first_0_credits_0_0_1_cr_ETC__q1 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(outPortFIFOs_1_0$first or credits_0_0 or credits_1_0 or credits_2_0)
  begin
    case (outPortFIFOs_1_0$first)
      2'd0:
	  CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 = credits_0_0;
      2'd1:
	  CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 = credits_1_0;
      2'd2:
	  CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 = credits_2_0;
      2'd3:
	  CASE_outPortFIFOs_1_0first_0_credits_0_0_1_cr_ETC__q2 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(outPortFIFOs_2_0$first or credits_0_0 or credits_1_0 or credits_2_0)
  begin
    case (outPortFIFOs_2_0$first)
      2'd0:
	  CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 = credits_0_0;
      2'd1:
	  CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 = credits_1_0;
      2'd2:
	  CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 = credits_2_0;
      2'd3:
	  CASE_outPortFIFOs_2_0first_0_credits_0_0_1_cr_ETC__q3 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(outPortFIFOs_2_1$first or credits_0_1 or credits_1_1 or credits_2_1)
  begin
    case (outPortFIFOs_2_1$first)
      2'd0:
	  CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 = credits_0_1;
      2'd1:
	  CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 = credits_1_1;
      2'd2:
	  CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 = credits_2_1;
      2'd3:
	  CASE_outPortFIFOs_2_1first_0_credits_0_1_1_cr_ETC__q4 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(outPortFIFOs_1_1$first or credits_0_1 or credits_1_1 or credits_2_1)
  begin
    case (outPortFIFOs_1_1$first)
      2'd0:
	  CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 = credits_0_1;
      2'd1:
	  CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 = credits_1_1;
      2'd2:
	  CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 = credits_2_1;
      2'd3:
	  CASE_outPortFIFOs_1_1first_0_credits_0_1_1_cr_ETC__q5 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(outPortFIFOs_0_1$first or credits_0_1 or credits_1_1 or credits_2_1)
  begin
    case (outPortFIFOs_0_1$first)
      2'd0:
	  CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 = credits_0_1;
      2'd1:
	  CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 = credits_1_1;
      2'd2:
	  CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 = credits_2_1;
      2'd3:
	  CASE_outPortFIFOs_0_1first_0_credits_0_1_1_cr_ETC__q6 =
	      3'bxxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0: active_vc__h25157 = hasFlitsToSend_perIn_0$wget[34];
      2'd1: active_vc__h25157 = hasFlitsToSend_perIn_1$wget[34];
      2'd2: active_vc__h25157 = hasFlitsToSend_perIn_2$wget[34];
      2'd3: active_vc__h25157 = 1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0: active_vc__h26282 = hasFlitsToSend_perIn_0$wget[34];
      2'd1: active_vc__h26282 = hasFlitsToSend_perIn_1$wget[34];
      2'd2: active_vc__h26282 = hasFlitsToSend_perIn_2$wget[34];
      2'd3: active_vc__h26282 = 1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0: active_vc__h27407 = hasFlitsToSend_perIn_0$wget[34];
      2'd1: active_vc__h27407 = hasFlitsToSend_perIn_1$wget[34];
      2'd2: active_vc__h27407 = hasFlitsToSend_perIn_2$wget[34];
      2'd3: active_vc__h27407 = 1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406 =
	      !outport_encoder___d108[2] || !hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406 =
	      !outport_encoder___d137[2] || !hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406 =
	      !outport_encoder___d166[2] || !hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471 =
	      !outport_encoder___d108[2] || !hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471 =
	      !outport_encoder___d137[2] || !hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471 =
	      !outport_encoder___d166[2] || !hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412 =
	      outport_encoder___d108[2] && hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412 =
	      outport_encoder___d137[2] && hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412 =
	      outport_encoder___d166[2] && hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d412 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473 =
	      outport_encoder___d108[2] && hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473 =
	      outport_encoder___d137[2] && hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473 =
	      outport_encoder___d166[2] && hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d473 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7 =
	      hasFlitsToSend_perIn_0$wget[36:35];
      2'd1:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7 =
	      hasFlitsToSend_perIn_1$wget[36:35];
      2'd2:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7 =
	      hasFlitsToSend_perIn_2$wget[36:35];
      2'd3:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q7 =
	      2'bxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8 =
	      hasFlitsToSend_perIn_0$wget[33:0];
      2'd1:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8 =
	      hasFlitsToSend_perIn_1$wget[33:0];
      2'd2:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8 =
	      hasFlitsToSend_perIn_2$wget[33:0];
      2'd3:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q8 =
	      34'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h24741 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h24741)
      2'd0:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9 =
	      hasFlitsToSend_perIn_0$wget[37];
      2'd1:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9 =
	      hasFlitsToSend_perIn_1$wget[37];
      2'd2:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9 =
	      hasFlitsToSend_perIn_2$wget[37];
      2'd3:
	  CASE_active_in4741_0_hasFlitsToSend_perIn_0wg_ETC__q9 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516 =
	      !outport_encoder___d108[2] || !hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516 =
	      !outport_encoder___d137[2] || !hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516 =
	      !outport_encoder___d166[2] || !hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10 =
	      hasFlitsToSend_perIn_0$wget[36:35];
      2'd1:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10 =
	      hasFlitsToSend_perIn_1$wget[36:35];
      2'd2:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10 =
	      hasFlitsToSend_perIn_2$wget[36:35];
      2'd3:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q10 =
	      2'bxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11 =
	      hasFlitsToSend_perIn_0$wget[33:0];
      2'd1:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11 =
	      hasFlitsToSend_perIn_1$wget[33:0];
      2'd2:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11 =
	      hasFlitsToSend_perIn_2$wget[33:0];
      2'd3:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q11 =
	      34'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h25968 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h25968)
      2'd0:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12 =
	      hasFlitsToSend_perIn_0$wget[37];
      2'd1:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12 =
	      hasFlitsToSend_perIn_1$wget[37];
      2'd2:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12 =
	      hasFlitsToSend_perIn_2$wget[37];
      2'd3:
	  CASE_active_in5968_0_hasFlitsToSend_perIn_0wg_ETC__q12 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  outport_encoder___d108 or
	  hasFlitsToSend_perIn_0$wget or
	  outport_encoder___d137 or
	  hasFlitsToSend_perIn_1$wget or
	  outport_encoder___d166 or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518 =
	      outport_encoder___d108[2] && hasFlitsToSend_perIn_0$wget[38];
      2'd1:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518 =
	      outport_encoder___d137[2] && hasFlitsToSend_perIn_1$wget[38];
      2'd2:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518 =
	      outport_encoder___d166[2] && hasFlitsToSend_perIn_2$wget[38];
      2'd3:
	  SEL_ARR_hasFlitsToSend_perIn_0_whas__80_AND_ha_ETC___d518 =
	      1'bx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13 =
	      hasFlitsToSend_perIn_0$wget[36:35];
      2'd1:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13 =
	      hasFlitsToSend_perIn_1$wget[36:35];
      2'd2:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13 =
	      hasFlitsToSend_perIn_2$wget[36:35];
      2'd3:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q13 =
	      2'bxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14 =
	      hasFlitsToSend_perIn_0$wget[33:0];
      2'd1:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14 =
	      hasFlitsToSend_perIn_1$wget[33:0];
      2'd2:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14 =
	      hasFlitsToSend_perIn_2$wget[33:0];
      2'd3:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q14 =
	      34'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx /* unspecified value */ ;
    endcase
  end
  always@(active_in__h27093 or
	  hasFlitsToSend_perIn_0$wget or
	  hasFlitsToSend_perIn_1$wget or hasFlitsToSend_perIn_2$wget)
  begin
    case (active_in__h27093)
      2'd0:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15 =
	      hasFlitsToSend_perIn_0$wget[37];
      2'd1:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15 =
	      hasFlitsToSend_perIn_1$wget[37];
      2'd2:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15 =
	      hasFlitsToSend_perIn_2$wget[37];
      2'd3:
	  CASE_active_in7093_0_hasFlitsToSend_perIn_0wg_ETC__q15 =
	      1'bx /* unspecified value */ ;
    endcase
  end

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        activeVC_perIn_reg_0 <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0, 1'bx /* unspecified value */  };
	activeVC_perIn_reg_1 <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0, 1'bx /* unspecified value */  };
	activeVC_perIn_reg_2 <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0, 1'bx /* unspecified value */  };
	credits_0_0 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	credits_0_1 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	credits_1_0 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	credits_1_1 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	credits_2_0 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	credits_2_1 <= `BSV_ASSIGNMENT_DELAY 3'd4;
	inPortVL_0_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inPortVL_0_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inPortVL_1_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inPortVL_1_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inPortVL_2_0 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	inPortVL_2_1 <= `BSV_ASSIGNMENT_DELAY 2'd0;
	lockedVL_0_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	lockedVL_0_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	lockedVL_1_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	lockedVL_1_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	lockedVL_2_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	lockedVL_2_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_0_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_0_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_0_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_1_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_1_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_1_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_2_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_2_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	selectedIO_reg_2_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (activeVC_perIn_reg_0$EN)
	  activeVC_perIn_reg_0 <= `BSV_ASSIGNMENT_DELAY
	      activeVC_perIn_reg_0$D_IN;
	if (activeVC_perIn_reg_1$EN)
	  activeVC_perIn_reg_1 <= `BSV_ASSIGNMENT_DELAY
	      activeVC_perIn_reg_1$D_IN;
	if (activeVC_perIn_reg_2$EN)
	  activeVC_perIn_reg_2 <= `BSV_ASSIGNMENT_DELAY
	      activeVC_perIn_reg_2$D_IN;
	if (credits_0_0$EN)
	  credits_0_0 <= `BSV_ASSIGNMENT_DELAY credits_0_0$D_IN;
	if (credits_0_1$EN)
	  credits_0_1 <= `BSV_ASSIGNMENT_DELAY credits_0_1$D_IN;
	if (credits_1_0$EN)
	  credits_1_0 <= `BSV_ASSIGNMENT_DELAY credits_1_0$D_IN;
	if (credits_1_1$EN)
	  credits_1_1 <= `BSV_ASSIGNMENT_DELAY credits_1_1$D_IN;
	if (credits_2_0$EN)
	  credits_2_0 <= `BSV_ASSIGNMENT_DELAY credits_2_0$D_IN;
	if (credits_2_1$EN)
	  credits_2_1 <= `BSV_ASSIGNMENT_DELAY credits_2_1$D_IN;
	if (inPortVL_0_0$EN)
	  inPortVL_0_0 <= `BSV_ASSIGNMENT_DELAY inPortVL_0_0$D_IN;
	if (inPortVL_0_1$EN)
	  inPortVL_0_1 <= `BSV_ASSIGNMENT_DELAY inPortVL_0_1$D_IN;
	if (inPortVL_1_0$EN)
	  inPortVL_1_0 <= `BSV_ASSIGNMENT_DELAY inPortVL_1_0$D_IN;
	if (inPortVL_1_1$EN)
	  inPortVL_1_1 <= `BSV_ASSIGNMENT_DELAY inPortVL_1_1$D_IN;
	if (inPortVL_2_0$EN)
	  inPortVL_2_0 <= `BSV_ASSIGNMENT_DELAY inPortVL_2_0$D_IN;
	if (inPortVL_2_1$EN)
	  inPortVL_2_1 <= `BSV_ASSIGNMENT_DELAY inPortVL_2_1$D_IN;
	if (lockedVL_0_0$EN)
	  lockedVL_0_0 <= `BSV_ASSIGNMENT_DELAY lockedVL_0_0$D_IN;
	if (lockedVL_0_1$EN)
	  lockedVL_0_1 <= `BSV_ASSIGNMENT_DELAY lockedVL_0_1$D_IN;
	if (lockedVL_1_0$EN)
	  lockedVL_1_0 <= `BSV_ASSIGNMENT_DELAY lockedVL_1_0$D_IN;
	if (lockedVL_1_1$EN)
	  lockedVL_1_1 <= `BSV_ASSIGNMENT_DELAY lockedVL_1_1$D_IN;
	if (lockedVL_2_0$EN)
	  lockedVL_2_0 <= `BSV_ASSIGNMENT_DELAY lockedVL_2_0$D_IN;
	if (lockedVL_2_1$EN)
	  lockedVL_2_1 <= `BSV_ASSIGNMENT_DELAY lockedVL_2_1$D_IN;
	if (selectedIO_reg_0_0$EN)
	  selectedIO_reg_0_0 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_0_0$D_IN;
	if (selectedIO_reg_0_1$EN)
	  selectedIO_reg_0_1 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_0_1$D_IN;
	if (selectedIO_reg_0_2$EN)
	  selectedIO_reg_0_2 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_0_2$D_IN;
	if (selectedIO_reg_1_0$EN)
	  selectedIO_reg_1_0 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_1_0$D_IN;
	if (selectedIO_reg_1_1$EN)
	  selectedIO_reg_1_1 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_1_1$D_IN;
	if (selectedIO_reg_1_2$EN)
	  selectedIO_reg_1_2 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_1_2$D_IN;
	if (selectedIO_reg_2_0$EN)
	  selectedIO_reg_2_0 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_2_0$D_IN;
	if (selectedIO_reg_2_1$EN)
	  selectedIO_reg_2_1 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_2_1$D_IN;
	if (selectedIO_reg_2_2$EN)
	  selectedIO_reg_2_2 <= `BSV_ASSIGNMENT_DELAY selectedIO_reg_2_2$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    activeVC_perIn_reg_0 = 2'h2;
    activeVC_perIn_reg_1 = 2'h2;
    activeVC_perIn_reg_2 = 2'h2;
    credits_0_0 = 3'h2;
    credits_0_1 = 3'h2;
    credits_1_0 = 3'h2;
    credits_1_1 = 3'h2;
    credits_2_0 = 3'h2;
    credits_2_1 = 3'h2;
    inPortVL_0_0 = 2'h2;
    inPortVL_0_1 = 2'h2;
    inPortVL_1_0 = 2'h2;
    inPortVL_1_1 = 2'h2;
    inPortVL_2_0 = 2'h2;
    inPortVL_2_1 = 2'h2;
    lockedVL_0_0 = 1'h0;
    lockedVL_0_1 = 1'h0;
    lockedVL_1_0 = 1'h0;
    lockedVL_1_1 = 1'h0;
    lockedVL_2_0 = 1'h0;
    lockedVL_2_1 = 1'h0;
    selectedIO_reg_0_0 = 1'h0;
    selectedIO_reg_0_1 = 1'h0;
    selectedIO_reg_0_2 = 1'h0;
    selectedIO_reg_1_0 = 1'h0;
    selectedIO_reg_1_1 = 1'h0;
    selectedIO_reg_1_2 = 1'h0;
    selectedIO_reg_2_0 = 1'h0;
    selectedIO_reg_2_1 = 1'h0;
    selectedIO_reg_2_2 = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on

  // handling of system tasks

  // synopsys translate_off
  always@(negedge CLK)
  begin
    #0;
    if (RST_N != `BSV_RESET_VALUE) if (EN_out_ports_0_putCredits) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_putCredits && out_ports_0_putCredits_cr_in[1])
	$write("");
    if (RST_N != `BSV_RESET_VALUE) if (EN_out_ports_1_putCredits) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_putCredits && out_ports_1_putCredits_cr_in[1])
	$write("");
    if (RST_N != `BSV_RESET_VALUE) if (EN_out_ports_2_putCredits) $write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_putCredits && out_ports_2_putCredits_cr_in[1])
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (outport_encoder___d108[2] &&
	  flitBuffers_0$deq[34] != fifo_out__h15874)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (outport_encoder___d137[2] &&
	  flitBuffers_1$deq[34] != fifo_out__h16629)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (outport_encoder___d166[2] &&
	  flitBuffers_2$deq[34] != fifo_out__h16969)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d379)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406)
	$display("Dynamic assertion failed: \"Router.bsv\", line 769, column 47\nOutput selected invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406)
	$display("Dynamic assertion failed: \"Router.bsv\", line 780, column 47\nAllocation selected input port with invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_0_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d369 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d406)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d463)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471)
	$display("Dynamic assertion failed: \"Router.bsv\", line 769, column 47\nOutput selected invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471)
	$display("Dynamic assertion failed: \"Router.bsv\", line 780, column 47\nAllocation selected input port with invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_1_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d454 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d471)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d508)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516)
	$display("Dynamic assertion failed: \"Router.bsv\", line 769, column 47\nOutput selected invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516)
	$display("Dynamic assertion failed: \"Router.bsv\", line 780, column 47\nAllocation selected input port with invalid flit!");
    if (RST_N != `BSV_RESET_VALUE)
      if (EN_out_ports_2_getFlit &&
	  IF_outport_encoder_66_BIT_2_67_THEN_IF_outport_ETC___d499 &&
	  SEL_ARR_NOT_hasFlitsToSend_perIn_0_whas__80_81_ETC___d516)
	$finish(32'd0);
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_0_0$whas && !credits_clear_0_0$whas &&
	  credits_0_0_read_PLUS_1___d200 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_0_0$whas && credits_clear_0_0$whas &&
	  credits_0_0 == 3'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_0_1$whas && !credits_clear_0_1$whas &&
	  credits_0_1_read__1_PLUS_1___d223 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_0_1$whas && credits_clear_0_1$whas &&
	  credits_0_1 == 3'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_1_0$whas && !credits_clear_1_0$whas &&
	  credits_1_0_read_PLUS_1___d246 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_1_0$whas && credits_clear_1_0$whas &&
	  credits_1_0 == 3'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_1_1$whas && !credits_clear_1_1$whas &&
	  credits_1_1_read__2_PLUS_1___d269 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_1_1$whas && credits_clear_1_1$whas &&
	  credits_1_1 == 3'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_2_0$whas && !credits_clear_2_0$whas &&
	  credits_2_0_read_PLUS_1___d292 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_2_0$whas && credits_clear_2_0$whas &&
	  credits_2_0 == 3'd0)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (credits_set_2_1$whas && !credits_clear_2_1$whas &&
	  credits_2_1_read__3_PLUS_1___d315 > 3'd4)
	$write("");
    if (RST_N != `BSV_RESET_VALUE)
      if (!credits_set_2_1$whas && credits_clear_2_1$whas &&
	  credits_2_1 == 3'd0)
	$write("");
  end
  // synopsys translate_on
endmodule  // mkRouterCore

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// input_arbs_0_select            O     3
// input_arbs_1_select            O     3
// input_arbs_2_select            O     3
// CLK                            I     1 clock
// RST_N                          I     1 reset
// input_arbs_0_select_requests   I     3
// input_arbs_1_select_requests   I     3
// input_arbs_2_select_requests   I     3
// EN_input_arbs_0_next           I     1
// EN_input_arbs_1_next           I     1
// EN_input_arbs_2_next           I     1
//
// Combinational paths from inputs to outputs:
//   input_arbs_0_select_requests -> input_arbs_0_select
//   input_arbs_1_select_requests -> input_arbs_1_select
//   input_arbs_2_select_requests -> input_arbs_2_select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouterInputArbitersRoundRobin(CLK,
				       RST_N,

				       input_arbs_0_select_requests,
				       input_arbs_0_select,

				       EN_input_arbs_0_next,

				       input_arbs_1_select_requests,
				       input_arbs_1_select,

				       EN_input_arbs_1_next,

				       input_arbs_2_select_requests,
				       input_arbs_2_select,

				       EN_input_arbs_2_next);
  input  CLK;
  input  RST_N;

  // value method input_arbs_0_select
  input  [2 : 0] input_arbs_0_select_requests;
  output [2 : 0] input_arbs_0_select;

  // action method input_arbs_0_next
  input  EN_input_arbs_0_next;

  // value method input_arbs_1_select
  input  [2 : 0] input_arbs_1_select_requests;
  output [2 : 0] input_arbs_1_select;

  // action method input_arbs_1_next
  input  EN_input_arbs_1_next;

  // value method input_arbs_2_select
  input  [2 : 0] input_arbs_2_select_requests;
  output [2 : 0] input_arbs_2_select;

  // action method input_arbs_2_next
  input  EN_input_arbs_2_next;

  // signals for module outputs
  wire [2 : 0] input_arbs_0_select, input_arbs_1_select, input_arbs_2_select;

  // register ias_0_token
  reg [2 : 0] ias_0_token;
  wire [2 : 0] ias_0_token$D_IN;
  wire ias_0_token$EN;

  // register ias_1_token
  reg [2 : 0] ias_1_token;
  wire [2 : 0] ias_1_token$D_IN;
  wire ias_1_token$EN;

  // register ias_2_token
  reg [2 : 0] ias_2_token;
  wire [2 : 0] ias_2_token$D_IN;
  wire ias_2_token$EN;

  // remaining internal signals
  wire [1 : 0] gen_grant_carry___d12,
	       gen_grant_carry___d15,
	       gen_grant_carry___d17,
	       gen_grant_carry___d19,
	       gen_grant_carry___d4,
	       gen_grant_carry___d42,
	       gen_grant_carry___d46,
	       gen_grant_carry___d50,
	       gen_grant_carry___d53,
	       gen_grant_carry___d55,
	       gen_grant_carry___d57,
	       gen_grant_carry___d8,
	       gen_grant_carry___d80,
	       gen_grant_carry___d84,
	       gen_grant_carry___d88,
	       gen_grant_carry___d91,
	       gen_grant_carry___d93,
	       gen_grant_carry___d95;
  wire NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74,
       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36,
       NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112,
       ias_0_token_BIT_0___h2167,
       ias_0_token_BIT_1___h2233,
       ias_0_token_BIT_2___h2299,
       ias_1_token_BIT_0___h4711,
       ias_1_token_BIT_1___h4777,
       ias_1_token_BIT_2___h4843,
       ias_2_token_BIT_0___h7252,
       ias_2_token_BIT_1___h7318,
       ias_2_token_BIT_2___h7384;

  // value method input_arbs_0_select
  assign input_arbs_0_select =
	     { gen_grant_carry___d12[1] || gen_grant_carry___d19[1],
	       !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	       (gen_grant_carry___d8[1] || gen_grant_carry___d17[1]),
	       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 } ;

  // value method input_arbs_1_select
  assign input_arbs_1_select =
	     { gen_grant_carry___d50[1] || gen_grant_carry___d57[1],
	       !gen_grant_carry___d50[1] && !gen_grant_carry___d57[1] &&
	       (gen_grant_carry___d46[1] || gen_grant_carry___d55[1]),
	       NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74 } ;

  // value method input_arbs_2_select
  assign input_arbs_2_select =
	     { gen_grant_carry___d88[1] || gen_grant_carry___d95[1],
	       !gen_grant_carry___d88[1] && !gen_grant_carry___d95[1] &&
	       (gen_grant_carry___d84[1] || gen_grant_carry___d93[1]),
	       NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112 } ;

  // register ias_0_token
  assign ias_0_token$D_IN = { ias_0_token[0], ias_0_token[2:1] } ;
  assign ias_0_token$EN = EN_input_arbs_0_next ;

  // register ias_1_token
  assign ias_1_token$D_IN = { ias_1_token[0], ias_1_token[2:1] } ;
  assign ias_1_token$EN = EN_input_arbs_1_next ;

  // register ias_2_token
  assign ias_2_token$D_IN = { ias_2_token[0], ias_2_token[2:1] } ;
  assign ias_2_token$EN = EN_input_arbs_2_next ;

  // remaining internal signals
  module_gen_grant_carry instance_gen_grant_carry_15(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(input_arbs_0_select_requests[0]),
						     .gen_grant_carry_p(ias_0_token_BIT_0___h2167),
						     .gen_grant_carry(gen_grant_carry___d4));
  module_gen_grant_carry instance_gen_grant_carry_1(.gen_grant_carry_c(gen_grant_carry___d4[0]),
						    .gen_grant_carry_r(input_arbs_0_select_requests[1]),
						    .gen_grant_carry_p(ias_0_token_BIT_1___h2233),
						    .gen_grant_carry(gen_grant_carry___d8));
  module_gen_grant_carry instance_gen_grant_carry_0(.gen_grant_carry_c(gen_grant_carry___d8[0]),
						    .gen_grant_carry_r(input_arbs_0_select_requests[2]),
						    .gen_grant_carry_p(ias_0_token_BIT_2___h2299),
						    .gen_grant_carry(gen_grant_carry___d12));
  module_gen_grant_carry instance_gen_grant_carry_2(.gen_grant_carry_c(gen_grant_carry___d12[0]),
						    .gen_grant_carry_r(input_arbs_0_select_requests[0]),
						    .gen_grant_carry_p(ias_0_token_BIT_0___h2167),
						    .gen_grant_carry(gen_grant_carry___d15));
  module_gen_grant_carry instance_gen_grant_carry_3(.gen_grant_carry_c(gen_grant_carry___d15[0]),
						    .gen_grant_carry_r(input_arbs_0_select_requests[1]),
						    .gen_grant_carry_p(ias_0_token_BIT_1___h2233),
						    .gen_grant_carry(gen_grant_carry___d17));
  module_gen_grant_carry instance_gen_grant_carry_4(.gen_grant_carry_c(gen_grant_carry___d17[0]),
						    .gen_grant_carry_r(input_arbs_0_select_requests[2]),
						    .gen_grant_carry_p(ias_0_token_BIT_2___h2299),
						    .gen_grant_carry(gen_grant_carry___d19));
  module_gen_grant_carry instance_gen_grant_carry_16(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(input_arbs_1_select_requests[0]),
						     .gen_grant_carry_p(ias_1_token_BIT_0___h4711),
						     .gen_grant_carry(gen_grant_carry___d42));
  module_gen_grant_carry instance_gen_grant_carry_5(.gen_grant_carry_c(gen_grant_carry___d42[0]),
						    .gen_grant_carry_r(input_arbs_1_select_requests[1]),
						    .gen_grant_carry_p(ias_1_token_BIT_1___h4777),
						    .gen_grant_carry(gen_grant_carry___d46));
  module_gen_grant_carry instance_gen_grant_carry_6(.gen_grant_carry_c(gen_grant_carry___d46[0]),
						    .gen_grant_carry_r(input_arbs_1_select_requests[2]),
						    .gen_grant_carry_p(ias_1_token_BIT_2___h4843),
						    .gen_grant_carry(gen_grant_carry___d50));
  module_gen_grant_carry instance_gen_grant_carry_7(.gen_grant_carry_c(gen_grant_carry___d50[0]),
						    .gen_grant_carry_r(input_arbs_1_select_requests[0]),
						    .gen_grant_carry_p(ias_1_token_BIT_0___h4711),
						    .gen_grant_carry(gen_grant_carry___d53));
  module_gen_grant_carry instance_gen_grant_carry_8(.gen_grant_carry_c(gen_grant_carry___d53[0]),
						    .gen_grant_carry_r(input_arbs_1_select_requests[1]),
						    .gen_grant_carry_p(ias_1_token_BIT_1___h4777),
						    .gen_grant_carry(gen_grant_carry___d55));
  module_gen_grant_carry instance_gen_grant_carry_9(.gen_grant_carry_c(gen_grant_carry___d55[0]),
						    .gen_grant_carry_r(input_arbs_1_select_requests[2]),
						    .gen_grant_carry_p(ias_1_token_BIT_2___h4843),
						    .gen_grant_carry(gen_grant_carry___d57));
  module_gen_grant_carry instance_gen_grant_carry_17(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(input_arbs_2_select_requests[0]),
						     .gen_grant_carry_p(ias_2_token_BIT_0___h7252),
						     .gen_grant_carry(gen_grant_carry___d80));
  module_gen_grant_carry instance_gen_grant_carry_10(.gen_grant_carry_c(gen_grant_carry___d80[0]),
						     .gen_grant_carry_r(input_arbs_2_select_requests[1]),
						     .gen_grant_carry_p(ias_2_token_BIT_1___h7318),
						     .gen_grant_carry(gen_grant_carry___d84));
  module_gen_grant_carry instance_gen_grant_carry_11(.gen_grant_carry_c(gen_grant_carry___d84[0]),
						     .gen_grant_carry_r(input_arbs_2_select_requests[2]),
						     .gen_grant_carry_p(ias_2_token_BIT_2___h7384),
						     .gen_grant_carry(gen_grant_carry___d88));
  module_gen_grant_carry instance_gen_grant_carry_12(.gen_grant_carry_c(gen_grant_carry___d88[0]),
						     .gen_grant_carry_r(input_arbs_2_select_requests[0]),
						     .gen_grant_carry_p(ias_2_token_BIT_0___h7252),
						     .gen_grant_carry(gen_grant_carry___d91));
  module_gen_grant_carry instance_gen_grant_carry_13(.gen_grant_carry_c(gen_grant_carry___d91[0]),
						     .gen_grant_carry_r(input_arbs_2_select_requests[1]),
						     .gen_grant_carry_p(ias_2_token_BIT_1___h7318),
						     .gen_grant_carry(gen_grant_carry___d93));
  module_gen_grant_carry instance_gen_grant_carry_14(.gen_grant_carry_c(gen_grant_carry___d93[0]),
						     .gen_grant_carry_r(input_arbs_2_select_requests[2]),
						     .gen_grant_carry_p(ias_2_token_BIT_2___h7384),
						     .gen_grant_carry(gen_grant_carry___d95));
  assign NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74 =
	     !gen_grant_carry___d50[1] && !gen_grant_carry___d57[1] &&
	     !gen_grant_carry___d46[1] &&
	     !gen_grant_carry___d55[1] &&
	     (gen_grant_carry___d42[1] || gen_grant_carry___d53[1]) ;
  assign NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 =
	     !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	     !gen_grant_carry___d8[1] &&
	     !gen_grant_carry___d17[1] &&
	     (gen_grant_carry___d4[1] || gen_grant_carry___d15[1]) ;
  assign NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112 =
	     !gen_grant_carry___d88[1] && !gen_grant_carry___d95[1] &&
	     !gen_grant_carry___d84[1] &&
	     !gen_grant_carry___d93[1] &&
	     (gen_grant_carry___d80[1] || gen_grant_carry___d91[1]) ;
  assign ias_0_token_BIT_0___h2167 = ias_0_token[0] ;
  assign ias_0_token_BIT_1___h2233 = ias_0_token[1] ;
  assign ias_0_token_BIT_2___h2299 = ias_0_token[2] ;
  assign ias_1_token_BIT_0___h4711 = ias_1_token[0] ;
  assign ias_1_token_BIT_1___h4777 = ias_1_token[1] ;
  assign ias_1_token_BIT_2___h4843 = ias_1_token[2] ;
  assign ias_2_token_BIT_0___h7252 = ias_2_token[0] ;
  assign ias_2_token_BIT_1___h7318 = ias_2_token[1] ;
  assign ias_2_token_BIT_2___h7384 = ias_2_token[2] ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        ias_0_token <= `BSV_ASSIGNMENT_DELAY 3'd1;
	ias_1_token <= `BSV_ASSIGNMENT_DELAY 3'd2;
	ias_2_token <= `BSV_ASSIGNMENT_DELAY 3'd4;
      end
    else
      begin
        if (ias_0_token$EN)
	  ias_0_token <= `BSV_ASSIGNMENT_DELAY ias_0_token$D_IN;
	if (ias_1_token$EN)
	  ias_1_token <= `BSV_ASSIGNMENT_DELAY ias_1_token$D_IN;
	if (ias_2_token$EN)
	  ias_2_token <= `BSV_ASSIGNMENT_DELAY ias_2_token$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    ias_0_token = 3'h2;
    ias_1_token = 3'h2;
    ias_2_token = 3'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkRouterInputArbitersRoundRobin

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// input_arbs_0_select            O     3
// input_arbs_1_select            O     3
// input_arbs_2_select            O     3
// CLK                            I     1 unused
// RST_N                          I     1 unused
// input_arbs_0_select_requests   I     3
// input_arbs_1_select_requests   I     3
// input_arbs_2_select_requests   I     3
// EN_input_arbs_0_next           I     1 unused
// EN_input_arbs_1_next           I     1 unused
// EN_input_arbs_2_next           I     1 unused
//
// Combinational paths from inputs to outputs:
//   input_arbs_0_select_requests -> input_arbs_0_select
//   input_arbs_1_select_requests -> input_arbs_1_select
//   input_arbs_2_select_requests -> input_arbs_2_select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouterInputArbitersStatic(CLK,
				   RST_N,

				   input_arbs_0_select_requests,
				   input_arbs_0_select,

				   EN_input_arbs_0_next,

				   input_arbs_1_select_requests,
				   input_arbs_1_select,

				   EN_input_arbs_1_next,

				   input_arbs_2_select_requests,
				   input_arbs_2_select,

				   EN_input_arbs_2_next);
  input  CLK;
  input  RST_N;

  // value method input_arbs_0_select
  input  [2 : 0] input_arbs_0_select_requests;
  output [2 : 0] input_arbs_0_select;

  // action method input_arbs_0_next
  input  EN_input_arbs_0_next;

  // value method input_arbs_1_select
  input  [2 : 0] input_arbs_1_select_requests;
  output [2 : 0] input_arbs_1_select;

  // action method input_arbs_1_next
  input  EN_input_arbs_1_next;

  // value method input_arbs_2_select
  input  [2 : 0] input_arbs_2_select_requests;
  output [2 : 0] input_arbs_2_select;

  // action method input_arbs_2_next
  input  EN_input_arbs_2_next;

  // signals for module outputs
  wire [2 : 0] input_arbs_0_select, input_arbs_1_select, input_arbs_2_select;

  // value method input_arbs_0_select
  assign input_arbs_0_select =
	     { input_arbs_0_select_requests[2],
	       !input_arbs_0_select_requests[2] &&
	       input_arbs_0_select_requests[1],
	       !input_arbs_0_select_requests[2] &&
	       !input_arbs_0_select_requests[1] &&
	       input_arbs_0_select_requests[0] } ;

  // value method input_arbs_1_select
  assign input_arbs_1_select =
	     { !input_arbs_1_select_requests[0] &&
	       input_arbs_1_select_requests[2],
	       !input_arbs_1_select_requests[0] &&
	       !input_arbs_1_select_requests[2] &&
	       input_arbs_1_select_requests[1],
	       input_arbs_1_select_requests[0] } ;

  // value method input_arbs_2_select
  assign input_arbs_2_select =
	     { !input_arbs_2_select_requests[1] &&
	       !input_arbs_2_select_requests[0] &&
	       input_arbs_2_select_requests[2],
	       input_arbs_2_select_requests[1],
	       !input_arbs_2_select_requests[1] &&
	       input_arbs_2_select_requests[0] } ;
endmodule  // mkRouterInputArbitersStatic

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// output_arbs_0_select           O     3
// output_arbs_1_select           O     3
// output_arbs_2_select           O     3
// CLK                            I     1 clock
// RST_N                          I     1 reset
// output_arbs_0_select_requests  I     3
// output_arbs_1_select_requests  I     3
// output_arbs_2_select_requests  I     3
// EN_output_arbs_0_next          I     1
// EN_output_arbs_1_next          I     1
// EN_output_arbs_2_next          I     1
//
// Combinational paths from inputs to outputs:
//   output_arbs_0_select_requests -> output_arbs_0_select
//   output_arbs_1_select_requests -> output_arbs_1_select
//   output_arbs_2_select_requests -> output_arbs_2_select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouterOutputArbitersRoundRobin(CLK,
					RST_N,

					output_arbs_0_select_requests,
					output_arbs_0_select,

					EN_output_arbs_0_next,

					output_arbs_1_select_requests,
					output_arbs_1_select,

					EN_output_arbs_1_next,

					output_arbs_2_select_requests,
					output_arbs_2_select,

					EN_output_arbs_2_next);
  input  CLK;
  input  RST_N;

  // value method output_arbs_0_select
  input  [2 : 0] output_arbs_0_select_requests;
  output [2 : 0] output_arbs_0_select;

  // action method output_arbs_0_next
  input  EN_output_arbs_0_next;

  // value method output_arbs_1_select
  input  [2 : 0] output_arbs_1_select_requests;
  output [2 : 0] output_arbs_1_select;

  // action method output_arbs_1_next
  input  EN_output_arbs_1_next;

  // value method output_arbs_2_select
  input  [2 : 0] output_arbs_2_select_requests;
  output [2 : 0] output_arbs_2_select;

  // action method output_arbs_2_next
  input  EN_output_arbs_2_next;

  // signals for module outputs
  wire [2 : 0] output_arbs_0_select,
	       output_arbs_1_select,
	       output_arbs_2_select;

  // register oas_0_token
  reg [2 : 0] oas_0_token;
  wire [2 : 0] oas_0_token$D_IN;
  wire oas_0_token$EN;

  // register oas_1_token
  reg [2 : 0] oas_1_token;
  wire [2 : 0] oas_1_token$D_IN;
  wire oas_1_token$EN;

  // register oas_2_token
  reg [2 : 0] oas_2_token;
  wire [2 : 0] oas_2_token$D_IN;
  wire oas_2_token$EN;

  // remaining internal signals
  wire [1 : 0] gen_grant_carry___d12,
	       gen_grant_carry___d15,
	       gen_grant_carry___d17,
	       gen_grant_carry___d19,
	       gen_grant_carry___d4,
	       gen_grant_carry___d42,
	       gen_grant_carry___d46,
	       gen_grant_carry___d50,
	       gen_grant_carry___d53,
	       gen_grant_carry___d55,
	       gen_grant_carry___d57,
	       gen_grant_carry___d8,
	       gen_grant_carry___d80,
	       gen_grant_carry___d84,
	       gen_grant_carry___d88,
	       gen_grant_carry___d91,
	       gen_grant_carry___d93,
	       gen_grant_carry___d95;
  wire NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74,
       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36,
       NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112,
       oas_0_token_BIT_0___h2167,
       oas_0_token_BIT_1___h2233,
       oas_0_token_BIT_2___h2299,
       oas_1_token_BIT_0___h4711,
       oas_1_token_BIT_1___h4777,
       oas_1_token_BIT_2___h4843,
       oas_2_token_BIT_0___h7252,
       oas_2_token_BIT_1___h7318,
       oas_2_token_BIT_2___h7384;

  // value method output_arbs_0_select
  assign output_arbs_0_select =
	     { gen_grant_carry___d12[1] || gen_grant_carry___d19[1],
	       !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	       (gen_grant_carry___d8[1] || gen_grant_carry___d17[1]),
	       NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 } ;

  // value method output_arbs_1_select
  assign output_arbs_1_select =
	     { gen_grant_carry___d50[1] || gen_grant_carry___d57[1],
	       !gen_grant_carry___d50[1] && !gen_grant_carry___d57[1] &&
	       (gen_grant_carry___d46[1] || gen_grant_carry___d55[1]),
	       NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74 } ;

  // value method output_arbs_2_select
  assign output_arbs_2_select =
	     { gen_grant_carry___d88[1] || gen_grant_carry___d95[1],
	       !gen_grant_carry___d88[1] && !gen_grant_carry___d95[1] &&
	       (gen_grant_carry___d84[1] || gen_grant_carry___d93[1]),
	       NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112 } ;

  // register oas_0_token
  assign oas_0_token$D_IN = { oas_0_token[0], oas_0_token[2:1] } ;
  assign oas_0_token$EN = EN_output_arbs_0_next ;

  // register oas_1_token
  assign oas_1_token$D_IN = { oas_1_token[0], oas_1_token[2:1] } ;
  assign oas_1_token$EN = EN_output_arbs_1_next ;

  // register oas_2_token
  assign oas_2_token$D_IN = { oas_2_token[0], oas_2_token[2:1] } ;
  assign oas_2_token$EN = EN_output_arbs_2_next ;

  // remaining internal signals
  module_gen_grant_carry instance_gen_grant_carry_15(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(output_arbs_0_select_requests[0]),
						     .gen_grant_carry_p(oas_0_token_BIT_0___h2167),
						     .gen_grant_carry(gen_grant_carry___d4));
  module_gen_grant_carry instance_gen_grant_carry_16(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(output_arbs_1_select_requests[0]),
						     .gen_grant_carry_p(oas_1_token_BIT_0___h4711),
						     .gen_grant_carry(gen_grant_carry___d42));
  module_gen_grant_carry instance_gen_grant_carry_17(.gen_grant_carry_c(1'd0),
						     .gen_grant_carry_r(output_arbs_2_select_requests[0]),
						     .gen_grant_carry_p(oas_2_token_BIT_0___h7252),
						     .gen_grant_carry(gen_grant_carry___d80));
  module_gen_grant_carry instance_gen_grant_carry_1(.gen_grant_carry_c(gen_grant_carry___d4[0]),
						    .gen_grant_carry_r(output_arbs_0_select_requests[1]),
						    .gen_grant_carry_p(oas_0_token_BIT_1___h2233),
						    .gen_grant_carry(gen_grant_carry___d8));
  module_gen_grant_carry instance_gen_grant_carry_0(.gen_grant_carry_c(gen_grant_carry___d8[0]),
						    .gen_grant_carry_r(output_arbs_0_select_requests[2]),
						    .gen_grant_carry_p(oas_0_token_BIT_2___h2299),
						    .gen_grant_carry(gen_grant_carry___d12));
  module_gen_grant_carry instance_gen_grant_carry_2(.gen_grant_carry_c(gen_grant_carry___d12[0]),
						    .gen_grant_carry_r(output_arbs_0_select_requests[0]),
						    .gen_grant_carry_p(oas_0_token_BIT_0___h2167),
						    .gen_grant_carry(gen_grant_carry___d15));
  module_gen_grant_carry instance_gen_grant_carry_3(.gen_grant_carry_c(gen_grant_carry___d15[0]),
						    .gen_grant_carry_r(output_arbs_0_select_requests[1]),
						    .gen_grant_carry_p(oas_0_token_BIT_1___h2233),
						    .gen_grant_carry(gen_grant_carry___d17));
  module_gen_grant_carry instance_gen_grant_carry_4(.gen_grant_carry_c(gen_grant_carry___d17[0]),
						    .gen_grant_carry_r(output_arbs_0_select_requests[2]),
						    .gen_grant_carry_p(oas_0_token_BIT_2___h2299),
						    .gen_grant_carry(gen_grant_carry___d19));
  module_gen_grant_carry instance_gen_grant_carry_5(.gen_grant_carry_c(gen_grant_carry___d42[0]),
						    .gen_grant_carry_r(output_arbs_1_select_requests[1]),
						    .gen_grant_carry_p(oas_1_token_BIT_1___h4777),
						    .gen_grant_carry(gen_grant_carry___d46));
  module_gen_grant_carry instance_gen_grant_carry_6(.gen_grant_carry_c(gen_grant_carry___d46[0]),
						    .gen_grant_carry_r(output_arbs_1_select_requests[2]),
						    .gen_grant_carry_p(oas_1_token_BIT_2___h4843),
						    .gen_grant_carry(gen_grant_carry___d50));
  module_gen_grant_carry instance_gen_grant_carry_7(.gen_grant_carry_c(gen_grant_carry___d50[0]),
						    .gen_grant_carry_r(output_arbs_1_select_requests[0]),
						    .gen_grant_carry_p(oas_1_token_BIT_0___h4711),
						    .gen_grant_carry(gen_grant_carry___d53));
  module_gen_grant_carry instance_gen_grant_carry_8(.gen_grant_carry_c(gen_grant_carry___d53[0]),
						    .gen_grant_carry_r(output_arbs_1_select_requests[1]),
						    .gen_grant_carry_p(oas_1_token_BIT_1___h4777),
						    .gen_grant_carry(gen_grant_carry___d55));
  module_gen_grant_carry instance_gen_grant_carry_9(.gen_grant_carry_c(gen_grant_carry___d55[0]),
						    .gen_grant_carry_r(output_arbs_1_select_requests[2]),
						    .gen_grant_carry_p(oas_1_token_BIT_2___h4843),
						    .gen_grant_carry(gen_grant_carry___d57));
  module_gen_grant_carry instance_gen_grant_carry_10(.gen_grant_carry_c(gen_grant_carry___d80[0]),
						     .gen_grant_carry_r(output_arbs_2_select_requests[1]),
						     .gen_grant_carry_p(oas_2_token_BIT_1___h7318),
						     .gen_grant_carry(gen_grant_carry___d84));
  module_gen_grant_carry instance_gen_grant_carry_11(.gen_grant_carry_c(gen_grant_carry___d84[0]),
						     .gen_grant_carry_r(output_arbs_2_select_requests[2]),
						     .gen_grant_carry_p(oas_2_token_BIT_2___h7384),
						     .gen_grant_carry(gen_grant_carry___d88));
  module_gen_grant_carry instance_gen_grant_carry_12(.gen_grant_carry_c(gen_grant_carry___d88[0]),
						     .gen_grant_carry_r(output_arbs_2_select_requests[0]),
						     .gen_grant_carry_p(oas_2_token_BIT_0___h7252),
						     .gen_grant_carry(gen_grant_carry___d91));
  module_gen_grant_carry instance_gen_grant_carry_13(.gen_grant_carry_c(gen_grant_carry___d91[0]),
						     .gen_grant_carry_r(output_arbs_2_select_requests[1]),
						     .gen_grant_carry_p(oas_2_token_BIT_1___h7318),
						     .gen_grant_carry(gen_grant_carry___d93));
  module_gen_grant_carry instance_gen_grant_carry_14(.gen_grant_carry_c(gen_grant_carry___d93[0]),
						     .gen_grant_carry_r(output_arbs_2_select_requests[2]),
						     .gen_grant_carry_p(oas_2_token_BIT_2___h7384),
						     .gen_grant_carry(gen_grant_carry___d95));
  assign NOT_gen_grant_carry_0_BIT_1_1_0_AND_NOT_gen_gr_ETC___d74 =
	     !gen_grant_carry___d50[1] && !gen_grant_carry___d57[1] &&
	     !gen_grant_carry___d46[1] &&
	     !gen_grant_carry___d55[1] &&
	     (gen_grant_carry___d42[1] || gen_grant_carry___d53[1]) ;
  assign NOT_gen_grant_carry_2_BIT_1_3_2_AND_NOT_gen_gr_ETC___d36 =
	     !gen_grant_carry___d12[1] && !gen_grant_carry___d19[1] &&
	     !gen_grant_carry___d8[1] &&
	     !gen_grant_carry___d17[1] &&
	     (gen_grant_carry___d4[1] || gen_grant_carry___d15[1]) ;
  assign NOT_gen_grant_carry_8_BIT_1_9_8_AND_NOT_gen_gr_ETC___d112 =
	     !gen_grant_carry___d88[1] && !gen_grant_carry___d95[1] &&
	     !gen_grant_carry___d84[1] &&
	     !gen_grant_carry___d93[1] &&
	     (gen_grant_carry___d80[1] || gen_grant_carry___d91[1]) ;
  assign oas_0_token_BIT_0___h2167 = oas_0_token[0] ;
  assign oas_0_token_BIT_1___h2233 = oas_0_token[1] ;
  assign oas_0_token_BIT_2___h2299 = oas_0_token[2] ;
  assign oas_1_token_BIT_0___h4711 = oas_1_token[0] ;
  assign oas_1_token_BIT_1___h4777 = oas_1_token[1] ;
  assign oas_1_token_BIT_2___h4843 = oas_1_token[2] ;
  assign oas_2_token_BIT_0___h7252 = oas_2_token[0] ;
  assign oas_2_token_BIT_1___h7318 = oas_2_token[1] ;
  assign oas_2_token_BIT_2___h7384 = oas_2_token[2] ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        oas_0_token <= `BSV_ASSIGNMENT_DELAY 3'd1;
	oas_1_token <= `BSV_ASSIGNMENT_DELAY 3'd2;
	oas_2_token <= `BSV_ASSIGNMENT_DELAY 3'd4;
      end
    else
      begin
        if (oas_0_token$EN)
	  oas_0_token <= `BSV_ASSIGNMENT_DELAY oas_0_token$D_IN;
	if (oas_1_token$EN)
	  oas_1_token <= `BSV_ASSIGNMENT_DELAY oas_1_token$D_IN;
	if (oas_2_token$EN)
	  oas_2_token <= `BSV_ASSIGNMENT_DELAY oas_2_token$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    oas_0_token = 3'h2;
    oas_1_token = 3'h2;
    oas_2_token = 3'h2;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkRouterOutputArbitersRoundRobin

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// output_arbs_0_select           O     3
// output_arbs_1_select           O     3
// output_arbs_2_select           O     3
// CLK                            I     1 unused
// RST_N                          I     1 unused
// output_arbs_0_select_requests  I     3
// output_arbs_1_select_requests  I     3
// output_arbs_2_select_requests  I     3
// EN_output_arbs_0_next          I     1 unused
// EN_output_arbs_1_next          I     1 unused
// EN_output_arbs_2_next          I     1 unused
//
// Combinational paths from inputs to outputs:
//   output_arbs_0_select_requests -> output_arbs_0_select
//   output_arbs_1_select_requests -> output_arbs_1_select
//   output_arbs_2_select_requests -> output_arbs_2_select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouterOutputArbitersStatic(CLK,
				    RST_N,

				    output_arbs_0_select_requests,
				    output_arbs_0_select,

				    EN_output_arbs_0_next,

				    output_arbs_1_select_requests,
				    output_arbs_1_select,

				    EN_output_arbs_1_next,

				    output_arbs_2_select_requests,
				    output_arbs_2_select,

				    EN_output_arbs_2_next);
  input  CLK;
  input  RST_N;

  // value method output_arbs_0_select
  input  [2 : 0] output_arbs_0_select_requests;
  output [2 : 0] output_arbs_0_select;

  // action method output_arbs_0_next
  input  EN_output_arbs_0_next;

  // value method output_arbs_1_select
  input  [2 : 0] output_arbs_1_select_requests;
  output [2 : 0] output_arbs_1_select;

  // action method output_arbs_1_next
  input  EN_output_arbs_1_next;

  // value method output_arbs_2_select
  input  [2 : 0] output_arbs_2_select_requests;
  output [2 : 0] output_arbs_2_select;

  // action method output_arbs_2_next
  input  EN_output_arbs_2_next;

  // signals for module outputs
  wire [2 : 0] output_arbs_0_select,
	       output_arbs_1_select,
	       output_arbs_2_select;

  // value method output_arbs_0_select
  assign output_arbs_0_select =
	     { output_arbs_0_select_requests[2],
	       !output_arbs_0_select_requests[2] &&
	       output_arbs_0_select_requests[1],
	       !output_arbs_0_select_requests[2] &&
	       !output_arbs_0_select_requests[1] &&
	       output_arbs_0_select_requests[0] } ;

  // value method output_arbs_1_select
  assign output_arbs_1_select =
	     { !output_arbs_1_select_requests[0] &&
	       output_arbs_1_select_requests[2],
	       !output_arbs_1_select_requests[0] &&
	       !output_arbs_1_select_requests[2] &&
	       output_arbs_1_select_requests[1],
	       output_arbs_1_select_requests[0] } ;

  // value method output_arbs_2_select
  assign output_arbs_2_select =
	     { !output_arbs_2_select_requests[1] &&
	       !output_arbs_2_select_requests[0] &&
	       output_arbs_2_select_requests[2],
	       output_arbs_2_select_requests[1],
	       !output_arbs_2_select_requests[1] &&
	       output_arbs_2_select_requests[0] } ;
endmodule  // mkRouterOutputArbitersStatic

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:19 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// r_0_sub                        O     2
// RDY_r_0_sub                    O     1 const
// r_1_sub                        O     2
// RDY_r_1_sub                    O     1 const
// r_2_sub                        O     2
// RDY_r_2_sub                    O     1 const
// RDY_w_0_upd                    O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// r_0_sub_a                      I     2
// r_1_sub_a                      I     2
// r_2_sub_a                      I     2
// w_0_upd_a                      I     2
// w_0_upd_d                      I     2
// EN_w_0_upd                     I     1
//
// No combinational paths from inputs to outputs
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkRouteTableSynth(CLK,
			 RST_N,

			 r_0_sub_a,
			 r_0_sub,
			 RDY_r_0_sub,

			 r_1_sub_a,
			 r_1_sub,
			 RDY_r_1_sub,

			 r_2_sub_a,
			 r_2_sub,
			 RDY_r_2_sub,

			 w_0_upd_a,
			 w_0_upd_d,
			 EN_w_0_upd,
			 RDY_w_0_upd);
  input  CLK;
  input  RST_N;

  // value method r_0_sub
  input  [1 : 0] r_0_sub_a;
  output [1 : 0] r_0_sub;
  output RDY_r_0_sub;

  // value method r_1_sub
  input  [1 : 0] r_1_sub_a;
  output [1 : 0] r_1_sub;
  output RDY_r_1_sub;

  // value method r_2_sub
  input  [1 : 0] r_2_sub_a;
  output [1 : 0] r_2_sub;
  output RDY_r_2_sub;

  // action method w_0_upd
  input  [1 : 0] w_0_upd_a;
  input  [1 : 0] w_0_upd_d;
  input  EN_w_0_upd;
  output RDY_w_0_upd;

  // signals for module outputs
  wire [1 : 0] r_0_sub, r_1_sub, r_2_sub;
  wire RDY_r_0_sub, RDY_r_1_sub, RDY_r_2_sub, RDY_w_0_upd;

  // ports of submodule rt_ifc_banks_0_banks_0_rf
  wire [1 : 0] rt_ifc_banks_0_banks_0_rf$ADDR_1,
	       rt_ifc_banks_0_banks_0_rf$ADDR_IN,
	       rt_ifc_banks_0_banks_0_rf$D_IN,
	       rt_ifc_banks_0_banks_0_rf$D_OUT_1;
  wire rt_ifc_banks_0_banks_0_rf$WE;

  // ports of submodule rt_ifc_banks_0_banks_1_rf
  wire [1 : 0] rt_ifc_banks_0_banks_1_rf$ADDR_1,
	       rt_ifc_banks_0_banks_1_rf$ADDR_IN,
	       rt_ifc_banks_0_banks_1_rf$D_IN,
	       rt_ifc_banks_0_banks_1_rf$D_OUT_1;
  wire rt_ifc_banks_0_banks_1_rf$WE;

  // ports of submodule rt_ifc_banks_0_banks_2_rf
  wire [1 : 0] rt_ifc_banks_0_banks_2_rf$ADDR_1,
	       rt_ifc_banks_0_banks_2_rf$ADDR_IN,
	       rt_ifc_banks_0_banks_2_rf$D_IN,
	       rt_ifc_banks_0_banks_2_rf$D_OUT_1;
  wire rt_ifc_banks_0_banks_2_rf$WE;

  // value method r_0_sub
  assign r_0_sub = rt_ifc_banks_0_banks_0_rf$D_OUT_1 ;
  assign RDY_r_0_sub = 1'd1 ;

  // value method r_1_sub
  assign r_1_sub = rt_ifc_banks_0_banks_1_rf$D_OUT_1 ;
  assign RDY_r_1_sub = 1'd1 ;

  // value method r_2_sub
  assign r_2_sub = rt_ifc_banks_0_banks_2_rf$D_OUT_1 ;
  assign RDY_r_2_sub = 1'd1 ;

  // action method w_0_upd
  assign RDY_w_0_upd = 1'd1 ;

  // submodule rt_ifc_banks_0_banks_0_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_4.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) rt_ifc_banks_0_banks_0_rf(.CLK(CLK),
								.RST_N(RST_N),
								.ADDR_1(rt_ifc_banks_0_banks_0_rf$ADDR_1),
								.ADDR_IN(rt_ifc_banks_0_banks_0_rf$ADDR_IN),
								.D_IN(rt_ifc_banks_0_banks_0_rf$D_IN),
								.WE(rt_ifc_banks_0_banks_0_rf$WE),
								.D_OUT_1(rt_ifc_banks_0_banks_0_rf$D_OUT_1));

  // submodule rt_ifc_banks_0_banks_1_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_4.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) rt_ifc_banks_0_banks_1_rf(.CLK(CLK),
								.RST_N(RST_N),
								.ADDR_1(rt_ifc_banks_0_banks_1_rf$ADDR_1),
								.ADDR_IN(rt_ifc_banks_0_banks_1_rf$ADDR_IN),
								.D_IN(rt_ifc_banks_0_banks_1_rf$D_IN),
								.WE(rt_ifc_banks_0_banks_1_rf$WE),
								.D_OUT_1(rt_ifc_banks_0_banks_1_rf$D_OUT_1));

  // submodule rt_ifc_banks_0_banks_2_rf
  RegFileLoadSyn #( /*file*/ "double_ring_4RTs_2VCs_4BD_34DW_SepIFRoundRobinAlloc_routing_4.hex",
		    /*addr_width*/ 32'd2,
		    /*data_width*/ 32'd2,
		    /*lo*/ 32'd0,
		    /*hi*/ 32'd3,
		    /*binary*/ 32'd0) rt_ifc_banks_0_banks_2_rf(.CLK(CLK),
								.RST_N(RST_N),
								.ADDR_1(rt_ifc_banks_0_banks_2_rf$ADDR_1),
								.ADDR_IN(rt_ifc_banks_0_banks_2_rf$ADDR_IN),
								.D_IN(rt_ifc_banks_0_banks_2_rf$D_IN),
								.WE(rt_ifc_banks_0_banks_2_rf$WE),
								.D_OUT_1(rt_ifc_banks_0_banks_2_rf$D_OUT_1));

  // submodule rt_ifc_banks_0_banks_0_rf
  assign rt_ifc_banks_0_banks_0_rf$ADDR_1 = r_0_sub_a ;
  assign rt_ifc_banks_0_banks_0_rf$ADDR_IN = w_0_upd_a ;
  assign rt_ifc_banks_0_banks_0_rf$D_IN = w_0_upd_d ;
  assign rt_ifc_banks_0_banks_0_rf$WE = EN_w_0_upd ;

  // submodule rt_ifc_banks_0_banks_1_rf
  assign rt_ifc_banks_0_banks_1_rf$ADDR_1 = r_1_sub_a ;
  assign rt_ifc_banks_0_banks_1_rf$ADDR_IN = w_0_upd_a ;
  assign rt_ifc_banks_0_banks_1_rf$D_IN = w_0_upd_d ;
  assign rt_ifc_banks_0_banks_1_rf$WE = EN_w_0_upd ;

  // submodule rt_ifc_banks_0_banks_2_rf
  assign rt_ifc_banks_0_banks_2_rf$ADDR_1 = r_2_sub_a ;
  assign rt_ifc_banks_0_banks_2_rf$ADDR_IN = w_0_upd_a ;
  assign rt_ifc_banks_0_banks_2_rf$D_IN = w_0_upd_d ;
  assign rt_ifc_banks_0_banks_2_rf$WE = EN_w_0_upd ;
endmodule  // mkRouteTableSynth

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:17 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// allocate                       O     9
// pipeline                       I     1
// CLK                            I     1 clock
// RST_N                          I     1 reset
// allocate_alloc_input           I     9
// EN_next                        I     1
// EN_allocate                    I     1
//
// Combinational paths from inputs to outputs:
//   (allocate_alloc_input, pipeline) -> allocate
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkSepRouterAllocator(pipeline,
			    CLK,
			    RST_N,

			    allocate_alloc_input,
			    EN_allocate,
			    allocate,

			    EN_next);
  input  pipeline;
  input  CLK;
  input  RST_N;

  // actionvalue method allocate
  input  [8 : 0] allocate_alloc_input;
  input  EN_allocate;
  output [8 : 0] allocate;

  // action method next
  input  EN_next;

  // signals for module outputs
  wire [8 : 0] allocate;

  // register as_inputArbGrants_reg_0_0
  reg as_inputArbGrants_reg_0_0;
  wire as_inputArbGrants_reg_0_0$D_IN, as_inputArbGrants_reg_0_0$EN;

  // register as_inputArbGrants_reg_0_1
  reg as_inputArbGrants_reg_0_1;
  wire as_inputArbGrants_reg_0_1$D_IN, as_inputArbGrants_reg_0_1$EN;

  // register as_inputArbGrants_reg_0_2
  reg as_inputArbGrants_reg_0_2;
  wire as_inputArbGrants_reg_0_2$D_IN, as_inputArbGrants_reg_0_2$EN;

  // register as_inputArbGrants_reg_1_0
  reg as_inputArbGrants_reg_1_0;
  wire as_inputArbGrants_reg_1_0$D_IN, as_inputArbGrants_reg_1_0$EN;

  // register as_inputArbGrants_reg_1_1
  reg as_inputArbGrants_reg_1_1;
  wire as_inputArbGrants_reg_1_1$D_IN, as_inputArbGrants_reg_1_1$EN;

  // register as_inputArbGrants_reg_1_2
  reg as_inputArbGrants_reg_1_2;
  wire as_inputArbGrants_reg_1_2$D_IN, as_inputArbGrants_reg_1_2$EN;

  // register as_inputArbGrants_reg_2_0
  reg as_inputArbGrants_reg_2_0;
  wire as_inputArbGrants_reg_2_0$D_IN, as_inputArbGrants_reg_2_0$EN;

  // register as_inputArbGrants_reg_2_1
  reg as_inputArbGrants_reg_2_1;
  wire as_inputArbGrants_reg_2_1$D_IN, as_inputArbGrants_reg_2_1$EN;

  // register as_inputArbGrants_reg_2_2
  reg as_inputArbGrants_reg_2_2;
  wire as_inputArbGrants_reg_2_2$D_IN, as_inputArbGrants_reg_2_2$EN;

  // ports of submodule inputArbs
  wire [2 : 0] inputArbs$input_arbs_0_select,
	       inputArbs$input_arbs_0_select_requests,
	       inputArbs$input_arbs_1_select,
	       inputArbs$input_arbs_1_select_requests,
	       inputArbs$input_arbs_2_select,
	       inputArbs$input_arbs_2_select_requests;
  wire inputArbs$EN_input_arbs_0_next,
       inputArbs$EN_input_arbs_1_next,
       inputArbs$EN_input_arbs_2_next;

  // ports of submodule outputArbs
  wire [2 : 0] outputArbs$output_arbs_0_select,
	       outputArbs$output_arbs_0_select_requests,
	       outputArbs$output_arbs_1_select,
	       outputArbs$output_arbs_1_select_requests,
	       outputArbs$output_arbs_2_select,
	       outputArbs$output_arbs_2_select_requests;
  wire outputArbs$EN_output_arbs_0_next,
       outputArbs$EN_output_arbs_1_next,
       outputArbs$EN_output_arbs_2_next;

  // actionvalue method allocate
  assign allocate =
	     { outputArbs$output_arbs_2_select[2],
	       outputArbs$output_arbs_1_select[2],
	       outputArbs$output_arbs_0_select[2],
	       outputArbs$output_arbs_2_select[1],
	       outputArbs$output_arbs_1_select[1],
	       outputArbs$output_arbs_0_select[1],
	       outputArbs$output_arbs_2_select[0],
	       outputArbs$output_arbs_1_select[0],
	       outputArbs$output_arbs_0_select[0] } ;

  // submodule inputArbs
  mkRouterInputArbitersRoundRobin inputArbs(.CLK(CLK),
					    .RST_N(RST_N),
					    .input_arbs_0_select_requests(inputArbs$input_arbs_0_select_requests),
					    .input_arbs_1_select_requests(inputArbs$input_arbs_1_select_requests),
					    .input_arbs_2_select_requests(inputArbs$input_arbs_2_select_requests),
					    .EN_input_arbs_0_next(inputArbs$EN_input_arbs_0_next),
					    .EN_input_arbs_1_next(inputArbs$EN_input_arbs_1_next),
					    .EN_input_arbs_2_next(inputArbs$EN_input_arbs_2_next),
					    .input_arbs_0_select(inputArbs$input_arbs_0_select),
					    .input_arbs_1_select(inputArbs$input_arbs_1_select),
					    .input_arbs_2_select(inputArbs$input_arbs_2_select));

  // submodule outputArbs
  mkRouterOutputArbitersRoundRobin outputArbs(.CLK(CLK),
					      .RST_N(RST_N),
					      .output_arbs_0_select_requests(outputArbs$output_arbs_0_select_requests),
					      .output_arbs_1_select_requests(outputArbs$output_arbs_1_select_requests),
					      .output_arbs_2_select_requests(outputArbs$output_arbs_2_select_requests),
					      .EN_output_arbs_0_next(outputArbs$EN_output_arbs_0_next),
					      .EN_output_arbs_1_next(outputArbs$EN_output_arbs_1_next),
					      .EN_output_arbs_2_next(outputArbs$EN_output_arbs_2_next),
					      .output_arbs_0_select(outputArbs$output_arbs_0_select),
					      .output_arbs_1_select(outputArbs$output_arbs_1_select),
					      .output_arbs_2_select(outputArbs$output_arbs_2_select));

  // register as_inputArbGrants_reg_0_0
  assign as_inputArbGrants_reg_0_0$D_IN = inputArbs$input_arbs_0_select[0] ;
  assign as_inputArbGrants_reg_0_0$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_0_1
  assign as_inputArbGrants_reg_0_1$D_IN = inputArbs$input_arbs_0_select[1] ;
  assign as_inputArbGrants_reg_0_1$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_0_2
  assign as_inputArbGrants_reg_0_2$D_IN = inputArbs$input_arbs_0_select[2] ;
  assign as_inputArbGrants_reg_0_2$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_1_0
  assign as_inputArbGrants_reg_1_0$D_IN = inputArbs$input_arbs_1_select[0] ;
  assign as_inputArbGrants_reg_1_0$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_1_1
  assign as_inputArbGrants_reg_1_1$D_IN = inputArbs$input_arbs_1_select[1] ;
  assign as_inputArbGrants_reg_1_1$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_1_2
  assign as_inputArbGrants_reg_1_2$D_IN = inputArbs$input_arbs_1_select[2] ;
  assign as_inputArbGrants_reg_1_2$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_2_0
  assign as_inputArbGrants_reg_2_0$D_IN = inputArbs$input_arbs_2_select[0] ;
  assign as_inputArbGrants_reg_2_0$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_2_1
  assign as_inputArbGrants_reg_2_1$D_IN = inputArbs$input_arbs_2_select[1] ;
  assign as_inputArbGrants_reg_2_1$EN = EN_allocate && pipeline ;

  // register as_inputArbGrants_reg_2_2
  assign as_inputArbGrants_reg_2_2$D_IN = inputArbs$input_arbs_2_select[2] ;
  assign as_inputArbGrants_reg_2_2$EN = EN_allocate && pipeline ;

  // submodule inputArbs
  assign inputArbs$input_arbs_0_select_requests = allocate_alloc_input[2:0] ;
  assign inputArbs$input_arbs_1_select_requests = allocate_alloc_input[5:3] ;
  assign inputArbs$input_arbs_2_select_requests = allocate_alloc_input[8:6] ;
  assign inputArbs$EN_input_arbs_0_next = EN_next ;
  assign inputArbs$EN_input_arbs_1_next = EN_next ;
  assign inputArbs$EN_input_arbs_2_next = EN_next ;

  // submodule outputArbs
  assign outputArbs$output_arbs_0_select_requests =
	     pipeline ?
	       { as_inputArbGrants_reg_2_0,
		 as_inputArbGrants_reg_1_0,
		 as_inputArbGrants_reg_0_0 } :
	       { inputArbs$input_arbs_2_select[0],
		 inputArbs$input_arbs_1_select[0],
		 inputArbs$input_arbs_0_select[0] } ;
  assign outputArbs$output_arbs_1_select_requests =
	     pipeline ?
	       { as_inputArbGrants_reg_2_1,
		 as_inputArbGrants_reg_1_1,
		 as_inputArbGrants_reg_0_1 } :
	       { inputArbs$input_arbs_2_select[1],
		 inputArbs$input_arbs_1_select[1],
		 inputArbs$input_arbs_0_select[1] } ;
  assign outputArbs$output_arbs_2_select_requests =
	     pipeline ?
	       { as_inputArbGrants_reg_2_2,
		 as_inputArbGrants_reg_1_2,
		 as_inputArbGrants_reg_0_2 } :
	       { inputArbs$input_arbs_2_select[2],
		 inputArbs$input_arbs_1_select[2],
		 inputArbs$input_arbs_0_select[2] } ;
  assign outputArbs$EN_output_arbs_0_next = EN_next ;
  assign outputArbs$EN_output_arbs_1_next = EN_next ;
  assign outputArbs$EN_output_arbs_2_next = EN_next ;

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        as_inputArbGrants_reg_0_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_0_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_0_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_1_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_1_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_1_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_2_0 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_2_1 <= `BSV_ASSIGNMENT_DELAY 1'd0;
	as_inputArbGrants_reg_2_2 <= `BSV_ASSIGNMENT_DELAY 1'd0;
      end
    else
      begin
        if (as_inputArbGrants_reg_0_0$EN)
	  as_inputArbGrants_reg_0_0 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_0_0$D_IN;
	if (as_inputArbGrants_reg_0_1$EN)
	  as_inputArbGrants_reg_0_1 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_0_1$D_IN;
	if (as_inputArbGrants_reg_0_2$EN)
	  as_inputArbGrants_reg_0_2 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_0_2$D_IN;
	if (as_inputArbGrants_reg_1_0$EN)
	  as_inputArbGrants_reg_1_0 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_1_0$D_IN;
	if (as_inputArbGrants_reg_1_1$EN)
	  as_inputArbGrants_reg_1_1 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_1_1$D_IN;
	if (as_inputArbGrants_reg_1_2$EN)
	  as_inputArbGrants_reg_1_2 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_1_2$D_IN;
	if (as_inputArbGrants_reg_2_0$EN)
	  as_inputArbGrants_reg_2_0 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_2_0$D_IN;
	if (as_inputArbGrants_reg_2_1$EN)
	  as_inputArbGrants_reg_2_1 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_2_1$D_IN;
	if (as_inputArbGrants_reg_2_2$EN)
	  as_inputArbGrants_reg_2_2 <= `BSV_ASSIGNMENT_DELAY
	      as_inputArbGrants_reg_2_2$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    as_inputArbGrants_reg_0_0 = 1'h0;
    as_inputArbGrants_reg_0_1 = 1'h0;
    as_inputArbGrants_reg_0_2 = 1'h0;
    as_inputArbGrants_reg_1_0 = 1'h0;
    as_inputArbGrants_reg_1_1 = 1'h0;
    as_inputArbGrants_reg_1_2 = 1'h0;
    as_inputArbGrants_reg_2_0 = 1'h0;
    as_inputArbGrants_reg_2_1 = 1'h0;
    as_inputArbGrants_reg_2_2 = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkSepRouterAllocator

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:16 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// select                         O     8
// CLK                            I     1 unused
// RST_N                          I     1 unused
// select_requests                I     8
// EN_next                        I     1 unused
//
// Combinational paths from inputs to outputs:
//   select_requests -> select
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module mkTestArbiter8(CLK,
		      RST_N,

		      select_requests,
		      select,

		      EN_next);
  input  CLK;
  input  RST_N;

  // value method select
  input  [7 : 0] select_requests;
  output [7 : 0] select;

  // action method next
  input  EN_next;

  // signals for module outputs
  wire [7 : 0] select;

  // value method select
  assign select =
	     { !select_requests[1] && !select_requests[0] &&
	       select_requests[7],
	       !select_requests[1] && !select_requests[0] &&
	       !select_requests[7] &&
	       select_requests[6],
	       !select_requests[1] && !select_requests[0] &&
	       !select_requests[7] &&
	       !select_requests[6] &&
	       select_requests[5],
	       !select_requests[1] && !select_requests[0] &&
	       !select_requests[7] &&
	       !select_requests[6] &&
	       !select_requests[5] &&
	       select_requests[4],
	       !select_requests[1] && !select_requests[0] &&
	       !select_requests[7] &&
	       !select_requests[6] &&
	       !select_requests[5] &&
	       !select_requests[4] &&
	       select_requests[3],
	       !select_requests[1] && !select_requests[0] &&
	       !select_requests[7] &&
	       !select_requests[6] &&
	       !select_requests[5] &&
	       !select_requests[4] &&
	       !select_requests[3] &&
	       select_requests[2],
	       select_requests[1],
	       !select_requests[1] && select_requests[0] } ;
endmodule  // mkTestArbiter8

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:16 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// gen_grant_carry                O     2
// gen_grant_carry_c              I     1
// gen_grant_carry_r              I     1
// gen_grant_carry_p              I     1
//
// Combinational paths from inputs to outputs:
//   (gen_grant_carry_c, gen_grant_carry_r, gen_grant_carry_p) -> gen_grant_carry
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module module_gen_grant_carry(gen_grant_carry_c,
			      gen_grant_carry_r,
			      gen_grant_carry_p,
			      gen_grant_carry);
  // value method gen_grant_carry
  input  gen_grant_carry_c;
  input  gen_grant_carry_r;
  input  gen_grant_carry_p;
  output [1 : 0] gen_grant_carry;

  // signals for module outputs
  wire [1 : 0] gen_grant_carry;

  // value method gen_grant_carry
  assign gen_grant_carry =
	     { gen_grant_carry_r && (gen_grant_carry_c || gen_grant_carry_p),
	       !gen_grant_carry_r &&
	       (gen_grant_carry_c || gen_grant_carry_p) } ;
endmodule  // module_gen_grant_carry

//
// Generated by Bluespec Compiler (build f2da894)
//
// On Fri Jul  1 02:27:14 EDT 2022
//
//
// Ports:
// Name                         I/O  size props
// outport_encoder                O     3
// outport_encoder_vec            I     3
//
// Combinational paths from inputs to outputs:
//   outport_encoder_vec -> outport_encoder
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module module_outport_encoder(outport_encoder_vec,
			      outport_encoder);
  // value method outport_encoder
  input  [2 : 0] outport_encoder_vec;
  output [2 : 0] outport_encoder;

  // signals for module outputs
  wire [2 : 0] outport_encoder;

  // value method outport_encoder
  assign outport_encoder =
	     { outport_encoder_vec[0] || outport_encoder_vec[1] ||
	       outport_encoder_vec[2],
	       outport_encoder_vec[0] ?
		 2'd0 :
		 (outport_encoder_vec[1] ? 2'd1 : 2'd2) } ;
endmodule  // module_outport_encoder

module PriorityEncoder
(
input_data,
output_data
);


parameter OUTPUT_WIDTH=8;
parameter INPUT_WIDTH=1<<OUTPUT_WIDTH;

 input      [INPUT_WIDTH-1:0]  input_data;
 output     [OUTPUT_WIDTH-1:0] output_data;

 reg [OUTPUT_WIDTH-1:0] output_data;
 
integer                            ii;
 
always @* begin
  output_data = {OUTPUT_WIDTH{1'bx}};
  for(ii=0;ii<INPUT_WIDTH;ii=ii+1) if (input_data[ii]) output_data = ii;
end
 
endmodule
/**
 *
 * Copyright (c) 2006-2008 The University of Texas All Rights Reserved.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 * 
 * The GNU Public License is available in the file LICENSE, or you can
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA, or you can find it on the World Wide Web at
 * http://www.fsf.org.
 * 
 * Authors: Eric Johnson, and Prof. Derek Chiou
 * 
 * The authors are with the Department of Electrical and Computer Engineering,
 * The University of Texas at Austin, Austin, TX 78712 USA.
 * 
 * They can be reached at dejohnso@ece.utexas.edu, derek@ece.utexas.edu
 * 
 * More information about related work can be found at
 * http://users.ece.utexas.edu/~derek/FAST.html
 * 
 **/


module dual_ported_bram (clka, clkb, ena, enb, wea, web, addra, addrb, dia, dib, doa, dob);

   parameter DATA_WIDTH = 36;
   parameter ADDR_WIDTH = 9;
   parameter DEPTH = 1 << ADDR_WIDTH;
   
   input clka, clkb, ena, enb, wea, web;
   input [ADDR_WIDTH-1:0] addra, addrb;
   input [DATA_WIDTH-1:0] 	  dia, dib;
   output [DATA_WIDTH-1:0] 	  doa, dob;
   reg [DATA_WIDTH-1:0] 	  ram [DEPTH-1:0];
   reg [DATA_WIDTH-1:0] 	  doa, dob;
   
   always @(posedge clka) begin
      if (ena) begin
	 if (wea)
	   ram[addra] <= dia;
	 doa <= ram[addra];
      end
   end

   always @(posedge clkb) begin
      if (enb) begin
	 if (web)
	   ram[addrb] <= dib;
	 dob <= ram[addrb];
      end
   end

endmodule

module BRAM (CLK, RST_N, RD_ADDRA, RD_ADDRB, REA, REB, WR_ADDRA, WR_ADDRB, WEA, WEB, DIA, DIB, DOA, DOB);

   parameter DATA_WIDTH = 36;
   parameter ADDR_WIDTH = 9;
   parameter DEPTH = 1 << ADDR_WIDTH;

   input     CLK, RST_N;
   input     REA, REB;
   input     WEA, WEB;
   input [ADDR_WIDTH-1:0] RD_ADDRA, RD_ADDRB;
   input [ADDR_WIDTH-1:0] WR_ADDRA, WR_ADDRB;
   input [DATA_WIDTH-1:0] DIA, DIB;
   output [DATA_WIDTH-1:0] DOA, DOB;

   wire 		  CLK, RST_N;
   wire 		  REA, REB;
   wire 		  WEA, WEB;
   wire [ADDR_WIDTH-1:0]  RD_ADDRA, RD_ADDRB;
   wire [ADDR_WIDTH-1:0]  WR_ADDRA, WR_ADDRB;
   wire [DATA_WIDTH-1:0]  DIA, DIB;
   wire [DATA_WIDTH-1:0]  DOA, DOB;

   wire 		  ENA, ENB;
   wire [ADDR_WIDTH-1:0]  ADDRA, ADDRB;

   assign 		  ENA = 1;
   assign 		  ENB = 1;

   assign 		  ADDRA = (WEA) ? WR_ADDRA : RD_ADDRA;
   assign 		  ADDRB = (WEB) ? WR_ADDRB : RD_ADDRB;
   
   dual_ported_bram #(.DATA_WIDTH(DATA_WIDTH),
		      .ADDR_WIDTH(ADDR_WIDTH),
		      .DEPTH(DEPTH)) ram(CLK, CLK, ENA, ENB, WEA, WEB, ADDRA, ADDRB, DIA, DIB, DOA, DOB);
   
endmodule

module QUAD_BRAM (CLK, CLK2X, RST_N, RD_ADDRA, RD_ADDRB, RD_ADDRC, RD_ADDRD, REA, REB, REC, RED, WR_ADDRA, WR_ADDRB, WR_ADDRC, WR_ADDRD, WEA, WEB, WEC, WED, DIA, DIB, DIC, DID, DOA, DOB, DOC, DOD);

   parameter DATA_WIDTH = 36;
   parameter ADDR_WIDTH = 9;
   parameter DEPTH = 1 << ADDR_WIDTH;

   input     CLK, CLK2X, RST_N;
   input     REA, REB, REC, RED;
   input     WEA, WEB, WEC, WED;
   input [ADDR_WIDTH-1:0] RD_ADDRA, RD_ADDRB, RD_ADDRC, RD_ADDRD;
   input [ADDR_WIDTH-1:0] WR_ADDRA, WR_ADDRB, WR_ADDRC, WR_ADDRD;
   input [DATA_WIDTH-1:0] 	  DIA, DIB, DIC, DID;
   output [DATA_WIDTH-1:0] 	  DOA, DOB, DOC, DOD;

   //wire versions of inputs and outputs
   wire     CLK, CLK2X, RST_N;
   wire     REA, REB, REC, RED;
   wire     WEA, WEB, WEC, WED;
   wire [ADDR_WIDTH-1:0] RD_ADDRA, RD_ADDRB, RD_ADDRC, RD_ADDRD;
   wire [ADDR_WIDTH-1:0] WR_ADDRA, WR_ADDRB, WR_ADDRC, WR_ADDRD;
   wire [DATA_WIDTH-1:0] 	  DIA, DIB, DIC, DID;
   reg [DATA_WIDTH-1:0] 	  DOA, DOB, DOC, DOD;

   //create some intermediate wires
   wire [DATA_WIDTH-1:0] 	  DI_A, DI_B;
   wire [DATA_WIDTH-1:0]        DO_A, DO_B;
   wire 		  WE_A, WE_B;
   wire 		  EN_A,EN_B;
   wire [ADDR_WIDTH-1:0]  ADDRA, ADDRB, ADDRC, ADDRD, ADDR_A, ADDR_B;

   assign 		  EN_A = 1;
   assign 		  EN_B = 1;
   assign 		  DI_A = (CLK) ? DIA : DIC;
   assign 		  DI_B = (CLK)? DIB : DID;
   assign 		  WE_A = (CLK) ? WEA : WEC;
   assign 		  WE_B = (CLK) ? WEB : WED;

   assign 		  ADDRA = (WEA) ? WR_ADDRA : RD_ADDRA;
   assign 		  ADDRB = (WEB) ? WR_ADDRB : RD_ADDRB;
   assign 		  ADDRC = (WEC) ? WR_ADDRC : RD_ADDRC;
   assign 		  ADDRD = (WED) ? WR_ADDRD : RD_ADDRD;
   
   assign 		  ADDR_A = (CLK) ? ADDRA : ADDRC;
   assign 		  ADDR_B = (CLK) ? ADDRB : ADDRD;

   always @(posedge CLK) begin
      DOA <= DO_A;
      DOB <= DO_B;
   end
   always @(negedge CLK) begin
      DOC <= DO_A;
      DOD <= DO_B;
   end

   dual_ported_bram #(.DATA_WIDTH(DATA_WIDTH),
		      .ADDR_WIDTH(ADDR_WIDTH),
		      .DEPTH(DEPTH)) ram(CLK2X,CLK2X,EN_A,EN_B,WE_A,WE_B,ADDR_A,ADDR_B,DI_A,DI_B,DO_A,DO_B);

endmodule

/*
 * =========================================================================
 *
 * Filename:            RegFile_16ports.v
 * Date created:        03-29-2011
 * Last modified:       03-29-2011
 * Authors:		Michael Papamichael <papamixATcs.cmu.edu>
 *
 * Description:
 * 16-ported register file that maps to LUT RAM.
 * 
 */

// Multi-ported Register File
module RegFile_16ports_load(CLK, rst_n,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5,
               ADDR_6, D_OUT_6,
               ADDR_7, D_OUT_7,
               ADDR_8, D_OUT_8,
               ADDR_9, D_OUT_9,
               ADDR_10, D_OUT_10,
               ADDR_11, D_OUT_11,
               ADDR_12, D_OUT_12,
               ADDR_13, D_OUT_13,
               ADDR_14, D_OUT_14,
               ADDR_15, D_OUT_15,
               ADDR_16, D_OUT_16
               );

   // synopsys template   
   parameter                   data_width = 1;
   parameter                   addr_width = 1;
   parameter                   loadfile = "";
   parameter                   binary = 0;
   //parameter                   lo = 0;
   //parameter                   hi = 1;
   parameter                   depth = 1<<addr_width;
   
   input                       CLK;
   input                       rst_n;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;
   
   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;
   
   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;
   
   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   input [addr_width - 1 : 0]  ADDR_6;
   output [data_width - 1 : 0] D_OUT_6;
   
   input [addr_width - 1 : 0]  ADDR_7;
   output [data_width - 1 : 0] D_OUT_7;
   
   input [addr_width - 1 : 0]  ADDR_8;
   output [data_width - 1 : 0] D_OUT_8;
   
   input [addr_width - 1 : 0]  ADDR_9;
   output [data_width - 1 : 0] D_OUT_9;
   
   input [addr_width - 1 : 0]  ADDR_10;
   output [data_width - 1 : 0] D_OUT_10;

   input [addr_width - 1 : 0]  ADDR_11;
   output [data_width - 1 : 0] D_OUT_11;
   
   input [addr_width - 1 : 0]  ADDR_12;
   output [data_width - 1 : 0] D_OUT_12;
   
   input [addr_width - 1 : 0]  ADDR_13;
   output [data_width - 1 : 0] D_OUT_13;
   
   input [addr_width - 1 : 0]  ADDR_14;
   output [data_width - 1 : 0] D_OUT_14;
   
   input [addr_width - 1 : 0]  ADDR_15;
   output [data_width - 1 : 0] D_OUT_15;

   input [addr_width - 1 : 0]  ADDR_16;
   output [data_width - 1 : 0] D_OUT_16;
   
   // synthesis attribute ram_style of arr is distributed

   //reg [data_width - 1 : 0]    arr[lo:hi];
   reg [data_width - 1 : 0]    arr[0 : depth-1];
   

   initial begin
      if (binary)
        $readmemb(loadfile, arr, 0, depth-1);
      else
        $readmemh(loadfile, arr, 0, depth-1);
   end
//`ifdef BSV_NO_INITIAL_BLOCKS
//`else // not BSV_NO_INITIAL_BLOCKS
//   // synopsys translate_off
//   initial
//     begin : init_block
//        integer                     i; 		// temporary for generate reset value
//        for (i = lo; i <= hi; i = i + 1) begin
//           arr[i] = {((data_width + 1)/2){2'b10}} ;
//        end 
//     end // initial begin   
//   // synopsys translate_on
//`endif // BSV_NO_INITIAL_BLOCKS

   always@(posedge CLK)
     begin
        if (WE)
          arr[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
     end // always@ (posedge CLK)

   assign D_OUT_1  = arr[ADDR_1 ];
   assign D_OUT_2  = arr[ADDR_2 ];
   assign D_OUT_3  = arr[ADDR_3 ];
   assign D_OUT_4  = arr[ADDR_4 ];
   assign D_OUT_5  = arr[ADDR_5 ];
   assign D_OUT_6  = arr[ADDR_6 ];
   assign D_OUT_7  = arr[ADDR_7 ];
   assign D_OUT_8  = arr[ADDR_8 ];
   assign D_OUT_9  = arr[ADDR_9 ];
   assign D_OUT_10 = arr[ADDR_10];
   assign D_OUT_11 = arr[ADDR_11];
   assign D_OUT_12 = arr[ADDR_12];
   assign D_OUT_13 = arr[ADDR_13];
   assign D_OUT_14 = arr[ADDR_14];
   assign D_OUT_15 = arr[ADDR_15];
   assign D_OUT_16 = arr[ADDR_16];


endmodule

/*
 * =========================================================================
 *
 * Filename:            RegFile_16ports.v
 * Date created:        03-29-2011
 * Last modified:       03-29-2011
 * Authors:		Michael Papamichael <papamixATcs.cmu.edu>
 *
 * Description:
 * 16-ported register file that maps to LUT RAM.
 * 
 */

// Multi-ported Register File
module RegFile_16ports(CLK, rst_n,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5,
               ADDR_6, D_OUT_6,
               ADDR_7, D_OUT_7,
               ADDR_8, D_OUT_8,
               ADDR_9, D_OUT_9,
               ADDR_10, D_OUT_10,
               ADDR_11, D_OUT_11,
               ADDR_12, D_OUT_12,
               ADDR_13, D_OUT_13,
               ADDR_14, D_OUT_14,
               ADDR_15, D_OUT_15,
               ADDR_16, D_OUT_16
               );

   // synopsys template   
   parameter                   data_width = 1;
   parameter                   addr_width = 1;
   parameter                   depth = 1<<addr_width;
   //parameter                   lo = 0;
   //parameter                   hi = 1;
   
   input                       CLK;
   input                       rst_n;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;
   
   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;
   
   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;
   
   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;

   input [addr_width - 1 : 0]  ADDR_6;
   output [data_width - 1 : 0] D_OUT_6;
   
   input [addr_width - 1 : 0]  ADDR_7;
   output [data_width - 1 : 0] D_OUT_7;
   
   input [addr_width - 1 : 0]  ADDR_8;
   output [data_width - 1 : 0] D_OUT_8;
   
   input [addr_width - 1 : 0]  ADDR_9;
   output [data_width - 1 : 0] D_OUT_9;
   
   input [addr_width - 1 : 0]  ADDR_10;
   output [data_width - 1 : 0] D_OUT_10;

   input [addr_width - 1 : 0]  ADDR_11;
   output [data_width - 1 : 0] D_OUT_11;
   
   input [addr_width - 1 : 0]  ADDR_12;
   output [data_width - 1 : 0] D_OUT_12;
   
   input [addr_width - 1 : 0]  ADDR_13;
   output [data_width - 1 : 0] D_OUT_13;
   
   input [addr_width - 1 : 0]  ADDR_14;
   output [data_width - 1 : 0] D_OUT_14;
   
   input [addr_width - 1 : 0]  ADDR_15;
   output [data_width - 1 : 0] D_OUT_15;

   input [addr_width - 1 : 0]  ADDR_16;
   output [data_width - 1 : 0] D_OUT_16;
   
   //reg [data_width - 1 : 0]    arr[lo:hi];
   reg [data_width - 1 : 0]    arr[0 : depth-1];
   
   
//`ifdef BSV_NO_INITIAL_BLOCKS
//`else // not BSV_NO_INITIAL_BLOCKS
//   // synopsys translate_off
//   initial
//     begin : init_block
//        integer                     i; 		// temporary for generate reset value
//        for (i = lo; i <= hi; i = i + 1) begin
//           arr[i] = {((data_width + 1)/2){2'b10}} ;
//        end 
//     end // initial begin   
//   // synopsys translate_on
//`endif // BSV_NO_INITIAL_BLOCKS

// initialize
   integer 	       i;
   initial begin
      for(i=0;i<depth;i=i+1) begin
	 arr[i]=0;
      end
   end

   always@(posedge CLK)
     begin
        if (WE)
          arr[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
     end // always@ (posedge CLK)

   assign D_OUT_1  = arr[ADDR_1 ];
   assign D_OUT_2  = arr[ADDR_2 ];
   assign D_OUT_3  = arr[ADDR_3 ];
   assign D_OUT_4  = arr[ADDR_4 ];
   assign D_OUT_5  = arr[ADDR_5 ];
   assign D_OUT_6  = arr[ADDR_6 ];
   assign D_OUT_7  = arr[ADDR_7 ];
   assign D_OUT_8  = arr[ADDR_8 ];
   assign D_OUT_9  = arr[ADDR_9 ];
   assign D_OUT_10 = arr[ADDR_10];
   assign D_OUT_11 = arr[ADDR_11];
   assign D_OUT_12 = arr[ADDR_12];
   assign D_OUT_13 = arr[ADDR_13];
   assign D_OUT_14 = arr[ADDR_14];
   assign D_OUT_15 = arr[ADDR_15];
   assign D_OUT_16 = arr[ADDR_16];


endmodule

///////////////////////////////////
// RegFile_1ports Verilog module
///////////////////////////////////

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

// Multi-ported Register File
//(* ram_style = "distributed" *)
//(* ram_extract = "no" *)
module RegFile_1port(CLK, rst_n,
               ADDR_IN, D_IN, WE,
               ADDR_OUT, D_OUT
               );

   // synopsys template   
   parameter                   data_width = 1;
   parameter                   addr_width = 1;
   parameter                   depth = 1<<addr_width;
   //parameter                   lo = 0;
   //parameter                   hi = 1;
   
   input                       CLK;
   input                       rst_n;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_OUT;
   output [data_width - 1 : 0] D_OUT;

   //reg [data_width - 1 : 0]    arr[lo:hi];
   reg [data_width - 1 : 0]    arr[0 : depth-1];
   
   
//`ifdef BSV_NO_INITIAL_BLOCKS
//`else // not BSV_NO_INITIAL_BLOCKS
//   // synopsys translate_off
//   initial
//     begin : init_block
//        integer                     i; 		// temporary for generate reset value
//        for (i = lo; i <= hi; i = i + 1) begin
//           arr[i] = {((data_width + 1)/2){2'b10}} ;
//        end 
//     end // initial begin   
//   // synopsys translate_on
//`endif // BSV_NO_INITIAL_BLOCKS


   always@(posedge CLK)
     begin
        if (WE)
          arr[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
     end // always@ (posedge CLK)

   assign D_OUT  = arr[ADDR_OUT ];

endmodule

module RegFileLoadSyn
		  (CLK, RST_N,
                   ADDR_IN, D_IN, WE,
                   ADDR_1, D_OUT_1
                   );

   parameter                   file = "";
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;
   parameter                   binary = 0;
   
   input                       CLK;
   input                       RST_N;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   reg [data_width - 1 : 0]    arr[lo:hi];
   
   initial
     begin : init_block
           $readmemh(file, arr, lo, hi);
     end

   always@(posedge CLK)
     begin
        if (WE && RST_N)
          arr[ADDR_IN] <= D_IN;
     end // always@ (posedge CLK)

   assign D_OUT_1 = arr[ADDR_1];

endmodule

// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 17872 $
// $Date: 2009-09-18 14:32:56 +0000 (Fri, 18 Sep 2009) $

`define BSV_WARN_REGFILE_ADDR_RANGE 1

`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif


// Multi-ported Register File
module RegFile(CLK,
               ADDR_IN, D_IN, WE,
               ADDR_1, D_OUT_1,
               ADDR_2, D_OUT_2,
               ADDR_3, D_OUT_3,
               ADDR_4, D_OUT_4,
               ADDR_5, D_OUT_5
               );
   // synopsys template   
   parameter                   addr_width = 1;
   parameter                   data_width = 1;
   parameter                   lo = 0;
   parameter                   hi = 1;
   
   input                       CLK;
   input [addr_width - 1 : 0]  ADDR_IN;
   input [data_width - 1 : 0]  D_IN;
   input                       WE;
   
   input [addr_width - 1 : 0]  ADDR_1;
   output [data_width - 1 : 0] D_OUT_1;
   
   input [addr_width - 1 : 0]  ADDR_2;
   output [data_width - 1 : 0] D_OUT_2;
   
   input [addr_width - 1 : 0]  ADDR_3;
   output [data_width - 1 : 0] D_OUT_3;
   
   input [addr_width - 1 : 0]  ADDR_4;
   output [data_width - 1 : 0] D_OUT_4;
   
   input [addr_width - 1 : 0]  ADDR_5;
   output [data_width - 1 : 0] D_OUT_5;
   
   reg [data_width - 1 : 0]    arr[lo:hi];
   
   
`ifdef BSV_NO_INITIAL_BLOCKS
`else // not BSV_NO_INITIAL_BLOCKS
   // synopsys translate_off
   initial
     begin : init_block
        integer                     i; 		// temporary for generate reset value
        for (i = lo; i <= hi; i = i + 1) begin
           arr[i] = {((data_width + 1)/2){2'b10}} ;
        end 
     end // initial begin   
   // synopsys translate_on
`endif // BSV_NO_INITIAL_BLOCKS


   always@(posedge CLK)
     begin
        if (WE)
          arr[ADDR_IN] <= `BSV_ASSIGNMENT_DELAY D_IN;
     end // always@ (posedge CLK)

   assign D_OUT_1 = arr[ADDR_1];
   assign D_OUT_2 = arr[ADDR_2];
   assign D_OUT_3 = arr[ADDR_3];
   assign D_OUT_4 = arr[ADDR_4];
   assign D_OUT_5 = arr[ADDR_5];

   // synopsys translate_off
   always@(posedge CLK)
     begin : runtime_check
        reg enable_check;
        enable_check = `BSV_WARN_REGFILE_ADDR_RANGE ;
        if ( enable_check )
           begin
              if (( ADDR_1 < lo ) || (ADDR_1 > hi) )
                $display( "Warning: RegFile: %m -- Address port 1 is out of bounds: %h", ADDR_1 ) ;
              if (( ADDR_2 < lo ) || (ADDR_2 > hi) )
                $display( "Warning: RegFile: %m -- Address port 2 is out of bounds: %h", ADDR_2 ) ;
              if (( ADDR_3 < lo ) || (ADDR_3 > hi) )
                $display( "Warning: RegFile: %m -- Address port 3 is out of bounds: %h", ADDR_3 ) ;
              if (( ADDR_4 < lo ) || (ADDR_4 > hi) )
                $display( "Warning: RegFile: %m -- Address port 4 is out of bounds: %h", ADDR_4 ) ;
              if (( ADDR_5 < lo ) || (ADDR_5 > hi) )
                $display( "Warning: RegFile: %m -- Address port 5 is out of bounds: %h", ADDR_5 ) ;
              if ( WE && ( ADDR_IN < lo ) || (ADDR_IN > hi) )
                $display( "Warning: RegFile: %m -- Write Address port is out of bounds: %h", ADDR_IN ) ;
           end
     end
   // synopsys translate_on

endmodule

module ROM (
			      Rd,
			      IdxR,
			      DoutR, 

			      clk,
			      rst_n
		      );

	// synthesis attribute BRAM_MAP of DPSRAM is "yes";

   parameter 	WIDTH = 1;
   parameter    ADDR_BITS = 9;
   parameter	DEPTH = 1<<ADDR_BITS; 
   
   input		    Rd;
   input [ADDR_BITS-1 : 0]  IdxR;
   output [WIDTH-1 : 0]     DoutR; 

   input 	       clk;
   input 	       rst_n;

   reg [WIDTH-1 : 0]     rom[0 : DEPTH-1];

//   reg 		            forward;
//   reg [WIDTH-1 : 0]    forwardData;
   reg [WIDTH-1 : 0]    romData;

   integer 	       i;
   
//   always begin
//     rom[0] = 0;
//     rom[1] = 0;
//     rom[2] = 1;
//     rom[3] = 0;
//   end

     initial begin
       rom[0] = 0;
       rom[1] = 0;
       rom[2] = 1;
       rom[3] = 0;   
     end               
     
     always @(posedge clk) begin
   	  romData <= rom[IdxR];
   	  //forwardData <= DinW;
   	  //forward <= We && (IdxR==IdxW);
     end

   //assign DoutR = forward?forwardData:sramData;
  assign DoutR = romData;

endmodule


module shift_8x64_taps 				(clk, 
				shift,
				sr_in,
				sr_out,
				sr_tap_one,
				sr_tap_two,
				sr_tap_three
		 		);
  
	input clk, shift;

	input [7:0] sr_in;
	output [7:0] sr_tap_one, sr_tap_two, sr_tap_three, sr_out;

	reg [7:0] sr [63:0];
	integer n;

 	always@(posedge clk)
	begin
		if (shift == 1'b1)
		begin
			for (n = 63; n>0; n = n-1)
			begin
				sr[n] <= sr[n-1];
			end 

			sr[0] <= sr_in;
		end 
	end 
	
	assign sr_tap_one = sr[15];
	assign sr_tap_two = sr[31];
	assign sr_tap_three = sr[47];
	assign sr_out = sr[63];

endmodule
module shift_reg 		(clk, 
                                rst_n,
				shift,
				sr_in,
				sr_out
		 		);
  
	parameter WIDTH = 64;
	parameter STAGES = 16;
	input clk, rst_n, shift;

	input [WIDTH-1:0] sr_in;
	output [WIDTH-1:0] sr_out;
	//output [7:0] sr_tap_one, sr_tap_two, sr_tap_three, sr_out;

	reg [WIDTH-1:0] sr [STAGES-1:0];
	integer n;

	// initialize
        initial begin
	    for (n = 0; n<STAGES; n = n+1)
	    begin
		    sr[n] <= 0;
	    end 
	end

 	always@(posedge clk)
	begin
	  //if(!rst_n) begin

	  //  for (n = 0; n<STAGES; n = n+1)
	  //  begin
	  //          sr[n] <= 0;
	  //  end 

	  //end else begin
		if (shift == 1'b1)
		//if (1'b1)
		begin
			for (n = STAGES-1; n>0; n = n-1)
			begin
				sr[n] <= sr[n-1];
			end 

			sr[0] <= sr_in;
		end 
	    //end
	end 
	
	assign sr_out = sr[STAGES-1];

endmodule

// Copyright (c) 2000-2009 Bluespec, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// $Revision: 24080 $
// $Date: 2011-05-18 19:32:52 +0000 (Wed, 18 May 2011) $

`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif


// Sized fifo.  Model has output register which improves timing
module SizedFIFO(CLK, RST_N, D_IN, ENQ, FULL_N, D_OUT, DEQ, EMPTY_N, CLR);
   parameter               p1width = 1; // data width
   parameter               p2depth = 3;
   parameter               p3cntr_width = 1; // log(p2depth-1)
   // The -1 is allowed since this model has a fast output register
   parameter               guarded = 1;
   localparam              p2depth2 = p2depth -2 ;

   input                   CLK;
   input                   RST_N;
   input                   CLR;
   input [p1width - 1 : 0] D_IN;
   input                   ENQ;
   input                   DEQ;

   output                  FULL_N;
   output                  EMPTY_N;
   output [p1width - 1 : 0] D_OUT;

   reg                      not_ring_full;
   reg                      ring_empty;

   reg [p3cntr_width-1 : 0] head;
   wire [p3cntr_width-1 : 0] next_head;

   reg [p3cntr_width-1 : 0]  tail;
   wire [p3cntr_width-1 : 0] next_tail;

   // if the depth is too small, don't create an ill-sized array;
   // instead, make a 1-sized array and let the initial block report an error
   reg [p1width - 1 : 0]     arr[0: ((p2depth >= 2) ? (p2depth2) : 0)];

   reg [p1width - 1 : 0]     D_OUT;
   reg                       hasodata;

   wire [p3cntr_width-1:0]   depthLess2 = p2depth2[p3cntr_width-1:0] ;

   wire [p3cntr_width-1 : 0] incr_tail;
   wire [p3cntr_width-1 : 0] incr_head;

   assign                    incr_tail = tail + 1'b1 ;
   assign                    incr_head = head + 1'b1 ;

   assign    next_head = (head == depthLess2 ) ? {p3cntr_width{1'b0}} : incr_head ;
   assign    next_tail = (tail == depthLess2 ) ? {p3cntr_width{1'b0}} : incr_tail ;

   assign    EMPTY_N = hasodata;
   assign    FULL_N  = not_ring_full;

`ifdef BSV_NO_INITIAL_BLOCKS
`else // not BSV_NO_INITIAL_BLOCKS
   // synopsys translate_off
   initial
     begin : initial_block
        integer   i;
        D_OUT         = {((p1width + 1)/2){2'b10}} ;

        ring_empty    = 1'b1;
        not_ring_full = 1'b1;
        hasodata      = 1'b0;
        head          = {p3cntr_width {1'b0}} ;
        tail          = {p3cntr_width {1'b0}} ;

        for (i = 0; i <= p2depth2 && p2depth > 2; i = i + 1)
          begin
             arr[i]   = D_OUT ;
          end
     end
   // synopsys translate_on
`endif // BSV_NO_INITIAL_BLOCKS

   always @(posedge CLK /* or negedge RST_N */ )
     begin
        if (!RST_N)
          begin
             head <= `BSV_ASSIGNMENT_DELAY {p3cntr_width {1'b0}} ;
             tail <= `BSV_ASSIGNMENT_DELAY {p3cntr_width {1'b0}} ;
             ring_empty <= `BSV_ASSIGNMENT_DELAY 1'b1;
             not_ring_full <= `BSV_ASSIGNMENT_DELAY 1'b1;
             hasodata <= `BSV_ASSIGNMENT_DELAY 1'b0;

             // Following section initializes the data registers which
             // may be desired only in some situations.
             // Uncomment to initialize array
             /*
             D_OUT    <= `BSV_ASSIGNMENT_DELAY {p1width {1'b0}} ;
             for (i = 0; i <= p2depth2 && p2depth > 2; i = i + 1)
               begin
                   arr[i]  <= `BSV_ASSIGNMENT_DELAY {p1width {1'b0}} ;
               end
              */
          end // if (RST_N == 0)
        else
         begin

	    // Update arr[tail] once, since some FPGA synthesis tools are unable
            // to infer good RAM placement when there are multiple separate
	    // writes of arr[tail] <= D_IN
            if (!CLR && ENQ && ((DEQ && !ring_empty) || (!DEQ && hasodata && not_ring_full)))
              begin
                 arr[tail] <= `BSV_ASSIGNMENT_DELAY D_IN;
              end

            if (CLR)
              begin
                 head <= `BSV_ASSIGNMENT_DELAY {p3cntr_width {1'b0}} ;
                 tail <= `BSV_ASSIGNMENT_DELAY {p3cntr_width {1'b0}} ;
                 ring_empty <= `BSV_ASSIGNMENT_DELAY 1'b1;
                 not_ring_full <= `BSV_ASSIGNMENT_DELAY 1'b1;
                 hasodata <= `BSV_ASSIGNMENT_DELAY 1'b0;
              end // if (CLR)

            else if (DEQ && ENQ )
              begin
                 if (ring_empty)
                   begin
                      D_OUT <= `BSV_ASSIGNMENT_DELAY D_IN;
                   end
                 else
                   begin
                      // moved into combined write above
		      // arr[tail] <= `BSV_ASSIGNMENT_DELAY D_IN;
                      tail <= `BSV_ASSIGNMENT_DELAY next_tail;
                      D_OUT <= `BSV_ASSIGNMENT_DELAY arr[head];
                      head <= `BSV_ASSIGNMENT_DELAY next_head;
                   end
              end // if (DEQ && ENQ )

            else if ( DEQ )
              begin
                 if (ring_empty)
                   begin
                      hasodata <= `BSV_ASSIGNMENT_DELAY 1'b0;
                   end
                 else
                   begin
                      D_OUT <= `BSV_ASSIGNMENT_DELAY arr[head];
                      head <= `BSV_ASSIGNMENT_DELAY next_head;
                      not_ring_full <= `BSV_ASSIGNMENT_DELAY 1'b1;
                      ring_empty <= `BSV_ASSIGNMENT_DELAY next_head == tail ;
                   end
              end // if ( DEQ )

            else if (ENQ)
              begin
                 if (! hasodata)
                   begin
                      D_OUT <= `BSV_ASSIGNMENT_DELAY D_IN;
                      hasodata <= `BSV_ASSIGNMENT_DELAY 1'b1;
                   end
                 else if ( not_ring_full ) // Drop this test to save redundant test
                   // but be warnned that with test fifo overflow causes loss of new data
                   // while without test fifo drops all but head entry! (pointer overflow)
                   begin
                      // moved into combined write above
                      // arr[tail] <= `BSV_ASSIGNMENT_DELAY D_IN; // drop the old element
                      tail <= `BSV_ASSIGNMENT_DELAY next_tail;
                      ring_empty <= `BSV_ASSIGNMENT_DELAY 1'b0;
                      not_ring_full <= `BSV_ASSIGNMENT_DELAY ! (next_tail == head) ;
                   end
              end // if (ENQ)
         end // else: !if(RST_N == 0)

     end // always @ (posedge CLK)

   // synopsys translate_off
   always@(posedge CLK)
     begin: error_checks
        reg deqerror, enqerror ;

        deqerror =  0;
        enqerror = 0;
        if ( RST_N )
           begin
              if ( ! EMPTY_N && DEQ )
                begin
                   deqerror = 1 ;
                   $display( "Warning: SizedFIFO: %m -- Dequeuing from empty fifo" ) ;
                end
              if ( ! FULL_N && ENQ && (!DEQ || guarded) )
                begin
                   enqerror =  1 ;
                   $display( "Warning: SizedFIFO: %m -- Enqueuing to a full fifo" ) ;
                end
           end
     end // block: error_checks
   // synopsys translate_on

   // synopsys translate_off
   // Some assertions about parameter values
   initial
     begin : parameter_assertions
        integer ok ;
        ok = 1 ;

        if ( p2depth <= 2 )
          begin
             ok = 0;
             $display ( "ERROR SizedFIFO.v: depth parameter must be greater than 2" ) ;
          end

        if ( p3cntr_width <= 0 )
          begin
             ok = 0;
             $display ( "ERROR SizedFIFO.v: width parameter must be greater than 0" ) ;
          end

        if ( ok == 0 ) $finish ;

      end // initial begin
   // synopsys translate_on

endmodule
`define clogb2(x) (\
	x <= 1 ? 0: \
	x <= 2 ? 1: \
	x <= 4 ? 2: \
	x <= 8 ? 3: \
	x <= 16 ? 4: \
	x <= 32 ? 5: \
	x <= 64 ? 6: \
	x <= 128 ? 7: \
	x <= 256 ? 8 : \
	x <= 512 ? 9 : \
	x <= 1024 ? 10 : \
	x <= 2048 ? 11 : \
	x <= 4096 ? 12 : \
	x <= 8192 ? 13 : \
	x <= 16384 ? 14 : -1)  

module XbarArbiter(CLK, RST_N, raises, grant, valid);

    parameter N=4;

    input CLK;
    input RST_N;
    input [N-1:0] raises;
    output reg [N-1:0] grant;
    output reg valid;

    function [1:0] gen_grant_carry;
	input c, r, p;
	begin
	    gen_grant_carry[1] = ~r & (c | p);
	    gen_grant_carry[0] = r & (c | p);
	end
    endfunction

    reg [N-1:0] token;
    reg [N-1:0] granted_A;
    reg [N-1:0] granted_B;
    reg carry;
    reg [1:0] gc;

    integer i;


    always@(*) begin
	valid = 1'b0;
	grant = 0;
	carry = 0;
	granted_A = 0;
	granted_B = 0;

	// Arbiter 1
	for(i=0; i < N; i=i+1) begin
	    gc = gen_grant_carry(carry, raises[i], token[i]);
	    granted_A[i] = gc[0];
	    carry = gc[1];
	end

        // Arbiter 2 (uses the carry from Arbiter 1)
	for(i=0; i < N; i=i+1) begin
	    gc = gen_grant_carry(carry, raises[i], token[i]);
	    granted_B[i] = gc[0];
	    carry = gc[1];
	end

	for(i=0; i < N; i=i+1) begin
	    if(granted_A[i] | granted_B[i]) begin
		grant = 0;
		grant[i] = 1'b1;
		valid = 1'b1;
	    end
	end
    end

    always@(posedge CLK) begin
	if(RST_N) token <= {token[N-2:0], token[N-1]};
	else token <= 1;
    end

endmodule


module Xbar(CLK, RST_N,
	    i_valid,
	    i_prio,
	    i_tail,
	    i_dst,
	    i_vc,
	    i_data, 

	    o_valid,
	    o_prio,
	    o_tail,
	    o_dst,
	    o_vc,
	    o_data, 

 	    i_cred,
	    i_cred_valid,

	    o_cred_en
	    );

    parameter N		    = 16;
    parameter NUM_VCS	    = 2;
    parameter CUT	    = 2;
    parameter DATA	    = 32;
    parameter BUFFER_DEPTH  = 16;

    parameter LOG_N	    = `clogb2(N);
    parameter VC	    = `clogb2(NUM_VCS); 
    parameter DST	    = `clogb2(N);
    parameter FLIT_WIDTH    = 1+1+DST+VC+DATA;
    parameter CRED_WIDTH    = `clogb2(BUFFER_DEPTH) + 1;

    input CLK, RST_N;

    // Input ports
    input [N-1:0]              i_valid;
    input [N-1:0]              i_prio; 
    input [N-1:0]              i_tail;
    input [N*DST-1:0]          i_dst; 
    input [N*VC-1:0]           i_vc;
    input [N*DATA-1:0]         i_data;

    wire [VC-1:0]              i_vc_arr [N-1:0];

    // Input queue front ports
    wire [N-1:0]               f_prio;
    wire [N-1:0]               f_tail;
    wire [DST-1:0]             f_dst [N-1:0];
    wire [VC-1:0]              f_vc [N-1:0];
    wire [DATA-1:0]            f_data [N-1:0];
    wire [N-1:0]               f_elig;

    // Needed to play friendly with Icarus Verilog and Modelsim
    wire [DST*N-1:0]	       f_dst_flat;
    wire [VC*N-1:0]            f_vc_flat;
    wire [DATA*N-1:0]          f_data_flat;

    // Output ports
    output reg [N-1:0]         o_valid;
    output reg [N-1:0]         o_prio;
    output reg [N-1:0]         o_tail;
    output [N*DST-1:0]         o_dst;
    output [N*VC-1:0]          o_vc;
    output [N*DATA-1:0]        o_data;

    reg [DST-1:0]              o_dst_arr [N-1:0];
    reg [VC-1:0]               o_vc_arr [N-1:0];
    reg [DATA-1:0]             o_data_arr [N-1:0];

    // Input credit 
    output [N*VC-1:0]          i_cred; // just remembers the VC of 1st packet that arrives
    output reg [N-1:0]         i_cred_valid; // maybe bit
    reg [VC-1:0]               i_cred_arr [N-1:0];
 
    // Output credit
    input [N-1:0]              o_cred_en;

    // Dequeue wires
    wire [N-1:0]               grants [N-1:0];
    wire [N-1:0]               grant_valids;
    reg [N-1:0]                deq_en;

    reg [CRED_WIDTH-1:0]       creds_left [N-1:0];

    genvar i, o, k;
    integer in,out;

    generate
	for(o=0; o < N; o=o+1) begin: arbiters
	    wire [N-1:0] raises;

	    for(k=0; k < N; k=k+1) begin: raisewires
		assign raises[k] = (f_dst[k] == o) && f_elig[k];
	    end

	    XbarArbiter#(.N(N)) arbiter(.CLK(CLK), 
					.RST_N(RST_N),
					.raises(raises),
					.valid(grant_valids[o]),
					.grant(grants[o])); // [(o+1)*LOG_N-1:o*LOG_N]));

	    
	     
	end
    endgenerate


    /*
    // Stats 
    always@(negedge CLK) begin
	if(RST_N) begin
	    for(in=0; in < N; in=in+1) begin
		if(f_elig[in])
		    $display("strace time=%0d component=noc inst=0 evt=raises val=1", $time);

		if(deq_en[in] != 0) 
		    $display("strace time=%0d component=noc inst=0 evt=grants val=1", $time);
		    //$display("strace time=%0d component=noc inst=0 evt=full val=1", $time);
	    end
	end
    end 
    */

    // Record the input VC
    always@(posedge CLK) begin
	if(RST_N) begin
	    for(in=0; in < N; in=in+1) begin
		if(i_valid[in])
		    i_cred_arr[in] <= i_vc_arr[in];
	    end
	end
	else begin
	    for(in=0; in < N; in=in+1) begin
		i_cred_arr[in]<='hx;
	    end
	end
    end

    for(i=0; i < N; i=i+1) begin: assign_arr
	assign i_vc_arr[i] = i_vc[(i+1)*VC-1:i*VC];
        assign i_cred[(i+1)*VC-1:i*VC] = i_cred_arr[i];
        assign o_dst[(i+1)*DST-1:i*DST] = o_dst_arr[i];
	assign o_vc[(i+1)*VC-1:i*VC] = o_vc_arr[i];
	assign o_data[(i+1)*DATA-1:i*DATA] = o_data_arr[i]; 
    end

    // Enable deq 
    always@(*) begin
	for(in=0; in < N; in=in+1) begin: deqwires
	    deq_en[in] = 1'b0;
	    i_cred_valid[in] = 1'b0;

	    for(out=0; out < N; out=out+1) begin: outer
		if(grant_valids[out] && (grants[out][in] == 1'b1) && (creds_left[out] != 0)) begin
		    deq_en[in] = 1'b1;
		    i_cred_valid[in] = 1'b1;
		end
	    end
	end
    end

    // Needed to play friendly with Icarus Verilog
    for(i=0; i < N; i=i+1) begin
	assign f_dst_flat[(i+1)*DST-1:i*DST] = f_dst[i];
	assign f_vc_flat[(i+1)*VC-1:i*VC] = f_vc[i];
	assign f_data_flat[(i+1)*DATA-1:i*DATA] = f_data[i];
    end

    // Muxbar
    for(i=0; i < N; i=i+1) begin: steerwires
	always@(grant_valids[i] or grants[i] or creds_left[i] or f_prio or f_tail or f_dst_flat or f_vc_flat or f_data_flat) begin
	    o_valid[i] = 1'b0;
	    o_prio[i] = 'hx;
	    o_tail[i] = 'hx;
	    o_dst_arr[i] = 'hx;
	    o_vc_arr[i] = 'hx;
	    o_data_arr[i] = 'hx;

	    for(in=0; in < N; in=in+1) begin: innersteer
		if(grant_valids[i] && (grants[i][in] == 1'b1) && (creds_left[i] != 0)) begin
		    o_valid[i] = 1'b1;
		    o_prio[i] = f_prio[in];
		    o_tail[i] = f_tail[in];
		    o_dst_arr[i]  = f_dst[in];
		    o_vc_arr[i]   = f_vc[in];
		    o_data_arr[i] = f_data[in];
		end
	    end
	end
    end
     

    /*
    // Muxbar
    always@(*) begin
	for(out=0; out < N; out=out+1) begin: steerwires
	    o_valid[out] = 1'b0;
	    o_prio[out] = 'hx;
	    o_tail[out] = 'hx;
	    o_dst_arr[out] = 'hx;
	    o_vc_arr[out] = 'hx;
	    o_data_arr[out] = 'hx;

	    for(in=0; in < N; in=in+1) begin: innersteer
		if(grant_valids[out] && (grants[out][in] == 1'b1) && (creds_left[out] != 0)) begin
		    o_valid[out] = 1'b1;
		    o_prio[out] = f_prio[in];
		    o_tail[out] = f_tail[in];
		    o_dst_arr[out]  = f_dst[in];
		    o_vc_arr[out]   = f_vc[in];
		    o_data_arr[out] = f_data[in];
		end
	    end
	end
    end
    */

    // Transmit credits
    for(o=0; o < N; o=o+1) begin: output_credits
	always@(posedge CLK) begin
	    if(RST_N) begin
		if((o_cred_en[o] == 1'b0) && (o_valid[o] == 1'b1))
		    creds_left[o] <= creds_left[o] - 1;
		else if((o_cred_en[o] == 1'b1) && (o_valid[o] == 1'b0))
		    creds_left[o] <= creds_left[o] + 1;
	    end
	    else begin
		creds_left[o] <= BUFFER_DEPTH;
	    end
	end
    end

    /////////////////////////
    // Input Queues
    /////////////////////////
    
    generate
	for(i=0; i < N; i=i+1) begin: ififos
/*
	    SizedFIFO#(.p1width(FLIT_WIDTH), .p2depth(BUFFER_DEPTH), .p3cntr_width(`clogb2(BUFFER_DEPTH))) inQ
		       (.CLK(CLK), 
			.RST_N(RST_N), 
			.D_IN({i_prio[i], i_tail[i], i_dst[(i+1)*DST-1:i*DST], i_vc[(i+1)*VC-1:i*VC], i_data[(i+1)*DATA-1:i*DATA]}),
			.ENQ(i_valid[i]),
			.D_OUT({f_prio[i], f_tail[i], f_dst[i], f_vc[i], f_data[i]}),
			.DEQ(deq_en[i]),
			.EMPTY_N(f_elig[i]),
			.FULL_N(), // unused
			.CLR(1'b0) // unused
		      );
*/
	    mkNetworkXbarQ inQ(.CLK(CLK), .RST_N(RST_N),
                      	   .enq_sendData({i_prio[i], i_tail[i], i_dst[(i+1)*DST-1:i*DST], i_vc[(i+1)*VC-1:i*VC], i_data[(i+1)*DATA-1:i*DATA]}),
                           .EN_enq(i_valid[i]),
                      	   .RDY_enq(),
                           .EN_deq(deq_en[i]),
                           .RDY_deq(),
                           .first({f_prio[i], f_tail[i], f_dst[i], f_vc[i], f_data[i]}),
                           .RDY_first(),
                           .notFull(),
                           .RDY_notFull(),
                           .notEmpty(f_elig[i]),
                           .RDY_notEmpty(),
                           .count(),
                           .RDY_count(),
                           .EN_clear(1'b0),
                           .RDY_clear());

	end
    endgenerate

endmodule
