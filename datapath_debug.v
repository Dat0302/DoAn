	module datapath_debug(
	input clk,
	input rst_n,
	output wire [31:0] aluResult,
	 output wire [1:0] alu_op,
	output wire [31:0] instr,
	output wire [31:0] signImm,
	output 	  wire  jump,
	output 	 wire ifbranch
	
);
		//khai báo các tín hiệu
	 wire [31:0] pc_next;
	 wire reg_write;
    wire mem_to_reg;
    wire mem_read;
    wire mem_write;
    wire alu_src;
	 wire zero;
	 wire [31:0] bRData0;
	 wire branch;
	 wire [31:0] pc;
	 wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
	 wire [5:0] imAddr;
	wire [31:0] rd1,rd2;
	wire [31:0] pc_new;
	wire [31:0] jumpaddr;
	wire [31:0] pcBranch;
	
	
	
	
	 assign opcode = instr[6:0];
	 
	 	 //xử lý thanh ghi pc 
	 wire less; // Giả sử ALU có tín hiệu less (rs1 < rs2, có thể signed hoặc unsigned)
	 assign less = aluResult[31]; // Đơn giản hóa: Dùng bit dấu từ ALU (cho signed comparison)

	 assign ifbranch = branch & (
			 (instr[14:12] == 3'b000 && zero) ||    // beq: rs1 == rs2
			 (instr[14:12] == 3'b001 && !zero) ||   // bne: rs1 != rs2
			 (instr[14:12] == 3'b100 && less) ||    // blt: rs1 < rs2 (signed)
			 (instr[14:12] == 3'b101 && !less) ||   // bge: rs1 >= rs2 (signed)
			 (instr[14:12] == 3'b110 && less) ||    // bltu: rs1 < rs2 (unsigned, cần logic riêng)
			 (instr[14:12] == 3'b111 && !less)      // bgeu: rs1 >= rs2 (unsigned)
		);
	 assign pc_next=pc+4;
	 assign pcBranch = pc + signImm;
	 
	 assign jumpaddr = (opcode==7'b1101111)? aluResult : pcBranch;
    assign pc_new =(jump==1)? jumpaddr: (ifbranch == 1) ? pcBranch : pc_next;
	 
	 pc r_pc(.clk(clk),.rst_n(rst_n),.d(pc_new),.q(pc));
	 assign imAddr = pc >> 2;
		
	 rom instr_rom(.a(imAddr),.rd (instr));
	 
	 wire [31:0] wd3 = (jump==1)?(pc_next):(mem_to_reg==1)?bRData0:aluResult;  //write data
	 register_file rf
		(
		.clk ( clk ),
		.a1 ( instr[19:15] ),
		.a2 ( instr[24:20] ),
		.a3 ( instr[11:7]),
		.rd1 ( rd1 ),
		.rd2 ( rd2 ),
		.wd3 ( wd3 ),
		.we3 ( reg_write )
		);
	 
	 
	 control_unit control
	 (
    .opcode(instr[6:0]),
    .RegWrite(reg_write),
    .MemToReg(mem_to_reg),
    .MemRead(mem_read),
    .MemWrite(mem_write),
    .ALUSrc(alu_src),
    .ALUOp(alu_op),
    .Branch(branch),
	 .Jump(jump)
	 );
	 
	 //immgen
	 imm_gen imm_gen1(.instruction(instr),.imm(signImm));
							
	//alu
	wire [31:0] srcB=(alu_src==1)? signImm: rd2;
	wire [3:0] ALUCONT;
	alu_control alucont
	(
	.ALUOp(alu_op),
	.funct7(instr[31:25]),
	.funct3(instr[14:12]),
	.ALUControl(ALUCONT)
	);
	
	alu alu0
	(
	.A ( rd1 ),
	.B ( srcB ),
	.ALUControl ( ALUCONT ),
	.Result ( aluResult ),
	.Zero ( zero )
	);
	
	//ram
	    ram data_ram (
        .clk(clk),
        .a(aluResult),
        .we(mem_write),
		  .re(mem_read),
        .wd(rd2),
        .rd(bRData0)
    );
	 
	 endmodule