`timescale 1ns / 1ps
// 七段数码管显示模块
// 支持 8 位数码管动态扫描显示
// 适用于 Nexys A7-100T 开发板
//
// 使用说明：
// 1. 所有端口名称（CLK100MHZ, CPU_RESETN, AN[7:0], SEG[7:0]）与约束文件完全匹配
// 2. 可直接作为顶层模块使用，无需额外映射
// 3. SEG[7:0] = {DP, CG, CF, CE, CD, CC, CB, CA}
//
// 顶层模块示例（如果需要实例化）：
// seg7_display u_seg7 (
//     .CLK100MHZ(CLK100MHZ),
//     .CPU_RESETN(CPU_RESETN),
//     .number(display_value),
//     .AN(AN),
//     .SEG(SEG)  // 直接连接，无需映射
// );

module seg7_display(
    input CLK100MHZ,              // 系统时钟 (100MHz)
    input CPU_RESETN,             // 复位信号（低有效）
    input [31:0] number,          // 要显示的数字（8位十六进制）
    output reg [7:0] AN,          // 位选信号（共阳极，低有效）
    output reg [7:0] SEG          // 段选信号 {DP,CG,CF,CE,CD,CC,CB,CA}
);

    // 扫描时钟分频 - 产生约1.5kHz的扫描频率
    // 100MHz / 2^16 ≈ 1526 Hz
    reg [15:0] scan_cnt;
    wire scan_clk;
    assign scan_clk = scan_cnt[15];  // 使用第15位作为扫描时钟
    
    always @(posedge CLK100MHZ or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            scan_cnt <= 16'b0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    // 位选计数器 - 循环选择 0-7 号数码管
    reg [2:0] digit_sel;
    always @(posedge scan_clk or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            digit_sel <= 3'b0;
        else
            digit_sel <= digit_sel + 1'b1;
    end

    // 提取当前要显示的数字（4位）
    reg [3:0] current_digit;
    always @(*) begin
        case(digit_sel)
            3'd0: current_digit = number[3:0];    // 最低位
            3'd1: current_digit = number[7:4];
            3'd2: current_digit = number[11:8];
            3'd3: current_digit = number[15:12];
            3'd4: current_digit = number[19:16];
            3'd5: current_digit = number[23:20];
            3'd6: current_digit = number[27:24];
            3'd7: current_digit = number[31:28];  // 最高位
            default: current_digit = 4'h0;
        endcase
    end

    // 七段码查找表（共阳极，低电平点亮）
    // 编码格式：{CG, CF, CE, CD, CC, CB, CA}
    reg [6:0] seg_data;
    always @(*) begin
        case(current_digit)
            4'h0: seg_data = 7'b1000000;  // 0: 显示 "0"
            4'h1: seg_data = 7'b1111001;  // 1: 显示 "1"
            4'h2: seg_data = 7'b0100100;  // 2: 显示 "2"
            4'h3: seg_data = 7'b0110000;  // 3: 显示 "3"
            4'h4: seg_data = 7'b0011001;  // 4: 显示 "4"
            4'h5: seg_data = 7'b0010010;  // 5: 显示 "5"
            4'h6: seg_data = 7'b0000010;  // 6: 显示 "6"
            4'h7: seg_data = 7'b1111000;  // 7: 显示 "7"
            4'h8: seg_data = 7'b0000000;  // 8: 显示 "8"
            4'h9: seg_data = 7'b0010000;  // 9: 显示 "9"
            4'hA: seg_data = 7'b0001000;  // A: 显示 "A"
            4'hB: seg_data = 7'b0000011;  // B: 显示 "b"
            4'hC: seg_data = 7'b1000110;  // C: 显示 "C"
            4'hD: seg_data = 7'b0100001;  // D: 显示 "d"
            4'hE: seg_data = 7'b0000110;  // E: 显示 "E"
            4'hF: seg_data = 7'b0001110;  // F: 显示 "F"
            default: seg_data = 7'b1111111;  // 全灭
        endcase
    end

    // 输出位选和段选信号
    always @(posedge scan_clk or negedge CPU_RESETN) begin
        if(!CPU_RESETN) begin
            AN <= 8'b11111111;  // 全部关闭
            SEG <= 8'b11111111; // 全部关闭
        end
        else begin
            // 位选：只选中当前位（低电平有效）
            AN <= ~(8'b00000001 << digit_sel);
            // 段选：输出当前数字的七段码 + 小数点关闭
            SEG <= {1'b1, seg_data};
        end
    end

endmodule

