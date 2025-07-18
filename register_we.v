module register_we (
    input        clk,
    input        rst,          
    input        we,
    input  [15:0] d,
    output reg [15:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 16'b0;
        else if (we)
            q <= d;
    end
endmodule
