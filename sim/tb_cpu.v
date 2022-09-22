`timescale 1 ns/1 ns
`include  "../rtl/opcode.vh"

`define IROM(addr) cpu.irom_i.sync_rom_i.mem[addr]

`define REGFILE cpu.cpu_i.data_path_i.reg_group_i

`define X0 2'b00
`define X1 2'b01
`define X2 2'b10
`define X3 2'b11

`define DX0 `REGFILE.q0 
`define DX1 `REGFILE.q1
`define DX2 `REGFILE.q2
`define DX3 `REGFILE.q3

`define DWIDTH 16
`define AWIDTH 12

module tb_cpu();
    parameter Tclk=10;
    reg clk, rst_n, en_in;

	always #Tclk clk=~clk;

	cpu_top cpu(
    .clk  (clk),
    .rst_n(rst_n),
    .en_in(en_in)
    );

	reg  [31 : 0] cycle;
	wire [31 : 0] timeout_cycle = 100;

	reg done;
	reg [31 : 0]  all_tests_passed = 0;
	reg [31 : 0]  current_test_id = 0;
	reg [255 : 0] current_test_type; // 32 bytes 
	reg [31 : 0]  current_output;
	reg [31 : 0]  current_result;

	// Count the number of cycles. 
	always @(posedge clk) begin
		cycle <= (done === 0) ? cycle + 1 : 0;
	end
	
	// Check for timeout
	initial begin
		// `===` is logical equality
		while (all_tests_passed === 0) begin
			@(posedge clk); // wait for the rising edge
			if (cycle === timeout_cycle) begin
				$display("[Falied] Timeout at [%d] test %s, expected_result = %h, got = %h",
						current_test_id, current_test_type, current_result, current_output);
				$finish();
			end
		end
	end

	task reset;
	begin
		@(negedge clk);
		rst_n = 0;
		@(negedge clk);
		rst_n = 1;
	end
	endtask

	function [`DWIDTH - 1 : 0] get_rd;
		input [1 : 0] register;
		begin
			case (register)
				`X0: get_rd = `DX0;
				`X1: get_rd = `DX1;
				`X2: get_rd = `DX2;
				`X3: get_rd = `DX3;
			endcase
		end
	endfunction

	task check_result_rf;
		input [1 : 0]  register;
		input [`DWIDTH - 1  : 0] result;
		input [255 : 0] test_type;

		begin
			done = 0;
			current_test_id   = current_test_id + 1;
			current_test_type = test_type;
			current_result    = result;

			while (get_rd(register) !== result) begin
				current_output = get_rd(register);
				@(posedge clk);
			end
			// finish
			done = 1;
			$display("[%d] Test %s passed!", current_test_id, test_type);
		end
	endtask


	//reg [1 : 0] RS1, RS2; // register
	//reg [`DWIDTH - 1 : 0] RD1, RD2; // register value 
	reg [`AWIDTH - 1 : 0] START_ADDR; // start instruction address

	initial
	begin
		`ifdef IVERILOG
			$dumpfile("tb_cpu.vcd");
			$dumpvars(0, tb_cpu);
		`endif
        
		clk=0;
		rst_n =0;
		#(Tclk*2) rst_n = 1;

		en_in=0;
        #(Tclk*3) en_in = 1;

		reset();

		START_ADDR = `AWIDTH'd0;

		`REGFILE.x0.q = 0;
		`REGFILE.x1.q = 1;
		`REGFILE.x2.q = 4;
		`REGFILE.x3.q = 2;
		
		// test cases
		//`IROM(START_ADDR + 0) = {`ADD,  `X1, `X0,  8'd0};
		//`IROM(START_ADDR + 1) = {`SUB,  `X1, `X0,  8'd0};
		//`IROM(START_ADDR + 2) = {`AND,  `X2, `X3,  8'd0};
		//`IROM(START_ADDR + 3) = {`OR,	`X3, `X1,  8'd0};
		`IROM(START_ADDR + 0) = {`ADDI,  `X1, `X0,  8'd1};
		`IROM(START_ADDR + 1) = {`ANDI,  `X0, `X0,  8'd1};
		// check result
		//check_result_rf(`X1, `DWIDTH'd3, "ADD" );
		//check_result_rf(`X1, `DWIDTH'd2, "SUB");
		//check_result_rf(`X2, `DWIDTH'd0, "AND");
		//check_result_rf(`X3, `DWIDTH'd6, "OR");
		check_result_rf(`X1, `DWIDTH'd2, "ADDI" );
		check_result_rf(`X0, `DWIDTH'd0, "ANDI" );
		all_tests_passed = 1'b1;

		#100;
		$display("All tests passed!");
		$finish();
	end
         
endmodule
