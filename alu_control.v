module alu_control (
    input  [1:0] ALUOp,
    input  [6:0] funct7,
    input  [2:0] funct3,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010; // Load/Store: Addition
            2'b01: ALUControl = 4'b0110; // Branch: Subtract
            2'b10: begin
                case ({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0010; // ADD
                    10'b0100000_000: ALUControl = 4'b0110; // SUB
                    10'b0000000_111: ALUControl = 4'b0000; // AND
                    10'b0000000_110: ALUControl = 4'b0001; // OR
                    10'b0000000_001: ALUControl = 4'b0100; // SLL
                    10'b0000000_101: ALUControl = 4'b0101; // SRL
                    10'b0100000_101: ALUControl = 4'b0111; // SRA
                    10'b0000000_010: ALUControl = 4'b1000; // SLT
                    default: ALUControl = 4'b0010; // Default to ADD
                endcase
            end
            2'b11: ALUControl = 4'b0010; // jal/jalr: Addition (PC + imm or rs1 + imm)
            default: ALUControl = 4'b0010; // Default to ADDa
        endcase
    end

endmodule