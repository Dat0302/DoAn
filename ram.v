module ram (
    input         clk,      // Clock
    input  [31:0] a,        // Address
    input         we,       // Write Enable
	 input         re,		// Read Enable
    input  [31:0] wd,       // Write Data
    output reg [31:0] rd        // Read Data
);
    // Khai báo bộ nhớ RAM gồm 64 ô nhớ, mỗi ô 32-bit
    reg [31:0] ram [0:63];
    // Ghi dữ liệu vào RAM vào cạnh lên của xung clock nếu `we` được kích hoạt
    always @(posedge clk) begin
        if (we)
            ram[a[31:2]] <= wd;
    end
	always@(*) begin
	if(re)
		rd = ram[a[31:2]];
	else 
		rd=32'b0;
	end
endmodule