module imm_gen (
    input  [31:0] instruction,
    output reg [31:0] imm
);

    // Extract opcode (bits 6-0)
    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            // I-type (e.g., addi, lw, jalr)	
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend 12-bit immediate
            end
            // S-type (e.g., sw)
            7'b0100011: begin
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend 12-bit immediate
            end
            // B-type (e.g., beq)
            7'b1100011: begin
                imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // Sign-extend 13-bit immediate
            end
            // U-type (e.g., lui, auipc)
            7'b0110111, 7'b0010111: begin
                imm = {instruction[31:12], 12'b0}; // Upper 20 bits, lower 12 bits are 0
            end
            // J-type (e.g., jal)
            7'b1101111: begin
                imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // Sign-extend 21-bit immediate
            end
            default: begin
                imm = 32'b0; // Default case (R-type has no immediate)
            end
        endcase
    end

endmodule