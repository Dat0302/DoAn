module wb_gpio1 (
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input         wb_we_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output reg    wb_ack_o,
    input  [31:0] gpio_in,
    output [31:0] gpio_out
);

    wire valid = wb_stb_i & wb_cyc_i;

    always @(posedge clk or posedge rst) begin
        if (rst)
            wb_ack_o <= 1'b0;
        else
            wb_ack_o <= valid;
    end

    gpio u_gpio (
        .clk(clk),
        .rst(rst),
        .data_in(wb_dat_i),
        .we(wb_we_i & valid),
        .data_out(wb_dat_o),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out)
    );

endmodule