module system_top (
    input  clk,
    input  rst_n,
    
    // UART Interface
    output uart_txd,
    input  uart_rxd,
	 inout [7:0] gpio_io
);

    // Wishbone signals
    wire        wb_cyc, wb_stb, wb_we, wb_ack;
    wire [31:0] wb_adr, wb_wdata, wb_rdata;
    
    // RAM signals
    wire        ram_cyc, ram_stb, ram_we, ram_ack;
    wire [31:0] ram_adr, ram_wdata, ram_rdata;
    
    // UART signals
    wire        uart_cyc, uart_stb, uart_we, uart_ack;
    wire [31:0] uart_adr, uart_wdata, uart_rdata;
	   // GPIO signals
    wire        gpio_cyc, gpio_stb, gpio_we, gpio_ack;
    wire [31:0] gpio_adr, gpio_wdata, gpio_rdata;

    // CPU Pipeline
    cpu_pipeline5_wb u_cpu (
        .clk(clk),
        .rst_n(rst_n),
        .wb_cyc_o(wb_cyc),
        .wb_stb_o(wb_stb),
        .wb_we_o(wb_we),
        .wb_adr_o(wb_adr),
        .wb_dat_o(wb_wdata),
        .wb_dat_i(wb_rdata),
        .wb_ack_i(wb_ack)
    );
    
    // Wishbone Interconnect
    wb_interconnect u_intercon (
        // Master interface
        .wbm_cyc_i(wb_cyc),
        .wbm_stb_i(wb_stb),
        .wbm_we_i(wb_we),
        .wbm_adr_i(wb_adr),
        .wbm_dat_i(wb_wdata),
        .wbm_dat_o(wb_rdata),
        .wbm_ack_o(wb_ack),
        
        // RAM slave
        .wbs0_cyc_o(ram_cyc),
        .wbs0_stb_o(ram_stb),
        .wbs0_we_o(ram_we),
        .wbs0_adr_o(ram_adr),
        .wbs0_dat_o(ram_wdata),
        .wbs0_dat_i(ram_rdata),
        .wbs0_ack_i(ram_ack),
        
        // UART slave
        .wbs1_cyc_o(uart_cyc),
        .wbs1_stb_o(uart_stb),
        .wbs1_we_o(uart_we),
        .wbs1_adr_o(uart_adr),
        .wbs1_dat_o(uart_wdata),
        .wbs1_dat_i(uart_rdata),
        .wbs1_ack_i(uart_ack),
		  
        // GPIO slave
        .wbs2_cyc_o(gpio_cyc),
        .wbs2_stb_o(gpio_stb),
        .wbs2_we_o(gpio_we),
        .wbs2_adr_o(gpio_adr),
        .wbs2_dat_o(gpio_wdata),
        .wbs2_dat_i(gpio_rdata),
        .wbs2_ack_i(gpio_ack)
    );
    
    // RAM (1KB for example)
  wb_ram_wrapper ram_wb(
    // Wishbone Interface
    .clk(clk),
    .rst_n(rst_n),
    .wb_cyc_i(ram_cyc),
    .wb_stb_i(ram_stb),
    .wb_we_i(ram_we),
    .wb_adr_i(ram_adr),
    .wb_dat_i(ram_wdata),
    .wb_dat_o(ram_rdata),
    .wb_ack_o(ram_ack)
);
    
    // UART Controller
    uart_wishbone_wrapper u_uart (
        .clk(clk),
        .rstn(rst_n),
        .wb_cyc_i(uart_cyc),
        .wb_stb_i(uart_stb),
        .wb_we_i(uart_we),
        .wb_adr_i(uart_adr[3:0]), // Only 4 bits needed
        .wb_dat_i(uart_wdata[7:0]),
        .wb_dat_o(uart_rdata[7:0]),
        .wb_ack_o(uart_ack),
        .uart_txd(uart_txd),
        .uart_rxd(uart_rxd)
    );

	 gpio_wb u_gpio(
	    .wb_clk(clk),
	    .wb_rst(~rst_n),
	    
	    .wb_adr_i(gpio_adr[3:0]),
	    .wb_dat_i(gpio_wdata[7:0]),
	    .wb_we_i(gpio_we),
	    .wb_cyc_i(gpio_cyc),
	    .wb_stb_i(gpio_stb),

	    .wb_ack_o(gpio_ack),
	    .wb_dat_o(gpio_rdata),


	    .gpio_io(gpio_io));

endmodule