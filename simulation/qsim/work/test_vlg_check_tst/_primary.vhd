library verilog;
use verilog.vl_types.all;
entity test_vlg_check_tst is
    port(
        imAddr          : in     vl_logic_vector(31 downto 0);
        instr           : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end test_vlg_check_tst;
