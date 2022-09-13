# Lab Guidance

## Instruction Set Architecture

### Instruction Format

| instr[15 : 12] | instr[11 : 10] | instr[9 : 8] | instr[7 : 0] |
| :------------: | :------------: | :----------: | :----------: |
|     opcode     |       rd       |      rs      |     imm      |
|     4 bit      |     2 bit      |    2 bit     |    8 bit     |

### Basic Instruction Encode

| opcode | rd/rs2 |  rs1   |  imm   |       asm        |       description       |
| :----: | :----: | :----: | :----: | :--------------: | :---------------------: |
|  0000  |   rd   | unused |  imm   |   movi rd, imm   |  R[rd] = imm = imm + 0  |
|  0001  |   rd   | unused |  imm   |   addi rd, imm   |   R[rd] = R[rd] + imm   |
|  0010  |   rd   |  rs1   | unused |   add rd, rs1    | R[rd] = R[rd] + R[rs1]  |
|  0011  |   rd   |  rs1   | unused |   sub rd, rs1    | R[rd] = R[rd] - R[rs1]  |
|  0100  |   rd   | unused |  imm   |   andi rd, imm   |   R[rd] = R[rd] & imm   |
|  0101  |   rd   |  rs1   | unused |   and rd, rs1    | R[rd] = R[rd] & R[rs1]  |
|  0110  |   rd   |  rs1   | unused |  or    rd, rs1   | R[rd] = R[rd] \| R[rs1] |
|  1000  | unused | unused |  imm   |     jump imm     |        pc = imm         |
|  1100  |   rd   |  rs1   |  imm   | ld rd, (imm)rs1  | R[rd] = Mem[R[rs1]+imm] |
|  1101  |  rs2   |  rs1   |  imm   | st rs2, (imm)rs1 |  Mem[R[rs1]+imm] = rs2  |
```ad-important
In the ISA, 8 bit data convert to 16 bit data with zero extension. 
For example: 8'b1101_1100 -> 16'b0000_0000_1101_1100 
```

## File List

```shell
DigitalLab
├── doc
│   └── labguide_en.md
├── Makefile
├── rtl
│   ├── alufunc.vh          # Head file includes the macro of alu functions.
│   ├── alu_mux.v           # Module for selecting source operands of ALU.
│   ├── alu.v               # ALU.
│   ├── control_unit.v      # CPU controller.
│   ├── cpu_top.v           # Top module.
│   ├── cpu.v               # CPU core.
│   ├── data_path.v         # Data path.
│   ├── irom.v              # Instruction ROM.
│   ├── ir.v                # Instuction Register, is used to store the current instruction.
│   ├── opcode.vh           # Head file includes the macro of opcode.
│   ├── pc.v                # Program Counter, storage for the address of instruction in memory. 
│   ├── reg_group.v         # Register File.
│   ├── register.v          # Including an asynchronous reset flip-flop with enable signal.
│   ├── rom.v               # Including a single port synchronous ROM.
│   └── state_transition.v  # FSM module, the core of controller.
└── sim
    └── tb_cpu.v            # Testbench of the top module.
```

## Code Description

### Test Code

The major task of test code`sim/tb_cpu.v` for the top module: to store some instructions into instruction ROM during initialization,  and check whether the instrcutions checked has been implemented by comparing the value within the destination register with the expected value. `All tests passed!` will be printed if all the instruction pass, and then simulation will terminate.The terminatio of simulation will occur immediatly, whenever any instruction errors with some information about the error instruction printed.

The following is the core of the test code:


```Verilog
		reset();

		START_ADDR = `AWIDTH'd0;

		// test cases
		`IROM(START_ADDR + 0) = {`MOVI, `X0, 2'b0, 8'd4};
		`IROM(START_ADDR + 1) = {`ADD,  `X1, `X0,  8'd0};
		`IROM(START_ADDR + 2) = {`ADD,  `X2, `X1,  8'd0};
		`IROM(START_ADDR + 3) = {`JUMP, 4'b0,      8'd5};
		`IROM(START_ADDR + 4) = {`SUB,  `X2, `X0,  8'd0};
		`IROM(START_ADDR + 5) = {`ADDI, `X3, 2'b0, 8'd1};
		`IROM(START_ADDR + 6) = {`ADD,  `X2, `X3,  8'd0};

		// check result
		check_result_rf(`X0, `DWIDTH'd4, "MOVI");
		check_result_rf(`X1, `DWIDTH'd4, "ADD" );
		check_result_rf(`X2, `DWIDTH'd4, "ADD" );
		check_result_rf(`X2, `DWIDTH'd4, "ADD" );
		check_result_rf(`X2, `DWIDTH'd5, "JUMP");

		all_tests_passed = 1'b1;
```

```ad-tip
title: Tips
`Verilog` was born for simulation originally, widely used for hardware description later. Harddware description and test have different ways of coding thinking. The saying that "Hardware description is not software code" is often misunderstood by the newer as "Writing Verilog is not writing software code". Use all the ideas and skills you learned in software programming while reading and writing the test code in `Verilog`(Maybe you can treat it as `C` program language).
```




### RTL代码导读

#### 阅读方法

+ 指令的行为应该烂熟于心。
+ 熟悉Verilog的基本语法。

+ 采用自顶向下的方法阅读，先把握系统整体结构，底层模块内部实现细节暂时不需要关注，只需要知道它们的作用即可。
+ 阅读过程中建议手动画出系统中各个模块的连接图（即各个模块的输入输出，以及它们之间的连接方式），或者使用综合工具让计算机绘制出来。这一步是关键的，是把握系统整体结构的有效方法。

+ 阅读代码的过程中，一个有效的方法是边读边注释。
+ 如果有读不懂的地方，可以通过查看波形图来帮助理解。
+ 如果遇到陌生的语法，请RTFM（Read-The-Friendly-Mannul）、STFW（Search-The=Friendly-Website）。

#### 一些注意点

状态机`state_transition.v`中可能会有些看起来“诡异/不符合直觉的地方”。以下有两点需要仔细思考一下：

+ 根据`next_state`判断输出，而不是根据`current_state`的原因是为了节省一个时钟周期，即跳转到下一个状态，可以立即获得相应的激励值。
+ 带有`en_*_pulse`这类型号是一个冲击信号，更直白的讲，它们是采集一个使能信号的上升沿（即，从低电平转变到高电平）。其这样设计的原因是，相关的使能信号可能在拉高后保持好几个时钟周期，但我们的设计只需判断一次高电平。
