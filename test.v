module test(
		input clk,
		output [31:0] pc,
		output [31:0] imAddr,
		output [31:0] instr
);
		assign imAddr = pc >> 2;
		wire [31:0] pc_next = pc+4;
	   pc r_pc(.clk(clk),.rst_n(1),.d(pc_next),.q(pc));
		rom instr_rom(.a(imAddr),.rd (instr));


endmodule