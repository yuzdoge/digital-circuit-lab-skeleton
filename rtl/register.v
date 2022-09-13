`timescale 1 ns / 1 ns
// Asynchronous reset flip-flop with enable signal
module ASYNCR_EN_REG #(
	parameter WIDTH = 1,
	parameter INIT  = 0
)(
	input clk, rst_n, en,
	input      [WIDTH - 1 : 0] d, 
	output reg [WIDTH - 1 : 0] q
);
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			q <= INIT;
		end 
		else begin
			if (en) begin
				q <= d;
			end
		end
	end
endmodule
