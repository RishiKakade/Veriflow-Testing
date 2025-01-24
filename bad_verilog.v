// bad_verilog.v
// This file contains examples of Verilog code that would likely fail Verible linting.

`timescale 1ns / 1ps

module bad_design (
  input clk,
  input rst_n,
  input [7:0] data_in,
  output reg [7:0] data_out,
  output wire enable
);

  // Non-ANSI port declaration (should be in the port list)
  wire internal_sig;

  // Inconsistent indentation (should be 2 spaces)
 if (rst_n == 0)
    data_out <= 8'h00;
  else begin
    data_out <= data_in;
  end

  // Missing default case in case statement
  always @(posedge clk) begin
    case (data_in[1:0])
      2'b00: data_out <= 8'hAA;
      2'b01: data_out <= 8'hBB;
      // Missing default:
    endcase
  end

  // Unused signal
  wire unused_wire;

  // Implicit net declaration (should be explicit)
  assign implicit_net = data_in[0];

  // Magic number (should be a named constant)
  assign data_out[7] = data_in[7] ^ 1; // 1 should be a parameter

  // Bad identifier names (should be lowercase with underscores)
  wire Bad_Name;
  reg REALLY_BAD_NAME;

    // missing sensitivity list for combinational logic
    always begin
        internal_sig = data_in[2] & data_in[3]; // missing @(*) or @(data_in[2], data_in[3])
    end

    // Non-blocking assignment in combinational logic
    always @(*) begin
        enable <= data_in[4]; // should be blocking =
    end

    //Continuous assignment to a reg type
    assign data_out = internal_sig;

    // Nested comments /* /* Nested */ */ - will produce warnings

    // Line longer than 80 characters
    assign internal_sig = data_in[7] | data_in[6] | data_in[5] | data_in[4] | data_in[3] | data_in[2] | data_in[1] | data_in[0];

endmodule

//Example of a parameter
parameter MY_CONSTANT = 1;

// Example of a macro that should be a localparam
`define MACRO_CONSTANT 5

module another_module (input clk);
    //using the macro
    reg [7:0] counter;
    always @(posedge clk) begin
        counter <= counter + `MACRO_CONSTANT;
    end
endmodule
