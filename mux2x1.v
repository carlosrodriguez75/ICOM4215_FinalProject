module mux2x1 (output reg[3:0] Y, input S, input[3:0] I0,I1);
always @(S,I0,I1)
	if(S) Y=I1;
	else Y=I0;
endmodule