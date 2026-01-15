`timescale 1ns / 1ps

// =============================================================
// seg7x16: 8 位数码管动态扫描显示驱动
// =============================================================
// 功能: 驱动 8 位共阴极七段数码管进行动态扫描显示
//
// 典型开发板上的 8 位数码管不是"每一位都有一套独立段线"，而是:
// - 8 位共用 8 根段线 o_seg (A~G + DP)
// - 通过位选 o_sel 选择当前点亮哪一位 (AN0~AN7)
// - 快速轮流点亮每一位，人眼视觉暂留就会看到"8 位同时亮"
//
// 输出极性:
// - o_sel: 低电平有效 (某一位为 0 表示选中该位)
// - o_seg: 低电平点亮 (段码 0 表示该段亮)
// =============================================================

// =============================================================
// 动态扫描显示原理
// =============================================================
// 8 位数码管共用段线，通过快速轮流点亮实现"同时显示"效果:
//
// 时序图:
// scan_clk:  _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
// digit:        0   1   2   3   4   5   6   7   0 ...
// o_sel:     ...0   1   2   3   4   5   6   7   0 ...
//
// 刷新率计算 (假设系统时钟 100MHz):
// - scan_clk = 100MHz / 2^15 ≈ 3.05kHz
// - 每位刷新率 = 3.05kHz / 8 ≈ 381Hz
// - 人眼感知不到闪烁 (>30Hz 即可)
// =============================================================

// =============================================================
// 七段数码管段码对照表 (共阴极，低电平点亮)
// =============================================================
//        a
//       ---
//    f |   | b
//       -g-
//    e |   | c
//       ---  . dp
//        d
//
// 段码格式: {dp, g, f, e, d, c, b, a} (从高位到低位)
// 0 = 该段点亮, 1 = 该段熄灭
//
// 数字 | 段码   | 点亮的段     | 说明
// -----|--------|--------------|------------------
//  0   | 8'hC0  | a,b,c,d,e,f  | g 灭
//  1   | 8'hF9  | b,c          | 只亮右边两段
//  2   | 8'hA4  | a,b,d,e,g    |
//  3   | 8'hB0  | a,b,c,d,g    |
//  4   | 8'h99  | b,c,f,g      |
//  5   | 8'h92  | a,c,d,f,g    |
//  6   | 8'h82  | a,c,d,e,f,g  |
//  7   | 8'hF8  | a,b,c        |
//  8   | 8'h80  | 全亮         | 所有段都亮
//  9   | 8'h90  | a,b,c,d,f,g  |
//  A   | 8'h88  | a,b,c,e,f,g  |
//  B   | 8'h83  | c,d,e,f,g    | 小写 b 形状
//  C   | 8'hC6  | a,d,e,f      |
//  D   | 8'hA1  | b,c,d,e,g    | 小写 d 形状
//  E   | 8'h86  | a,d,e,f,g    |
//  F   | 8'h8E  | a,e,f,g      |
// =============================================================

module seg7x16(
    input         clk,          // 系统时钟
    input         rstn,         // 复位信号 (低电平有效)
    input         disp_mode,    // 显示模式: 0=字符模式, 1=图形模式
    input  [63:0] i_data,       // 要显示的数据
    output [7:0]  o_seg,        // 段选信号 {dp, g, f, e, d, c, b, a}
    output [7:0]  o_sel         // 位选信号 {AN7, ..., AN0}
);

    // ---------------------------------------------------------
    // 1. 分频电路: 产生扫描时钟
    // ---------------------------------------------------------
    reg [14:0] scan_counter;
    wire       scan_clk;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            scan_counter <= 15'd0;
        else
            scan_counter <= scan_counter + 15'd1;
    end

    // scan_counter[14] 作为扫描时钟 (分频后的慢时钟)
    // 具体频率取决于板上 clk 的频率:
    // - 假设 clk = 100MHz，则 scan_clk ≈ 100MHz / 2^15 ≈ 3kHz
    // - 8 位轮询后每一位刷新约 3kHz / 8 ≈ 375Hz，肉眼不会闪烁
    assign scan_clk = scan_counter[14];

    // ---------------------------------------------------------
    // 2. 位选控制: 8 选 1 循环扫描
    // ---------------------------------------------------------
    reg [2:0] digit_select;

    always @(posedge scan_clk or negedge rstn) begin
        if (!rstn)
            digit_select <= 3'd0;
        else
            digit_select <= digit_select + 3'd1;
    end

    // ---------------------------------------------------------
    // 3. 位选信号输出 (低电平有效)
    // ---------------------------------------------------------
    // digit_select 决定当前显示哪一位
    // o_sel 中只有对应位为 0，其他位为 1
    reg [7:0] digit_enable;

    always @(*) begin
        case(digit_select)
            3'd0: digit_enable = 8'b11111110;  // AN0 有效
            3'd1: digit_enable = 8'b11111101;  // AN1 有效
            3'd2: digit_enable = 8'b11111011;  // AN2 有效
            3'd3: digit_enable = 8'b11110111;  // AN3 有效
            3'd4: digit_enable = 8'b11101111;  // AN4 有效
            3'd5: digit_enable = 8'b11011111;  // AN5 有效
            3'd6: digit_enable = 8'b10111111;  // AN6 有效
            3'd7: digit_enable = 8'b01111111;  // AN7 有效
            default: digit_enable = 8'b11111111;  // 全灭
        endcase
    end

    // ---------------------------------------------------------
    // 4. 数据选择: 根据当前扫描位选择对应的显示内容
    // ---------------------------------------------------------
    reg [7:0] digit_value;

    always @(*) begin
        if (disp_mode == 1'b0) begin
            // 字符模式: 每一位只取 4 bit (显示 0~F)
            case(digit_select)
                3'd0: digit_value = {4'b0, i_data[3:0]};
                3'd1: digit_value = {4'b0, i_data[7:4]};
                3'd2: digit_value = {4'b0, i_data[11:8]};
                3'd3: digit_value = {4'b0, i_data[15:12]};
                3'd4: digit_value = {4'b0, i_data[19:16]};
                3'd5: digit_value = {4'b0, i_data[23:20]};
                3'd6: digit_value = {4'b0, i_data[27:24]};
                3'd7: digit_value = {4'b0, i_data[31:28]};
                default: digit_value = 8'd0;
            endcase
        end
        else begin
            // 图形模式: 每一位取 8 bit (直接作为段码输出)
            case(digit_select)
                3'd0: digit_value = i_data[7:0];
                3'd1: digit_value = i_data[15:8];
                3'd2: digit_value = i_data[23:16];
                3'd3: digit_value = i_data[31:24];
                3'd4: digit_value = i_data[39:32];
                3'd5: digit_value = i_data[47:40];
                3'd6: digit_value = i_data[55:48];
                3'd7: digit_value = i_data[63:56];
                default: digit_value = 8'd0;
            endcase
        end
    end

    // ---------------------------------------------------------
    // 5. 段码译码输出
    // ---------------------------------------------------------
    reg [7:0] segment_code;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            segment_code <= 8'hFF;  // 全灭
        else if (disp_mode == 1'b0) begin
            // 字符模式: 0~F -> 七段译码
            case(digit_value[3:0])
                4'h0: segment_code <= 8'hC0;  // 0
                4'h1: segment_code <= 8'hF9;  // 1
                4'h2: segment_code <= 8'hA4;  // 2
                4'h3: segment_code <= 8'hB0;  // 3
                4'h4: segment_code <= 8'h99;  // 4
                4'h5: segment_code <= 8'h92;  // 5
                4'h6: segment_code <= 8'h82;  // 6
                4'h7: segment_code <= 8'hF8;  // 7
                4'h8: segment_code <= 8'h80;  // 8
                4'h9: segment_code <= 8'h90;  // 9
                4'hA: segment_code <= 8'h88;  // A
                4'hB: segment_code <= 8'h83;  // b
                4'hC: segment_code <= 8'hC6;  // C
                4'hD: segment_code <= 8'hA1;  // d
                4'hE: segment_code <= 8'h86;  // E
                4'hF: segment_code <= 8'h8E;  // F
                default: segment_code <= 8'hFF;  // 全灭
            endcase
        end
        else begin
            // 图形模式: 直接输出用户提供的段码
            segment_code <= digit_value;
        end
    end

    // ---------------------------------------------------------
    // 6. 输出赋值
    // ---------------------------------------------------------
    assign o_sel = digit_enable;
    assign o_seg = segment_code;

endmodule
