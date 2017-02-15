/*32-bit ARM Condition tester Module. Behavioral Description.
	By: Maria Jimenez 
	Description: This program describes the behaviour of an ARM Condition Tester
	The signals in this software are:
		Outputs:
			1. Cond== Condition status bit to control unit 
		Inputs:
			1. Zin== Zero flag from flag register
			2. Nin== Negative flag from ALU
			3. Cin== Carry flag from ALU
			4. Vin== Overflow flag from ALU
			5. CC== Condition code taken from most significant nibble of instruction 
	The program returns condition result and sends control bit to control unit.
*/

module Condition_Tester(output reg Cond, input N, Z, C, V, input [3:0]CC);
		
	always @(N, Z, C, V, CC)
	begin 
		case(CC)
			
			4'b0000:	//Equal
				if(Z)
					Cond=1;
				else
					Cond=0;
						
			4'b0001:	//Not Equal 
				if(Z==0)
					Cond=1;
				else
					Cond=0;
						
			4'b0010:	//Unsigned higher or same
				if(C)
					Cond=1;
				else
					Cond=0;
					
			4'b0011:	//Unsigned lower
				if(C==0)
					Cond=1;
				else
					Cond=0;
					
			4'b0100:	//Minus
				if(N)
					Cond=1;
				else
					Cond=0;
					
			4'b0101:	//Positive or zero
				if(N==0)
					Cond=1;
				else
					Cond=0;
	
			4'b0110:	//Overflow
				if(V)
					Cond=1;
				else
					Cond=0;
	
			4'b0111:	//No overflow
				if(V==0)
					Cond=1;
				else
					Cond=0;
	
			4'b1000:	//Unsigned higher
				if(C==1 & Z==0)
					Cond=1;
				else
					Cond=0;	
			
			4'b1001:	//Unsigned lower or same
				if(C==0 | Z==1)
					Cond=1;
				else
					Cond=0;	
			
			4'b1010:	//Greater or equal
				if(N==V)
					Cond=1;
				else
					Cond=0;	
			
			4'b1011:	//Less than
				if(N!=V)
					Cond=1;
				else
					Cond=0;
			
			4'b1100:	//Greater than
				if(Z==0 & N==V)
					Cond=1;
				else
					Cond=0;
			
			4'b1101:	//Less than or equal
				if(Z==1 | N!=V)
					Cond=1;
				else
					Cond=0;
	
			4'b1110:// Always
					Cond=1;

			
		endcase
		
	end
endmodule