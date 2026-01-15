`timescale 1ns / 1ps

// =============================================================
// SCPU_TOP：单周期（或简化）CPU 顶层封装 + 板级外设连接
// -------------------------------------------------------------
// 你可以把它理解成“把所有模块连起来的总装配图”：
//   PC -> 指令存储器(IM) -> 控制器(ctrl) / 立即数(EXT) / 寄存器堆(RF)
//      -> ALU -> 数据存储器(DM) -> 写回 RF
//      -> NPC 计算 next PC -> 更新 PC
//
// 板级输入/输出：
// - sw_i[15]：选择 CPU 时钟快/慢（用于观察运行过程）
// - sw_i[1] ：调试模式开关（=1 时暂停 CPU 的 PC 更新，并允许手动读寄存器）
// - sw_i[14:12]：选择数码管显示内容
// - led_o：这里直接把开关值映射到 LED，方便确认开关状态
//
// 初学者提示：
// - 顶层主要是“连线”，不应包含复杂算法；复杂逻辑应该放在子模块里。
// - 时序逻辑用 always @(posedge ...)；组合逻辑用 always @(*) / assign。
// =============================================================
module SCPU_TOP(
        input clk,
        input rstn,
        input [15:0] sw_i,
        input BTNC, BTNU, BTNL, BTNR, BTND,
        output [15:0] led_o,
        output [7:0] disp_an_o,
        output [7:0] disp_seg_o
    );

    // ---------------------------------------------------------
    // 1) 时钟分频：用板上高速 clk 产生一个“更适合观察”的 clk_cpu
    // ---------------------------------------------------------
    reg [31:0] clk_div;
    always @(posedge clk or negedge rstn)
        if (!rstn)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;

    // sw_i[15]=1：选择更慢的分频时钟（便于肉眼观察）
    // sw_i[15]=0：选择更快的分频时钟（运行更快）
    wire clk_cpu = sw_i[15] ? clk_div[26] : clk_div[2];

    // ---------------------------------------------------------
    // 2) PC 寄存器：保存当前指令地址
    // ---------------------------------------------------------
    reg [31:0] PC;
    wire [31:0] NPC_out;
    always @(posedge clk_cpu or negedge rstn)
        if (!rstn)
            PC <= 0;
        else if (sw_i[1]==0) // 调试模式(sw_i[1]=1)下暂停 PC 更新，便于观察
            PC <= NPC_out;

    // ---------------------------------------------------------
    // 3) 子模块连线（数据通路）
    // ---------------------------------------------------------
    // instr：取出的 32 位指令
    // RD1/RD2：寄存器堆读出的两个源操作数
    // immout：扩展后的立即数
    // alu_out：ALU 运算结果（也常作为访存地址）
    // dm_out：数据存储器读出数据
    // WD：写回寄存器堆的数据（Write Data）
    wire [31:0] instr, RD1, RD2, immout, alu_out, dm_out, WD;
    wire [31:0] alu_a, alu_b;
    wire RegWrite, MemWrite, ALUSrcA, ALUSrcB, Zero;
    wire [4:0] ALUOp;
    wire [5:0] EXTOp;
    wire [2:0] DMType;
    wire [1:0] WDSel, NPCOp;

    // 指令存储器：通常由 Vivado 的 IP（dist_mem_im）生成
    // 注意：PC 是字节地址；RV32I 指令 4 字节对齐，所以取 PC[7:2] 作为“字地址”
    dist_mem_im U_IM (.a(PC[7:2]), .spo(instr));

    // 控制器：根据 instr 字段生成控制信号
    ctrl U_Ctrl (
             .Op(instr[6:0]), .Funct7(instr[31:25]), .Funct3(instr[14:12]),
             .RegWrite(RegWrite), .MemWrite(MemWrite), .EXTOp(EXTOp),
             .ALUOp(ALUOp), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
             .DMType(DMType), .WDSel(WDSel), .NPCOp(NPCOp)
         );

    // 寄存器堆：A1/A2/A3 对应 rs1/rs2/rd
    RF U_RF (
           .clk(clk_cpu), .rstn(rstn), .RFWr(RegWrite), .sw_i(sw_i),
           // 调试模式(sw_i[1]=1)：用开关 sw_i[10:6] 手动选择读哪个寄存器，方便在板子上查看
           // 正常模式(sw_i[1]=0)：A1 取 rs1 = instr[19:15]
           .A1(sw_i[1]? sw_i[10:6] : instr[19:15]),
           .A2(instr[24:20]), .A3(instr[11:7]), .WD(WD),
           .RD1(RD1), .RD2(RD2)
       );

    // 立即数生成：把指令中的立即数字段扩展到 32 位
    EXT U_EXT (.instr(instr[31:7]), .EXTOp(EXTOp), .immout(immout));

    // ALU 操作数选择：由控制器决定来自 PC/RD1 和 imm/RD2
    assign alu_a = ALUSrcA ? PC : RD1;
    assign alu_b = ALUSrcB ? immout : RD2;

    alu U_ALU (.A(alu_a), .B(alu_b), .ALUOp(ALUOp), .C(alu_out), .Zero(Zero));

    // 数据存储器：地址取 alu_out 低 8 位（本工程 DM 只有 256 字节）
    dm U_DM (
           .clk(clk_cpu), .DMWr(MemWrite), .addr(alu_out[7:0]),
           .din(RD2), .DMType(DMType), .dout(dm_out)
       );

    // 写回多路选择：
    // - WDSel==2：JAL/JALR 写回 PC+4（返回地址）
    // - WDSel==1：Load 写回 dm_out
    // - 否则写回 ALU 结果
    assign WD = (WDSel==2) ? PC+4 : ((WDSel==1) ? dm_out : alu_out);

    // 下一条 PC 计算：分支/跳转/顺序
    NPC U_NPC (
            .PC(PC), .Imm(immout), .rs1(RD1), .NPCOp(NPCOp),
            .ALUZero(Zero), .ALUResult0(alu_out[0]), .BrType(instr[14:12]),
            .next_pc(NPC_out)
        );

    // ---------------------------------------------------------
    // 4) 数码管显示：把内部信号“可视化”
    // ---------------------------------------------------------
    // display_data 是 64-bit，这里用 seg7x16 的“字符模式”显示低 32-bit 的 8 个十六进制数字
    reg [63:0] display_data;
    always @(*) begin
        if (sw_i[1])
            display_data = {4'hD, 3'b0, sw_i[10:6], 8'b0, RD1[23:0]}; // 调试查RF
        else if (sw_i[14])
            display_data = {32'b0, instr};
        else if (sw_i[13])
            display_data = {32'b0, alu_out};
        else if (sw_i[12])
            display_data = {32'b0, 24'b0, PC[7:0]};
        else
            display_data = {32'b0, WD};
    end

    seg7x16 u_seg (.clk(clk), .rstn(rstn), .disp_mode(1'b0), .i_data(display_data), .o_seg(disp_seg_o), .o_sel(disp_an_o));

    // LED输出(可用于调试)
    assign led_o = sw_i;

endmodule
