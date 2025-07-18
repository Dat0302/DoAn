module gpio (
    input         clk,
    input         rst,
    input  [31:0] data_in,
    input         we,             // Write Enable
    output [31:0] data_out,
    input  [31:0] gpio_in,        // Tín hiệu input vật lý từ ngoài
    output [31:0] gpio_out        // Tín hiệu output vật lý
);

    reg [31:0] gpio_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            gpio_reg <= 32'b0;
        else if (we)
            gpio_reg <= data_in;
    end

    assign data_out = gpio_in;
    assign gpio_out = gpio_reg;

endmodule
