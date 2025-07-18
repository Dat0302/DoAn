library verilog;
use verilog.vl_types.all;
entity datapath_debug is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        aluResult       : out    vl_logic_vector(31 downto 0);
        rd1             : out    vl_logic_vector(31 downto 0);
        rd2             : out    vl_logic_vector(31 downto 0);
        alu_op          : out    vl_logic_vector(1 downto 0);
        opcode          : out    vl_logic_vector(6 downto 0);
        funct3          : out    vl_logic_vector(2 downto 0);
        funct7          : out    vl_logic_vector(6 downto 0);
        instr           : out    vl_logic_vector(31 downto 0);
        pc              : out    vl_logic_vector(31 downto 0);
        branch          : out    vl_logic;
        imAddr          : out    vl_logic_vector(5 downto 0)
    );
end datapath_debug;
