module wb_interconnect (
    // Wishbone Master Interface (from CPU)
    input         wbm_cyc_i,
    input         wbm_stb_i,
    input         wbm_we_i,
    input  [31:0] wbm_adr_i,
    input  [31:0] wbm_dat_i,
    output [31:0] wbm_dat_o,
    output        wbm_ack_o,
    
    // Wishbone Slave 0: RAM
    output        wbs0_cyc_o,
    output        wbs0_stb_o,
    output        wbs0_we_o,
    output [31:0] wbs0_adr_o,
    output [31:0] wbs0_dat_o,
    input  [31:0] wbs0_dat_i,
    input         wbs0_ack_i,
    
    // Wishbone Slave 1: UART
    output        wbs1_cyc_o,
    output        wbs1_stb_o,
    output        wbs1_we_o,
    output [31:0] wbs1_adr_o,
    output [31:0] wbs1_dat_o,
    input  [31:0] wbs1_dat_i,
    input         wbs1_ack_i,
	// Wishbone Slave 2: GPIO
    output        wbs2_cyc_o,
    output        wbs2_stb_o,
    output        wbs2_we_o,
    output [31:0] wbs2_adr_o,
    output [31:0] wbs2_dat_o,
    input  [31:0] wbs2_dat_i,
    input         wbs2_ack_i
);

// Address Decoding
wire ram_select  = (wbm_adr_i[31:16] == 16'h0000);
wire uart_select = (wbm_adr_i[31:4]  == 28'h1000000); // Match 0x10000000-0x1000000F
wire gpio_select = (wbm_adr_i[31:4]  == 28'h2000000);
// Connect to RAM
assign wbs0_cyc_o = wbm_cyc_i && ram_select;
assign wbs0_stb_o = wbm_stb_i && ram_select;
assign wbs0_we_o  = wbm_we_i;
assign wbs0_adr_o = wbm_adr_i;
assign wbs0_dat_o = wbm_dat_i;

// Connect to UART
assign wbs1_cyc_o = wbm_cyc_i && uart_select;
assign wbs1_stb_o = wbm_stb_i && uart_select;
assign wbs1_we_o  = wbm_we_i;
assign wbs1_adr_o = {4'b0, wbm_adr_i[3:0]}; // Only lower 4 bits for UART regs
assign wbs1_dat_o = wbm_dat_i;

// Connect to GPIO
assign wbs2_cyc_o = wbm_cyc_i && gpio_select;
assign wbs2_stb_o = wbm_stb_i && gpio_select;
assign wbs2_we_o  = wbm_we_i;
assign wbs2_adr_o =  wbm_adr_i[3:0]; // Only lower 4 bits for UART regs
assign wbs2_dat_o = wbm_dat_i;

// Mux for read data and ack
assign wbm_dat_o = ram_select  ? wbs0_dat_i :
                   uart_select ? wbs1_dat_i :
						 gpio_select ? wbs2_dat_o:
                   32'h00000000;
                   
assign wbm_ack_o = (ram_select  && wbs0_ack_i) ||
                   (uart_select && wbs1_ack_i)||
						 (gpio_select && wbs2_ack_i);

endmodule