`timescale 1ns / 1ps

// =============================================================
// NPC：Next PC 计算单元
// -------------------------------------------------------------
// 作用：根据当前 PC、立即数 Imm、以及分支/跳转控制信号，算出 next_pc。
//
// 关键信号解释：
// - NPCOp：来自 ctrl.v，决定“下一条 PC 的大模式”
//     0: 顺序执行 next_pc = PC + 4
//     1: 条件分支 next_pc = (flag ? PC+Imm : PC+4)
//     2: JAL      next_pc = PC + Imm
//     3: JALR     next_pc = (rs1 + Imm) & ~1
// - BrType：来自指令 Funct3（Branch 指令的子类型）
// - ALUZero：来自 ALU 的 Zero 输出，常用于判断 A==B（BEQ/BNE）
// - ALUResult0：ALU 结果的 bit0（本工程里用于承载“比较结果”，例如 SLT/SLTU 的 0/1）
//
// 初学者提示：
// - 为什么分支要用 ALUZero / ALUResult0？
//   因为我们复用 ALU 来做比较：
//   * BEQ/BNE：ALU 做 SUB，如果 A-B==0 则 A==B，因此 Zero=1
//   * BLT/BGE：ALU 做 SLT（结果 0/1），用 alu_out[0] 作为比较标志
// =============================================================
module NPC(
        input  [31:0] PC, Imm, rs1,
        input  [1:0]  NPCOp,
        input         ALUZero,
        input         ALUResult0,
        input  [2:0]  BrType,
        output reg [31:0] next_pc
    );
    reg flag;

    // 1. 跳转条件判断
    always @(*) begin
        case(BrType)
            3'b000:
                flag = ALUZero;      // BEQ
            3'b001:
                flag = ~ALUZero;     // BNE
            3'b100:
                flag = ALUResult0;   // BLT
            3'b101:
                flag = ~ALUResult0;  // BGE
            3'b110:
                flag = ALUResult0;   // BLTU
            3'b111:
                flag = ~ALUResult0;  // BGEU

            // =================================================
            // 【DIY 预留区】考试时看题目给的 Funct3 是多少
            // 假设题目给的是 010，就用下面这个 case
            // =================================================
            3'b010: begin
                // 模板 A: BGT (大于跳转) -> !(A<B) && !(A==B)
                flag = (~ALUResult0) && (~ALUZero);

                // 模板 B: BODD (奇数跳转) -> 需配合 ALUOp=AND
                // flag = !ALUZero;
            end

            default:
                flag = 0;
        endcase
    end

    // 2. 下一条 PC 计算 (标准版，无需修改)
    always @(*) begin
        case(NPCOp)
            2'd0:
                next_pc = PC + 4;
            2'd1:
                next_pc = flag ? (PC+Imm) : (PC+4);
            2'd2:
                next_pc = PC + Imm;
            2'd3:
                // JALR 规定跳转目标最低位必须为 0（保证对齐），所以与 ~1
                next_pc = (rs1 + Imm) & ~1;
            default:
                next_pc = PC + 4;
        endcase
    end
endmodule
