// File: testbench.v
// Author: Diego Dominguez
// Module hierarchy: Verification / top-level Booth multiplier testbench
// Version history:
//  v1.0 - 2026-09-21 - Initial NPTEL-style verification harness
//  v1.1 - 2026-09-21 - Fix signal naming and documentation
//
// Description:
// This testbench instantiates the Booth multiplier datapath and control
// path together and drives a signed multiplication sequence. It validates the
// synchronised behaviour of the improved RTL while keeping the simulation
// environment lightweight and portable.
//
// Critical design notes:
// - The testbench does not insert artificial delays in the RTL logic.
// - It uses a simple periodic clock and a single start pulse for stimulus.

`timescale 1ns / 1ps
`include "modules_datapath.v"
`include "controller.v"
`include "BOOTH.v"

module testbench;
  reg [15:0] data_in;
  reg start, clk;
  wire done;
  wire ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, addsub;
  wire decr, ldcnt, q0, qm1, eqz;

  controller CONTROL_PATH (ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM,
                          clrff, addsub, start, decr, ldcnt, done,
                          clk, q0, qm1, eqz);

  BOOTH DATAPATH (ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ,
                  addsub, decr, ldcnt, data_in, clk, qm1, eqz, q0);

  initial
    begin
      $monitor($time, "%b %b %b", DATAPATH.A, DATAPATH.Q, done);
      $dumpfile("booth.vcd");
      $dumpvars(0, testbench);
      clk = 1'b0;
      start = 1'b0;
      #1000 $finish;
    end

  initial
    begin
      #2 start = 1'b1;
      data_in = -341;
      #15 start = 1'b0;
      data_in = -91;
    end

  always #5 clk = ~clk;

endmodule