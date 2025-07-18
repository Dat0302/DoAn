module id_ex (
    input clk,
    input rst_n,
    input [31:0] pc_in,
    input [31:0] instruction_in,
    input [31:0] reg1_in,
    input [31:0] reg2_in,
    input [31:0] imm_in,
    input RegWrite_in, MemToReg_in, MemRead_in, MemWrite_in, ALUSrc_in,
    input [1:0] ALUOp_in,
    input Branch_in, Jump_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out,
    output reg [31:0] reg1_out,
    output reg [31:0] reg2_out,
    output reg [31:0] imm_out,
    output reg RegWrite_out, MemToReg_out, MemRead_out, MemWrite_out, ALUSrc_out,
    output reg [1:0] ALUOp_out,
    output reg Branch_out, Jump_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 0;
            instruction_out <= 0;
            reg1_out <= 0;
            reg2_out <= 0;
            imm_out <= 0;
            RegWrite_out <= 0;
            MemToReg_out <= 0;
            MemRead_out <= 0;
            MemWrite_out <= 0;
            ALUSrc_out <= 0;
            ALUOp_out <= 0;
            Branch_out <= 0;
            Jump_out <= 0;
        end else begin
            pc_out <= pc_in;
            instruction_out <= instruction_in;
            reg1_out <= reg1_in;
            reg2_out <= reg2_in;
            imm_out <= imm_in;
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            ALUSrc_out <= ALUSrc_in;
            ALUOp_out <= ALUOp_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
        end
    end
endmodule