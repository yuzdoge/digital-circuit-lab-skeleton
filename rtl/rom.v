/* verilator lint_off UNDRIVEN */
`timescale 1 ns / 1 ns
module SYNC_ROM #(
	parameter DWIDTH = 16,
	parameter AWIDTH = 12,
	parameter DEPTH  = 1 << AWIDTH
)(
	input clk,
	input en,
	input [AWIDTH - 1 : 0] addr,
	output reg [DWIDTH - 1 : 0] dout
);

	reg [DWIDTH - 1 : 0] mem[0 : DEPTH - 1];

/*
	initial begin
		mem[0] = 16'b0000_0000_0000_0100; //mov r0 #4, R[x0] = 4;
		mem[1] = 16'b0011_0100_0000_0000; //add r1 r0, R[x1] += R[x0];
		mem[2] = 16'b0011_1001_0000_0000; //add r2 r1, R[x2] += R[x1]; 
		mem[3] = 16'b1010_0000_0000_0000; //jump #0
	end
*/
// If not give a input(driven) to mem or initialize it, the verilator will 
// rise a undriven warning. But doesn't matter here, so we turn off this warning.


	always @(posedge clk) begin
		if (en) begin 
			dout <= mem[addr];		
		end
	end

endmodule
