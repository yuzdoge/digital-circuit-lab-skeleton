/* verilator lint_off UNUSED */ 
`timescale 1ns / 1ns
module cpu_top #(
	parameter DWIDTH = 16,
	parameter AWIDTH = 12
)( input clk, rst_n, input en_in
);
    wire en_ram_in, en_ram_out;
    wire [DWIDTH - 1 : 0] addr, ins;
    
    cpu cpu_i (
		.clk(clk),
		.rst_n(rst_n),
		.en_in(en_in),
		.en_ram_out(en_ram_out),
		.ins(ins),
		.en_ram_in(en_ram_in),
		.addr(addr)
    );
	
	irom irom_i (
		// input
		.clk   (clk),
		.rst_n (rst_n),
		.addr  (addr[AWIDTH - 1 : 0]),
		.ready (en_ram_in),
		// output
		.dout  (ins),
		.valid (en_ram_out)
	);
endmodule
