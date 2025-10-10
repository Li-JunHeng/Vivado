`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2025/09/27 18:42:48
// Design Name:
// Module Name: tb_course_1
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tb_course_1;

    // ---- 端口信号 ----
    reg  [3:0]  SW;     // 驱动输入
    wire [15:0] LED;    // 观测输出（我们只关心 LED[0]）

    // ---- 循环变量（只声明一次，且放在实例化之前更保险）----
    integer i;

    // ---- 实例化 DUT ----
    course_1 dut (
        .SW (SW),
        .LED(LED)
    );

    // ---- 激励 ----
    initial begin
        SW = 4'd0;
        // 从 0 到 15 扫一遍
        for (i = 0; i < 16; i = i + 1) begin
            SW = i[3:0];
            #10;  // 等待 10ns
            $display("%0t ns  SW=%b  LED0=%b", $time, SW, LED[0]);
        end
        $stop;
    end

endmodule