library verilog;
use verilog.vl_types.all;
entity gpio is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        data_in         : in     vl_logic_vector(31 downto 0);
        we              : in     vl_logic;
        data_out        : out    vl_logic_vector(31 downto 0);
        gpio_in         : in     vl_logic_vector(31 downto 0);
        gpio_out        : out    vl_logic_vector(31 downto 0)
    );
end gpio;
