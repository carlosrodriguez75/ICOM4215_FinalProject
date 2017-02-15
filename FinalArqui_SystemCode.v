module Complete_CPU_System(input CLK, CLR);

reg[3:0] CeroValue= 4'b0000;
reg[3:0] OneValue= 4'b1111;

//Clock and Clear wires
wire CLK, CLR;

//Control Unit wires: RFLD & IRLD & MARLD & MDRLD & RW & MOV & Cin & FRLD & MA & MB & MC & MD & ME & OPcu= OUT; Cond & [31:0]IR &  MOC= INPUT
wire [18:0]ControlSignal; wire Cin; wire[7:0] Q; wire[1:0] Size; wire Sign;

//Register wires: PA & PB= OUT; [3:0]A & [3:0]C & RFLD & [31:0]PC & [3:0]IR= INPUT
wire [31:0]PA; wire [31:0]PB;

//MuxA wires: A= OUT; [19:16]IR & [15:12]IR & (1111) & (0000) & [1:0]MA= INPUT
wire [3:0]A;

//MuxB wires: B= OUT; [31:0]PB & [31:0]OUTsse & [31:0]DataIN & (0000) & [1:0]MB= INPUT
wire [31:0]B;

//MuxC wires: C= OUT; [15:12]IR & (1111) & MC= INPUT
wire [3:0]C;

//MuxD wires: OPalu = OUT; [24:21]IR & MD & OPcu= INPUT
wire [4:0]OPalu;

//MuxE wires: E= OUT; [31:0]DataOUT & [31:0]PC & ME= INPUT
wire [31:0]E;

//ALU wires: Flags & PC= OUT; PA & B & Cin & OPalu= INPUT
wire [3:0]Flags; wire [31:0]PC;

//Flag register wires: NewFlags= OUT; FRLD & Flags= INPUT
wire [3:0]NewFlags;

//Condition Tester wires: Cond= OUT; [3:0]FlagsNew & [31:28]IR= INPUT
wire Cond;

//Instruction Register wires: IR= OUT; [31:0]DataOUT & IRLD & CLK = INPUT
wire [31:0]IR;

//Shifter & Sign Extender wires: OUTsse= OUT; [31:0]IR & [31:0]PB= INPUT
wire [31:0]OUTsse;

//MDR wires: DataIN= OUT; [31:0]E & MDRLD= INPUT
wire [31:0]DataIN;

//MAR wires: Address= OUT; [31:0]PC & MARLD= INPUT
wire [31:0]Address;

//Memory wires: DataOUT & MOC= OUT; [31:0]DataIN & MOV & RW & [31:0]Address= INPUT
wire [31:0]DataOUT; wire MOC;


// Module Calls

cunit   ControlUnit(.Out(ControlSignal[18:0]), .MOC(MOC), .Clr(CLR), .Clk(CLK), .InstructionReg(IR[31:0]), .Size(Size), .Sign(Sign), .Cond(Cond)); // Calls Control Unit module

ALU_32Bit ALU(.result(PC[31:0]), .Z(Flags[3]), .N(Flags[2]), .C(Flags[1]), .V(Flags[0]), .A(PA[31:0]), .B(B[31:0]), .Cin(Cin), .OP(OPalu[4:0])); //Calls 32bit ALU module

mux2x1_5bit  MuxD(.Y(OPalu[4:0]), .S(ControlSignal[6]), .I1(ControlSignal[4:0]), .I0(5'b00000 + IR[24:21])); //Calls MuxD module

mux4x1  MuxA(.Y(A[3:0]), .S(ControlSignal[11:10]), .I0(IR[19:16]), .I1(IR[15:12]), .I2(4'b1111), .I3(CeroValue)); // Calls MuxA module

mux2x1  MuxC(.Y(C[3:0]), .S(ControlSignal[7]), .I0(IR[15:12]), .I1(OneValue)); //Calls MuxC module

mux4x1_32bit  MuxB(.Y(B[31:0]), .S(ControlSignal[9:8]), .I0(PB[31:0]), .I1(OUTsse[31:0]), .I2(DataIN[31:0]), .I3(32'h00000000)); // Calls MuxB module

theRegisterFile FileRegister(.In(C[3:0]), .D(PC[31:0]), .enable(ControlSignal[17]), .clear(CLR), .clk(CLK), .Y1(PA[31:0]), .Y2(PB[31:0]), .S1(A[3:0]), .S2(IR[3:0]));

Flag_Register   FlagReg(.Zout(NewFlags[3]), .Nout(NewFlags[2]), .Cout(NewFlags[1]), .Vout(NewFlags[0]), .Z(Flags[3]), .N(Flags[2]), .C(Flags[1]), .V(Flags[0]), .FRLd(ControlSignal[18])); // Calls Flag register module

Condition_Tester    CondTest(.Cond(Cond), .Z(NewFlags[3]), .N(NewFlags[2]), .C(NewFlags[1]), .V(NewFlags[0]), .CC(IR[31:28])); // Calls Condition Tester module

MARreg   MAR(.Qs(Address[31:0]), .Ds(PC[31:0]), .Ld(ControlSignal[15]), .Clk(CLK)); // Calls Instruction register module

ram256x8    Memory(.DataOut(DataOUT[31:0]), .MOC(MOC), .Enable(ControlSignal[12]), .ReadWrite(ControlSignal[13]), .Address(Address[31:0]), .DataIn(DataIN[31:0]), .Size(Size), .Sign(Sign)); // Calls Memory module

Ireg   IR_Register(.Ds(DataOUT[31:0]), .Qs(IR[31:0]), .Ld(ControlSignal[16]), .Clk(CLK)); // Calls Instruction register module

shifter Shifter_SignExt(.O(OUTsse[31:0]), .InstructionReg(IR[31:0]), .Rm(PB[31:0])); // Calls Shifter & Sign Extender module

reg32   MDR(.Qs(DataIN[31:0]), .Ds(E[31:0]), .Ld(ControlSignal[14]), .Clk(CLK)); // Calls Instruction register module

mux2x1_32bit  MuxE(.Y(E[31:0]), .S(ControlSignal[5]), .I0(DataOUT[31:0]), .I1(PC[31:0])); // Calls MuxE module

endmodule





