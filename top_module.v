module top_module (
    input         clk,
    input         rst,
    input  [15:0] gpioInput,
    output [15:0] gpioOutput
);

    // ===== Wires giữa CPU và Bus =====
    wire [31:0] instr, aluResult;
    wire [31:0] bAddr, bWData, bRData;
    wire [5:0]  bSel;
	 wire 		 MemRead;
    wire        MemWrite;

    // ===== Các dữ liệu đọc từ từng slave =====
    wire [31:0] ramRData, gpioRData;

    // ===== CPU =====
    datapath_pipeline_wb cpu1(
	.clk(clk),
	.rst_n(~rst),

	.instr(instr),
    .bAddr(bAddr),
    .bRData(bRData),
    .bWData(bWData),
    .MemRead(MemRead),
    .MemWrite(MemWrite)
);


    // ===== RAM (Memory Slave) =====
    ram ram_slave (
        .clk(clk),
        .a(bAddr),
        .we(bSel[0] & MemWrite),
		  .re(MemRead),
        .wd(bWData),
        .rd(ramRData)
    );

    // ===== GPIO Slave =====
    gpio gpio_slave (
        .clk(clk),
        .rst(rst),
        .bSel(bSel[1]),
        .bWrite(MemWrite),
        .bAddr(bAddr),
        .bWData(bWData),
        .bRData(gpioRData),
        .gpioInput(gpioInput),
        .gpioOutput(gpioOutput)
    );


    // ===== Simple Bus: Decoder + Mux =====
    bus bus_simple (
        .bAddr(bAddr),
        .bRData0(ramRData),
        .bRData1(gpioRData),
        .bRData(bRData),
        .bSel(bSel)
    );

endmodule
