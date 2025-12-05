`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: ALU_RF
// Description: 实验任务二 - ALU 与 寄存器堆 (RF) 联调
//              实现 RF 与 ALU 的数据通路连接
//              支持从寄存器读取数据进行运算，并将结果写回寄存器
//
// SW 开关定义 (任务二):
//   SW[15]     : 时钟速度控制 (1: 慢速 ~0.74Hz, 0: 快速 ~3Hz)
//   SW[14]     : ROM 显示模式 (1: 显示 ROM 指令内容)
//   SW[13]     : RF 自动轮询模式 (1: 自动循环显示所有寄存器)
//   SW[12]     : ALU 循环显示模式 (1: 循环显示 A, B, C, Zero, FFFFFFFF)
//   SW[11]     : (保留，当前未使用)
//   SW[10:8]   : 寄存器地址 (复用)
//                - SW[2]=0 时: A1 (读地址1)
//                - SW[2]=1 时: A3 (写地址)
//   SW[7:5]    : 数据/地址 (复用)
//                - SW[2]=0 时: A2 (读地址2)
//                - SW[2]=1 时: WD (写数据，3位扩展为32位)
//   SW[4:3]    : ALU 操作码 (ALUOp[1:0])
//   SW[2]      : 写使能 (RFWr: 1=写模式, 0=读模式)
//   SW[1]      : 调试模式 (1=保护模式，禁止写入)
//   SW[0]      : (保留，暂未使用)
//////////////////////////////////////////////////////////////////////////////////

module ALU_RF (
    input         clk,          // 100MHz 板载时钟
    input         rstn,         // 复位信号，低电平有效 (CPU_RESETN)
    input  [15:0] sw_i,         // 拨码开关输入
    output [7:0]  disp_an_o,    // 数码管位选信号
    output [7:0]  disp_seg_o    // 数码管段选信号
);

    //================================================================
    // 1. 时钟分频模块 (Clock Divider)
    //================================================================
    reg [31:0] clkdiv;
    wire Clk_CPU;  // 用于循环显示和RF轮询的慢速时钟

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            clkdiv <= 0;
        else
            clkdiv <= clkdiv + 1'b1;
    end

    // sw_i[15] 控制时钟速度
    // 1: 慢速 (约0.74Hz), 0: 快速 (约3Hz)
    assign Clk_CPU = (sw_i[15]) ? clkdiv[27] : clkdiv[25];


    //================================================================
    // 2. RF (寄存器堆) 信号定义与多路复用
    //================================================================
    wire [4:0]  rf_A1, rf_A2, rf_A3;
    wire [31:0] rf_WD;
    wire [31:0] rf_RD1, rf_RD2;
    wire        rf_RFWr;
    reg  [4:0]  rf_addr_cnt;  // 用于 SW[13]=1 时的RF自动轮询

    // RF 自动扫描计数器 (当 SW[13]=1 时自动循环显示所有寄存器)
    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            rf_addr_cnt <= 5'd0;
        else if (sw_i[13] == 1'b1)  // 仅在 RF 循环显示模式下计数
            rf_addr_cnt <= rf_addr_cnt + 1'b1;
        else
            rf_addr_cnt <= 5'd0;
    end

    // A1 (读地址1): SW[13]=1时用计数器自动轮询，否则用开关SW[10:8]
    assign rf_A1 = (sw_i[13]) ? rf_addr_cnt : {2'b00, sw_i[10:8]};

    // A2 (读地址2): 始终由 SW[7:5] 控制
    assign rf_A2 = {2'b00, sw_i[7:5]};

    // A3 (写地址): 手动写入时用 SW[10:8]
    assign rf_A3 = {2'b00, sw_i[10:8]};

    // WD (写数据): 仅来自开关 SW[7:5]，扩展为32位
    assign rf_WD = {29'd0, sw_i[7:5]};

    // RFWr (写使能): 由 SW[2] 控制
    assign rf_RFWr = sw_i[2];


    //================================================================
    // 3. ROM 指令显示逻辑 (SW[14]=1 显示)
    //================================================================
    reg [5:0] rom_addr;      // ROM 地址计数器
    wire [31:0] instr;       // ROM 输出指令

    // ROM 地址累加：仅在选择显示ROM时递增
    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            rom_addr <= 6'd0;
        else if (sw_i[14])
            rom_addr <= rom_addr + 1'b1;
    end

    // 例化 ROM IP
    dist_mem_im U_IM (
        .a(rom_addr),
        .spo(instr)
    );


    //================================================================
    // 4. 实例化 RF 模块
    //================================================================
    RF U_RF (
        .clk(clk),
        .rstn(rstn),
        .RFWr(rf_RFWr),
        .sw_i(sw_i),        // 传入开关用于写保护判断 (SW[1])
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(rf_A3),
        .WD(rf_WD),
        .RD1(rf_RD1),
        .RD2(rf_RD2)
    );


    //================================================================
    // 5. ALU 信号定义与实例化
    //================================================================
    wire [31:0] alu_A, alu_B;
    wire [2:0]  alu_op;
    wire [31:0] alu_C;
    wire        alu_Zero;

    // ALU 输入来自 RF 的读出数据
    assign alu_A = rf_RD1;
    assign alu_B = rf_RD2;
    
    // ALU 操作码: 由 SW[4:3] 控制 (扩展为3位)
    assign alu_op = {1'b0, sw_i[4:3]};

    // 实例化 ALU
    ALU U_ALU (
        .A(alu_A),
        .B(alu_B),
        .ALUOp(alu_op),
        .C(alu_C),
        .Zero(alu_Zero)
    );

    //================================================================
    // 6. 循环显示逻辑 (当 SW[12]=1 时)
    //================================================================
    // 需要5个状态: 0=A, 1=B, 2=C, 3=Zero, 4=FFFFFFFF
    reg [2:0] disp_sel;  // 3位寄存器，兼容未来扩展

    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            disp_sel <= 3'b000;
        else if (sw_i[12]) begin  // 仅在 SW[12]=1 时循环
            if (disp_sel == 3'd4)
                disp_sel <= 3'b000;  // 循环回到第一个状态
            else
                disp_sel <= disp_sel + 1'b1;
        end
        else begin
            disp_sel <= 3'b000;      // 退出循环后回到起始显示
        end
    end


    //================================================================
    // 7. 显示数据选择与多路复用 (Display Mux)
    //================================================================
    reg [63:0] final_disp_data;

    always @(*) begin
        if (sw_i[14]) begin
            // 优先级1: ROM 指令显示 (SW[14]=1)
            // 低32位显示ROM内容，高32位补0
            final_disp_data = {32'd0, instr};
        end
        else if (sw_i[13]) begin
            // 优先级2: RF 自动轮询显示 (SW[13]=1)
            // 低32位显示当前寄存器值(RD1)，高32位补0
            final_disp_data = {32'd0, rf_RD1};
        end
        else if (sw_i[12]) begin
            // 优先级3: ALU 循环显示模式 (SW[12]=1)
            // 循环显示: A -> B -> C -> Zero -> FFFFFFFF
            case (disp_sel)
                3'd0: final_disp_data = {32'd0, alu_A};        // 显示 A (RD1)
                3'd1: final_disp_data = {32'd0, alu_B};        // 显示 B (RD2)
                3'd2: final_disp_data = {32'd0, alu_C};        // 显示 C (ALU结果)
                3'd3: final_disp_data = {32'd0, 31'd0, alu_Zero}; // 显示 Zero 标志
                3'd4: final_disp_data = {32'd0, 32'hFFFFFFFF}; // 显示 FFFFFFFF
                default: final_disp_data = 64'd0;
            endcase
        end
        else begin
            // 优先级4: 默认显示模式
            // 高32位显示 RD2 (左侧)，低32位显示 RD1 (右侧)
            final_disp_data = {rf_RD2, rf_RD1};
        end
    end


    //================================================================
    // 8. 实例化数码管显示模块
    //================================================================
    // 使用 seg7x16 模块以支持64位数据显示
    seg7x16 U_SEG7 (
        .clk(clk),
        .rstn(rstn),
        .i_data(final_disp_data),   // 64位输入数据
        .disp_mode(1'b0),           // 0: 文本模式 (十六进制显示)
        .o_seg(disp_seg_o),         // 段选输出
        .o_sel(disp_an_o)           // 位选输出
    );

endmodule
