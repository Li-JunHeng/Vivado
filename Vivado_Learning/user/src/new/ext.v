`timescale 1ns / 1ps

// =============================================================
// EXT：立即数扩展 (Immediate Generator)
// -------------------------------------------------------------
// RISC-V 的立即数并不是总在同一段 bit 里，而是按指令类型分为：
//   I-Type / S-Type / B-Type / U-Type / J-Type
// 本模块根据 EXTOp 选择哪一种格式，把 instr[31:7] 里相关位拼成 32 位立即数。
//
// 约定（与 ctrl.v 保持一致）：
//   EXTOp=0:I, 1:S, 2:B, 3:J, 4:U
//
// 初学者提示：
// - {{N{bit}}, ...} 是“重复拼接”，常用于符号扩展：用最高位复制 N 次。
// - B/J 类立即数最低位固定为 0（因为跳转目标按 2 字节对齐），所以这里补 1'b0。
// =============================================================
module EXT(
        input  [31:7] instr,
        input  [5:0]  EXTOp,
        output reg [31:0] immout
    );
    // 下面先把 5 种类型的立即数都“算出来”，最后再按 EXTOp 选择其中一个输出。
    wire [31:0] i_type = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] s_type = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] b_type = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] j_type = {{11{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    wire [31:0] u_type = {instr[31:12], 12'b0};

    always @(*) begin
        case(EXTOp)
            6'd0:
                immout = i_type;
            6'd1:
                immout = s_type;
            6'd2:
                immout = b_type;
            6'd3:
                immout = j_type;
            6'd4:
                immout = u_type;
            default:
                immout = 0;
        endcase
    end
endmodule
