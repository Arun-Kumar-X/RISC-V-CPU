// alu_decoder.v — Version_3 with correct shift-right decode
module alu_decoder (
    input            opb5,
    input  [2:0]     funct3,
    input            funct7b5,
    input  [1:0]     ALUOp,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000; // add (loads/stores)
        2'b01: ALUControl = 3'b001; // sub (branches)
        default: begin
            case (funct3)
                3'b000: ALUControl = (funct7b5 & opb5) ? 3'b001 : 3'b000; // sub/add
                3'b001: ALUControl = 3'b100; // SLL / SLLI
                3'b010:  ALUControl = 3'b001; // SLT / SLTI (signed compare)
					 3'b011:  ALUControl = 3'b010; // SLTU / SLTIU (unsigned compare)
                3'b100: ALUControl = 3'b111; // XOR / XORI
                3'b101: begin
                    // FIX: SRL/SRLI vs SRA/SRAI
                    ALUControl = (funct7b5) ? 3'b110 : 3'b101;
                end
                3'b110: ALUControl = 3'b011; // OR / ORI
                3'b111: ALUControl = 3'b010; // AND / ANDI
                default: ALUControl = 3'b000;
            endcase
        end
    endcase
end

endmodule 