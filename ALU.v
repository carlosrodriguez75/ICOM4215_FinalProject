
/*32-bit ARM ALU Module. Behavioral Description.
	By: Maria Jimenez 
	Description: This program describes the behaviour of a 32 bit ARM ALU
	The signals in this software are:
		Outputs:
			1. O[32:0]== ALU Operation result including carry bit
			2. ALU_OUT[31:0]== ALU result (not taking into consideration the carry bit)-------Rd
			3. Z== Zero flag
			4. N== Negative flag
			5. C== Carry flag
			6. V== Overflow flag
		Inputs:
			1. A[31:0]== Input A -------Rn
			2. B[31:0]== Input B -------shifter operand------Rm
			3. Cin== Carry in bit
			4. OP[3:0]== Operation instruction
	The program returns a 32 bit result as an output of the programmed arithmetic operations available along with Z,C,N,V flag results.
*/

module ALU_32Bit(output reg [32:0]O, output reg [31:0]result, output reg Z, N, C, V, input [31:0]B,A, input Cin, input [4:0]OP);
	

	always @(OP, A, B)
	begin
		case(OP)
			5'b00000: O= A & B ;	//A and B
			5'b00001: O= A ^ B ;	//A xor B
			5'b00010: O= A - B ;	//A minus B
			5'b00011: O= B - A;		//B minus A
			5'b00100: O= A + B;		//A plus B
			5'b00101: O= A + B + Cin;	//A plus B plus Carry
			5'b00110: O= A - B - !Cin;	//A minus B minus not Carry
			5'b00111: O= B - A - !Cin;	//B minus A minus not Carry 
			5'b01000: O= A & B;		//A and B; Used to test and update Flags			
			5'b01001: O= A ^ B;		// A xor B; used to test equivalence and update Flags		
			5'b01010: O= A - B;		//A minus B; Used to compare values and update Flags		
			5'b01011: O= A + B;		//A plus B; Used to compare values and update Flags
			5'b01100: O=A | B;		//A or B
			5'b01101: O= B;			//move to output value of B
			5'b01110: O= A & !B;	//A and not B; Used to clear bit
			5'b01111: O= !B;		//not B; Used to move the not value of B to the output
			5'b10000: O= A;
			5'b10001: O= A+4;
			5'b10010: O= A+B;
		endcase
		
		result = O[31:0];//ALU output value/ operation result
		C = O[32];		//Value assigned to Carry flag bit
		N = O[31];		//Condition for negative flag bit
		V = Cin ^ C;	//Condition for overflow flag bit
		
		if(O[31:0] == 32'h00000000)	//Condition for zero flag bit	
			Z = 1;
		else
			Z = 0;		
	end
endmodule
		