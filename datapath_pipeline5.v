module datapath_pipeline5(
	input clk,
	input rst_n,
	output zero

);
		//khai baÌo caÌc tiÌn hiÃªÌ£u
	 wire ifbranch;
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
    wire [31:0] jumpaddr;
	 wire [31:0] mem_data;
	 wire [31:0] rd1,rd2;
	 wire less;
	 wire jump;
	 wire [31:0] wd3;
	 wire [31:0] pc,pc_new,pc_next;
	 wire [31:0] pcBranch;
	 wire [31:0] instr,signImm;
	 wire RegWrite_wb,RegWrite_mem;
	 wire flush;		

		
		
	 //INSTRUCTION FETCH STAGE !!!!!!
	 
	 assign pc_next=pc+4;
	 

	 
	 pc r_pc(.clk(clk),.rst_n(rst_n),.d(pc_new),.q(pc));
	 
	 
	 //naÌ£p tÆ°Ì€ pc vaÌ€o rom
	 wire [5:0] imAddr = pc >> 2;
		
	
	 rom instr_rom(.a(imAddr),.rd (instr));
	 	 
	 //tin hieu cua if_id
	wire [31:0] pc_if_id,instr_if_id;	
	
	
	 if_id_flush pipeline1
	 (
	 .clk(clk),
    .rst_n(rst_n),
	 .flush(flush),
    .pc_in(pc),
    .instruction_in(instr),
    .pc_out(pc_if_id),
    .instruction_out(instr_if_id)
	 );
	 
	 
	 
	 
	 //INSTRUCTION DECODE STAGE !!!!
	 
	 
	 
	 control_unit control
	 (
    .opcode(instr_if_id[6:0]),
    .RegWrite(reg_write),
    .MemToReg(mem_to_reg),
    .MemRead(mem_read),
    .MemWrite(mem_write),
    .ALUSrc(alu_src),
    .ALUOp(alu_op),
    .Branch(branch),
	 .Jump(jump)
	 );
	 
	 
	 register_file_pipeline rf
		(
		.clk ( clk ),
		.a1 ( instr_if_id[19:15] ),
		.a2 ( instr_if_id[24:20] ),
		.a3 ( instr_wb[11:7]),
		.rd1 ( rd1 ),
		.rd2 ( rd2 ),
		.wd3 ( wd3 ),
		.we3 ( RegWrite_wb )
		);

	 

	 
	 
	  //imm generate
	  
	 imm_gen imm_gen1(.instruction(instr_if_id[31:0]),.imm(signImm));
	 
	//caÌc dÃ¢y tiÌn hiÃªÌ£u 
	 wire [31:0] rd1_ex,rd2_ex,signImm_ex,pc_ex,instr_ex,aluResult_ex;
	 wire reg_write_ex,mem_to_reg_ex,mem_read_ex,mem_write_ex,alu_src_ex;
	 wire [1:0] alu_op_ex;
	 wire branch_ex,jump_ex;
	 id_ex_flush pipeline2
	 (
    .clk(clk),.rst_n(rst_n),.flush(flush),
    .pc_in(pc_if_id),.instruction_in(instr_if_id),
    .reg1_in(rd1),
    .reg2_in(rd2),
    .imm_in(signImm),
    .RegWrite_in(reg_write), .MemToReg_in(mem_to_reg), .MemRead_in(mem_read), .MemWrite_in(mem_write), .ALUSrc_in(alu_src),
    .ALUOp_in(alu_op),
    .Branch_in(branch),.Jump_in(jump),
    .pc_out(pc_ex),
    .instruction_out(instr_ex),
    .reg1_out(rd1_ex),
    .reg2_out(rd2_ex),
    .imm_out(signImm_ex),
    .RegWrite_out(reg_write_ex), .MemToReg_out(mem_to_reg_ex), .MemRead_out(mem_read_ex), .MemWrite_out(mem_write_ex), .ALUSrc_out(alu_src_ex),
    .ALUOp_out(alu_op_ex),
    .Branch_out(branch_ex), .Jump_out(jump_ex)
	 );
							
	//EXECUTE STAGE !!!!
	
	
	//ALU Control
	wire [3:0] ALUCONT;
	alu_control alucont
	(
	.ALUOp(alu_op_ex),
	.funct7(instr_ex[31:25]),
	.funct3(instr_ex[14:12]),
	.ALUControl(ALUCONT)
	);

	//Forwarding
	wire [31:0] alu_in1,alu_in2;
	wire [1:0] forwardA, forwardB;
	wire [31:0] srcB=(alu_src_ex==1)? signImm_ex: rd2_ex;
	forwarding fwd (.rs1_ex(instr_ex[19:15]), .rs2_ex(instr_ex[24:20]), 
                .rd_mem(instr_mem[11:7]), .rd_wb(instr_wb[11:7]), .opcode_ex(instr_ex[6:0]),
                .RegWrite_mem(RegWrite_mem), .RegWrite_wb(RegWrite_wb), 
                .forwardA(forwardA), .forwardB(forwardB));

	assign alu_in1 = (forwardA == 2'b01) ? alu_result_mem : 
                 (forwardA == 2'b10) ? wd3 : rd1_ex;
	assign alu_in2 = (forwardB == 2'b01) ? alu_result_mem : 
						  (forwardB == 2'b10) ? wd3 : srcB;
		
	//ALU 


	alu alu0
	(
	.A ( alu_in1 ),
	.B ( alu_in2 ),
	.ALUControl ( ALUCONT ),
	.Result ( aluResult_ex ),
	.Zero ( zero )
	);
	//tiÌnh branch vaÌ€ jump
	assign pcBranch = pc_ex + signImm_ex;
	assign jumpaddr = (instr_ex[6:0]==7'b1101111)? aluResult_ex : pcBranch;   //jump address

	
	//EX TO MEM
	 wire [31:0] pc_mem,reg2_mem,pcBranch_mem,jumpaddr_mem,instr_mem,alu_result_mem;
	 wire MemToReg_mem,MemRead_mem,MemWrite_mem,Branch_mem,Jump_mem;
	ex_mem pipeline3 (.clk(clk), .rst_n(rst_n), .pc_in(pc_ex), .alu_result_in(aluResult_ex), 
                       .reg2_in(rd2_ex),.instr_in(instr_ex), .RegWrite_in(reg_write_ex), .MemToReg_in(mem_to_reg_ex), 
                       .MemRead_in(mem_read_ex), .MemWrite_in(mem_write_ex), .Branch_in(branch_ex), 
                       .Jump_in(jump_ex),.pcBranch_in(pcBranch),.jumpaddr_in(jumpaddr),.jumpaddr_out(jumpaddr_mem),.pcBranch_out(pcBranch_mem), .pc_out(pc_mem), .alu_result_out(alu_result_mem), 
                       .reg2_out(reg2_mem), .RegWrite_out(RegWrite_mem), .MemToReg_out(MemToReg_mem), 
                       .MemRead_out(MemRead_mem), .MemWrite_out(MemWrite_mem), .Branch_out(Branch_mem), 
                       .Jump_out(Jump_mem),.instr_out(instr_mem));
	
	
	
	
	//MEM STAGE !!!!!!
	
	
	    ram data_ram (
        .clk(clk),
        .a(alu_result_mem),
        .we(MemWrite_mem),
		  .re(MemRead_mem),
        .wd(reg2_mem),
        .rd(mem_data)
    );
	 
	 
	 // khai baÌo wire cho mem_wb
	 wire [31:0] mem_data_wb,alu_result_wb,instr_wb;
	 wire MemToReg_wb,Jump_wb;
	 mem_wb pipeline4 (.clk(clk), .rst_n(rst_n), .alu_result_in(alu_result_mem), 
                       .mem_data_in(mem_data), .RegWrite_in(RegWrite_mem), .MemToReg_in(MemToReg_mem),.Jump_in(Jump_mem),.instr_in(instr_mem),
                       .alu_result_out(alu_result_wb), .mem_data_out(mem_data_wb), 
                       .RegWrite_out(RegWrite_wb), .MemToReg_out(MemToReg_wb),.Jump_out(Jump_wb),.instr_out(instr_wb));
	 assign wd3 = (Jump_wb==1)?(pc_next):(MemToReg_wb==1)?mem_data_wb:alu_result_wb;  //write data
	 
	 
	 
	 assign less = alu_result_mem[31]; 
	 assign ifbranch = Branch_mem & (
			 (instr_ex[14:12] == 3'b000 && zero) ||    // beq: rs1 == rs2
			 (instr_ex[14:12] == 3'b001 && !zero) ||   // bne: rs1 != rs2
			 (instr_ex[14:12] == 3'b100 && less) ||    // blt: rs1 < rs2 (signed)
			 (instr_ex[14:12] == 3'b101 && !less) ||   // bge: rs1 >= rs2 (signed)
			 (instr_ex[14:12] == 3'b110 && less) ||    // bltu: rs1 < rs2 (unsigned, cáº§n logic riÃªng)
			 (instr_ex[14:12] == 3'b111 && !less)      // bgeu: rs1 >= rs2 (unsigned)
		);
	 
	 assign pc_new =(Jump_mem==1)? jumpaddr_mem: (ifbranch == 1) ? pcBranch_mem : pc_next;   // choÌ£n Ä‘iÌ£a chiÌ‰
	 assign flush = ifbranch | Jump_mem;
	 
	 endmodule