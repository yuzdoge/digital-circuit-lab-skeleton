`timescale 1 ns / 1 ns
module irom #(
	parameter DWIDTH = 16,
	parameter AWIDTH = 12,
	parameter DEPTH  = 1 << AWIDTH
)(
	input clk, rst_n,
	input [AWIDTH - 1 : 0] addr,

	input ready, 
	output [DWIDTH - 1 : 0] dout,
	output valid
); 

	
	wire reg_din = ready ? 1'b1 : 1'b0;

	ASYNCR_EN_REG reg_i (
		// input
		.clk (clk),
		.rst_n (rst_n),
		.en  (1'b1),
		.d   (reg_din),
		// output
		.q    (valid)
	);

	SYNC_ROM #(
		.DWIDTH (DWIDTH),
		.AWIDTH (AWIDTH),
		.DEPTH  (DEPTH)
	) sync_rom_i (
		// input
		.clk  (clk),
		.en   (ready),
		.addr (addr),
		// output
		.dout (dout)
	);


endmodule
