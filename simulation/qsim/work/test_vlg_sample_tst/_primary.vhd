library verilog;
use verilog.vl_types.all;
entity test_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end test_vlg_sample_tst;
