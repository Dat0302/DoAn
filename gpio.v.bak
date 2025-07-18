module gpio (
    input         clk,
    input         rst,
    input         bSel,            // chọn GPIO từ decoder
    input         bWrite,          // tín hiệu ghi
    input  [31:0] bAddr,           // địa chỉ bus
    input  [31:0] bWData,          // dữ liệu ghi từ CPU
    output reg [31:0] bRData,      // dữ liệu đọc về CPU
    input  [15:0] gpioInput,       // dữ liệu từ các chân input ngoài
    output [15:0] gpioOutput       // xuất ra chân GPIO
);

    wire [15:0] gpioIn;
    wire [15:0] gpioOut;
    wire        gpioOutWe;

    assign gpioOut     = bWData[15:0];  // chỉ quan tâm 16 bit thấp
    assign gpioOutWe   = bSel & bWrite & (bAddr[3:0] == 4'h4);

    // REG IN lưu giữ dữ liệu input
    register_we reg_in (
        .clk(clk),
        .rst(rst),
        .we(1'b1),               // luôn update từ chân ngoài
        .d(gpioInput),
        .q(gpioIn)
    );

    // REG OUT lưu giữ dữ liệu output khi ghi từ CPU
    register_we reg_out (
        .clk(clk),
        .rst(rst),
        .we(gpioOutWe),
        .d(gpioOut),
        .q(gpioOutput)
    );

    // Read mux theo địa chỉ
    always @(*) begin
        case (bAddr[3:0])
            4'h0: bRData = { 16'b0, gpioIn };       // GPIO input register
            4'h4: bRData = { 16'b0, gpioOutput };   // GPIO output register
            default: bRData = { 16'b0, gpioIn };    // mặc định đọc input
        endcase
    end

endmodule
