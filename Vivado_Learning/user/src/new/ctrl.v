`timescale 1ns/1ps

// =============================================================
// ctrl：控制器 / 指令译码器 (Control Unit / Decoder)
// -------------------------------------------------------------
// 输入：来自指令的字段
//   - Op     = instr[6:0]   ：主操作码（决定大类：R/I/Load/Store/Branch/J...）
//   - Funct3 = instr[14:12] ：子操作码（决定具体运算/分支类型/访存宽度等）
//   - Funct7 = instr[31:25] ：进一步区分（例如 ADD vs SUB、SRL vs SRA）
//
// 输出：各类控制信号（连接到数据通路）
//   - RegWrite：寄存器堆写使能（写回阶段是否写寄存器）
//   - MemWrite：数据存储器写使能（Store 指令）
//   - EXTOp   ：立即数扩展类型（告诉 EXT 模块按 I/S/B/J/U 哪种格式拼立即数）
//   - ALUOp   ：告诉 ALU 做什么运算（编码在 alu.v 里解释）
//   - NPCOp   ：告诉 NPC 选择哪种“下一条 PC”计算方式（顺序/分支/jal/jalr）
//   - WDSel   ：写回数据选择（ALU 结果 / DM 读出 / PC+4）
//   - ALUSrcA ：ALU 的 A 口来源（0:RD1, 1:PC，用于 AUIPC）
//   - ALUSrcB ：ALU 的 B 口来源（0:RD2, 1:imm，用于 I/Load/Store/LUI/AUIPC）
//   - DMType  ：访存宽度与符号扩展类型（通常直接等于 Funct3，给 dm.v 用）
//
// 初学者提示：
// - “控制器”做的事就是：看指令的 Op/Funct3/Funct7，然后输出一堆开关信号。
// - 这里是单周期/简单 CPU 常见写法：大量 assign + 少量组合 always @(*)。
// =============================================================
module ctrl(
        input  [6:0] Op, Funct7,
        input  [2:0] Funct3,
        output       RegWrite, MemWrite,
        output [5:0] EXTOp,
        output reg [4:0] ALUOp,
        output [1:0] NPCOp, WDSel,
        output       ALUSrcA, ALUSrcB,
        output [2:0] DMType
    );

    // =========================================================
    // 1. 指令识别
    // =========================================================
    // 这些常量来自 RV32I 指令集的 opcode 定义
    // - 0110011：R-Type（寄存器-寄存器运算）
    // - 0010011：I-Type ALU（寄存器-立即数运算）
    // - 0000011：Load
    // - 0100011：Store
    // - 1100011：Branch
    // - 1101111：JAL
    // - 1100111：JALR
    // - 0110111：LUI
    // - 0010111：AUIPC
    wire rtype = (Op == 7'b0110011);
    wire i_alu = (Op == 7'b0010011);
    wire load  = (Op == 7'b0000011);
    wire store = (Op == 7'b0100011);
    wire branch= (Op == 7'b1100011);
    wire jal   = (Op == 7'b1101111);
    wire jalr  = (Op == 7'b1100111);
    wire lui   = (Op == 7'b0110111);
    wire auipc = (Op == 7'b0010111);

    // 【DIY 预留区：考试时修改这里的 7'b...】
    wire diy_calc   = (Op == 7'b1011011); // 预留给计算指令 (如 MIN, MAX)
    wire diy_branch = (Op == 7'b1011111); // 预留给分支指令 (如 BGT, BODD)

    // =========================================================
    // 2. 控制信号
    // =========================================================

    // RegWrite：哪些指令需要写寄存器 rd？
    // - R/I 运算：写 rd
    // - Load：把内存读出的数据写 rd
    // - LUI/AUIPC：写 rd
    // - JAL/JALR：把 PC+4 写入 rd（当作返回地址）
    // - diy_calc：自定义“计算类”指令一般也要写回
    assign RegWrite = rtype | i_alu | load | lui | auipc | jal | jalr | diy_calc;

    // MemWrite：只有 Store 指令需要写数据存储器
    assign MemWrite = store;

    // ALUSrcA：AUIPC 的 A 口取 PC（其余通常取寄存器 rs1）
    assign ALUSrcA  = auipc;

    // ALUSrcB：选择 ALU 的第二个操作数来源
    // - 需要“立即数”的指令：I/Load/Store/LUI/AUIPC（以及可能的 diy_calc）
    // - 需要“寄存器”的指令：R-Type
    //
    // 【重要】DIY 指令如果你设计成 I-Type（用立即数），必须保留 “| diy_calc”
    //         DIY 指令如果你设计成 R-Type（用寄存器），则应删掉 “| diy_calc”
    assign ALUSrcB  = i_alu | load | store | lui | auipc | diy_calc;

    // WDSel：写回数据选择
    // 0：ALU 结果（大多数算术指令）
    // 1：数据存储器读出（Load）
    // 2：PC+4（JAL/JALR）
    assign WDSel    = (jal | jalr) ? 2'd2 : (load ? 2'd1 : 2'd0);

    // NPCOp：下一条 PC 的来源选择
    // 0：PC+4（顺序执行）
    // 1：分支（满足条件：PC+Imm，否则 PC+4）
    // 2：JAL（无条件：PC+Imm）
    // 3：JALR（无条件：(rs1+Imm)&~1）
    //
    // DIY 分支指令也走 “Branch 模式(1)”
    assign NPCOp    = jalr ? 2'd3 : (jal ? 2'd2 : ((branch | diy_branch) ? 2'd1 : 2'd0));

    // EXTOp：立即数扩展类型（给 EXT 模块）
    // 0:I-Type  1:S-Type  2:B-Type  3:J-Type  4:U-Type
    // DIY 分支指令同样按 B-Type 解析立即数
    assign EXTOp    = store?1: ((branch | diy_branch)?2: (jal?3: ((lui|auipc)?4: 0)));

    // DMType：访存宽度/符号扩展类型，通常直接用 Funct3
    // load：000 LB, 001 LH, 010 LW, 100 LBU, 101 LHU
    // store：000 SB, 001 SH, 010 SW
    assign DMType   = Funct3;

    // =========================================================
    // 3. ALUOp 生成
    // =========================================================
    always @(*) begin
        if (lui)
            ALUOp = 5'd10;

        // --- 分支指令 (包括 DIY) ---
        else if (branch | diy_branch) begin
            if (diy_branch) begin
                ALUOp = 5'd12; // 【DIY】分配 12 号给 DIY 分支 (去 alu.v 改逻辑)
            end
            else if (Funct3[2:1] == 2'b00)
                ALUOp = 5'd1; // BEQ/BNE -> SUB
            else if (Funct3[2:1] == 2'b10)
                ALUOp = 5'd3; // BLT/BGE -> SLT
            else
                ALUOp = 5'd4; // BLTU/BGEU -> SLTU
        end
        else if (load | store | auipc | jal | jalr)
            ALUOp = 5'd0;

        // --- 计算指令 (包括 DIY) ---
        else if (rtype || i_alu || diy_calc) begin
            if (diy_calc) begin
                ALUOp = 5'd11; // 【DIY】分配 11 号给 DIY 计算 (去 alu.v 改逻辑)
            end
            else begin
                case(Funct3)
                    3'b000:
                        // R-Type：ADD/SUB（由 Funct7[5] 决定）
                        // I-Type：ADDI（Funct7 不参与，走 ADD）
                        ALUOp = (rtype && Funct7[5]) ? 5'd1 : 5'd0;
                    3'b001:
                        ALUOp = 5'd2;
                    3'b010:
                        ALUOp = 5'd3;
                    3'b011:
                        ALUOp = 5'd4;
                    3'b100:
                        ALUOp = 5'd5;
                    3'b101:
                        // SRL/SRA：由 Funct7[5] 决定
                        ALUOp = (Funct7[5]) ? 5'd7 : 5'd6;
                    3'b110:
                        ALUOp = 5'd8;
                    3'b111:
                        ALUOp = 5'd9;
                    default:
                        ALUOp = 5'd0;
                endcase
            end
        end
        else
            ALUOp = 5'd0;
    end
endmodule
