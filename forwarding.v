module forwarding (
    input [4:0] rs1_ex, rs2_ex, rd_mem, rd_wb,
    input RegWrite_mem, RegWrite_wb,
    input [6:0] opcode_ex,
    output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        forwardA = 2'b00; forwardB = 2'b00;
        // ForwardA cho rs1_ex (tất cả loại lệnh dùng rs1: I-type, R-type, S-type, B-type, jalr)
        if (RegWrite_mem && rd_mem != 0 && rd_mem == rs1_ex) forwardA = 2'b01;
        if (RegWrite_wb && rd_wb != 0 && rd_wb == rs1_ex) forwardA = 2'b10;
        // ForwardB chỉ cho rs2_ex của R-type, S-type, B-type
        if ((opcode_ex == 7'b0110011 || opcode_ex == 7'b0100011 || opcode_ex == 7'b1100011) &&
            RegWrite_mem && rd_mem != 0 && rd_mem == rs2_ex) forwardB = 2'b01;
        if ((opcode_ex == 7'b0110011 || opcode_ex == 7'b0100011 || opcode_ex == 7'b1100011) &&
            RegWrite_wb && rd_wb != 0 && rd_wb == rs2_ex) forwardB = 2'b10;
    end
endmodule