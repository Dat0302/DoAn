// Testbench for Simple SPI
// ========================
module tb_spi;

    reg clk, rst;
    reg [31:0] wb_adr_i;
    reg [31:0] wb_dat_i;
    wire [31:0] wb_dat_o;
    reg wb_we_i, wb_stb_i, wb_cyc_i;
    wire wb_ack_o;

    reg miso;
    wire mosi, sclk, cs;

    // Clock generation
    always #5 clk = ~clk;

    // Echo: miso follows mosi with a delay
    always @(posedge sclk) begin
        miso <= mosi;
    end

    // Instantiate DUT
    wb_spi dut (
        .clk(clk), .rst(rst),
        .wb_adr_i(wb_adr_i), .wb_dat_i(wb_dat_i), .wb_dat_o(wb_dat_o),
        .wb_we_i(wb_we_i), .wb_stb_i(wb_stb_i), .wb_cyc_i(wb_cyc_i), .wb_ack_o(wb_ack_o),
        .miso(miso), .mosi(mosi), .sclk(sclk), .cs(cs)
    );

    initial begin
        $display("=== SPI Simple Test ===");
        clk = 0; rst = 1;
        wb_we_i = 0; wb_stb_i = 0; wb_cyc_i = 0;
        wb_adr_i = 32'h00008000; wb_dat_i = 32'h00000000;
        #20 rst = 0;

        // Send A5
        #10 wb_dat_i = 32'h000000A5;
            wb_we_i = 1; wb_stb_i = 1; wb_cyc_i = 1;
        #10 wb_we_i = 0; wb_stb_i = 0; wb_cyc_i = 0;

        // Wait for SPI transaction to finish
        #200;

        $display("SPI Received = %h", wb_dat_o);
        $finish;
    end
endmodule
