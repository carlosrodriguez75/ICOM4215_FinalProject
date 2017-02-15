module reg8 (output reg[7:0] Qs, input [7:0] Ds, input Clk);
	always@(Clk)
		if(Clk == 1)
			Qs = Ds;
endmodule