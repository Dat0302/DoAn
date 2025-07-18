// ========================
module uart (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    output       tx,
    output       tx_busy,
    input        rx,
    output reg [7:0] rx_data,
    output reg   rx_done
);

    reg [9:0] tx_shift;
    reg [3:0] tx_cnt;
    reg       tx_reg;
    reg       tx_active;

    assign tx = tx_reg;
    assign tx_busy = tx_active;

    // Transmitter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_active <= 0;
            tx_cnt <= 0;
            tx_reg <= 1;
        end else if (tx_start && !tx_active) begin
            tx_shift <= {1'b1, tx_data, 1'b0};
            tx_cnt <= 0;
            tx_active <= 1;
        end else if (tx_active) begin
            tx_reg <= tx_shift[tx_cnt];
            tx_cnt <= tx_cnt + 1;
            if (tx_cnt == 9)
                tx_active <= 0;
        end
    end

    // Receiver
    reg [3:0] rx_cnt;
    reg       rx_active;
    reg [7:0] rx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_cnt <= 0;
            rx_active <= 0;
            rx_done <= 0;
            rx_data <= 0;
        end else begin
            rx_done <= 0;
            if (!rx_active && rx == 0) begin
                rx_active <= 1;
                rx_cnt <= 0;
            end else if (rx_active) begin
                rx_cnt <= rx_cnt + 1;
               if (rx_cnt >= 1 && rx_cnt <= 8)
                    rx_shift[8 - rx_cnt] <= rx;
                else if (rx_cnt == 9) begin
                    rx_data <= rx_shift;
                    rx_done <= 1;
                    rx_active <= 0;
                end
            end
        end
    end
endmodule