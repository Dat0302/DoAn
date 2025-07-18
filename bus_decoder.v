module bus_decoder (
    input  [31:0] bAddr,
    output [5:0]  bSel
);
    assign bSel[0] = (bAddr[15:14] == 2'b00);                 // RAM: 0x00000000 – 0x00003FFF
    assign bSel[1] = (bAddr[15:4] == 12'h7F0);                // GPIO: 0x00007F00 – 0x00007F0F
    assign bSel[2] = (bAddr[15:4] == 12'h7F1);                // PWM : 0x00007F10 – 0x00007F1F
    assign bSel[3] = 1'b0;                                    // không dùng
    assign bSel[4] = 1'b0;                                    // không dùng
    assign bSel[5] = 1'b0;                                    // không dùng
endmodule
