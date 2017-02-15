module shifter(input[31:0] InstructionReg, input[31:0] Rm, output reg[31:0] O);
	reg[3:0] rotimm;
	reg[4:0] shiftimm;
	reg C;
	reg[1:0] shift;
	
	always@(InstructionReg, Rm) begin 
		O = 32'h00000000;
		if(InstructionReg[27:25] == 3'b001) begin
			//shift 32-bit
			rotimm = InstructionReg[11:8] * 2;
			O[7:0] = InstructionReg[7:0];
			while(rotimm > 0) begin
				C = O[0];
				O = O/2;
				O[31] = C;
				rotimm = rotimm - 1;
			end
		end
		
		else if (InstructionReg[27:25] == 3'b000 && InstructionReg[4] == 0) begin
			//shift immediate
			shift = InstructionReg[6:5];
			shiftimm = InstructionReg[11:7];
			O = Rm;
			case(shift)
				2'b00:	while(shiftimm > 0) begin  //LSL
							C = O[31];
							O = O*2;
							shiftimm = shiftimm - 1;
						end
				2'b01:	while(shiftimm > 0) begin  //LSR
							C = O[0];
							O = O/2;
							O[31] = 0;
							shiftimm = shiftimm - 1; //adds 0's
						end
				2'b10:	while(shiftimm > 0) begin  //ASR
							C = O[0];
							O = O/2;
							O[31] = 1;
							shiftimm = shiftimm - 1;  //adds 1's
						end
				2'b11:	while(shiftimm > 0) begin  //ROR
							C = O[0];
							O = O/2;
							O[31] = C;
							shiftimm = shiftimm - 1; 
						end
			endcase
		end

		else if(InstructionReg[27:25] == 3'b101) begin
			O = O + InstructionReg[23:0];
			if(O[23] == 1) begin
				O[24] = 1;
				O[25] = 1;
				O[26] = 1;
				O[27] = 1;
				O[28] = 1;
				O[29] = 1;
			end
			O = O * 4;
		end
			
		else O = O + InstructionReg[11:0];
	end 	
endmodule