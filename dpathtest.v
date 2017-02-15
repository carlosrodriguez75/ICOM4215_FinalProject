module datapath;
	reg Clk;
	reg Clr;
	integer fd, code, i;
	reg [7:0] data;

	Complete_CPU_System final(Clk, Clr);

	initial #1690 $finish;
	initial begin
		fd = $fopenr("primeraprueba.txt");
		i = 0;
		while (!($feof(fd)))
		begin
			code = $fscanf(fd, "%b", data);
			final.Memory.Mem[i] = data;
			i = i + 1;
		end
		$fclose(fd);

		i=0;
		while(i<50) begin
			$display("Data at %d:  %b", i, final.Memory.Mem[i]);
			i = i + 1;
		end

		Clk = 0;
		Clr = 0;
		
		repeat(400) #5 Clk = ~Clk;
	end

	initial begin
		#1680 i=0;
		while(i<50) begin
			$display("Data at %d:  %b", i, final.Memory.Mem[i]);
			i = i + 1;
		end
	end
endmodule