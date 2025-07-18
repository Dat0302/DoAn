module datapath(
	input clk,
	input rst_n,
	output zero
);
		//khai báo các tín hiệu
	 wire reg_write;
    wire mem_to_reg;
    wire mem_read;
    wire mem_write;
    wire alu_src;
    wire branch;
    wire [1:0] alu_op;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire zero_flag;
    wire [31:0] pc,pc_new,pc_next,jumpaddr,pcBranch;
	 wire [31:0] aluResult;
	 wire [31:0] bRData0;
	 wire [31:0] rd1,rd2;
	 wire ifbranch;
	 wire less;
	 wire jump;
	 wire [31:0] instr;
	 wire [31:0] signImm;
	 
	 	 //xử lý thanh ghi pc 
	 assign less = aluResult[31];
	 assign ifbranch = branch & (
			 (instr[14:12] == 3'b000 && zero) ||    // beq
			 (instr[14:12] == 3'b001 && !zero) ||   // bne
			 (instr[14:12] == 3'b100 && less) ||    // blt
			 (instr[14:12] == 3'b101 && !less) ||   // bge	
			 (instr[14:12] == 3'b110 && less) ||    // bltu
			 (instr[14:12] == 3'b111 && !less)      // bgeu
		);
	 //xử lý tín hieu pc
	 assign pc_next=pc+4;
	 assign pcBranch = pc + signImm;
	 assign jumpaddr = (instr[6:0]==7'b1101111)? aluResult : pcBranch; //jump address
	 
    assign pc_new =(jump==1)? jumpaddr: (ifbranch == 1) ? pcBranch : pc_next;

	 
	 pc r_pc(.clk(clk),.rst_n(rst_n),.d(pc_new),.q(pc));
	 
	 //nạp từ pc vào rom
	 wire [5:0] imAddr = pc >> 2;
		
	
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
	 
	 
	  //imm generate
	 imm_gen imm_gen1(.instruction(instr[31:0]),.imm(signImm));
	 

							
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