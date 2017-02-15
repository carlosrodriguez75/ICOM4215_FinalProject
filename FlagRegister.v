/*32-bit ARM Flag register Module. Behavioral Description.
	By: Maria Jimenez 
	Description: This program describes the behaviour of an ARM Flag register
	The signals in this software are:
		Outputs:
			1. Zout== Zero flag to condition tester
			2. Nout== Negative flag to condition tester
			3. Cout== Carry flag to condition tester
			4. Vout== Overflow flag to condition tester
		Inputs:
			1. Z== Zero flag from ALU
			2. N== Negative flag from ALU
			3. C== Carry flag from ALU
			4. V== Overflow flag from ALU
			5. FRLd== Flag register load signal from CU-----High= Load register **** Low= No load
	The program returns the Z,C,N,V flag results from the ALU to the condition tester and loads new flag values when a 1 is sent through the FRLd signal.
*/

module Flag_Register(output reg  Nout, Zout, Cout, Vout, input N, Z, C, V, input FRLd);
	

	always @(FRLd)
	begin 
		
		if(FRLd)	//Condition for zero flag bit	
			
			Nout = N;
			Zout = Z;
			Cout = C;
			Vout = V;

	end
endmodule