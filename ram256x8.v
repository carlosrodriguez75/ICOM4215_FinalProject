module ram256x8 (output reg [31:0] DataOut, output reg MOC, input Enable, ReadWrite, input [1:0] Size, input Sign, input [31:0] Address, input [31:0] DataIn);	
	reg [7:0] Mem[0:255];		//256 localizaciones de bytes
	reg [7:0] newAddress;
	reg [31:0] rotatingNumber, rotatingNumber2;
	always @ (Enable, ReadWrite) begin
		MOC = 0;
		if(Enable) begin
			if (ReadWrite) begin  //LOAD
				newAddress = Address;
				if(Size == 2) begin  //word
					rotatingNumber = Mem[newAddress];
					repeat (3) begin
						newAddress = newAddress + 1;
						rotatingNumber = rotatingNumber*12'h100;
						rotatingNumber = rotatingNumber + Mem[newAddress];
					end
					DataOut = rotatingNumber;
				end
				else if(Size == 1) begin  //halfword
					rotatingNumber = Mem[newAddress];
					newAddress = newAddress + 1;
					rotatingNumber = rotatingNumber*12'h100;
					rotatingNumber = rotatingNumber + Mem[newAddress];
					DataOut = rotatingNumber;
					if(Sign == 1)
						if (DataOut[15] == 1) 
							DataOut = DataOut + 32'hffff0000;
				end
				else if(Size == 0) begin  //byte
					DataOut = Mem[newAddress];
					if(Sign == 1)
						if(DataOut[15] == 1)
							DataOut = DataOut + 32'hffffff00;
				end	
				else $display("Size = basura.");
				MOC = 1;
			end
			
			else begin  //SAVE
				if((DataIn&32'hffff0000) == 32'h00000000) begin
					if((DataIn&32'h0000ff00) == 32'h00000000) begin
						Mem[Address] = DataIn;						
					end
					else begin
						if(Address%2 != 0) newAddress = (Address-Address%2)+2;	//address must be multiple of 2
						else newAddress = Address;
						rotatingNumber = DataIn/12'h100;	//take most significant byte
						Mem[newAddress] = rotatingNumber;	//add to memory (big endian)
						newAddress = newAddress + 1;
						rotatingNumber = rotatingNumber*12'h100;
						rotatingNumber = DataIn - rotatingNumber;	//take least significant byte
						Mem[newAddress] = rotatingNumber;	//add to memory
					end
				end
				else begin
					if(Address%4 != 0) newAddress = (Address-Address%4)+4;	//address must be multiple of 4
					else newAddress = Address;
					rotatingNumber = DataIn/28'h1000000;	//take most significant byte
					Mem[newAddress] = rotatingNumber;		//add to memory (big endian)
					newAddress = newAddress + 1;
					rotatingNumber = rotatingNumber*12'h100;
					rotatingNumber = (DataIn/20'h10000) - rotatingNumber;
					Mem[newAddress] = rotatingNumber;		//add to memory (big endian)
					newAddress = newAddress + 1;
					rotatingNumber = (DataIn/20'h10000)*20'h10000;
					rotatingNumber2 = DataIn - rotatingNumber;
					rotatingNumber = rotatingNumber2/12'h100;
					Mem[newAddress] = rotatingNumber;		//add to memory (big endian)
					newAddress = newAddress + 1;
					rotatingNumber = rotatingNumber*12'h100;
					rotatingNumber = rotatingNumber2 - rotatingNumber;	//take least significant byte
					Mem[newAddress] = rotatingNumber;		//add to memory
				end
				MOC = 1;
			end
		end
		
		else DataOut = 32'bz;
	end
endmodule