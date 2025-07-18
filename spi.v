// SPI Core - Simple shift logic
// ========================
module spi (
    input         clk,
    input         rst,
    input         start,
    input  [7:0]  data_in,
    output [7:0]  data_out,
    output        busy,
    output reg    mosi,
    input         miso,
    output reg    sclk,
    output reg    cs
);

    reg [7:0] shift_reg;
    reg [7:0] recv_reg;
    reg [2:0] bit_cnt;
    reg       working;

    assign busy = working;
    assign data_out = recv_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 8'd0;
            recv_reg  <= 8'd0;
            bit_cnt   <= 3'd0;
            sclk      <= 0;
            cs        <= 1;
            working   <= 0;
        end else if (start && !working) begin
            shift_reg <= data_in;
            bit_cnt   <= 3'd7;
            cs        <= 0;
            working   <= 1;
        end else if (working) begin
            sclk <= ~sclk;
            if (sclk == 0) begin // Rising edge: shift out
                mosi <= shift_reg[bit_cnt];
            end else begin // Falling edge: sample input
                recv_reg[bit_cnt] <= miso;
                if (bit_cnt == 0) begin
                    working <= 0;
                    cs <= 1;
                end else begin
                    bit_cnt <= bit_cnt - 1;
                end
            end
        end
    end
endmodule