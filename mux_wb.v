module mux_wb (
    input  [5:0]  Sel,
    input  [31:0] in0, in1, in2, in3, in4, in5,
    output [31:0] out
);

    assign out = Sel[0] ? in0 :
                 Sel[1] ? in1 :
                 Sel[2] ? in2 :
                 Sel[3] ? in3 :
                 Sel[4] ? in4 :
                 Sel[5] ? in5 :
                 32'b0;

endmodule
