module control_unit (
    input  [6:0] opcode,
    output reg RegWrite,
    output reg MemToReg,
    output reg MemRead,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ALUOp,
    output reg Branch,
	 output reg Jump
);



    always @(*) begin
        // Default values
        RegWrite  = 0;
        MemToReg  = 0;
        MemRead   = 0;
        MemWrite  = 0;
        ALUSrc    = 0;
        ALUOp     = 2'b00;
        Branch    = 0;
		  Jump      =0;

        case (opcode)
            // R-type (e.g., add, sub)
            7'b0110011: begin
                RegWrite = 1;
                ALUOp    = 2'b10;
            end
            // I-type (e.g., addi, lw)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
            end
            // Load (lw)
            7'b0000011: begin
                RegWrite = 1;
                MemToReg = 1;
                MemRead  = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00;
            end
            // Store (sw)
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00;
            end
            // Branch (beq)
            7'b1100011: begin
                Branch   = 1;
                ALUOp    = 2'b01;
            end
            // jal
            7'b1101111: begin
					 RegWrite = 1;
					 Jump     = 1;
					 ALUSrc   = 1;
					 ALUOp    = 2'b11;
				end
				//jalr
				7'b1100111: begin
					 RegWrite = 1;
					 Jump     = 1;
					 ALUSrc   = 1;
					 ALUOp    = 2'b11;
				end
            default: begin
                // Default case (no operation)
            end
        endcase
    end

endmodule