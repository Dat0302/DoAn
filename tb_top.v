`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst;
    reg [15:0] gpioInput;
    wire [15:0] gpioOutput;

    // Instantiate top module
    top_module uut (
        .clk(clk),
        .rst(rst),
        .gpioInput(gpioInput),
        .gpioOutput(gpioOutput)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz

    initial begin
        // Initial values
        clk = 0;
        rst = 1;
        gpioInput = 16'hA5A5;

        // Apply reset
        #20;
        rst = 0;

        // Run simulation for a while
        #500;

        // Stimulus example: change GPIO input
        gpioInput = 16'h1234;
        #100;

        $display("GPIO Output: %h", gpioOutput);

        // Finish
        $stop;
    end

endmodule
