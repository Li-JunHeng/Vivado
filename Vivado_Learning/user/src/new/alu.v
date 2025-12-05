`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU (Arithmetic Logic Unit)
// Description: 32-bit ALU for RISC-V
//              Supports basic arithmetic and logic operations
//              Compatible with RF (Register File) module
//////////////////////////////////////////////////////////////////////////////////

module ALU (
    input  [31:0] A,        // 操作数 A (Operand A)
    input  [31:0] B,        // 操作数 B (Operand B)
    input  [2:0]  ALUOp,    // ALU 操作码 (ALU Operation Code)
    output [31:0] C,        // 运算结果 (Result)
    output        Zero      // 零标志位 (Zero Flag: 1 if C==0, else 0)
);

    reg [31:0] alu_result;

    // ALU 运算逻辑 (组合逻辑)
    always @(*) begin
        case (ALUOp)
            3'b000: alu_result = A + B;         // 加法 (ADD)
            3'b001: alu_result = A - B;         // 减法 (SUB)
            3'b010: alu_result = A & B;         // 按位与 (AND)
            3'b011: alu_result = A | B;         // 按位或 (OR)
            3'b100: alu_result = A ^ B;         // 按位异或 (XOR)
            3'b101: alu_result = (A < B) ? 32'd1 : 32'd0;  // 小于比较 (SLT - Set Less Than)
            3'b110: alu_result = A << B[4:0];   // 逻辑左移 (SLL - Shift Left Logical)
            3'b111: alu_result = A >> B[4:0];   // 逻辑右移 (SRL - Shift Right Logical)
            default: alu_result = 32'd0;        // 默认输出 0
        endcase
    end

    // 输出赋值
    assign C = alu_result;
    assign Zero = (alu_result == 32'd0) ? 1'b1 : 1'b0;

endmodule

