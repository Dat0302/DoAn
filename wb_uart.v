// ========================
module wb_uart (
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input         wb_we_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output reg    wb_ack_o,
    output        tx,
    input         rx
);

    wire valid = wb_stb_i & wb_cyc_i;
    wire tx_busy;
    wire rx_done;
    wire [7:0] rx_data;
    reg        tx_start;

    assign wb_dat_o = {24'b0, rx_data};

    always @(posedge clk or posedge rst) begin
        if (rst)
            wb_ack_o <= 0;
        else
            wb_ack_o <= valid;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            tx_start <= 0;
        else if (valid && wb_we_i)
            tx_start <= 1;
        else
            tx_start <= 0;
    end

    uart u_uart (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(wb_dat_i[7:0]),
        .tx(tx),
        .tx_busy(tx_busy),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );
endmodule