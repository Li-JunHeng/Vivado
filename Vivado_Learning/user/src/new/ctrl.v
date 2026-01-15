`timescale 1ns/1ps

// =============================================================
// ctrl: 控制器 / 指令译码器 (Control Unit / Decoder)
// =============================================================
// 功能: 根据指令的 opcode/funct3/funct7 字段，生成各类控制信号
//
// 输入: 来自指令的字段
//   - opcode  = instr[6:0]   : 主操作码 (决定大类: R/I/Load/Store/Branch/J...)
//   - funct3  = instr[14:12] : 子操作码 (决定具体运算/分支类型/访存宽度等)
//   - funct7  = instr[31:25] : 进一步区分 (例如 ADD vs SUB、SRL vs SRA)
//
// 输出: 各类控制信号 (连接到数据通路)
//   - RegWrite  : 寄存器堆写使能 (写回阶段是否写寄存器)
//   - MemWrite  : 数据存储器写使能 (Store 指令)
//   - ext_op    : 立即数扩展类型 (告诉 EXT 模块按 I/S/B/J/U 哪种格式拼立即数)
//   - alu_op    : 告诉 ALU 做什么运算 (编码在 alu.v 里解释)
//   - npc_op    : 告诉 NPC 选择哪种"下一条 PC"计算方式 (顺序/分支/jal/jalr)
//   - wb_sel    : 写回数据选择 (ALU 结果 / DM 读出 / PC+4)
//   - alu_src_a : ALU 的 A 口来源 (0:RD1, 1:PC，用于 AUIPC)
//   - alu_src_b : ALU 的 B 口来源 (0:RD2, 1:imm，用于 I/Load/Store/LUI/AUIPC)
//   - mem_type  : 访存宽度与符号扩展类型 (通常直接等于 funct3，给 dm.v 用)
//
// 初学者提示:
// - "控制器"做的事就是: 看指令的 opcode/funct3/funct7，然后输出一堆开关信号
// - 这里是单周期/简单 CPU 常见写法: 大量 assign + 少量组合 always @(*)
// =============================================================

// =============================================================
// RV32I Opcode 编码对照表 (来自 RISC-V 规范)
// =============================================================
// Opcode      | 格式   | 指令类型           | 说明
// ------------|--------|--------------------|-----------------------
// 7'b0110011  | R-Type | ADD/SUB/SLL/...    | 寄存器-寄存器运算
// 7'b0010011  | I-Type | ADDI/SLTI/XORI/... | 寄存器-立即数运算
// 7'b0000011  | I-Type | LB/LH/LW/LBU/LHU   | Load 指令
// 7'b0100011  | S-Type | SB/SH/SW           | Store 指令
// 7'b1100011  | B-Type | BEQ/BNE/BLT/...    | 条件分支
// 7'b1101111  | J-Type | JAL                | 无条件跳转并链接
// 7'b1100111  | I-Type | JALR               | 寄存器跳转并链接
// 7'b0110111  | U-Type | LUI                | 加载高位立即数
// 7'b0010111  | U-Type | AUIPC              | PC 加高位立即数
// =============================================================

// =============================================================
// DIY 指令 Opcode 选择原理
// =============================================================
// RISC-V 标准保留了部分 opcode 空间供自定义扩展:
// - 7'b0001011: custom-0 (官方保留)
// - 7'b0101011: custom-1 (官方保留)
// - 7'b1011011: custom-2 (官方保留) <- 本工程用于 DIY 计算指令
// - 7'b1111011: custom-3 (官方保留)
//
// 本工程额外使用 7'b1011111 作为 DIY 分支指令
// 注意: 考试时请根据题目要求的 opcode 修改下方定义
// =============================================================

// =============================================================
// ALUOp 编码参考 (与 alu.v 保持同步)
// =============================================================
// ALUOp | 操作  | 描述                      | 适用指令
// ------|-------|---------------------------|------------------
//   0   | ADD   | 加法 A + B                | ADD/ADDI/Load/Store/AUIPC
//   1   | SUB   | 减法 A - B                | SUB/BEQ/BNE
//   2   | SLL   | 逻辑左移 A << B[4:0]      | SLL/SLLI
//   3   | SLT   | 有符号比较 A < B ? 1 : 0  | SLT/SLTI/BLT/BGE
//   4   | SLTU  | 无符号比较                | SLTU/SLTIU/BLTU/BGEU
//   5   | XOR   | 按位异或 A ^ B            | XOR/XORI
//   6   | SRL   | 逻辑右移 A >> B[4:0]      | SRL/SRLI
//   7   | SRA   | 算术右移 A >>> B[4:0]     | SRA/SRAI
//   8   | OR    | 按位或 A | B              | OR/ORI
//   9   | AND   | 按位与 A & B              | AND/ANDI
//  10   | LUI   | 直通 B (高位立即数)       | LUI
//  11   | DIY   | 自定义计算 (如 MIN/MAX)   | DIY_CALC
//  12   | DIY_BR| 自定义分支辅助            | DIY_BRANCH
// =============================================================

module ctrl(
    input  [6:0] opcode,           // 主操作码 instr[6:0]
    input  [6:0] funct7,           // 功能码 instr[31:25]
    input  [2:0] funct3,           // 功能码 instr[14:12]
    output       RegWrite,         // 寄存器写使能
    output       MemWrite,         // 存储器写使能
    output [5:0] ext_op,           // 立即数扩展类型
    output reg [4:0] alu_op,       // ALU 操作码
    output [1:0] npc_op,           // Next PC 操作类型
    output [1:0] wb_sel,           // 写回数据选择
    output       alu_src_a,        // ALU A 端口来源选择
    output       alu_src_b,        // ALU B 端口来源选择
    output [2:0] mem_type          // 访存类型 (宽度/符号扩展)
);

    // ---------------------------------------------------------
    // 1. Opcode 常量定义
    // ---------------------------------------------------------
    localparam OP_RTYPE      = 7'b0110011;  // R-Type: 寄存器-寄存器运算
    localparam OP_I_ALU      = 7'b0010011;  // I-Type: 寄存器-立即数运算
    localparam OP_LOAD       = 7'b0000011;  // Load 指令
    localparam OP_STORE      = 7'b0100011;  // Store 指令
    localparam OP_BRANCH     = 7'b1100011;  // 条件分支
    localparam OP_JAL        = 7'b1101111;  // JAL
    localparam OP_JALR       = 7'b1100111;  // JALR
    localparam OP_LUI        = 7'b0110111;  // LUI
    localparam OP_AUIPC      = 7'b0010111;  // AUIPC
    localparam OP_DIY_CALC   = 7'b1011011;  // DIY 计算指令 (custom-2)
    localparam OP_DIY_BRANCH = 7'b1011111;  // DIY 分支指令

    // ---------------------------------------------------------
    // 2. 指令类型识别 (组合逻辑)
    // ---------------------------------------------------------
    wire is_rtype      = (opcode == OP_RTYPE);
    wire is_i_alu      = (opcode == OP_I_ALU);
    wire is_load       = (opcode == OP_LOAD);
    wire is_store      = (opcode == OP_STORE);
    wire is_branch     = (opcode == OP_BRANCH);
    wire is_jal        = (opcode == OP_JAL);
    wire is_jalr       = (opcode == OP_JALR);
    wire is_lui        = (opcode == OP_LUI);
    wire is_auipc      = (opcode == OP_AUIPC);

    // 【DIY 预留区: 考试时修改上方 localparam 的 7'b...】
    wire is_diy_calc   = (opcode == OP_DIY_CALC);   // DIY 计算指令 (如 MIN, MAX)
    wire is_diy_branch = (opcode == OP_DIY_BRANCH); // DIY 分支指令 (如 BGT, BODD)

    // ---------------------------------------------------------
    // 3. 辅助信号 (提取公共表达式，提高可读性)
    // ---------------------------------------------------------
    // 需要使用立即数作为 ALU B 端口的指令
    wire use_imm = is_i_alu | is_load | is_store | is_lui | is_auipc | is_diy_calc;

    // 跳转/分支类指令
    wire is_jump_or_branch = is_jal | is_jalr | is_branch | is_diy_branch;

    // ---------------------------------------------------------
    // 4. 控制信号生成
    // ---------------------------------------------------------

    // RegWrite: 哪些指令需要写寄存器 rd？
    // - R/I 运算: 写 rd
    // - Load: 把内存读出的数据写 rd
    // - LUI/AUIPC: 写 rd
    // - JAL/JALR: 把 PC+4 写入 rd (当作返回地址)
    // - diy_calc: 自定义"计算类"指令一般也要写回
    assign RegWrite = is_rtype | is_i_alu | is_load | is_lui | is_auipc | is_jal | is_jalr | is_diy_calc;

    // MemWrite: 只有 Store 指令需要写数据存储器
    assign MemWrite = is_store;

    // alu_src_a: AUIPC 的 A 口取 PC (其余通常取寄存器 rs1)
    assign alu_src_a = is_auipc;

    // alu_src_b: 选择 ALU 的第二个操作数来源
    // - 需要"立即数"的指令: I/Load/Store/LUI/AUIPC (以及可能的 diy_calc)
    // - 需要"寄存器"的指令: R-Type
    //
    // 【重要】DIY 指令如果你设计成 I-Type (用立即数)，必须保留 "| is_diy_calc"
    //         DIY 指令如果你设计成 R-Type (用寄存器)，则应删掉 "| is_diy_calc"
    assign alu_src_b = use_imm;

    // wb_sel: 写回数据选择
    // ---------------------------------------------------------
    // wb_sel | 来源         | 适用指令
    // -------|--------------|----------------------------------
    //   0    | alu_result   | R-Type, I-ALU, LUI, AUIPC, DIY_CALC
    //   1    | mem_rd_data  | Load (LB/LH/LW/LBU/LHU)
    //   2    | PC + 4       | JAL, JALR (返回地址)
    // ---------------------------------------------------------
    assign wb_sel = (is_jal | is_jalr) ? 2'd2 : (is_load ? 2'd1 : 2'd0);

    // npc_op: 下一条 PC 的来源选择
    // ---------------------------------------------------------
    // npc_op | 计算方式              | 适用指令
    // -------|----------------------|---------------------------
    //   0    | PC + 4               | 顺序执行 (大多数指令)
    //   1    | flag ? PC+Imm : PC+4 | 条件分支 (BEQ/BNE/BLT...)
    //   2    | PC + Imm             | JAL (无条件跳转)
    //   3    | (rs1+Imm) & ~1       | JALR (寄存器跳转)
    // ---------------------------------------------------------
    // DIY 分支指令也走 "Branch 模式(1)"
    assign npc_op = is_jalr ? 2'd3 : (is_jal ? 2'd2 : ((is_branch | is_diy_branch) ? 2'd1 : 2'd0));

    // ext_op: 立即数扩展类型 (给 EXT 模块)
    // ---------------------------------------------------------
    // ext_op | 类型   | 适用指令
    // -------|--------|----------------------------------------
    //   0    | I-Type | ADDI, SLTI, Load, JALR, SLLI, SRLI...
    //   1    | S-Type | Store (SB, SH, SW)
    //   2    | B-Type | Branch (BEQ, BNE, BLT...)
    //   3    | J-Type | JAL
    //   4    | U-Type | LUI, AUIPC
    // ---------------------------------------------------------
    // DIY 分支指令同样按 B-Type 解析立即数
    assign ext_op = is_store ? 6'd1 :
                    ((is_branch | is_diy_branch) ? 6'd2 :
                    (is_jal ? 6'd3 :
                    ((is_lui | is_auipc) ? 6'd4 : 6'd0)));

    // mem_type: 访存宽度/符号扩展类型，通常直接用 funct3
    // ---------------------------------------------------------
    // mem_type | Load 指令 | Store 指令 | 说明
    // ---------|-----------|------------|----------------------
    //   000    | LB        | SB         | 字节，有符号扩展
    //   001    | LH        | SH         | 半字，有符号扩展
    //   010    | LW        | SW         | 字
    //   100    | LBU       | -          | 字节，零扩展
    //   101    | LHU       | -          | 半字，零扩展
    // ---------------------------------------------------------
    assign mem_type = funct3;

    // ---------------------------------------------------------
    // 5. ALU 操作码生成 (较复杂，使用 always 块)
    // ---------------------------------------------------------
    always @(*) begin
        if (is_lui)
            // LUI: ALU 直通 B 端口 (立即数高位)
            alu_op = 5'd10;

        // --- 分支指令 (包括 DIY) ---
        else if (is_branch | is_diy_branch) begin
            if (is_diy_branch) begin
                // 【DIY】分配 12 号给 DIY 分支 (去 alu.v 改逻辑)
                alu_op = 5'd12;
            end
            else if (funct3[2:1] == 2'b00)
                // BEQ/BNE: 用 SUB 比较，通过 Zero 判断相等
                alu_op = 5'd1;
            else if (funct3[2:1] == 2'b10)
                // BLT/BGE: 用 SLT 比较，通过 Result[0] 判断大小
                alu_op = 5'd3;
            else
                // BLTU/BGEU: 用 SLTU 比较 (无符号)
                alu_op = 5'd4;
        end

        // --- Load/Store/AUIPC/JAL/JALR: 地址计算用 ADD ---
        else if (is_load | is_store | is_auipc | is_jal | is_jalr)
            alu_op = 5'd0;

        // --- 计算指令 (R-Type, I-Type, DIY) ---
        else if (is_rtype | is_i_alu | is_diy_calc) begin
            if (is_diy_calc) begin
                // 【DIY】分配 11 号给 DIY 计算 (去 alu.v 改逻辑)
                alu_op = 5'd11;
            end
            else begin
                case(funct3)
                    3'b000:
                        // R-Type: ADD/SUB (由 funct7[5] 决定)
                        // I-Type: ADDI (funct7 不参与，走 ADD)
                        alu_op = (is_rtype && funct7[5]) ? 5'd1 : 5'd0;
                    3'b001:
                        // SLL/SLLI: 逻辑左移
                        alu_op = 5'd2;
                    3'b010:
                        // SLT/SLTI: 有符号小于比较
                        alu_op = 5'd3;
                    3'b011:
                        // SLTU/SLTIU: 无符号小于比较
                        alu_op = 5'd4;
                    3'b100:
                        // XOR/XORI: 按位异或
                        alu_op = 5'd5;
                    3'b101:
                        // SRL/SRA: 由 funct7[5] 决定逻辑/算术右移
                        alu_op = (funct7[5]) ? 5'd7 : 5'd6;
                    3'b110:
                        // OR/ORI: 按位或
                        alu_op = 5'd8;
                    3'b111:
                        // AND/ANDI: 按位与
                        alu_op = 5'd9;
                    default:
                        alu_op = 5'd0;
                endcase
            end
        end
        else
            // 默认: ADD
            alu_op = 5'd0;
    end

endmodule
