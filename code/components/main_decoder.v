// main_decoder.v - explicit control-field assignments, ensures shift-immediate sets ImmSrc = 2'b11
module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    input        Zero,
    input        ALUR31,
    output reg [1:0] ResultSrc,
    output reg       MemWrite, Branch, ALUSrc,
    output reg       RegWrite, Jump, Jalr,
    output reg [1:0] ImmSrc,
    output reg [1:0] ALUOp
);

always @(*) begin
    // default values
    RegWrite  = 1'b0;
    ImmSrc    = 2'b00;
    ALUSrc    = 1'b0;
    MemWrite  = 1'b0;
    ResultSrc = 2'b00;
    ALUOp     = 2'b00;
    Jump      = 1'b0;
    Jalr      = 1'b0;
    Branch    = 1'b0;

    casez (op)
        7'b0000011: begin // LOAD (I-type)
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00; // I-type sign-extend
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 2'b01; // from memory
            ALUOp     = 2'b00; // add for address
        end

        7'b0100011: begin // STORE (S-type)
            RegWrite  = 1'b0;
            ImmSrc    = 2'b01; // S-type sign-extend
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
            ResultSrc = 2'b00;
            ALUOp     = 2'b00; // add for address
        end

        7'b0110011: begin // R-type
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00; // not used
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00; // ALU result
            ALUOp     = 2'b10; // use funct3/funct7 for ALU
        end

        7'b1100011: begin // BRANCH (B-type)
            RegWrite  = 1'b0;
            ImmSrc    = 2'b10; // B-type sign-extend
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00;
            ALUOp     = 2'b01; // subtraction for branch eq/ne
            Branch    = 1'b1;

            case (funct3)
                3'b000: Branch = Zero;            // BEQ
                3'b001: Branch = ~Zero;           // BNE
                3'b100: Branch = ALUR31;          // BLT (signed comparison using ALUR31 is existing behavior)
                3'b101: Branch = ~ALUR31;         // BGE (signed)
                3'b110: Branch = ALUR31;          // BLTU (placeholder; unsigned handling may require ALU unsigned flag)
                3'b111: Branch = ~ALUR31;         // BGEU (placeholder)
                default: Branch = 1'b0;
            endcase
        end

        7'b0010011: begin // I-type ALU (immediates)
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00; // default I-type sign-extend
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00; // ALU result
            ALUOp     = 2'b10; // use funct3/funct7 for ALU

            // shift-immediate variants use zero-extended 5-bit immediate
            if (funct3 == 3'b001 || funct3 == 3'b101) begin
                ImmSrc = 2'b11; // shift-immediate: zero-extend Instr[24:20]
            end
        end

        7'b1101111: begin // JAL
            RegWrite  = 1'b1;
            ImmSrc    = 2'b11; // not used for jal writeback, safe value
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b10; // PC+4
            ALUOp     = 2'b00;
            Jump      = 1'b1;
        end

        7'b0?10111: begin // LUI / AUIPC (pattern match)
            RegWrite  = 1'b1;
            ImmSrc    = 2'b11; // for AUIPC we use upper immediate handling externally
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b11; // special lAuiPC path
            ALUOp     = 2'b00;
        end

        7'b1100111: begin // JALR
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00; // I-type immediate for jalr
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 2'b10; // PC+4
            ALUOp     = 2'b00;
            Jalr      = 1'b1;
        end

        default: begin
            // keep defaults (no-op)
        end
    endcase
end

endmodule 