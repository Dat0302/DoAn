library verilog;
use verilog.vl_types.all;
entity test is
    port(
        clk             : in     vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        imAddr          : out    vl_logic_vector(31 downto 0);
        instr           : out    vl_logic_vector(31 downto 0)
    );
end test;
