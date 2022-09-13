`timescale 1 ns / 1 ns
module reg_group #(
	parameter DWIDTH = 16
)(
	input clk, rst_n, en_in,
    input [3 : 0]  reg_en,
    input [1 : 0]  rd, rs,
    input [DWIDTH - 1 : 0] d_in,
    output reg [DWIDTH - 1 : 0] rd_q, rs_q,
    output reg en_out
);
	localparam defaultval = {(DWIDTH){1'b0}};

    wire[DWIDTH - 1 : 0] q0, q1, q2, q3;

    ASYNCR_EN_REG #(
		.WIDTH(DWIDTH)
	) x0 (
		.clk(clk),
        .rst_n(rst_n),
        .en (reg_en[0]),
		.d  (d_in),
		.q  (q0)
    );

	ASYNCR_EN_REG #(
		.WIDTH(DWIDTH)
	) x1 (
		.clk(clk),
        .rst_n(rst_n),
        .en (reg_en[1]),
		.d  (d_in),
		.q  (q1)
    );

	ASYNCR_EN_REG #(
		.WIDTH(DWIDTH)
	) x2 (
		.clk(clk),
        .rst_n(rst_n),
        .en (reg_en[2]),
		.d  (d_in),
		.q  (q2)
    );

	ASYNCR_EN_REG #(
		.WIDTH(DWIDTH)
	) x3 (
		.clk(clk),
        .rst_n(rst_n),
        .en (reg_en[3]),
		.d  (d_in),
		.q  (q3)
    );

    always@(posedge clk or negedge rst_n) begin
		if (rst_n == 1'b0) begin
			rd_q <= defaultval;
            rs_q <= defaultval;    
            en_out <= 1'b0; 
        end 
		else if(en_in == 1'b1) begin
            en_out <= 1;
            case({rd[1:0],rs[1:0]})
				4'b0000: begin
					rd_q <= q0;
                    rs_q <= q0;
                end
                4'b0001: begin
                    rd_q <= q0;
                    rs_q <= q1;
                end
                4'b0010: begin
                    rd_q <= q0; 
                    rs_q <= q2; 
                end
                4'b0011: begin      
                    rd_q <= q0;
                    rs_q <= q3;
                end        
                4'b0100: begin      
                    rd_q <= q1;
                    rs_q <= q0;
				end
				4'b0101: begin      
					rd_q <= q1;
					rs_q <= q1;
                end
                4'b0110: begin      
					rd_q <= q1;
					rs_q <= q2;
                end 
                4'b0111: begin      
					rd_q <= q1;
                    rs_q <= q3;
                end 
                4'b1000: begin      
					rd_q <= q2;
					rs_q <= q0;
                end
				4'b1001: begin           
                    rd_q <= q2;     
                    rs_q <= q1;         
                end
                4'b1010: begin
					rd_q <= q2;
                    rs_q <= q2;
                end
                4'b1011: begin
					rd_q <= q2;
                    rs_q <= q3;
                end
                4'b1100: begin
                    rd_q <= q3;
                    rs_q <= q0;
                end              
                4'b1101: begin
                    rd_q <= q3;
                    rs_q <= q1;
                end
                4'b1110: begin
					rd_q <= q3;
                    rs_q <= q2;
                end
                4'b1111: begin
					rd_q <= q3;
                    rs_q <= q3;
                end
                default: begin
                    rd_q <= defaultval;
                    rs_q <= defaultval;
                end
            endcase
		end
		else begin
            en_out <= 1'b0;
		end
	end
endmodule               
                        
