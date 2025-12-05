`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: SCPU_TOP
// Description: Top level module integrating ROM, RF, and Marquee(Matrix) display.
//////////////////////////////////////////////////////////////////////////////////

module SCPU_TOP (
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
    wire Clk_CPU;

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
    // 2. 跑马灯/矩阵变换逻辑 (Marquee Logic) - 当 SW[0]=1 时有效
    //================================================================
    reg [5:0]  led_data_addr;
    reg [63:0] led_disp_data;
    
    // 定义存储跑马灯图形数据的数组
    parameter LED_DATA_NUM = 19;
    reg [63:0] LED_DATA [18:0];

    // 初始化图形数据
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

    // 跑马灯状态机
    always @(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) begin 
            led_data_addr <= 6'd0;
            led_disp_data <= LED_DATA[0];
        end
        else if(sw_i[0] == 1'b1) begin // 仅在图形模式下运行动画
            // 循环控制：到达最后一帧时重置
            if (led_data_addr == LED_DATA_NUM - 1) begin 
                led_data_addr <= 6'd0; 
                led_disp_data <= LED_DATA[0]; 
            end
            else begin
                led_data_addr <= led_data_addr + 1'b1; 
                // 预取下一帧数据，防止显示延迟
                led_disp_data <= LED_DATA[led_data_addr + 1'b1]; 
            end
        end
        // 非图形模式下保持状态
    end


    //================================================================
    // 3. ROM 模块 (IM) 及 地址生成 - 当 SW[14]=1 时显示
    //================================================================
    reg [5:0] rom_addr; 
    wire [31:0] instr;

    // ROM 地址计数器
    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn) begin
            rom_addr <= 6'd0;
        end
        else if (sw_i[14] == 1'b1 && sw_i[1] == 1'b0) begin 
            // 仅在显示ROM模式(SW14)且非调试暂停(SW1)时递增
            rom_addr <= rom_addr + 1'b1;
        end
    end

    // 例化 ROM IP 核 (Distributed Memory Generator)
    dist_mem_im U_IM (
        .a(rom_addr), // input wire [5 : 0] a
        .spo(instr)   // output wire [31 : 0] spo
    );


    //================================================================
    // 4. RF 模块及控制逻辑 - 当 SW[13]=1 或 默认模式 时显示
    //================================================================
    wire [31:0] RD1, RD2;
    reg  [4:0]  rf_addr_cnt; // 用于 SW[13]=1 时的循环显示地址
    
    // RF 信号定义
    wire [4:0]  rf_A1, rf_A2, rf_A3;
    wire [31:0] rf_WD;
    wire        rf_RFWr;

    // RF 自动扫描计数器
    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            rf_addr_cnt <= 5'd0;
        else if (sw_i[13] == 1'b1) // 仅在 RF 循环显示模式下计数
            rf_addr_cnt <= rf_addr_cnt + 1'b1;
        else
            rf_addr_cnt <= 5'd0;
    end

    // ---- RF 输入信号多路复用逻辑 ----
    
    // A1 (读地址1/右侧显示): SW[13]=1时用计数器，否则用开关SW[10:8]
    assign rf_A1 = (sw_i[13]) ? rf_addr_cnt : {2'b00, sw_i[10:8]};
    
    // A2 (读地址2/左侧显示): 始终由 SW[7:5] 控制
    assign rf_A2 = {2'b00, sw_i[7:5]};
    
    // A3 (写地址): 手动写入时用 SW[10:8]
    assign rf_A3 = {2'b00, sw_i[10:8]};
    
    // WD (写数据): 手动写入时用 SW[7:5] (扩展为32位)
    assign rf_WD = {29'd0, sw_i[7:5]};
    
    // RFWr (写使能): 由 SW[2] 控制
    assign rf_RFWr = sw_i[2];

    // 例化寄存器堆 RF
    RF U_RF (
        .clk(clk),
        .rstn(rstn),
        .RFWr(rf_RFWr),
        .sw_i(sw_i),    // 将开关传入RF用于写保护(SW[1])判断
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(rf_A3),
        .WD(rf_WD),
        .RD1(RD1),
        .RD2(RD2)
    );


    //================================================================
    // 5. 显示数据选择与多路复用 (Display Mux)
    //================================================================
    reg [63:0] final_disp_data;

    always @(*) begin
        if (sw_i[0] == 1'b1) begin
            // 优先级 1: 图形模式 (SW[0]=1)
            // 显示跑马灯/矩阵变换数据 (64位)
            final_disp_data = led_disp_data;
        end 
        else if (sw_i[14] == 1'b1) begin
            // 优先级 2: ROM 指令显示 (SW[14]=1)
            // 低32位显示指令，高32位补0
            final_disp_data = {32'd0, instr};
        end
        else if (sw_i[13] == 1'b1) begin
            // 优先级 3: RF 自动轮询显示 (SW[13]=1)
            // 低32位显示当前寄存器值(RD1)，高32位补0
            final_disp_data = {32'd0, RD1};
        end
        else begin
            // 优先级 4: RF 手动调试模式 (默认)
            // 高32位显示 RD2 (左侧)，低32位显示 RD1 (右侧)
            final_disp_data = {RD2, RD1};
        end
    end


    //================================================================
    // 6. 实例化数码管显示模块
    //================================================================
    // seg7x16 模块现在统一接收 64 位数据
    
    seg7x16 u_seg7x16 (
        .clk(clk),
        .rstn(rstn),
        .i_data(final_disp_data), // 64位输入数据
        .disp_mode(sw_i[0]),      // 0: 文本模式, 1: 图形模式
        .o_seg(disp_seg_o),       // 段选输出
        .o_sel(disp_an_o)         // 位选输出
    );

endmodule
