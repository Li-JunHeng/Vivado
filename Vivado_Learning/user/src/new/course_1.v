`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wuhan University
// Engineer: LiJunHeng
//
// Create Date: 2025/09/26 22:27:00
// Design Name: Course_1
// Module Name: course_1
// Project Name: Vivado_Learning
// Target Devices: xc7a100tcsg324-1
// Tool Versions: ...
// Description: ...
//
// Dependencies: ...
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module course_1(
    input  [3:0]  SW,
    output [15:0] LED
);
    assign LED[0]     = SW[3] & ~SW[2] & ~SW[1]; // 只点亮 LED0
    assign LED[15:1]  = 15'b0;                   // 其他 LED 熄灭
endmodule

