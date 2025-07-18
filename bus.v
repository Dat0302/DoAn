module bus (
    input  [31:0] bAddr,
    input  [31:0] bRData0,  // RAM
    input  [31:0] bRData1,  // GPIO
    output [31:0] bRData,
    output [5:0]  bSel
);

    // Decoder: chọn slave
    bus_decoder decoder (
        .bAddr(bAddr),
        .bSel(bSel)
    );

    // Mux: chọn dữ liệu đọc từ đúng slave
    bus_mux mux (
        .bSel(bSel),
        .in0(bRData0),
        .in1(bRData1),
        .in2(32'b0),
        .in3(32'b0),  // unused
        .in4(32'b0),  // unused
        .in5(32'b0),  // unused
        .out(bRData)
    );

endmodule
