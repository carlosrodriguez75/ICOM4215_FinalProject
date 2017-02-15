//Author: Carlos A. Rodriguez Santiago
module theRegisterFile(input[3:0] In, input enable, clear, clk, input[31:0] D, input[3:0] S1, S2, output reg[31:0] Y1, Y2);
  reg[31:0] Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15;
  reg[15:0] Out;

  //Binary Decoder
  initial begin Q0 = 0; Q1 = 0; Q2 = 0; Q3 = 0; Q4 = 0; Q5 = 0; Q6 = 0; Q7 = 0; Q8 = 0; Q9 = 0; Q10 = 0; Q11 = 0; Q12 = 0; Q13 = 0; Q14 = 0; Q15 = 0; end


  always @ (enable, In) begin
    Out  = 0;
    if (enable) begin
      case (In)
        4'h0 : Out  = 16'h0001;
        4'h1 : Out  = 16'h0002;
        4'h2 : Out  = 16'h0004;
        4'h3 : Out  = 16'h0008;
        4'h4 : Out  = 16'h0010;
        4'h5 : Out  = 16'h0020;
        4'h6 : Out  = 16'h0040;
        4'h7 : Out  = 16'h0080;
        4'h8 : Out  = 16'h0100;
        4'h9 : Out  = 16'h0200;
        4'hA : Out  = 16'h0400;
        4'hB : Out  = 16'h0800;
        4'hC : Out  = 16'h1000;
        4'hD : Out  = 16'h2000;
        4'hE : Out  = 16'h4000;
        4'hF : Out  = 16'h8000;
      endcase
    end
  end

//Registers
always @(posedge clk) begin
  if (enable ==1)
    case(Out)
      16'h0001 : Q0 = D;
      16'h0002 : Q1 = D;
      16'h0004 : Q2 = D;
      16'h0008 : Q3 = D; 
      16'h0010 : Q4 = D; 
      16'h0020 : Q5 = D; 
      16'h0040 : Q6 = D; 
      16'h0080 : Q7 = D; 
      16'h0100 : Q8 = D; 
      16'h0200 : Q9 = D;
      16'h0400 : Q10 = D;
      16'h0800 : Q11 = D; 
      16'h1000 : Q12 = D;
      16'h2000 : Q13 = D; 
      16'h4000 : Q14 = D; 
      16'h8000 : Q15 = D;
    endcase
    //$display("Q15: %b", Q15);
end
  

always @ (S1,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15) begin
  case (S1)
    4'b0000: Y1 = Q0;
    4'b0001: Y1 = Q1;
    4'b0010: Y1 = Q2;
    4'b0011: Y1 = Q3;
    4'b0100: Y1 = Q4;
    4'b0101: Y1 = Q5;
    4'b0110: Y1 = Q6;
    4'b0111: Y1 = Q7;
    4'b1000: Y1 = Q8;
    4'b1001: Y1 = Q9;
    4'b1010: Y1 = Q10;
    4'b1011: Y1 = Q11;
    4'b1100: Y1 = Q12;
    4'b1101: Y1 = Q13;
    4'b1110: Y1 = Q14;
    4'b1111: Y1 = Q15;
  endcase
end

always @ (S2,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15)
  case (S2)
    4'b0000: Y2 = Q0;
    4'b0001: Y2 = Q1;
    4'b0010: Y2 = Q2;
    4'b0011: Y2 = Q3;
    4'b0100: Y2 = Q4;
    4'b0101: Y2 = Q5;
    4'b0110: Y2 = Q6;
    4'b0111: Y2 = Q7;
    4'b1000: Y2 = Q8;
    4'b1001: Y2 = Q9;
    4'b1010: Y2 = Q10;
    4'b1011: Y2 = Q11;
    4'b1100: Y2 = Q12;
    4'b1101: Y2 = Q13;
    4'b1110: Y2 = Q14;
    4'b1111: Y2 = Q15;
  endcase
endmodule