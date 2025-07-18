	module uart_wishbone_wrapper (
    // Wishbone Bus Interface
    input              clk,     // Clock
    input              rstn,     // Reset (active high)
    input              wb_cyc_i,     // Cycle valid
    input              wb_stb_i,     // Strobe
    output reg         wb_ack_o,     // Acknowledge
    input       [3:0]  wb_adr_i,     // Address bus
    input              wb_we_i,      // Write enable
    input       [7:0]  wb_dat_i,     // Data input
    output reg  [7:0]  wb_dat_o,     // Data output
    
    // UART Interface
    output             uart_txd,     // UART transmit
    input              uart_rxd      // UART receive
);

// Register addresses
localparam REG_TX_DATA    = 4'h0;  // Transmit data register (write-only)
localparam REG_RX_DATA    = 4'h1;  // Receive data register (read-only)
localparam REG_STATUS     = 4'h2;  // Status register (read-only)

// Status register bits
localparam STATUS_TX_BUSY = 0;     // Transmitter busy
localparam STATUS_RX_VALID = 1;    // Receive data valid
localparam STATUS_RX_BREAK = 2;    // Break condition detected

// Internal signals
wire       tx_busy;
wire       rx_valid;
wire       rx_break;
wire [7:0] rx_data;

// Instantiate UART transmitter
uart_tx #(
    .BIT_RATE(9600),
    .CLK_HZ(50_000_000)
) uart_tx_inst (
    .clk(clk),
    .resetn(rstn),
    .uart_txd(uart_txd),
    .uart_tx_en(wb_stb_i && wb_we_i && (wb_adr_i == REG_TX_DATA)),
    .uart_tx_busy(tx_busy),
    .uart_tx_data(wb_dat_i)
);

// Instantiate UART receiver
uart_rx #(
    .BIT_RATE(9600),
    .CLK_HZ(50_000_000)
) uart_rx_inst (
    .clk(clk),
    .resetn(rstn),
    .uart_rxd(uart_rxd),
    .uart_rx_en(1'b1),             // Luôn bật receiver
    .uart_rx_break(rx_break),
    .uart_rx_valid(rx_valid),
    .uart_rx_data(rx_data)
);

// Wishbone bus handling
always @(posedge clk) begin
    if (rstn==0) begin
        wb_ack_o <= 1'b0;
        wb_dat_o <= 8'h00;
    end else begin
        // Defaults
        wb_ack_o <= 1'b0;
        
        // Handle Wishbone transactions
        if (wb_cyc_i && wb_stb_i && !wb_ack_o) begin
            wb_ack_o <= 1'b1;
            
            if (wb_we_i) begin
                // Write operation - chỉ xử lý ghi vào TX_DATA
                if (wb_adr_i == REG_TX_DATA) begin
                    // Việc ghi đã được xử lý bởi uart_tx instantiation
                end
            end else begin
                // Read operation
                case (wb_adr_i)
                    REG_RX_DATA: begin
                        wb_dat_o <= rx_data;
                        // Reading RX_DATA không tự động clear valid flag
                        // (để phần mềm tự quản lý)
                    end
                    REG_STATUS: begin
                        wb_dat_o <= {5'b0, rx_break, rx_valid, tx_busy};
                    end
                    default: begin
                        wb_dat_o <= 8'h00;
                    end
                endcase
            end
        end
    end
end

endmodule