module pc(clk,rst_n,q,d);
	input clk;
	input rst_n;
	input [31:0]d;
	output reg [31:0] q;
	
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin 
			q<= {32{1'b0}};
		end else 
			q <=d;
		end
endmodule
	