`timescale 1 ns / 1 ns
`include "alufunc.vh"

module alu #(
	parameter DWIDTH = 16
)(
	input clk, rst_n, en_in,
	input  [2 : 0] alu_func,
	input  [DWIDTH - 1 : 0] alu_a, alu_b,
	output reg [DWIDTH - 1 : 0] alu_out,
	output reg en_out
);
	localparam defaultval = {(DWIDTH){1'b0}};

	always @(negedge rst_n or posedge clk) begin
		if(rst_n ==1'b0) begin
			alu_out <= defaultval;
			en_out  <= 1'b0;
		end
		else if (en_in == 1'b1) begin
			en_out  <= 1'b1;
			case (alu_func)
				`ALU_ADD:  alu_out <= alu_a + alu_b;
				default:   alu_out <= defaultval;
			endcase
		end
		else begin
			en_out <= 1'b0;
		end
	end
endmodule
