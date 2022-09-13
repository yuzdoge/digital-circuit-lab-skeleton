`timescale 1 ns / 1 ns
module pc #(
	parameter DWIDTH = 16
)(
    input clk, rst_n, en_in,
    input [1 : 0] pc_ctrl,
    input [7 : 0] offset_addr,
    output reg [DWIDTH - 1 : 0] pc_out
);
	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 1'b0) begin
			pc_out <= {(DWIDTH){1'b0}};
        end
		else begin
			if (en_in == 1'b1) begin
				case (pc_ctrl)
					2'b01: pc_out <= pc_out + 1;
                    default: pc_out <= pc_out;
                endcase
            end
        end   
	end
endmodule
