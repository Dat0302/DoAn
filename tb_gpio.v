// Testbench for GPIO
// ========================
module tb_gpio;

    reg clk, rst;
    reg [31:0] wb_adr_i, wb_dat_i;
    wire [31:0] wb_dat_o;
    reg wb_we_i, wb_stb_i, wb_cyc_i;
    wire wb_ack_o;

    reg [31:0] gpio_in;
    wire [31:0] gpio_out;

    // Instantiate GPIO wrapper
    wb_gpio1 dut (
        .clk(clk), .rst(rst),
        .wb_adr_i(wb_adr_i), .wb_dat_i(wb_dat_i), .wb_dat_o(wb_dat_o),
        .wb_we_i(wb_we_i), .wb_stb_i(wb_stb_i), .wb_cyc_i(wb_cyc_i), .wb_ack_o(wb_ack_o),
        .gpio_in(gpio_in), .gpio_out(gpio_out)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("=== GPIO Test ===");
        clk = 0; rst = 1; gpio_in = 32'hA5A5A5A5;
        wb_we_i = 0; wb_stb_i = 0; wb_cyc_i = 0; wb_adr_i = 0; wb_dat_i = 0;
        #20 rst = 0;

        // Write 0x12345678 to GPIO
        #10 wb_adr_i = 32'h00007F00;
            wb_dat_i = 32'h12345678;
            wb_we_i = 1; wb_stb_i = 1; wb_cyc_i = 1;
        #10 wb_we_i = 0; wb_stb_i = 0; wb_cyc_i = 0;

        // Wait and read back
        #10 wb_we_i = 0; wb_stb_i = 1; wb_cyc_i = 1;
        #10 wb_stb_i = 0; wb_cyc_i = 0;

        #20;
        $display("GPIO Output = %h , Data Out = %h ", gpio_out, wb_dat_o,);
        $finish;
    end
endmodule
