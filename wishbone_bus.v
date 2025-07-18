module wishbone_bus (
    input        clk,
    input        rst_n,

    // Tín hiệu từ CPU (master)
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    input         wb_we_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o,

    // Tín hiệu đến RAM (slave)
    output        ram_we,
    output        ram_re,
    output [31:0] ram_addr,
    output [31:0] ram_wd,
    input  [31:0] ram_rd,
    input         ram_ack
);

    wire ram_sel = (wb_adr_i[31:18] == 14'h0000);  // vùng RAM

    assign ram_we    = wb_we_i & ram_sel;
    assign ram_re    = ~wb_we_i & ram_sel & wb_cyc_i & wb_stb_i;
    assign ram_addr  = wb_adr_i;
    assign ram_wd    = wb_dat_i;

    assign wb_dat_o  = ram_rd;
    assign wb_ack_o  = ram_sel & (wb_cyc_i & wb_stb_i); // Đơn giản: giả định luôn ready

endmodule
