// alu.v — Version_3 with correct SRL/SRA behavior
module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,
    input       [2:0] alu_ctrl,
    output reg  [WIDTH-1:0] alu_out,
    output      zero
);

always @(*) begin
    case (alu_ctrl)
        3'b000: alu_out = a + b;                       // ADD, ADDI
        3'b001: alu_out = a - b;                       // SUB
        3'b010: alu_out = a & b;                       // AND, ANDI
        3'b011: alu_out = a | b;                       // OR, ORI
        3'b100: alu_out = a << b[4:0];                 // SLL, SLLI
        3'b101: alu_out = a >> b[4:0];                 // SRL, SRLI (logical right)  <-- FIXED
        3'b110: alu_out = $signed(a) >>> b[4:0];       // SRA, SRAI (arithmetic right) <-- FIXED
        3'b111: alu_out = a ^ b;                       // XOR, XORI
        default: alu_out = {WIDTH{1'b0}};
    endcase
end

assign zero = (alu_out == {WIDTH{1'b0}});

endmodule 