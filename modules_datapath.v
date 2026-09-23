// File: modules_datapath.v
// Author: Diego Dominguez
// Module hierarchy: RTL datapath / Booth arithmetic register bank
// Version history:
//  v1.0 - 2026-09-21 - Initial datapath blocks from NPTEL example
//  v1.1 - 2026-09-21 - Clean architecture and register-safe coding
//
// Description:
// This file contains the datapath primitives for the Booth multiplier. The
// register bank includes the A and Q shift registers, the QM1 bit, the M
// PIPO register, the ALU, and the loop counter. This implementation stays
// close to the original algorithm while removing simulation hazards and
// preserving synthesizable, race-free register behavior.
//
// Critical design notes:
// - Every register uses <= assignments in synchronous logic.
// - The datapath remains free of artificial delay primitives.
// - The ALU remains a pure combinational block with explicit default behavior.

module shiftreg (data_out, data_in, s_in, clk, ld, clr, sft);
  input s_in, clk, ld, clr, sft;
  input [15:0] data_in;
  output reg [15:0] data_out;

  always @(posedge clk)
    begin
      if (clr)
        data_out <= 16'b0000000000000000;
      else if (ld)
        data_out <= data_in;
      else if (sft)
        data_out <= {s_in, data_out[15:1]};
    end
endmodule

module PIPO (data_out, data_in, clk, load);
  input [15:0] data_in;
  input load, clk;
  output reg [15:0] data_out;

  always @(posedge clk)
    if (load)
      data_out <= data_in;
endmodule

module dff (d, q, clk, clr);
  input d, clk, clr;
  output reg q;

  always @(posedge clk)
    if (clr)
      q <= 1'b0;
    else
      q <= d;
endmodule


module ALU (out, in1, in2, addsub);
  input [15:0] in1, in2;
  input addsub;
  output reg [15:0] out;

  always @(*)
    begin
      if (addsub == 1'b0)
        out = in1 - in2;
      else
        out = in1 + in2;
    end
endmodule



module counter (data_out, decr, ldcnt, clk);
  input decr, clk, ldcnt;
  output reg [4:0] data_out = 5'b10000;

  always @(posedge clk)
    begin
      if (ldcnt)
        data_out <= 5'b10000;
      else if (decr)
        data_out <= data_out - 1;
    end
endmodule