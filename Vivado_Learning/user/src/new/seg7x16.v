`timescale 1ns / 1ps

// =============================================================
// seg7x16：8 位数码管动态扫描显示驱动
// -------------------------------------------------------------
// 典型开发板上的 8 位数码管不是“每一位都有一套独立段线”，而是：
// - 8 位共用 8 根段线 o_seg（A~G + DP）
// - 通过位选 o_sel 选择当前点亮哪一位（AN0~AN7）
// - 快速轮流点亮每一位，人眼视觉暂留就会看到“8 位同时亮”
//
// 输出极性（本工程写法）：
// - o_sel：低电平有效（某一位为 0 表示选中该位）
// - o_seg：通常也是低电平点亮（段码 0 表示该段亮）
//   因此 8'hC0 表示显示数字 0（A~F 亮、G 灭、DP 灭）
//
// disp_mode：
// - 0：字符模式，把 i_data 拆成 8 个 4-bit（0~F）并译码成段码
// - 1：图形模式，i_data 直接提供 8 个 8-bit 段码（可自定义图案）
// =============================================================
module seg7x16(
        input clk,
        input rstn,
        input disp_mode,      // SW[0]: 0为字符模式, 1为图形模式
        input [63:0] i_data,  // 要显示的数据
        output [7:0] o_seg,   // 段选信号 (DP, G, F, E, D, C, B, A)
        output [7:0] o_sel    // 位选信号 (AN7 ... AN0)
    );

    reg [14:0] cnt;
    wire seg7_clk;

    // 1. 分频电路：产生扫描时钟
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
    // cnt[14] 作为扫描时钟（分频后的慢时钟）
    // 具体频率取决于板上 clk 的频率：
    // - 假设 clk=100MHz，则 cnt[14] ≈ 100MHz / 2^15 ≈ 3kHz
    // - 8 位轮询后每一位刷新约 3kHz/8 ≈ 375Hz，肉眼不会闪烁
    assign seg7_clk = cnt[14];

    // 2. 位选控制：8选1循环扫描
    reg [2:0] seg7_addr;
    always @(posedge seg7_clk or negedge rstn) begin
        if (!rstn)
            seg7_addr <= 0;
        else
            seg7_addr <= seg7_addr + 1'b1;
    end

    // 3. 输出位选信号（低电平有效）
    reg [7:0] o_sel_r;
    always @(*) begin
        case(seg7_addr)
            0 :
                o_sel_r = 8'b11111110; // AN0
            1 :
                o_sel_r = 8'b11111101; // AN1
            2 :
                o_sel_r = 8'b11111011; // AN2
            3 :
                o_sel_r = 8'b11110111; // AN3
            4 :
                o_sel_r = 8'b11101111; // AN4
            5 :
                o_sel_r = 8'b11011111; // AN5
            6 :
                o_sel_r = 8'b10111111; // AN6
            7 :
                o_sel_r = 8'b01111111; // AN7
            default :
                o_sel_r = 8'b11111111;
        endcase
    end

    // 4. 数据选择：根据当前扫描的位，选择对应的显示内容
    reg [7:0] seg_data_r;
    always @(*) begin
        if(disp_mode == 1'b0) begin // 字符模式：每一位只取 4 bit（显示 0~F）
            case(seg7_addr)
                0 :
                    seg_data_r = i_data[3:0];
                1 :
                    seg_data_r = i_data[7:4];
                2 :
                    seg_data_r = i_data[11:8];
                3 :
                    seg_data_r = i_data[15:12];
                4 :
                    seg_data_r = i_data[19:16];
                5 :
                    seg_data_r = i_data[23:20];
                6 :
                    seg_data_r = i_data[27:24];
                7 :
                    seg_data_r = i_data[31:28];
            endcase
        end
        else begin // 图形模式：每一位取 8 bit（直接作为段码输出）
            case(seg7_addr)
                0 :
                    seg_data_r = i_data[7:0];
                1 :
                    seg_data_r = i_data[15:8];
                2 :
                    seg_data_r = i_data[23:16];
                3 :
                    seg_data_r = i_data[31:24];
                4 :
                    seg_data_r = i_data[39:32];
                5 :
                    seg_data_r = i_data[47:40];
                6 :
                    seg_data_r = i_data[55:48];
                7 :
                    seg_data_r = i_data[63:56];
            endcase
        end
    end

    // 5. 段码译码输出
    reg [7:0] o_seg_r;
    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            o_seg_r <= 8'hFF;
        else if(disp_mode == 1'b0) begin // 字符模式：0~F -> 七段译码
            case(seg_data_r[3:0])
                4'h0 :
                    o_seg_r <= 8'hC0;
                4'h1 :
                    o_seg_r <= 8'hF9;
                4'h2 :
                    o_seg_r <= 8'hA4;
                4'h3 :
                    o_seg_r <= 8'hB0;
                4'h4 :
                    o_seg_r <= 8'h99;
                4'h5 :
                    o_seg_r <= 8'h92;
                4'h6 :
                    o_seg_r <= 8'h82;
                4'h7 :
                    o_seg_r <= 8'hF8;
                4'h8 :
                    o_seg_r <= 8'h80;
                4'h9 :
                    o_seg_r <= 8'h90;
                4'hA :
                    o_seg_r <= 8'h88;
                4'hB :
                    o_seg_r <= 8'h83;
                4'hC :
                    o_seg_r <= 8'hC6;
                4'hD :
                    o_seg_r <= 8'hA1;
                4'hE :
                    o_seg_r <= 8'h86;
                4'hF :
                    o_seg_r <= 8'h8E;
                default :
                    o_seg_r <= 8'hFF;
            endcase
        end
        else begin // 图形模式直接输出
            o_seg_r <= seg_data_r;
        end
    end

    assign o_sel = o_sel_r;
    assign o_seg = o_seg_r;

endmodule
