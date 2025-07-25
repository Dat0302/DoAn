module wb_ram_wrapper (
    // Wishbone Interface
    input         clk,
    input         rst_n,
    input         wb_cyc_i,
    input         wb_stb_i,
    input         wb_we_i,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    output        wb_ack_o
);

	    // RAM Interface
    wire [31:0] ram_addr;
    wire        ram_we;
    wire        ram_re;
    wire [31:0] ram_wd;
    wire  [31:0] ram_rd;
    // Control signals
    assign ram_we = wb_cyc_i & wb_stb_i & wb_we_i;
    assign ram_re = wb_cyc_i & wb_stb_i & ~wb_we_i;
    
    // Address and data
    assign ram_addr = wb_adr_i;
    assign ram_wd = wb_dat_i;
    assign wb_dat_o = ram_rd;
    
	 
	ram u_ram (
        .clk(clk),
        .a(ram_addr),
        .we(ram_we),
        .re(ram_re),
        .wd(ram_wd),
        .rd(ram_rd)
    );
    // Acknowledge generation (combinational ready)
    assign wb_ack_o = wb_cyc_i & wb_stb_i;
	 
    
endmodule