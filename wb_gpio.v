// Wishbone-compatible GPIO (8-bit input/output)
module wb_gpio (
    input         clk,
    input         rst,
    input  [31:0] wb_adr_i,
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input         wb_we_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    output        wb_ack_o,

    input  [7:0]  gpio_in,
    output reg [7:0] gpio_out
);
    reg ack;
    reg [31:0] read_data;

    assign wb_dat_o = read_data;
    assign wb_ack_o = ack;
    wire valid = wb_cyc_i && wb_stb_i;

    always @(posedge clk) begin
        if (rst) begin
            ack <= 0;
            gpio_out <= 0;
            read_data <= 0;
        end else begin
            ack <= 0;
            if (valid && !ack) begin
                ack <= 1;
                case (wb_adr_i[3:2])
                    2'b00: begin
                        if (wb_we_i)
                            gpio_out <= wb_dat_i[7:0];
                        read_data <= {24'b0, gpio_out};
                    end
                    2'b01: begin
                        read_data <= {24'b0, gpio_in};
                    end
                    default: begin
                        read_data <= 32'hDEAD_BEEF;
                    end
                endcase
            end
        end
    end
endmodule
