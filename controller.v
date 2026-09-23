// File: controller.v
// Author: Diego Dominguez
// Module hierarchy: RTL control path / FSM for Booth multiplier
// Version history:
//  v1.0 - 2026-09-21 - Initial course-based controller
//  v1.1 - 2026-09-21 - Latch-free FSM and architecture cleanup
//
// Description:
// This is the enhanced, 100% synthesizable control path derived from the
// NPTEL Booth multiplier course. The logic keeps the original state flow,
// but it is cleaner and safer for synthesis. This version is superior to
// the original because the combinational logic assigns default values at the
// start of the block, preventing latches, and all state transitions use
// non-blocking assignments in the registered FSM.
//
// Critical design notes:
// - The FSM is updated only on the rising edge of clk.
// - The output control signals are assigned with default values to avoid
//   latch inference.
// - No artificial delays or race-prone assignments are used.

module controller (ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff,
                  addsub, start, decr, ldcnt, done, clk, q0, qm1, eqz);
  input clk, q0, qm1, start, eqz;
  output reg ldA, clrA, sftA, ldQ, clrQ, sftQ, ldM, clrff, addsub;
  output reg decr, ldcnt, done;

  reg [3:0] state = 4'b0000;
  reg [3:0] new_state = 4'b0000;

  parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0011;
  parameter S3 = 4'b0010, S4 = 4'b0110, S5 = 4'b0111;
  parameter S6 = 4'b0101, S7 = 4'b0100, S8 = 4'b1100;

  always @(posedge clk)
    state <= new_state;

  always @(*)
    begin
      // Default outputs are assigned first to prevent latch inference.
      clrA = 1'b0; ldA = 1'b0; sftA = 1'b0; clrQ = 1'b0;
      ldQ = 1'b0; sftQ = 1'b0; ldM = 1'b0; clrff = 1'b0;
      addsub = 1'b0; decr = 1'b0; ldcnt = 1'b0; done = 1'b0;
      new_state = S0;

      case (state)
        S0: begin
          clrff = 1'b1;
          if (start)
            new_state = S1;
          else
            new_state = S0;
        end

        S1: new_state = S2;

        S2: new_state = S3;

        S3: begin
          case ({q0, qm1})
            2'b01: new_state = S4;
            2'b10: new_state = S5;
            2'b11: new_state = S6;
            2'b00: new_state = S6;
            default: new_state = S3;
          endcase
        end

        S4: new_state = S6;

        S5: new_state = S6;

        S6: new_state = S7;

        S7: begin
          case ({q0, qm1, eqz})
            3'b010: new_state = S4;
            3'b100: new_state = S5;
            3'b110: new_state = S6;
            3'b000: new_state = S6;
            default: new_state = S8;
          endcase
        end

        S8: new_state = S0;

        default: new_state = S0;
      endcase

      case (state)
        S0: begin
          clrff = 1'b1;
        end

        S1: begin
          clrA = 1'b1;
          clrff = 1'b0;
          ldcnt = 1'b1;
          ldM = 1'b1;
        end

        S2: begin
          clrA = 1'b0;
          clrff = 1'b1;
          ldcnt = 1'b0;
          ldM = 1'b0;
          ldQ = 1'b1;
        end

        S3: begin
          clrA = 1'b0;
          clrff = 1'b0;
          ldcnt = 1'b0;
          ldM = 1'b0;
          ldQ = 1'b0;
        end

        S4: begin
          ldA = 1'b1;
          addsub = 1'b1;
        end

        S5: begin
          ldA = 1'b1;
          addsub = 1'b0;
        end

        S6: begin
          sftA = 1'b1;
          sftQ = 1'b1;
          decr = 1'b1;
        end

        S7: begin
          sftA = 1'b0;
          sftQ = 1'b0;
          decr = 1'b0;
        end

        S8: begin
          done = 1'b1;
        end

        default: begin
          clrA = 1'b0; ldA = 1'b0; sftA = 1'b0; clrQ = 1'b0;
          ldQ = 1'b0; sftQ = 1'b0; ldM = 1'b0; clrff = 1'b0;
          addsub = 1'b0; decr = 1'b0; ldcnt = 1'b0; done = 1'b0;
        end
      endcase
    end

endmodule