module datapath_pipeline5_wb(
    input clk,
    input rst_n,
    output zero,

    // Wishbone master interface

);
    // ===== KHAI BÁO TRƯỚC ĐỂ TRÁNH LỖI UNDEFINED =====
    wire [31:0] pc_mem, aluResult_mem, instr_mem;
    wire [31:0] signImm_ex;
    wire [31:0] aluResult_wb, mem_data_wb, instr_wb;
    wire RegWrite_mem, MemToReg_mem, MemRead_mem, MemWrite_mem, Branch_mem, Jump_mem;
    wire RegWrite_wb, MemToReg_wb, Jump_wb;
    wire ifbranch;

    // Khai báo các tín hiệu nội bộ
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
    wire [31:0] pc, pc_new, pc_next, pcBranch;
    wire [31:0] aluResult;
    wire [31:0] rd1, rd2;
    wire jump;
    wire [31:0] instr;
    wire [31:0] signImm;
    wire [31:0] wd3;

    // Instruction Fetch
    assign pcBranch = pc_mem + (signImm_ex << 1);
    assign pc_next = pc + 4;
    assign pc_new = (Jump_mem) ? aluResult_mem : (ifbranch ? pcBranch : pc_next);

    pc r_pc(.clk(clk), .rst_n(rst_n), .d(pc_new), .q(pc));
    wire [5:0] imAddr = pc >> 2;
    rom instr_rom(.a(imAddr), .rd(instr));

    // IF/ID pipeline
    wire [31:0] pc_if_id, instr_if_id;
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
	 

    // Decode stage
    control_unit ctrl(.opcode(instr_if_id[6:0]), .RegWrite(reg_write), .MemToReg(mem_to_reg), .MemRead(mem_read), .MemWrite(mem_write), .ALUSrc(alu_src), .ALUOp(alu_op), .Branch(branch), .Jump(jump));
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
		);    imm_gen immgen(.instruction(instr_if_id), .imm(signImm));

    // ID/EX pipeline
    wire [31:0] pc_ex, instr_ex, rd1_ex, rd2_ex;
    wire RegWrite_ex, MemToReg_ex, MemRead_ex, MemWrite_ex, ALUSrc_ex;
    wire [1:0] ALUOp_ex;
    wire Branch_ex, Jump_ex;
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
    // ALU + Forwarding
    wire [3:0] alu_control;
    wire [1:0] forwardA, forwardB;
    wire [31:0] forwardA_data, forwardB_data;
    forwarding fwd_unit(
        .rs1_ex(instr_ex[19:15]),
        .rs2_ex(instr_ex[24:20]),
        .rd_mem(instr_mem[11:7]),
        .rd_wb(instr_wb[11:7]),
        .RegWrite_mem(RegWrite_mem),
        .RegWrite_wb(RegWrite_wb),
        .opcode_ex(instr_ex[6:0]),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
	assign alu_in1 = (forwardA == 2'b01) ? alu_result_mem : 
                 (forwardA == 2'b10) ? wd3 : rd1_ex;
	assign alu_in2 = (forwardB == 2'b01) ? alu_result_mem : 
						  (forwardB == 2'b10) ? wd3 : srcB;
    alu_control alu_ctrl(.ALUOp(ALUOp_ex), .funct7(instr_ex[31:25]), .funct3(instr_ex[14:12]), .ALUControl(alu_control));
    wire [31:0] srcB = (ALUSrc_ex) ? signImm_ex : forwardB_data;
    alu alu(
        .A(alu_in1),
        .B(alu_in2),
        .ALUControl(alu_control),
        .Zero(zero),
        .Result(aluResult)
    );

    // EX/MEM pipeline
    wire [31:0] rd2_mem;
		ex_mem pipeline3 (.clk(clk), .rst_n(rst_n), .pc_in(pc_ex), .alu_result_in(aluResult_ex), 
                       .reg2_in(rd2_ex),.instr_in(instr_ex), .RegWrite_in(reg_write_ex), .MemToReg_in(mem_to_reg_ex), 
                       .MemRead_in(mem_read_ex), .MemWrite_in(mem_write_ex), .Branch_in(branch_ex), 
                       .Jump_in(jump_ex),.pcBranch_in(pcBranch),.jumpaddr_in(jumpaddr),.jumpaddr_out(jumpaddr_mem),.pcBranch_out(pcBranch_mem), .pc_out(pc_mem), .alu_result_out(alu_result_mem), 
                       .reg2_out(reg2_mem), .RegWrite_out(RegWrite_mem), .MemToReg_out(MemToReg_mem), 
                       .MemRead_out(MemRead_mem), .MemWrite_out(MemWrite_mem), .Branch_out(Branch_mem), 
                       .Jump_out(Jump_mem),.instr_out(instr_mem));
    // Branch condition evaluation
    wire less = aluResult_mem[31];
    assign ifbranch = Branch_mem & (
        (instr_ex[14:12] == 3'b000 && zero) ||
        (instr_ex[14:12] == 3'b001 && !zero) ||
        (instr_ex[14:12] == 3'b100 && less) ||
        (instr_ex[14:12] == 3'b101 && !less) ||
        (instr_ex[14:12] == 3'b110 && less) ||
        (instr_ex[14:12] == 3'b111 && !less)
    );

    // Wishbone with memory mapping
    wire is_ram  = (aluResult_mem[31:18] == 14'h0000);
    wire is_gpio = (aluResult_mem[31:8]  == 24'h00070F);
    wire is_spi  = (aluResult_mem[31:8]  == 24'h0007F1);
    wire is_uart = (aluResult_mem[31:8]  == 24'h0007F2);
    wire wb_access = is_ram | is_gpio | is_spi | is_uart;

    assign wb_adr_o = aluResult_mem;
    assign wb_dat_o = rd2_mem;
    assign wb_we_o  = MemWrite_mem;
    assign wb_cyc_o = wb_access & (MemWrite_mem | MemRead_mem);
    assign wb_stb_o = wb_access & (MemWrite_mem | MemRead_mem);
    wire [31:0] mem_data = wb_dat_i;

    // MEM/WB pipeline
    mem_wb mem_wb_reg(.clk(clk), .rst_n(rst_n), .alu_result_in(aluResult_mem), .mem_data_in(mem_data), .RegWrite_in(RegWrite_mem), .MemToReg_in(MemToReg_mem), .Jump_in(Jump_mem), .instr_in(instr_mem), .alu_result_out(aluResult_wb), .mem_data_out(mem_data_wb), .RegWrite_out(RegWrite_wb), .MemToReg_out(MemToReg_wb), .Jump_out(Jump_wb), .instr_out(instr_wb));

    // Writeback stage
    assign wd3 = (MemToReg_wb) ? mem_data_wb : aluResult_wb;

endmodule
