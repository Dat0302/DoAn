module decoder_wb (
    input  [31:0] Addr,
    output [5:0]  Sel
);

    assign bSel = (Addr[31:28] == 4'h0) ? 6'b000001 :  // RAM
                  (Addr[31:28] == 4'h1) ? 6'b000010 :  // GPIO
                  (Addr[31:28] == 4'h2) ? 6'b000100 :  // PWM
                                           6'b000000;

endmodule
