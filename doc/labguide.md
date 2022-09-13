# 数字电路实验指南

## 指令集

### 指令格式

| instr[15 : 12] | instr[11 : 10] | instr[9 : 8] | instr[7 : 0] |
| :------------: | :------------: | :----------: | :----------: |
|     opcode     |       rd       |      rs      |     imm      |
|     4 bit      |     2 bit      |    2 bit     |    8 bit     |

### 基本指令编码

| opcode | rd/rs2 |  rs1   |  imm   |       asm        |         description         |
| :----: | :----: | :----: | :----: | :--------------: | :-------------------------: |
|  0000  |   rd   | unused |  imm   |   movi rd, imm   |    R[rd] = imm = imm + 0    |
|  0001  |   rd   |  rs1   | unused |   mov rd, rs1    | R[rd] = R[rs1] = R[rs1] + 0 |
|  0010  |   rd   | unused |  imm   |   addi rd, imm   |     R[rd] = R[rd] + imm     |
|  0011  |   rd   |  rs1   | unused |   add rd, rs1    |   R[rd] = R[rd] + R[rs1]    |
|  0101  |   rd   |  rs1   | unused |   sub rd, rs1    |   R[rd] = R[rd] - R[rs1]    |
|  0110  |   rd   | unused |  imm   |   andi rd, imm   |     R[rd] = R[rd] & imm     |
|  0111  |   rd   |  rs1   | unused |   and rd, rs1    |   R[rd] = R[rd] & R[rs1]    |
|  1001  |   rd   |  rs1   | unused |  or    rd, rs1   |   R[rd] = R[rd] \| R[rs1]   |
|  1010  | unused | unused |  imm   |     jump imm     |          pc = imm           |
|  1100  |   rd   |  rs1   |  imm   | ld rd, (imm)rs1  |   R[rd] = Mem[R[rs1]+imm]   |
|  1101  |  rs2   |  rs1   |  imm   | st rs2, (imm)rs1 |    Mem[R[rs1]+imm] = rs2    |



## 文件列表

```
DigitalLab
├── doc
│   └── labguide.md
├── Makefile
├── rtl
│   ├── alu_mux.v				# 选择ALU源操作数的模块
│   ├── alu.v					# ALU
│   ├── control_unit.v			# CPU的控制器
│   ├── cpu_top.v				# 顶层模块，例化了一个CPU实例以及一个指令ROM实例
│   ├── cpu.v					# CPU模块，将控制器和数据通路互联
│   ├── data_path.v				# 数据通路
│   ├── irom.v					# 指令ROM
│   ├── ir.v					# 指令寄存器，用于暂存指令
│   ├── opcode.vh				# 头文件，包含操作码的宏定义
│   ├── pc.v					# 程序计数器，寄存指令在存储器中的地址
│   ├── reg_group.v				# 寄存器文件（Register File）
│   ├── register.v				# 寄存器模块，目前含有一个异步复位带使能端的触发器
│   ├── rom.v					# 目前包含一个单口同步ROM
│   └── state_transition.v		# 状态机，控制器的核心
└── sim
    └── tb_cpu.v				# 顶层模块的testbench
```





## 代码说明

### 测试代码说明

顶层模块的测试代码`sim/tb_cpu.v`主要的工作为：初始化时，向指令ROM中存入一些指令，随后通过比较目的寄存器中的值是否符合期望值来判断该CPU是否正确实现了所检查的指令。如果所有指令通过，则会打印出`All tests passed!`，并且终止仿真；但凡有一条指令出错，仿真会立刻被终止，并且输出一些有关指令的信息。

以下为测试代码的主体（核心）部分：

```verilog
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



> Tips：Verilog原本是为了仿真而诞生的，后来被广泛用于硬件描述。硬件描述的编码思维与测试代码的编写思维是有区别的。大家常说的“硬件描述不是软件编码”很容易被初学者误解成“写Verilog不是在写软件代码”。在理解以及编写Verilog测试代码时，务必使用软件编程时所学的一切思想以及技巧！（当作C语言来理解是鼓励的）



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
