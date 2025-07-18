// Simple SPI Wishbone Wrapper
// ========================
module wb_spi (
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input         wb_we_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output reg    wb_ack_o,
    input         miso,
    output        mosi,
    output        sclk,
    output        cs
);

    wire valid = wb_stb_i & wb_cyc_i;
    reg start;
    wire busy;
    wire [7:0] data_out;

    assign wb_dat_o = {24'b0, data_out};

    always @(posedge clk or posedge rst) begin
        if (rst)
            wb_ack_o <= 0;
        else
            wb_ack_o <= valid;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            start <= 0;
        else if (valid && wb_we_i)
            start <= 1;
        else
            start <= 0;
    end

    spi u_spi (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(wb_dat_i[7:0]),
        .data_out(data_out),
        .busy(busy),
        .mosi(mosi),
        .miso(miso),
        .sclk(sclk),
        .cs(cs)
    );
endmodule
