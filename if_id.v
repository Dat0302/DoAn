module if_id (
    input clk,
    input rst_n,
    input [31:0] pc_in,
    input [31:0] instruction_in,
    output reg [31:0] pc_out,
    output reg [31:0] instruction_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 0;
            instruction_out <= 0;
        end else begin
            pc_out <= pc_in;
            instruction_out <= instruction_in;
        end
    end
endmodule