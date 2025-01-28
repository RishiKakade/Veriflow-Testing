// 4-bit Counter Module
module counter_4bit (
    input wire clk,        // Clock signal
    input wire rst,        // Reset signal (active high)
    input wire en,         // Enable signal (active high)
    output reg [3:0] count // 4-bit counter output
);

    // Counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the counter to 0
            count <= 4'b0000;
        end else if (en) begin
            // Increment the counter if enabled
            count <= count + 4'b0001;
        end
    end

endmodule
