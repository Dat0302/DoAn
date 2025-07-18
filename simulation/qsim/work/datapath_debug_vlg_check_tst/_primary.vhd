library verilog;
use verilog.vl_types.all;
entity datapath_debug_vlg_check_tst is
    port(
        aluResult       : in     vl_logic_vector(31 downto 0);
        alu_op          : in     vl_logic_vector(1 downto 0);
        branch          : in     vl_logic;
        funct3          : in     vl_logic_vector(2 downto 0);
        funct7          : in     vl_logic_vector(6 downto 0);
        imAddr          : in     vl_logic_vector(5 downto 0);
        instr           : in     vl_logic_vector(31 downto 0);
        opcode          : in     vl_logic_vector(6 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        rd1             : in     vl_logic_vector(31 downto 0);
        rd2             : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end datapath_debug_vlg_check_tst;
