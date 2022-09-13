`timescale 1 ns / 1 ns
module ir #(
	parameter DWIDTH = 16
)(
	input clk, rst_n, en_in,
	input [DWIDTH - 1 : 0] ins,
	output reg [DWIDTH - 1 : 0] ir_out,
	output reg en_out
);

	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ir_out <= {(DWIDTH){1'b0}};
			en_out <= 1'b1;
		end
		else begin
			if(en_in) begin
				en_out <= 1'b1;
				ir_out <= ins;
			end
			else en_out <= 1'b0;
		end
	end
endmodule


