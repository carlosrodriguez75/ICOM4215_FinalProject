module reg32 (output reg[31:0] Qs, input [31:0] Ds, input Ld, Clk);
	always @(posedge Clk) begin
		if(Ld) Qs = Ds;
	end
endmodule