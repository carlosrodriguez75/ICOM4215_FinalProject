module cunit(input Cond, MOC, Clr, Clk, input [31:0] InstructionReg, output reg[18:0] Out, output reg[1:0] Size, output reg Sign);
	reg[3:0] opcode;
	reg[2:0] instruction;
	reg[3:0] registers;
	reg[7:0] State, NextState;

	wire[7:0] ControlState;

	always@(negedge Clk) begin
		//$display("State: %d", State);
		//$monitor("State = %d, NextState = %d, ControlState = %d, Out = %h, clk = %b, time = %d", State, NextState, ControlState, Out, Clk, $time);
		opcode = InstructionReg[24:21];
		instruction = InstructionReg[27:25];
		registers = 4'b0000;
		case (State)
			8'h00:  NextState = 8'h01; //0 to 1
			8'h01:	begin NextState = 8'h02; Size = 2; Sign = 0; end //1 to 2
			8'h02:	begin NextState = 8'h03; end //2 to 3
			8'h03:	if(MOC) begin NextState = 8'h04; end //if MOC=1, go to 4
					else NextState = 8'h03; //if MOc=0, stay in 3
			8'h04:	if(!Cond) NextState = 8'h01; //if Cond=0, return to 1
					else begin //if Cond=1, go to the next state depending of the instruction register
						if(instruction == 3'b000 && InstructionReg[4] == 0) begin //DATA PROCESSING IMMEDIATE
							if(opcode == 1000 || opcode == 1001 || opcode == 1010 || opcode == 1011) NextState = 8'h07; //4 instructions
							else if (opcode == 1101 || opcode == 1111) NextState = 8'h05; //2 instructions
							else begin //remaining 10
								if(InstructionReg[20] == 1) NextState = 8'h06; //if condition codes will be updated
								else NextState = 8'h05; //if not
							end
						end 
						
						else if(instruction == 3'b001) begin //DATA PROCESSING 32-BIT
							if(opcode == 1000 || opcode == 1001 || opcode == 1010 || opcode == 1011) NextState = 8'h07; //4 instructions
							else if (opcode == 1101 || opcode == 1111) NextState = 8'h05; //2 instructions
							else begin //remaining 10
								if(InstructionReg[20] == 1) NextState = 8'h06; //if condition codes will be updated
								else NextState = 8'h05; //if not
							end
						end

						else if(instruction == 3'b010) begin //LOAD/STORE IMMEDIATE
							if(InstructionReg[20] == 0) //STORE
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	NextState = 8'h0a; //offset
								2'b11:	NextState = 8'h0e; //preindex
								2'b00:	NextState = 8'h13; //postindex
								endcase
							else begin //LOAD
								if(InstructionReg == 0) Size = 2; else Size = 0;
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	if(InstructionReg[22] == 0) NextState = 8'h28; else NextState = 8'h3c; //offset word and byte
								2'b11:	if(InstructionReg[22] == 0) NextState = 8'h2c; else NextState = 8'h40; //preindex word and byte
								2'b00:	if(InstructionReg[22] == 0) NextState = 8'h31; else NextState = 8'h45; //postindex word and byte
								endcase
							end	
						end

						else if(instruction == 3'b011 && InstructionReg[4] == 0) begin //LOAD/STORE REGISTER
							if(InstructionReg[20] == 0) //STORE
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	NextState = 8'h14; //offset
								2'b11:	NextState = 8'h15; //preindex
								2'b00:	NextState = 8'h1a; //postindex
								endcase
							else begin //LOAD
								if(InstructionReg[22] == 0) Size = 2; else Size = 0;
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	if(InstructionReg[22] == 0) NextState = 8'h32; else NextState = 8'h46; //offset word and byte
								2'b11:	if(InstructionReg[22] == 0) NextState = 8'h33; else NextState = 8'h47; //preindex word and byte
								2'b00:	if(InstructionReg[22] == 0) NextState = 8'h38; else NextState = 8'h4c; //postindex word and byte
								endcase
							end	
						end

						else if(instruction == 3'b000 && InstructionReg[7] == 1 && InstructionReg[4] ==1) begin //MISC LOAD AND STORES
							if(InstructionReg[22] == 1) //immediate
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //offset
										3'b001:	NextState = 8'h0a;	//store halfword
										3'b010:	begin NextState = 8'h8c; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h64;	//store doubleword
										3'b101:	begin NextState = 8'h50; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h3c; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h50; Size = 1; Sign = 1; end	//load signed halfword
										endcase
								2'b11:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //preindex
										3'b001:	NextState = 8'h0e;	//store halfword
										3'b010:	begin NextState = 8'h9e; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h76;	//store doubleword
										3'b101:	begin NextState = 8'h54; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h40; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h54; Size = 1; Sign = 1; end	//load signed halfword
										endcase
								2'b00:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //postindex
										3'b001:	NextState = 8'h13;	//store halfword
										3'b010:	begin NextState = 8'ha8; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h80;	//store doubleword
										3'b101:	begin NextState = 8'h59; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h45; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h59; Size = 1; Sign = 1; end    //load signed halfword
										endcase
								endcase
							else //register
								case ({InstructionReg[24], InstructionReg[21]})
								2'b10:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //offset
										3'b001:	NextState = 8'h14;	//store halfword
										3'b010:	begin NextState = 8'h95; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h6d;	//store doubleword
										3'b101:	begin NextState = 8'h5a; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h46; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h5a; Size = 1; Sign = 1; end	//load signed halfword
										endcase
								2'b11:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //preindex
										3'b001:	NextState = 8'h15;	//store halfword
										3'b010:	begin NextState = 8'ha9; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h81;	//store doubleword
										3'b101:	begin NextState = 8'h5b; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h47; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h5b; Size = 1; Sign = 1; end	//load signed halfword
										endcase
								2'b00:	case({InstructionReg[20], InstructionReg[6], InstructionReg[5]}) //postindex
										3'b001:	NextState = 8'h1a;	//store halfword
										3'b010:	begin NextState = 8'hb3; Size = 2; end	//load doubleword
										3'b011:	NextState = 8'h8b;	//store doubleword
										3'b101:	begin NextState = 8'h60; Size = 1; end	//load halfword
										3'b110:	begin NextState = 8'h4c; Size = 0; Sign = 1; end	//load signed byte
										3'b111:	begin NextState = 8'h60; Size = 1; Sign = 1; end	//load signed halfword
										endcase
								endcase
						end

						else if(instruction == 3'b100) begin //STORE/LOAD MULTIPLE	
							if(InstructionReg[20] == 0) //store
								case(InstructionReg[24:23])
								2'b00:	NextState = 8'hca;	//decrement after
								2'b01:	NextState = 8'hbe;	//increment after
								2'b10:	NextState = 8'hd0;	//decrement before
								2'b11:	NextState = 8'hc4;	//increment before
								endcase
							else
								case(InstructionReg[24:23])
								2'b00:	NextState = 8'he3;	//decrement after
								2'b01:	NextState = 8'hd7;	//increment after
								2'b10:	NextState = 8'he9;	//decrement before
								2'b11:	NextState = 8'hdd;	//increment before
								endcase
						end

						else if(instruction == 3'b101) begin  //BRANCH Y BL
							if(InstructionReg[24] == 0) NextState = 8'h1e;	//branch
							else NextState = 8'h1f;	//branch and link
						end

						else NextState = 8'h00;	//if it isn't one of the cases added before, it will go to reset
					end
		
			8'h05:	NextState = 8'h01; //5 to 1
			8'h06:	NextState = 8'h01; //6 to 1
			8'h07:	NextState = 8'h01; //7 to 1
			8'h0a:	NextState = 8'h0b; //10 to 11
			8'h0b:	NextState = 8'h0c; //11 to 12
			8'h0c:	NextState = 8'h0d; //12 to 13
			8'h0d:	if(MOC) NextState = 8'h01; //if MOC, 13 to 1
					else NextState = 8'h0d; // else, 13 to 13
			8'h0d:	NextState = 8'h0e; //14 to 15
			8'h0e:	NextState = 8'h10; //15 to 16
			8'h10:	NextState = 8'h11; //16 to 17
			8'h11:	if(MOC) NextState = 8'h12; //if MOC, 17 to 18
					else NextState = 8'h11; // else, 17 to 17
			8'h12:	NextState = 8'h01; //18 to 1
			8'h13:	NextState = 8'h0e; //19 to 15
			8'h14:	NextState = 8'h0b; //20 to 11
			8'h15:	NextState = 8'h16; //21 to 22
			8'h16:	NextState = 8'h17; //22 to 23
			8'h17:	NextState = 8'h18; //23 to 24
			8'h18:	if(MOC) NextState = 8'h19; //if MOC, 24 to 25
					else NextState = 8'h18; // else, 24 to 24
			8'h19:	NextState = 8'h01; //25 to 1
			8'h1a:	NextState = 8'h16; //26 to 22
			8'h28:	NextState = 8'h29; //40 to 41
			8'h29:	NextState = 8'h2a; //41 to 42
			8'h2a:	if(MOC) NextState = 8'h2b; //if MOC, 42 to 43
					else NextState = 8'h2a; // else, 42 to 42
			8'h2b:	NextState = 8'h01; //43 to 1
			8'h2c:	NextState = 8'h2d; //44 to 45
			8'h2d:	NextState = 8'h2e; //45 to 46
			8'h2e:	if(MOC) NextState = 8'h2f; //if MOC, 46 to 47
					else NextState = 8'h2e; // else, 46 to 46
			8'h2f:	NextState = 8'h30; //47 to 48
			8'h30:	NextState = 8'h01; //48 to 1
			8'h31:	NextState = 8'h2d; //49 to 45
			8'h32:	NextState = 8'h29; //50 to 41
			8'h33:	NextState = 8'h34; //51 to 52
			8'h34:	NextState = 8'h35; //52 to 53
			8'h35:	if(MOC) NextState = 8'h36; //if MOC, 53 to 54
					else NextState = 8'h35; // else, 53 to 53
			8'h36:	NextState = 8'h37; //54 to 55
			8'h37:	NextState = 8'h01; //55 to 1
			8'h38:	NextState = 8'h34; //56 to 52
			8'h3c:	NextState = 8'h3d; //60 to 61
			8'h3d:	NextState = 8'h3e; //61 to 62
			8'h3e:	if(MOC) NextState = 8'h3f; //if MOC, 62 to 63
					else NextState = 8'h3e; // else, 62 to 62
			8'h3f:	NextState = 8'h01; //63 to 1
			8'h40:	NextState = 8'h41; //64 to 65
			8'h41:	NextState = 8'h42; //65 to 66
			8'h42:	if(MOC) NextState = 8'h43; //if MOC, 66 to 67
					else NextState = 8'h42; // else, 66 to 66
			8'h43:	NextState = 8'h44; //67 to 68
			8'h44:	NextState = 8'h01; //68 to 1
			8'h45:	NextState = 8'h41; //69 to 65
			8'h46:	NextState = 8'h3d; //70 to 61
			8'h47:	NextState = 8'h48; //71 to 72
			8'h48:	NextState = 8'h49; //72 to 73
			8'h49:	if(MOC) NextState = 8'h4a; //if MOC, 73 to 74
					else NextState = 8'h49; // else, 73 to 73
			8'h4a:	NextState = 8'h4b; //74 to 75
			8'h4b:	NextState = 8'h01; //75 to 1
			8'h4c:	NextState = 8'h48; //76 to 72
			8'h50:	NextState = 8'h51; //80 to 81
			8'h51:	NextState = 8'h52; //81 to 82
			8'h52:	if(MOC) NextState = 8'h53; //if MOC, 82 to 83
					else NextState = 8'h52; // else, 82 to 82
			8'h53:	NextState = 8'h01; //83 to 1
			8'h54:	NextState = 8'h55; //84 to 85
			8'h55:	NextState = 8'h56; //85 to 86
			8'h56:	if(MOC) NextState = 8'h57; //if MOC, 86 to 87
					else NextState = 8'h56; // else, 86 to 86
			8'h57:	NextState = 8'h58; //87 to 88
			8'h58:	NextState = 8'h01; //88 to 1
			8'h59:	NextState = 8'h55; //89 to 85
			8'h5a:	NextState = 8'h51; //90 to 81
			8'h5b:	NextState = 8'h5c; //91 to 92
			8'h5c:	NextState = 8'h5d; //92 to 93
			8'h5d:	if(MOC) NextState = 8'h5e; //if MOC, 93 to 94
					else NextState = 8'h5d; // else, 93 to 93
			8'h5e:	NextState = 8'h5f; //94 to 95
			8'h5f:	NextState = 8'h01; //95 to 1
			8'h60:	NextState = 8'h5c; //96 to 92

			8'h64:	NextState = 8'h65; //100 to 101
			8'h65:	NextState = 8'h66; //101 to 102
			8'h66:	NextState = 8'h67; //102 to 103
			8'h67:	if(MOC) NextState = 8'h68; //if MOC, 103 to 104
					else NextState = 8'h67; // else, 103 to 104		
			8'h68:	NextState = 8'h69; //104 to 105
			8'h69:	NextState = 8'h6a; //105 to 106
			8'h6a:	NextState = 8'h6b; //106 to 107
			8'h6b:	if(MOC) NextState = 8'h6c; //if MOC, 107 to 108
					else NextState = 8'h6b; // else, 107 to 107
			8'h6c:	NextState = 8'h01; //108 to 1
			8'h76:	NextState = 8'h77; //118 to 119
			8'h77:	NextState = 8'h78; //119 to 120
			8'h78:	NextState = 8'h79; //120 to 121
			8'h79:	if(MOC) NextState = 8'h7a; //if MOC, 121 to 122
					else NextState = 8'h79; // else, 121 to 121	
			8'h7a:	NextState = 8'h7b; //122 to 123
			8'h7b:	NextState = 8'h7c; //123 to 124
			8'h7c:	NextState = 8'h7d; //124 to 125
			8'h7d:	if(MOC) NextState = 8'h7e; //if MOC, 125 to 126
					else NextState = 8'h7d; // else, 125 to 125
			8'h7e:	NextState = 8'h7f; //126 to 127
			8'h7f:	NextState = 8'h01; //127 to 1
			8'h80:	NextState = 8'h77; //128 to 119
			8'h6d:	NextState = 8'h6e; //109 to 110
			8'h6e:	NextState = 8'h6f; //110 to 111
			8'h6f:	NextState = 8'h70; //111 to 112
			8'h70:	if(MOC) NextState = 8'h71; //if MOC, 112 to 113
					else NextState = 8'h70; // else, 112 to 112		
			8'h71:	NextState = 8'h72; //113 to 114
			8'h72:	NextState = 8'h73; //114 to 115
			8'h73:	NextState = 8'h74; //115 to 116
			8'h74:	if(MOC) NextState = 8'h75; //if MOC, 116 to 117
					else NextState = 8'h74; // else, 116 to 116
			8'h75:	NextState = 8'h01; //117 to 1
			8'h81:	NextState = 8'h82; //129 to 130
			8'h82:	NextState = 8'h83; //130 to 131
			8'h83:	NextState = 8'h84; //131 to 132
			8'h84:	if(MOC) NextState = 8'h85; //if MOC, 132 to 133
					else NextState = 8'h84; // else, 132 to 132	
			8'h85:	NextState = 8'h86; //133 to 134
			8'h86:	NextState = 8'h87; //134 to 135
			8'h87:	NextState = 8'h88; //135 to 136
			8'h88:	if(MOC) NextState = 8'h89; //if MOC, 136 to 137
					else NextState = 8'h88; // else, 136 to 136
			8'h89:	NextState = 8'h8a; //137 to 138
			8'h8a:	NextState = 8'h01; //138 to 1
			8'h8b:	NextState = 8'h82; //139 to 130
			8'h8c:	NextState = 8'h8d; //140 to 141
			8'h8d:	NextState = 8'h8e; //141 to 142
			8'h8e:	if(MOC) NextState = 8'h8f; //if MOC, 142 to 143
					else NextState = 8'h8e; // else, 142 to 142		
			8'h8f:	NextState = 8'h90; //143 to 144
			8'h90:	NextState = 8'h91; //144 to 145
			8'h91:	NextState = 8'h92; //145 to 146
			8'h92:	if(MOC) NextState = 8'h93; //if MOC, 146 to 147
					else NextState = 8'h92; // else, 146 to 146
			8'h93:	NextState = 8'h94; //147 to 148
			8'h94:	NextState = 8'h01; //148 to 1
			8'h9e:	NextState = 8'h9f; //158 to 159
			8'h9f:	NextState = 8'ha0; //159 to 160
			8'ha0:	if(MOC) NextState = 8'ha1; //if MOC, 160 to 161
					else NextState = 8'ha0; // else, 160 to 160
			8'ha1:	NextState = 8'ha2; //161 to 162	
			8'ha2:	NextState = 8'ha3; //162 to 163
			8'ha3:	NextState = 8'ha4; //163 to 164
			8'ha4:	if(MOC) NextState = 8'ha5; //if MOC, 164 to 165
					else NextState = 8'ha4; // else, 164 to 164
			8'ha5:	NextState = 8'ha6; //165 to 166
			8'ha6:	NextState = 8'ha7; //166 to 167
			8'ha7:	NextState = 8'h01; //167 to 1
			8'ha8:	NextState = 8'h9f; //168 to 159
			8'h95:	NextState = 8'h96; //149 to 150
			8'h96:	NextState = 8'h97; //150 to 151
			8'h97:	if(MOC) NextState = 8'h98; //if MOC, 151 to 152
					else NextState = 8'h97; // else, 151 to 151	
			8'h98:	NextState = 8'h99; //152 to 153	
			8'h99:	NextState = 8'h9a; //153 to 154
			8'h9a:	NextState = 8'h9b; //154 to 155
			8'h9b:	if(MOC) NextState = 8'h9c; //if MOC, 155 to 156
					else NextState = 8'h9b; // else, 155 to 155
			8'h9c:	NextState = 8'h9d; //156 to 157
			8'h9d:	NextState = 8'h01; //157 to 1
			8'ha9:	NextState = 8'haa; //169 to 170
			8'haa:	NextState = 8'hab; //170 to 171
			8'hab:	if(MOC) NextState = 8'hac; //if MOC, 171 to 172
					else NextState = 8'hab; // else, 171 to 171	
			8'hac:	NextState = 8'had; //172 to 173
			8'had:	NextState = 8'hae; //173 to 174
			8'hae:	NextState = 8'haf; //174 to 175
			8'haf:	if(MOC) NextState = 8'hb0; //if MOC, 175 to 176
					else NextState = 8'haf; // else, 175 to 175
			8'hb0:	NextState = 8'hb1; //176 to 177
			8'hb1:	NextState = 8'hb2; //177 to 178
			8'hb2:	NextState = 8'h01; //178 to 1
			8'hb3:	NextState = 8'hab; //179 to 170
			
			8'h1e:	NextState = 8'h01; //30 to 1
			8'h1f:	NextState = 8'h20; //31 to 32
			8'h20:	NextState = 8'h01; //32 to 1
					
			//necesita añadir------------------------------------------------------------------------------------------ 
			8'hbe:	NextState = 8'hbf; //190 to 191
			8'hbf:	NextState = 8'hc0; //191 to 192
			8'hc0:	NextState = 8'hc1; //192 to 193
			8'hc1:	if(MOC) NextState = 8'hc2; //if MOC, 193 to 194
					else NextState = 8'hc1; // else, 193 to 193
			default: NextState = 8'h00;
		endcase
	end

	reg8 statereg(ControlState, NextState, Clk);

	always@(posedge Clk)
		State = ControlState;

	always @(posedge Clk) begin
		case(ControlState)
			8'b00000000: Out = 19'b0000000000000000000;
			8'b00000001: Out = 19'b0001000100001010000; 
			8'b00000010: Out = 19'b0100011100011010001;
			8'b00000011: Out = 19'b0010011000000000000;
			8'b00000100: Out = 19'b0000000000000000000;
			8'b00000101: Out = 19'b0110000000100000000;
			8'b00000110: Out = 19'b1110000000100000000;
			8'b00000111: Out = 19'b1010000000100000000;
			8'b00001010: Out = 19'b0001000000101000100;
			8'b00001011: Out = 19'b0000100010001110000;
			8'b00001100: Out = 19'b0000001000000000000;
			8'b00001101: Out = 19'b0000001000000000000;
			8'b00001110: Out = 19'b0001000000101000100;
			8'b00001111: Out = 19'b0000100010001110000;
			8'b00010000: Out = 19'b0000001000000000000;
			8'b00010001: Out = 19'b0000001000000000000;
			8'b00010010: Out = 19'b0100000000110000100;
			8'b00010011: Out = 19'b0001000000001010000;
			8'b00010100: Out = 19'b0001000000001000100;

			8'b00010101: Out = 19'b0001000000001000100;
			8'b00010110: Out = 19'b0000100010001110000; 
			8'b00010111: Out = 19'b0000001000000000000;
			8'b00011000: Out = 19'b0000001000000000000;
			8'b00011001: Out = 19'b0100000000010000100;
			8'b00011010: Out = 19'b0001000000001010000;
			8'b00011110: Out = 19'b0100000100111010010;
			8'b00011111: Out = 19'b0100000100001010000;
			8'b00100000: Out = 19'b0100000100111010010;
			8'b00101000: Out = 19'b0001000000101000100;
			8'b00101001: Out = 19'b0000011000000000000;
			8'b00101011: Out = 19'b0000111000000000000;
			8'b00101100: Out = 19'b0001000000101000100;
			8'b00101101: Out = 19'b0000011000000000000;
			8'b00101110: Out = 19'b0000111000000000000;
			8'b00101111: Out = 19'b0100000001001001101;
			8'b00110000: Out = 19'b0100000000110000100;
			8'b00110001: Out = 19'b0001000000001010000;
			8'b00110010: Out = 19'b0001000000001000100;


			8'b00110011: Out = 19'b0001000000001000100;
			8'b00110100: Out = 19'b0000011000000000000; 
			8'b00110101: Out = 19'b0000111000000000000;
			8'b00110110: Out = 19'b0100000001001001101;
			8'b00110111: Out = 19'b0100000000010000100;
			8'b00111000: Out = 19'b0001000000001010000;//56


			8'b00111100: Out = 19'b0001000000101000100;
			8'b00111101: Out = 19'b0000011000000000000;
			8'b00111110: Out = 19'b0000111000000000000;
			8'b00111111: Out = 19'b0100000001001001101;
			8'b01000000: Out = 19'b0001000000101000100;
			8'b01000001: Out = 19'b0000011000000000000;
			8'b01000010: Out = 19'b0000111000000000000;
			8'b01000011: Out = 19'b0100000001001001101;
			8'b01000100: Out = 19'b0100000000110000100;
			8'b01000101: Out = 19'b0001000000001010000;
			8'b01000110: Out = 19'b0001000000001000100;
			8'b01000111: Out = 19'b0001000000001000100;
			8'b01001000: Out = 19'b0000011000000000000;
			8'b01001001: Out = 19'b0000111000000000000;
			8'b01001010: Out = 19'b0100000001001001101;
			8'b01001011: Out = 19'b0100000000010000100;
			8'b01001100: Out = 19'b0001000000001010000;
			8'b01010000: Out = 19'b0001000000101000100;
			8'b01010001: Out = 19'b0000011000000000000;
			8'b01010010: Out = 19'b0000111000000000000;
			8'b01010011: Out = 19'b0100000001001001101;
			8'b01010100: Out = 19'b0001000000101000100;
			8'b01010101: Out = 19'b0000011000000000000;
			8'b01010110: Out = 19'b0000111000000000000;
			8'b01010111: Out = 19'b0100000001001001101;
			8'b01011000: Out = 19'b0100000000110000100;
			8'b01011001: Out = 19'b0001000000001010000;
			8'b01011010: Out = 19'b0001000000001000100;
			8'b01011011: Out = 19'b0001000000001000100;
			8'b01011100: Out = 19'b0000011000000000000;
			8'b01011101: Out = 19'b0000111000000000000;
			8'b01011110: Out = 19'b0100000001001001101;
			8'b01011111: Out = 19'b0100000000010000100;
			8'b01100000: Out = 19'b0001000000001010000;
			8'b01100100: Out = 19'b0001000000101000100;
			8'b01100101: Out = 19'b0000100010001110000;
			8'b01100110: Out = 19'b0000001000000000000;
			8'b01100111: Out = 19'b0000001000000000000;
			8'b01101000: Out = 19'b0100000000110000100;
			8'b01101001: Out = 19'b0001000100001010001;
			8'b01101010: Out = 19'b0000100010001110000;
			8'b01101011: Out = 19'b0000001000000000000;
			8'b01101100: Out = 19'b0000001000000000000;
			8'b01101101: Out = 19'b0001000000001000100;
			8'b01101110: Out = 19'b0000100010001110000;
			8'b01101111: Out = 19'b0000001000000000000;
			8'b01110000: Out = 19'b0000001000000000000;
			8'b01110001: Out = 19'b0100000000010000100;
			8'b01110010: Out = 19'b0001000100001010001;
			8'b01110011: Out = 19'b0000100010001110000;
			8'b01110100: Out = 19'b0000001000000000000;
			8'b01110101: Out = 19'b0000001000000000000;
			8'b01110110: Out = 19'b0001000000101000100;
			8'b01110111: Out = 19'b0000100010001110000;
			8'b01111000: Out = 19'b0000001000000000000;
			8'b01111001: Out = 19'b0000001000000000000;
			8'b01111010: Out = 19'b0100000000110000100;
			8'b01111011: Out = 19'b0001000100001010001;
			8'b01111100: Out = 19'b0000100010001110000;
			8'b01111101: Out = 19'b0000001000000000000;
			8'b01111110: Out = 19'b0000001000000000000;
			8'b01111111: Out = 19'b0100000000110000100;
			8'b10000000: Out = 19'b0001000000001010000;
			8'b10000001: Out = 19'b0001000000001000100;
			8'b10000010: Out = 19'b0000100010001110000;
			8'b10000011: Out = 19'b0000001000000000000;
			8'b10000100: Out = 19'b0000001000000000000;
			8'b10000101: Out = 19'b0100000000110000100;
			8'b10000110: Out = 19'b0001000100001010001;
			8'b10000111: Out = 19'b0000100010001110000;
			8'b10001000: Out = 19'b0000001000000000000;
			8'b10001001: Out = 19'b0000001000000000000;
			8'b10001010: Out = 19'b0100000000010000100;
			8'b10001011: Out = 19'b0001000000001010000;
			8'b10001100: Out = 19'b0001000000101000100;
			8'b10001101: Out = 19'b0000011000000000000;
			8'b10001110: Out = 19'b0000111000000000000;
			8'b10001111: Out = 19'b0100000001001001101;
			8'b10010000: Out = 19'b0100000000110000100;
			8'b10010001: Out = 19'b0001000100001010001;
			8'b10010010: Out = 19'b0000100010001110000;
			8'b10010011: Out = 19'b0000001000000000000;
			8'b10010100: Out = 19'b0000001000000000000;
			8'b10010101: Out = 19'b0001000000001000100;
			8'b10010110: Out = 19'b0000011000000000000;
			8'b10010111: Out = 19'b0000111000000000000;
			8'b10011000: Out = 19'b0100000001001001101;
			8'b10011001: Out = 19'b0100000000010000100;
			8'b10011010: Out = 19'b0001000100001010001;
			8'b10011011: Out = 19'b0000100010001110000;
			8'b10011100: Out = 19'b0000001000000000000;
			8'b10011101: Out = 19'b0000001000000000000;
			8'b10011110: Out = 19'b0001000000101000100;
			8'b10011111: Out = 19'b0000011000000000000;
			8'b10100000: Out = 19'b0000111000000000000;
			8'b10100001: Out = 19'b0100000001001001101;
			8'b10100010: Out = 19'b0100000000110000100;
			8'b10100011: Out = 19'b0001000100001010001;
			8'b10100100: Out = 19'b0000100010001110000;
			8'b10100101: Out = 19'b0000001000000000000;
			8'b10100110: Out = 19'b0000001000000000000;
			8'b10100111: Out = 19'b0100000000110000100;
			8'b10101000: Out = 19'b0001000000001010000;
			8'b10101001: Out = 19'b0001000000001000100;
			8'b10101010: Out = 19'b0000011000000000000;
			8'b10101011: Out = 19'b0000111000000000000;
			8'b10101100: Out = 19'b0100000001001001101;
			8'b10101101: Out = 19'b0100000000110000100;
			8'b10101110: Out = 19'b0001000100001010001;
			8'b10101111: Out = 19'b0000100010001110000;
			8'b10110000: Out = 19'b0000001000000000000;
			8'b10110001: Out = 19'b0000001000000000000;
			8'b10110010: Out = 19'b0100000000010000100;
			8'b10110011: Out = 19'b0001000000001010000;
			8'b10111110: Out = 19'b0001000000101000100;
			8'b10111111: Out = 19'b0000100010001110000;
			8'b11000000: Out = 19'b0000001000000000000;
			8'b11000001: Out = 19'b0000001000000000000;
			8'b11000010: Out = 19'b0000000000000000000;
			8'b11000011: Out = 19'b0001000000101000100;
			8'b11000100: Out = 19'b0001000000001010001;
			8'b11000101: Out = 19'b0000100010001110000;
			8'b11000110: Out = 19'b0000001000000000000;
			8'b11000111: Out = 19'b0000001000000000000;
			8'b11001000: Out = 19'b0000000000000000000;
			8'b11001001: Out = 19'b0001000000101000100;
			8'b11001010: Out = 19'b0001000000101010011;
			8'b11001011: Out = 19'b0000100010001110000;
			8'b11001100: Out = 19'b0000001000000000000;
			8'b11001101: Out = 19'b0000001000000000000;
			8'b11001110: Out = 19'b0000000000000000000;
			8'b11001111: Out = 19'b0001000000101000100;
			8'b11010000: Out = 19'b0001000000101000010;
			8'b11010001: Out = 19'b0000100010001110000;
			8'b11010010: Out = 19'b0000001000000000000;
			8'b11010011: Out = 19'b0000001000000000000;
			8'b11010100: Out = 19'b0000000000000000000;
			8'b11010101: Out = 19'b0001000000101000100;
			8'b11010111: Out = 19'b0001000000101000100;
			8'b11011000: Out = 19'b0000011000000000000;
			8'b11011001: Out = 19'b0000111000000000000;
			8'b11011010: Out = 19'b0100000001001001101;
			8'b11011011: Out = 19'b0000000000000000000;
			8'b11011100: Out = 19'b0001000000101000100;
			8'b11011101: Out = 19'b0001000000001010001;
			8'b11011110: Out = 19'b0000011000000000000;
			8'b11011111: Out = 19'b0000111000000000000;
			8'b11100000: Out = 19'b0100000001001001101;
			8'b11100001: Out = 19'b0000000000000000000;
			8'b11100010: Out = 19'b0001000000101000100;
			8'b11100011: Out = 19'b0001000000101010011;
			8'b11100100: Out = 19'b0000011000000000000;
			8'b11100101: Out = 19'b0000111000000000000;
			8'b11100110: Out = 19'b0100000001001001101;
			8'b11100111: Out = 19'b0000000000000000000;
			8'b11101000: Out = 19'b0001000000101000100;
			8'b11101001: Out = 19'b0001000000101000010;
			8'b11101010: Out = 19'b0000011000000000000;
			8'b11101011: Out = 19'b0000111000000000000;
			8'b11101100: Out = 19'b0100000001001001101;
			8'b11101101: Out = 19'b0000000000000000000;
			8'b11101110: Out = 19'b0001000000101000100;
		endcase
		State = ControlState;
	end
endmodule