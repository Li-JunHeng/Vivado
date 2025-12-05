`timescale 1ns / 1ps
// 目标: 完成一个led跑马灯, 在拉下指定拨码开关(sw_i[0])的时候开启, 按下ETH_RSTN恢复初始状态


module led_marquee(
        input CLK100MHZ,
        input CPU_RESETN,
        input[15:0]SW,
        output reg[15:0]LED
    );
    parameter div_num = 25; // 分频系数

    // 分频代码: 产生较低频率的时钟信号
    reg[31:0] clk_cnt;
    always@(posedge CLK100MHZ or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            clk_cnt <= 32'b0;
        else
            clk_cnt <= clk_cnt + 1'b1;
    end

    wire clk_1s;
    assign clk_1s = clk_cnt[div_num];        //分频后的时钟信号


    // 使用分频后的时钟信号完成跑马灯功能
    // SW[0] 拉下(为0)时开始跑马灯；CPU_RESETN 为0时复位到初始状态
    always@(posedge clk_1s or negedge CPU_RESETN) begin
        if(!CPU_RESETN) begin
            LED <= 16'h0001;
        end
        else if(!SW[0]) begin
            // 左移循环
            LED <= {LED[14:0], LED[15]};
        end
    end


endmodule
