module test(i_clk, i_reset, ref_clk);
input i_clk;
input i_reset;
/* verilator lint_off UNUSED */
input ref_clk;

reg [3:0] a;

always @(posedge i_clk) begin
	if(i_reset)
		a <= 0;
	else
		a <= a+1;
end

endmodule
