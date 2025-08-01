// ========================
// CPU Datapath with Wishbone Bus
// ========================
module datapath_wishbone (
    input         clk,
    input         rst_n,

    // Wishbone Instruction Bus
    output [31:0] i_wb_adr_o,
    input  [31:0] i_wb_dat_i,
    output        i_wb_cyc_o,
    output        i_wb_stb_o,
    input         i_wb_ack_i,

    // Wishbone Data Bus
    output [31:0] d_wb_adr_o,
    output [31:0] d_wb_dat_o,
    input  [31:0] d_wb_dat_i,
    output        d_wb_we_o,
    output        d_wb_cyc_o,
    output        d_wb_stb_o,
    input         d_wb_ack_i,

    output        zero
);

    // Internal wires
    wire reg_write, mem_to_reg, mem_read, mem_write, alu_src, branch, jump;
    wire [1:0] alu_op;
    wire [31:0] pc, pc_new, pc_next, jumpaddr, pcBranch;
    wire [31:0] aluResult;
    wire [31:0] bRData0;
    wire [31:0] rd1, rd2;
    wire [31:0] instr;
    wire [31:0] signImm;
    wire ifbranch;
    wire less;

    // PC logic
    assign less = aluResult[31];
    assign ifbranch = branch & (
        (instr[14:12] == 3'b000 && zero) ||
        (instr[14:12] == 3'b001 && !zero) ||
        (instr[14:12] == 3'b100 && less) ||
        (instr[14:12] == 3'b101 && !less) ||
        (instr[14:12] == 3'b110 && less) ||
        (instr[14:12] == 3'b111 && !less)
    );

    assign pc_next = pc + 4;
    assign pcBranch = pc + signImm;
    assign jumpaddr = (instr[6:0] == 7'b1101111) ? aluResult : pcBranch;
    assign pc_new = jump ? jumpaddr : (ifbranch ? pcBranch : pc_next);

    // Program Counter
    pc r_pc (
        .clk(clk),
        .rst_n(rst_n),
        .d(pc_new),
        .q(pc)
    );


    assign i_wb_adr_o = pc;
    assign i_wb_cyc_o = 1'b1;
    assign i_wb_stb_o = 1'b1;
    assign instr = i_wb_ack_i ? i_wb_dat_i : 32'b0; // wait for ack

    // Writeback data selection
    wire [31:0] wd3 = jump ? pc_next : (mem_to_reg ? bRData0 : aluResult);

    // Register file
    register_file rf (
        .clk(clk),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .rd1(rd1),
        .rd2(rd2),
        .wd3(wd3),
        .we3(reg_write)
    );

    // Control Unit
    control_unit control (
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

    // Immediate Generator
    imm_gen imm_gen1 (
        .instruction(instr),
        .imm(signImm)
    );

    // ALU and ALU Control
    wire [3:0] ALUCONT;
    wire [31:0] srcB = alu_src ? signImm : rd2;

    alu_control alucont (
        .ALUOp(alu_op),
        .funct7(instr[31:25]),
        .funct3(instr[14:12]),
        .ALUControl(ALUCONT)
    );

    alu alu0 (
        .A(rd1),
        .B(srcB),
        .ALUControl(ALUCONT),
        .Result(aluResult),
        .Zero(zero)
    );

    // Data access via Wishbone
    assign d_wb_adr_o = aluResult;
    assign d_wb_dat_o = rd2;
    assign d_wb_we_o  = mem_write;
    assign d_wb_cyc_o = mem_read | mem_write;
    assign d_wb_stb_o = mem_read | mem_write;
    assign bRData0    = d_wb_ack_i ? d_wb_dat_i : 32'b0;

endmodule
