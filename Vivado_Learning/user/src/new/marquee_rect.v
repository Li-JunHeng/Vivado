`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 七段显示驱动模块 - seg7x16
// 功能：驱动8个七段数码管，支持两种显示模式
// disp_mode=0: 文本模式（十六进制数字显示）
// disp_mode=1: 图像模式（直接显示段码）
//////////////////////////////////////////////////////////////////////////////////
module seg7x16(
    input clk,
    input rstn,
    input [63:0] i_data,
    output [7:0] o_seg,
    output [7:0] o_sel,
    input disp_mode
);

    reg [14:0] cnt;
    wire seg7_clk;
    always @ (posedge clk, negedge rstn)
    if (!rstn)
        cnt <= 0;
    else
        cnt <= cnt + 1'b1;
    assign seg7_clk = cnt[14];

    reg [2:0] seg7_addr;// 8 to 1
    always @ (posedge seg7_clk, negedge rstn)
    if(!rstn)
        seg7_addr <= 0;
    else
        seg7_addr <= seg7_addr + 1'b1;

    reg [7:0] o_sel_r;
    always @ (*)
    case(seg7_addr)
        7 : o_sel_r = 8'b01111111;
        6 : o_sel_r = 8'b10111111;
        5 : o_sel_r = 8'b11011111;
        4 : o_sel_r = 8'b11101111;
        3 : o_sel_r = 8'b11110111;
        2 : o_sel_r = 8'b11111011;
        1 : o_sel_r = 8'b11111101;
        0 : o_sel_r = 8'b11111110;
    endcase

    reg [63:0] i_data_store;
    always @ (posedge clk, negedge rstn )
    if(!rstn)
        i_data_store <= 0;
    else
        i_data_store <= i_data;

    reg [7:0] seg_data_r;
    always @ (*)
    if(disp_mode == 1'b0) begin
    case(seg7_addr)
        0 : seg_data_r = i_data_store[3:0];
        1 : seg_data_r = i_data_store[7:4];
        2 : seg_data_r = i_data_store[11:8];
        3 : seg_data_r = i_data_store[15:12];
        4 : seg_data_r = i_data_store[19:16];
        5 : seg_data_r = i_data_store[23:20];
        6 : seg_data_r = i_data_store[27:24];
        7 : seg_data_r = i_data_store[31:28];
    endcase end
    else begin
    case(seg7_addr)
          0 : seg_data_r = i_data_store[7:0];
          1 : seg_data_r = i_data_store[15:8];
          2 : seg_data_r = i_data_store[23:16];
          3 : seg_data_r = i_data_store[31:24];
          4 : seg_data_r = i_data_store[39:32];
          5 : seg_data_r = i_data_store[47:40];
          6 : seg_data_r = i_data_store[55:48];
          7 : seg_data_r = i_data_store[63:56];
      endcase end

    reg [7:0] o_seg_r;
    always @ (posedge clk, negedge rstn)
    if(!rstn)
        o_seg_r <= 8'hff;
    else
        if(disp_mode == 1'b0) begin
        case(seg_data_r)
            4'h0 : o_seg_r <= 8'hC0;
            4'h1 : o_seg_r <= 8'hF9;
            4'h2 : o_seg_r <= 8'hA4;
            4'h3 : o_seg_r <= 8'hB0;
            4'h4 : o_seg_r <= 8'h99;
            4'h5 : o_seg_r <= 8'h92;
            4'h6 : o_seg_r <= 8'h82;
            4'h7 : o_seg_r <= 8'hF8;
            4'h8 : o_seg_r <= 8'h80;
            4'h9 : o_seg_r <= 8'h90;
            4'hA : o_seg_r <= 8'h88;
            4'hB : o_seg_r <= 8'h83;
            4'hC : o_seg_r <= 8'hC6;
            4'hD : o_seg_r <= 8'hA1;
            4'hE : o_seg_r <= 8'h86;
            4'hF : o_seg_r <= 8'h8E;
        endcase end
        else begin o_seg_r <= seg_data_r;end

    assign o_sel = o_sel_r;
    assign o_seg = o_seg_r;

endmodule


//////////////////////////////////////////////////////////////////////////////////
// 顶层模块 - marquee_rect
// 功能：矩形变换跑马灯
// SW[0]: 0-文本模式（显示十六进制，不播放），1-图像模式（播放动画）
// SW[15]: 0-慢速，1-快速
//////////////////////////////////////////////////////////////////////////////////
module marquee_rect(
    input CLK100MHZ,
    input CPU_RESETN,
    input [15:0] SW,
    output [7:0] SEG,
    output [7:0] AN
);

    reg[31:0] clkdiv;
    wire Clk_CPU;

    always @ (posedge CLK100MHZ or negedge CPU_RESETN) begin
        if (!CPU_RESETN) clkdiv <= 0;
        else clkdiv <= clkdiv + 1'b1; 
    end

    assign Clk_CPU = (SW[15])? clkdiv[27] : clkdiv[25];

    reg [63:0] display_data; 

    reg [5:0] led_data_addr;
    reg [63:0] led_disp_data;
    parameter LED_DATA_NUM = 19;

    reg [63:0] LED_DATA[18:0];
    initial begin
        LED_DATA[0]  = 64'hC6F6F6F0C6F6F6F0;
        LED_DATA[1]  = 64'hF9F6F6CFF9F6F6CF;
        LED_DATA[2]  = 64'hFFC6F0FFFFC6F0FF;
        LED_DATA[3]  = 64'hFFC0FFFFFFC0FFFF;
        LED_DATA[4]  = 64'hFFA3FFFFFFA3FFFF;
        LED_DATA[5]  = 64'hFFFFA3FFFFFA3FFF;
        LED_DATA[6]  = 64'hFFFF9CFFFFFF9CFF;
        LED_DATA[7]  = 64'hFF9EBCFFFF9EBCFF;
        LED_DATA[8]  = 64'hFF9CFFFFFF9CFFFF;
        LED_DATA[9]  = 64'hFFC0FFFFFFC0FFFF;
        LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
        LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
        LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
        LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
        LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
        LED_DATA[15] = 64'h2737373327373733;
        LED_DATA[16] = 64'h505454EC505454EC;
        LED_DATA[17] = 64'h744454F8744454F8;
        LED_DATA[18] = 64'h0062080000620800;
    end

    always@(posedge Clk_CPU or negedge CPU_RESETN) begin
        if(!CPU_RESETN) begin 
            led_data_addr <= 6'd0;
            led_disp_data <= 64'b1;
        end
        else if(SW[0] == 1'b1) begin
            if (led_data_addr == LED_DATA_NUM) begin 
                led_data_addr <= 6'd0; 
                led_disp_data <= 64'b1;
            end
            led_disp_data <= LED_DATA[led_data_addr];
            led_data_addr <= led_data_addr + 1'b1; 
        end
        else 
            led_data_addr <= led_data_addr;  
    end

    always @(*) begin
        display_data = led_disp_data;
    end

    seg7x16 u_seg7x16(
        .clk(CLK100MHZ),
        .rstn(CPU_RESETN),
        .i_data(display_data),
        .disp_mode(SW[0]),
        .o_seg(SEG),
        .o_sel(AN)
    );

endmodule

