module register_file_pipeline (
    input wire clk,
    input wire [4:0] a1, a2, a3,
    input wire [31:0] wd3,
    input wire we3,
    output wire [31:0] rd1, rd2
);
    reg [31:0] rf [0:31]; 
	always @ (posedge clk) begin
	if(we3) rf [a3] <= wd3;
	end
   assign rd1 =(a1 == a3 && we3) ? wd3 : (a1 != 0) ? rf [a1] : 32'b0;
	assign rd2 = (a2 == a3 && we3) ? wd3 :(a2 != 0) ? rf [a2] : 32'b0;	
endmodule