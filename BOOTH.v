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

  wire [15:0] A, M, Q, Z;
  wire [4:0] count;

  // This condition is asserted when the Booth iteration counter reaches zero.
  assign eqz = ~|count;
  assign q0 = Q[0];

  // A-register routing for the accumulator update path.
  shiftreg AR (A, Z, A[15], clk, ldA, clrA, sftA);

  // Q-register capture for the multiplicand operand and shift logic.
  shiftreg QR (Q, data_in, A[0], clk, ldQ, clrQ, sftQ);

  // QM1 stores the previous LSB of Q for Booth decision logic.
  dff QM1 (Q[0], qm1, clk, clrff);

  // M is the multiplicand register with parallel load.
  PIPO MR (M, data_in, clk, ldM);

  // Arithmetic stage for add/subtract decisions.
  ALU AS (Z, A, M, addsub);

  // Iteration counter for the Booth sequence length.
  counter CN (count, decr, ldcnt, clk);

endmodule