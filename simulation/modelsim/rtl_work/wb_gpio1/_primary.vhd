library verilog;
use verilog.vl_types.all;
entity wb_gpio1 is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        gpio_in         : in     vl_logic_vector(31 downto 0);
        gpio_out        : out    vl_logic_vector(31 downto 0)
    );
end wb_gpio1;
