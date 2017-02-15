module MARreg (output reg[31:0] Qs, input [31:0] Ds, input Ld, Clk);
	always @(posedge Clk) begin
		if(Ld) Qs = Ds;
	end
	initial $monitor("MAR = %d", Qs);
endmodule