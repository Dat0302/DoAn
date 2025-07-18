module mem_wb (
    input clk,
    input rst_n,
    input [31:0] alu_result_in,
    input [31:0] mem_data_in,
    input RegWrite_in, MemToReg_in,
	 input Jump_in,
	 input [31:0] instr_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_data_out,
    output reg RegWrite_out, MemToReg_out,
	 output reg Jump_out,
	 output reg [31:0] instr_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 0;
            mem_data_out <= 0;
            RegWrite_out <= 0;
            MemToReg_out <= 0;
				Jump_out <= 0;
				instr_out <=0;
        end else begin
            alu_result_out <= alu_result_in;
            mem_data_out <= mem_data_in;
            RegWrite_out <= RegWrite_in;
            MemToReg_out <= MemToReg_in;
				Jump_out <= Jump_in;
				instr_out <= instr_in;
        end
    end
endmodule