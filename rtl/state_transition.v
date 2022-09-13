`include "opcode.vh"
`include "alufunc.vh"
module state_transition (
	input clk, rst_n,
	input en_in,
	input en1,
	input en2,
	input [1 : 0] rd,
	input [3 : 0] opcode,
	output reg en_fetch_pulse,
	output reg en_group_pulse,
	output reg en_pc_pulse,
	output reg [1 : 0] pc_ctrl,
	output reg [3 : 0] reg_en,
	output reg alu_in_sel,
	output reg [2 : 0] alu_func
);
	reg en_fetch_reg, en_fetch;
	reg en_group_reg, en_group;
	reg en_pc_reg,    en_pc;

	reg [3 : 0] current_state, next_state;

	localparam Initial = 4'b0000;
	localparam Fetch = 4'b0001;
	localparam Decode = 4'b0010;
    localparam Execute_Add = 4'b1000;
	localparam Write_Back = 4'b0011;

	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= Initial;
		end
		else begin 
			current_state <= next_state;
		end
	end

	always @ (*) begin
		case (current_state)
			Initial: begin
				if (en_in) begin 
					next_state = Fetch;
				end
				else begin
					next_state = Initial;
				end
			end

			Fetch: begin
				if (en1) begin
					next_state = Decode;
				end
				else begin
					next_state = current_state;
				end
			end

			Decode: begin
				case (opcode) 
					`ADD:    next_state = Execute_Add;
					default: next_state = current_state;
				endcase
			end

			Execute_Add: begin
				if (en2) begin
					next_state = Write_Back;
				end
				else begin
					next_state = current_state;
				end
			end  

			Write_Back: begin
				next_state = Fetch;
			end

			default: next_state = current_state;
		endcase
	end

	always @ (*) begin
		if(!rst_n) begin
			en_fetch = 1'b0;
			en_group = 1'b0;
			en_pc = 1'b0;
			pc_ctrl = 2'b00;
			reg_en = 4'b0000;
			alu_in_sel = 1'b0;
			alu_func = `ALU_ADD;
		end
		else begin
			case (next_state)
				Initial: begin
					en_fetch = 1'b0;
					en_group = 1'b0;
					en_pc = 1'b0;
					pc_ctrl = 2'b00;
					reg_en = 4'b0000;
					alu_in_sel = 1'b0;
					alu_func = `ALU_ADD;
				end

				Fetch: begin
					en_fetch = 1'b1;
					en_group = 1'b0;
					en_pc = 1'b1;
					pc_ctrl = 2'b01;
					reg_en = 4'b0000;
					alu_in_sel = 1'b0;
					alu_func = `ALU_ADD;
				end

				Decode: begin
					en_fetch = 1'b0;
					en_group = 1'b0;
					en_pc = 1'b0;
					pc_ctrl = 2'b00;
					reg_en = 4'b0000;
					alu_in_sel = 1'b0;
					alu_func = `ALU_ADD;
				end

				Execute_Add: begin
					en_fetch = 1'b0;
					en_group = 1'b1;
					en_pc = 1'b0;
					pc_ctrl = 2'b00;
					reg_en = 4'b0000;
					alu_in_sel = 1'b1;
					alu_func = `ALU_ADD;
				end

				Write_Back: begin
					en_fetch = 1'b0;
					en_group = 1'b0;
					en_pc = 1'b0;
					pc_ctrl = 2'b00;
					alu_in_sel = 1'b0;
					alu_func = 3'b000;
					case(rd)
						2'b00: reg_en = 4'b0001;
						2'b01: reg_en = 4'b0010;
						2'b10: reg_en = 4'b0100;
						2'b11: reg_en = 4'b1000;
						default: reg_en = 4'b0000;
					endcase
				end

				default: begin
					en_fetch = 1'b0;
					en_group = 1'b0;
					en_pc = 1'b0;
					pc_ctrl = 2'b00;
					reg_en = 4'b0000;
					alu_in_sel = 1'b0;
					alu_func = 3'b000;
				end
			endcase
		end
	end

	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			en_fetch_reg <= 1'b0;
			en_pc_reg <= 1'b0;
			en_group_reg <= 1'b0;
		end
		else begin
			en_fetch_reg <= en_fetch;
			en_pc_reg <= en_pc;
			en_group_reg <= en_group;
		end
	end

	always @ (*) begin
		en_fetch_pulse = en_fetch & (~en_fetch_reg);
	end

	always @ (*) begin
		en_pc_pulse = en_pc & (~en_pc_reg);
	end

	always @ (*) begin
		en_group_pulse = en_group & (~en_group_reg);
	end
endmodule
