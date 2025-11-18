
// datapath.v - datapath module (Version_1, with correct shift-immediate zero-extension)

module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [2:0]   ALUControl,
    input         Jalr,
    output        Zero, ALUR31,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCJalr, PCPlus4, PCTarget, AuiPC, lAuiPC;
wire [31:0] SrcA, SrcB, WriteData, ALUResult;
wire [31:0] ImmExt;

// Immediate extension logic
assign ImmExt = (ImmSrc == 2'b00) ? {{20{Instr[31]}}, Instr[31:20]} :        // I-type
                (ImmSrc == 2'b01) ? {{20{Instr[31]}}, Instr[31:25], Instr[11:7]} : // S-type
                (ImmSrc == 2'b10) ? {{19{Instr[31]}}, Instr[31], Instr[7], Instr[30:25], Instr[11:8], 1'b0} : // B-type
                (ImmSrc == 2'b11) ? {27'b0, Instr[24:20]} :                    // Shift-immediate (zero-extend)
                32'bx;

// Next PC logic
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
mux2 #(32)     jalrmux(PCNext, ALUResult, Jalr, PCJalr);

reset_ff #(32) pcreg(clk, reset, PCJalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);

// Register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);

// ALU logic
// Detect SLT/SLTI and SLTU/SLTIU (R-type or I-type with funct3 = 010/011)
wire is_alu_immediate = (Instr[6:0] == 7'b0010011);
wire is_alu_rtype     = (Instr[6:0] == 7'b0110011);
wire is_slt_signed    = ( (is_alu_immediate || is_alu_rtype) && (Instr[14:12] == 3'b010) );
wire is_slt_unsigned  = ( (is_alu_immediate || is_alu_rtype) && (Instr[14:12] == 3'b011) );

// Comparator results
wire slt_signed_res   = ($signed(SrcA) < $signed(SrcB));
wire slt_unsigned_res = (SrcA < SrcB);

// Override ALU result only for SLT/SLTI and SLTU/SLTIU
wire [31:0] ALUResult_wb = (is_slt_signed)   ? {31'b0, slt_signed_res}   :
                           (is_slt_unsigned) ? {31'b0, slt_unsigned_res} :
                                              ALUResult;
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);
adder #(32)    auipcadder({Instr[31:12], 12'b0}, PC, AuiPC);
mux2 #(32)     lauipcmux(AuiPC, {Instr[31:12], 12'b0}, Instr[5], lAuiPC);

// Result selection logic
// Result selection logic
mux4 #(32) resultmux(
    ALUResult_wb,  // FIX: use compare override for SLT/SLTI and SLTU/SLTIU
    ReadData,
    PCPlus4,
    lAuiPC,
    ResultSrc,
    Result
);

// Outputs
assign ALUR31      = ALUResult[31];
assign Mem_WrData  = WriteData;
assign Mem_WrAddr  = ALUResult;

endmodule 