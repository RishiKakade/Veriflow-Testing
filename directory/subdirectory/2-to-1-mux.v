// 2-to-1 Multiplexer Module
module mux_2to1 (
    input wire [3:0] in0,  // Input 0 (4-bit)
    input wire [3:0] in1,  // Input 1 (4-bit)
    input wire sel,        // Select signal (0 for in0, 1 for in1)
    output wire [3:0] out  // Output (4-bit)
);

    // Multiplexer logic
    assign out = (sel) ? in1 : in0;

endmodule
