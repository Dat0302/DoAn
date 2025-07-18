`timescale 1ns / 1ps

module tb_datapath_pipeline_debug;

    // Inputs
    reg clk;
    reg rst_n;

    // Outputs
    wire [31:0] instr, instr_if_id, instr_ex, instr_mem, instr_wb;
    wire [31:0] signImm, aluResult_ex, alu_result_mem, alu_result_wb;
    wire Branch_mem, Jump_mem;
    wire ifbranch;

    // Instantiate the Unit Under Test (UUT)
    datapath_pipeline_debug uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .instr(instr), 
        .instr_if_id(instr_if_id),
        .instr_ex(instr_ex),
        .instr_mem(instr_mem),
        .instr_wb(instr_wb),
        .signImm(signImm),
        .aluResult_ex(aluResult_ex),
        .alu_result_mem(alu_result_mem),
        .alu_result_wb(alu_result_wb),
        .Branch_mem(Branch_mem),
        .Jump_mem(Jump_mem),
        .ifbranch(ifbranch)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Step 1: Reset
        rst_n = 0;
        #20;
        rst_n = 1;

        // Step 2: Run simulation for N cycles
        repeat (50) @(posedge clk);

        // Step 3: End simulation
        $finish;
    end

    // Optional: Monitor internal signals
    initial begin
        $monitor("Time=%0t, rst_n=%b, instr=%h,instr_if_id=%h,instr_ex=%h,instr_mem=%h, aluResult_ex=%d, signImm=%d,  Jump_mem=%b,  ifbranch=%b",
                 $time, rst_n, instr,instr_if_id,instr_ex,instr_mem, aluResult_ex, signImm, Jump_mem, ifbranch);
    end

endmodule
