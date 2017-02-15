module mux4x1_32bit (output reg[31:0] Y, input[1:0]S, input[31:0] I0,I1,I2,I3);
	always @(S,I0,I1,I2,I3) begin
		case(S)
			2'b00: Y=I0;
			2'b01: Y=I1;
			2'b10: Y=I2;
			2'b11: Y=I3;
		endcase
	end
endmodule