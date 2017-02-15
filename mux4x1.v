module mux4x1 (output reg[3:0] Y, input[1:0]S, input[3:0] I0,I1,I2,I3);
	always @(S,I0,I1,I2,I3) begin
		case(S)
			2'b00: Y=I0;
			2'b01: Y=I1;
			2'b10: Y=4'b1111;
			2'b11: Y=4'b0000;
		endcase
	end
endmodule