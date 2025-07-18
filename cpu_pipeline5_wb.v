module cpu_pipeline5_wb (
    input         clk,
    input         rst_n,

    // Wishbone Master Interface
    output        wb_cyc_o,
    output        wb_stb_o,
    output        wb_we_o,
    output [31:0] wb_adr_o,
    output [31:0] wb_dat_o,
    input  [31:0] wb_dat_i,
    input         wb_ack_i
);

    // === Tín hiệu RAM được kết nối ra Wishbone ===
    wire ram_we, ram_re;
    wire [31:0] ram_addr, ram_wd;
    wire [31:0] ram_rd = wb_dat_i;

    assign wb_adr_o  = ram_addr;
    assign wb_dat_o  = ram_wd;
    assign wb_cyc_o  = ram_we | ram_re;
    assign wb_stb_o  = wb_cyc_o;
    assign wb_we_o   = ram_we;

    // === Các tín hiệu nội bộ ===
    wire [31:0] instr;
    wire [31:0] pc, pc_next, pc_new;
    wire [31:0] pc_if_id, instr_if_id;
    wire [31:0] rd1, rd2, signImm;

    wire reg_write, mem_to_reg, mem_read, mem_write;
    wire alu_src, branch, jump;
    wire [1:0] alu_op;

    // === Instruction Fetch ===
    assign pc_next = pc + 4;
    pc u_pc(.clk(clk), .rst_n(rst_n), .d(pc_new), .q(pc));

    wire [5:0] imAddr = pc[7:2]; // ROM address
    rom instr_rom(.a(imAddr), .rd(instr));

    if_id_flush u_if_id(
        .clk(clk), .rst_n(rst_n), .flush(flush),
        .pc_in(pc), .instruction_in(instr),
        .pc_out(pc_if_id), .instruction_out(instr_if_id)
    );

    // === Instruction Decode ===
    control_unit u_ctrl(
        .opcode(instr_if_id[6:0]),
        .RegWrite(reg_write), .MemToReg(mem_to_reg),
        .MemRead(mem_read), .MemWrite(mem_write),
        .ALUSrc(alu_src), .ALUOp(alu_op),
        .Branch(branch), .Jump(jump)
    );

    register_file_pipeline u_rf(
        .clk(clk),
        .a1(instr_if_id[19:15]),
        .a2(instr_if_id[24:20]),
        .a3(instr_wb[11:7]),
        .rd1(rd1), .rd2(rd2),
        .wd3(wd3), .we3(RegWrite_wb)
    );

    imm_gen u_imm_gen(.instruction(instr_if_id), .imm(signImm));

    // === ID/EX Pipeline ===
    wire [31:0] rd1_ex, rd2_ex, signImm_ex, pc_ex, instr_ex;
    wire reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex, alu_src_ex;
    wire [1:0] alu_op_ex;
    wire branch_ex, jump_ex;

    id_ex_flush u_id_ex (
        .clk(clk), .rst_n(rst_n), .flush(flush),
        .pc_in(pc_if_id), .instruction_in(instr_if_id),
        .reg1_in(rd1), .reg2_in(rd2), .imm_in(signImm),
        .RegWrite_in(reg_write), .MemToReg_in(mem_to_reg),
        .MemRead_in(mem_read), .MemWrite_in(mem_write),
        .ALUSrc_in(alu_src), .ALUOp_in(alu_op),
        .Branch_in(branch), .Jump_in(jump),
        .pc_out(pc_ex), .instruction_out(instr_ex),
        .reg1_out(rd1_ex), .reg2_out(rd2_ex), .imm_out(signImm_ex),
        .RegWrite_out(reg_write_ex), .MemToReg_out(mem_to_reg_ex),
        .MemRead_out(mem_read_ex), .MemWrite_out(mem_write_ex),
        .ALUSrc_out(alu_src_ex), .ALUOp_out(alu_op_ex),
        .Branch_out(branch_ex), .Jump_out(jump_ex)
    );

    // === Execute Stage ===
    wire [3:0] ALUCONT;
    alu_control u_alu_ctrl(
        .ALUOp(alu_op_ex),
        .funct7(instr_ex[31:25]),
        .funct3(instr_ex[14:12]),
        .ALUControl(ALUCONT)
    );

    wire [1:0] forwardA, forwardB;
    wire [31:0] srcB = (alu_src_ex == 1) ? signImm_ex : rd2_ex;
    wire [31:0] alu_in1, alu_in2;

    forwarding u_fwd(
        .rs1_ex(instr_ex[19:15]),
        .rs2_ex(instr_ex[24:20]),
        .rd_mem(instr_mem[11:7]),
        .rd_wb(instr_wb[11:7]),
        .opcode_ex(instr_ex[6:0]),
        .RegWrite_mem(RegWrite_mem),
        .RegWrite_wb(RegWrite_wb),
        .forwardA(forwardA), .forwardB(forwardB)
    );

    assign alu_in1 = (forwardA == 2'b01) ? alu_result_mem :
                     (forwardA == 2'b10) ? wd3 : rd1_ex;

    assign alu_in2 = (forwardB == 2'b01) ? alu_result_mem :
                     (forwardB == 2'b10) ? wd3 : srcB;

    wire [31:0] aluResult_ex;
    wire zero;

    alu u_alu(
        .A(alu_in1), .B(alu_in2),
        .ALUControl(ALUCONT),
        .Result(aluResult_ex),
        .Zero(zero)
    );

    wire [31:0] pcBranch = pc_ex + signImm_ex;
    wire [31:0] jumpaddr = (instr_ex[6:0] == 7'b1101111) ? aluResult_ex : pcBranch;

    // === EX/MEM Pipeline ===
    wire [31:0] reg2_mem, pcBranch_mem, jumpaddr_mem, instr_mem, pc_mem;
    wire MemToReg_mem, MemRead_mem, MemWrite_mem;
    wire RegWrite_mem, Branch_mem, Jump_mem;
    wire [31:0] alu_result_mem;

    ex_mem u_ex_mem(
        .clk(clk), .rst_n(rst_n),
        .pc_in(pc_ex), .alu_result_in(aluResult_ex),
        .reg2_in(rd2_ex), .instr_in(instr_ex),
        .RegWrite_in(reg_write_ex), .MemToReg_in(mem_to_reg_ex),
        .MemRead_in(mem_read_ex), .MemWrite_in(mem_write_ex),
        .Branch_in(branch_ex), .Jump_in(jump_ex),
        .pcBranch_in(pcBranch), .jumpaddr_in(jumpaddr),
        .pc_out(pc_mem), .alu_result_out(alu_result_mem),
        .reg2_out(reg2_mem), .instr_out(instr_mem),
        .RegWrite_out(RegWrite_mem), .MemToReg_out(MemToReg_mem),
        .MemRead_out(MemRead_mem), .MemWrite_out(MemWrite_mem),
        .Branch_out(Branch_mem), .Jump_out(Jump_mem),
        .pcBranch_out(pcBranch_mem), .jumpaddr_out(jumpaddr_mem)
    );

    // === RAM (truyền tín hiệu ra để dùng Wishbone) ===
    assign ram_we    = MemWrite_mem;
    assign ram_re    = MemRead_mem;
    assign ram_addr  = alu_result_mem;
    assign ram_wd    = reg2_mem;

    wire [31:0] mem_data = ram_rd;

    // === MEM/WB Pipeline ===
    wire [31:0] mem_data_wb, alu_result_wb, instr_wb;
    wire MemToReg_wb, RegWrite_wb, Jump_wb;

    mem_wb u_mem_wb(
        .clk(clk), .rst_n(rst_n),
        .alu_result_in(alu_result_mem),
        .mem_data_in(mem_data),
        .RegWrite_in(RegWrite_mem),
        .MemToReg_in(MemToReg_mem),
        .Jump_in(Jump_mem),
        .instr_in(instr_mem),
        .alu_result_out(alu_result_wb),
        .mem_data_out(mem_data_wb),
        .RegWrite_out(RegWrite_wb),
        .MemToReg_out(MemToReg_wb),
        .Jump_out(Jump_wb),
        .instr_out(instr_wb)
    );

    wire [31:0] wd3 = (Jump_wb == 1) ? pc_next :
                      (MemToReg_wb == 1) ? mem_data_wb : alu_result_wb;

    // === Branch Decision ===
    wire less = alu_result_mem[31];
    wire ifbranch = Branch_mem & (
        (instr_ex[14:12] == 3'b000 && zero) || // beq
        (instr_ex[14:12] == 3'b001 && !zero) || // bne
        (instr_ex[14:12] == 3'b100 && less) || // blt
        (instr_ex[14:12] == 3'b101 && !less) || // bge
        (instr_ex[14:12] == 3'b110 && less) || // bltu (simple logic)
        (instr_ex[14:12] == 3'b111 && !less)   // bgeu
    );

    assign pc_new = (Jump_mem) ? jumpaddr_mem :
                    (ifbranch) ? pcBranch_mem : pc_next;

    assign flush = ifbranch | Jump_mem;

endmodule
