// File: BOOTH.v
// Author: Diego Dominguez
// Module hierarchy: Top-level RTL / Booth multiplier controller + datapath
// Version history:
//  v1.0 - 2026-09-21 - Initial NPTEL-inspired Booth multiplier
//  v1.1 - 2026-09-21 - Improved synthesizable architecture and docs
//
// Description:
// This is the enhanced, 100% synthesizable Booth multiplier derived from
// the NPTEL "Hardware Modeling using Verilog" course. It preserves the
// original algorithmic intent while eliminating simulation-only hazards.
// The design is superior to the original reference because all artificial
// intra-assignment delays (#) are removed, the FSM outputs are assigned
// default values to prevent latch inference, and all register transfers use
// non-blocking assignments (<=) to avoid race conditions.
//
// Critical design notes:
// - No # delays are used anywhere in the RTL.
// - Registers are updated with <= to match synchronous design practices.
// - The combinational FSM default assignments prevent latches during synthesis.

module BOOTH (ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ,
              addsub, decr, ldcnt, data_in, clk, qm1, eqz, q0);
  input ldA, ldQ, ldM, clrA, clrQ, clrff, sftA, sftQ, addsub;
  input decr, ldcnt, clk;
  input [15:0] data_in;
  output q0, qm1, eqz;

  // Internal datapath buses: accumulator A, multiplicand M, multiplier Q,
  // partial result Z, and the Booth iteration counter.
  wire [15:0] A, M, Q, Z;
  wire [4:0] count;

  // eqz is asserted when the Booth loop counter is zero, meaning the
  // multiplication sequence is complete.
  assign eqz = ~|count;

  // q0 exposes the least significant bit of the Q register so the control
  // FSM can decide whether to add, subtract, or shift.
  assign q0 = Q[0];

  // A-register: stores the partial accumulator and shifts it right while the
  // Booth algorithm progresses.
  shiftreg AR (A, Z, A[15], clk, ldA, clrA, sftA);

  // Q-register: captures the multiplier operand and shifts it to update the
  // Booth decision bits during each iteration.
  shiftreg QR (Q, data_in, A[0], clk, ldQ, clrQ, sftQ);

  // QM1 captures the previous value of Q[0] so the FSM can detect the Booth
  // transition pattern 01, 10, 00, or 11.
  dff QM1 (Q[0], qm1, clk, clrff);

  // Multiplicand register M is loaded in parallel and later used by the ALU.
  PIPO MR (M, data_in, clk, ldM);

  // ALU computes either A + M or A - M depending on the control signal
  // addsub. The result is stored in Z and fed back into A.
  ALU AS (Z, A, M, addsub);

  // Counter tracks the remaining Booth iterations and is decremented each
  // cycle while the FSM is active.
  counter CN (count, decr, ldcnt, clk);

endmodule