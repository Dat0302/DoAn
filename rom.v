module rom(
    input [5:0] a,         
    output reg [31:0] rd       
);

    reg [31:0] rom [64 - 1:0];        
    
    initial begin
       //$readmemh("program.hex", rom); 
		 $readmemh("shift.hex", rom); 
    end
	
	 always @(*) begin
		 rd = rom[a];
	end
endmodule