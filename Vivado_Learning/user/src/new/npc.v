`timescale 1ns / 1ps

// =============================================================
// NPC: Next PC 计算单元 (Next Program Counter)
// =============================================================
// 功能: 根据当前 PC、立即数、以及分支/跳转控制信号，计算下一条指令地址
//
// 输入信号说明:
// - PC         : 当前程序计数器值
// - imm_offset : 来自 EXT 模块的立即数 (偏移量)
// - rs1_data   : 寄存器 rs1 的值 (用于 JALR)
// - npc_op     : 来自 ctrl.v，决定"下一条 PC 的计算模式"
// - alu_zero   : 来自 ALU 的 Zero 输出，用于判断 A==B (BEQ/BNE)
// - alu_cmp    : ALU 结果的 bit0，用于承载比较结果 (SLT/SLTU 的 0/1)
// - branch_type: 来自指令 funct3 (Branch 指令的子类型)
//
// 输出信号:
// - next_pc    : 计算得到的下一条 PC 地址
// =============================================================

// =============================================================
// 分支条件判断原理详解
// =============================================================
// 分支指令复用 ALU 进行比较，通过 alu_zero 和 alu_cmp 判断:
//
// 【BEQ (相等跳转)】
//   - ctrl.v 设置 ALUOp = SUB (减法)
//   - ALU 执行: rs1 - rs2
//   - 若 rs1 == rs2，则结果为 0，alu_zero = 1
//   - 判断: branch_taken = alu_zero
//
// 【BNE (不等跳转)】
//   - ctrl.v 设置 ALUOp = SUB (减法)
//   - ALU 执行: rs1 - rs2
//   - 若 rs1 != rs2，则结果非 0，alu_zero = 0
//   - 判断: branch_taken = ~alu_zero
//
// 【BLT (有符号小于跳转)】
//   - ctrl.v 设置 ALUOp = SLT (有符号比较)
//   - ALU 执行: (rs1 < rs2) ? 1 : 0
//   - 若 rs1 < rs2，则结果 = 1，alu_cmp = 1
//   - 判断: branch_taken = alu_cmp
//
// 【BGE (有符号大于等于跳转)】
//   - ctrl.v 设置 ALUOp = SLT (有符号比较)
//   - ALU 执行: (rs1 < rs2) ? 1 : 0
//   - 若 rs1 >= rs2，则结果 = 0，alu_cmp = 0
//   - 判断: branch_taken = ~alu_cmp
//
// 【BLTU/BGEU】类似 BLT/BGE，但 ALU 执行 SLTU (无符号比较)
// =============================================================

// =============================================================
// DIY 分支指令设计示例
// =============================================================
//
// 【示例 1: BGT (大于跳转)】Branch if Greater Than
// ─────────────────────────────────────────────────────────────
// 条件: rs1 > rs2 (有符号)
// 等价: !(rs1 < rs2) && !(rs1 == rs2)
// 实现方案:
//   - ctrl.v 设置 ALUOp = SLT (结果存入 alu_cmp)
//   - 同时利用 ALU 的 SUB 结果判断相等 (alu_zero)
//   - 实际: ctrl.v 需设置 ALUOp = DIY_BR(12)，在 alu.v 中同时计算
//   - 判断: branch_taken = (~alu_cmp) && (~alu_zero)
//   - 即: 不小于 且 不等于 = 大于
//
// 【示例 2: BODD (奇数跳转)】Branch if Odd
// ─────────────────────────────────────────────────────────────
// 条件: rs1[0] == 1 (最低位为1，即奇数)
// 实现方案:
//   - ctrl.v 设置 ALUOp = AND
//   - ALU 执行: rs1 & 1
//   - 若 rs1 为奇数，结果 = 1，alu_zero = 0
//   - 判断: branch_taken = ~alu_zero
//
// 【示例 3: BLE (小于等于跳转)】Branch if Less or Equal
// ─────────────────────────────────────────────────────────────
// 条件: rs1 <= rs2 (有符号)
// 等价: (rs1 < rs2) || (rs1 == rs2)
// 实现方案:
//   - 判断: branch_taken = alu_cmp || alu_zero
//   - 即: 小于 或 等于 = 小于等于
//
// 【示例 4: BNEG (负数跳转)】Branch if Negative
// ─────────────────────────────────────────────────────────────
// 条件: rs1[31] == 1 (最高位为1，即负数)
// 实现方案:
//   - ctrl.v 设置 ALUOp = SLT，比较 rs1 < 0
//   - 或直接在 DIY ALU 操作中检查符号位
//   - 判断: branch_taken = alu_cmp (rs1 < 0 的结果)
// =============================================================

module NPC(
    input  [31:0] PC,           // 当前程序计数器
    input  [31:0] imm_offset,   // 立即数偏移量 (来自 EXT)
    input  [31:0] rs1_data,     // 寄存器 rs1 的值 (用于 JALR)
    input  [1:0]  npc_op,       // Next PC 操作类型
    input         alu_zero,     // ALU Zero 标志 (结果是否为0)
    input         alu_cmp,      // ALU 比较结果 (SLT/SLTU 的 bit0)
    input  [2:0]  branch_type,  // 分支类型 (来自 funct3)
    output reg [31:0] next_pc   // 计算得到的下一条 PC
);

    // ---------------------------------------------------------
    // 1. NPCOp 常量定义 (与 ctrl.v 保持一致)
    // ---------------------------------------------------------
    localparam NPC_SEQ    = 2'd0;  // 顺序执行: PC + 4
    localparam NPC_BRANCH = 2'd1;  // 条件分支: flag ? PC+Imm : PC+4
    localparam NPC_JAL    = 2'd2;  // JAL: PC + Imm (无条件)
    localparam NPC_JALR   = 2'd3;  // JALR: (rs1 + Imm) & ~1

    // ---------------------------------------------------------
    // 2. 分支类型常量定义 (对应 funct3)
    // ---------------------------------------------------------
    localparam BR_BEQ  = 3'b000;  // 相等跳转
    localparam BR_BNE  = 3'b001;  // 不等跳转
    localparam BR_BLT  = 3'b100;  // 有符号小于跳转
    localparam BR_BGE  = 3'b101;  // 有符号大于等于跳转
    localparam BR_BLTU = 3'b110;  // 无符号小于跳转
    localparam BR_BGEU = 3'b111;  // 无符号大于等于跳转
    localparam BR_DIY  = 3'b010;  // DIY 预留

    // ---------------------------------------------------------
    // 3. 分支条件判断逻辑
    // ---------------------------------------------------------
    reg branch_taken;  // 分支是否成立

    always @(*) begin
        case(branch_type)
            BR_BEQ:
                // BEQ: 若 rs1 == rs2 (ALU 做 SUB，结果为 0)
                branch_taken = alu_zero;

            BR_BNE:
                // BNE: 若 rs1 != rs2 (ALU 做 SUB，结果非 0)
                branch_taken = ~alu_zero;

            BR_BLT:
                // BLT: 若 rs1 < rs2 (有符号，ALU 做 SLT)
                branch_taken = alu_cmp;

            BR_BGE:
                // BGE: 若 rs1 >= rs2 (有符号，即 !(rs1 < rs2))
                branch_taken = ~alu_cmp;

            BR_BLTU:
                // BLTU: 若 rs1 < rs2 (无符号，ALU 做 SLTU)
                branch_taken = alu_cmp;

            BR_BGEU:
                // BGEU: 若 rs1 >= rs2 (无符号)
                branch_taken = ~alu_cmp;

            // =================================================
            // 【DIY 预留区】考试时看题目给的 funct3 是多少
            // 假设题目给的是 010，就用下面这个 case
            // =================================================
            BR_DIY: begin
                // -----------------------------------------------
                // 模板 A: BGT (大于跳转)
                // 条件: !(rs1 < rs2) && !(rs1 == rs2)
                // -----------------------------------------------
                branch_taken = (~alu_cmp) && (~alu_zero);

                // -----------------------------------------------
                // 模板 B: BODD (奇数跳转)
                // 需配合 ctrl.v 设置 ALUOp = AND (rs1 & 1)
                // 若 rs1 为奇数，结果非 0，alu_zero = 0
                // -----------------------------------------------
                // branch_taken = ~alu_zero;

                // -----------------------------------------------
                // 模板 C: BLE (小于等于跳转)
                // 条件: (rs1 < rs2) || (rs1 == rs2)
                // -----------------------------------------------
                // branch_taken = alu_cmp || alu_zero;
            end

            default:
                branch_taken = 1'b0;
        endcase
    end

    // ---------------------------------------------------------
    // 4. 下一条 PC 计算逻辑
    // ---------------------------------------------------------
    always @(*) begin
        case(npc_op)
            NPC_SEQ:
                // 顺序执行: PC + 4 (每条指令 4 字节)
                next_pc = PC + 32'd4;

            NPC_BRANCH:
                // 条件分支: 成立则跳转，否则顺序执行
                next_pc = branch_taken ? (PC + imm_offset) : (PC + 32'd4);

            NPC_JAL:
                // JAL: 无条件跳转到 PC + Imm
                next_pc = PC + imm_offset;

            NPC_JALR:
                // JALR: 跳转到 (rs1 + Imm) & ~1
                // 规定跳转目标最低位必须为 0 (保证对齐)，所以 & ~1
                next_pc = (rs1_data + imm_offset) & (~32'd1);

            default:
                next_pc = PC + 32'd4;
        endcase
    end

endmodule
