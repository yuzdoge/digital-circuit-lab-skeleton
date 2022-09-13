module alu_mux #(
	parameter DWIDTH = 16
)(
	input clk, rst_n, en_in,
	input alu_in_sel,
	input  [DWIDTH - 1 : 0] rd_q, rs_q,
	input  [7 : 0] offset,
	output [DWIDTH - 1 : 0] alu_a,alu_b,
	output en_out
);
	reg [DWIDTH - 1 : 0] alu_a,alu_b;
	reg  en_out;

	always @(negedge rst_n or posedge clk) begin
		if (rst_n ==1'b0) begin
			alu_a <= 16'd0;
			alu_b <= 16'd0;
			en_out  <= 1'b0;
		end		
		else if(en_in == 1'b1) begin
			en_out  <= 1'b1;
			alu_a <= rd_q;
			alu_b <= rs_q;					
		end
		else begin
			en_out  <= 1'b0;
		end
    end
endmodule
