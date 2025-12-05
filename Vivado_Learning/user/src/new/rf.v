`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: RF (Register File)
// Description: 32x32-bit Register File for RISC-V
//              r[0] is hardwired to 0.
//////////////////////////////////////////////////////////////////////////////////

module RF (
    input         clk,          // 时钟信号
    input         rstn,         // 复位信号 (低电平有效)
    input         RFWr,         // 写使能信号 (1: Write, 0: Read only)
    input  [15:0] sw_i,         // 拨码开关输入 (sw_i[1]用于写保护)
    input  [4:0]  A1,           // 读端口 1 地址 (Read Register 1)
    input  [4:0]  A2,           // 读端口 2 地址 (Read Register 2)
    input  [4:0]  A3,           // 写端口 地址 (Write Register)
    input  [31:0] WD,           // 写数据 (Write Data)
    output [31:0] RD1,          // 读数据 1 (Read Data 1)
    output [31:0] RD2           // 读数据 2 (Read Data 2)
);

    reg [31:0] rf [31:0];
    integer i;

    // 1. 读逻辑 (组合逻辑)
    // 寄存器 0 永远为 0
    assign RD1 = (A1 == 5'b0) ? 32'b0 : rf[A1];
    assign RD2 = (A2 == 5'b0) ? 32'b0 : rf[A2];

    // 2. 写逻辑 & 初始化 (时序逻辑)
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // 复位时初始化寄存器，rf[i] = i，方便测试
            for (i = 0; i < 32; i = i + 1) begin
                rf[i] <= i;
            end
        end
        else begin
            // 写操作：使能有效，且 sw_i[1] (调试模式) 为 0，且目标不是 x0
            if (RFWr && (sw_i[1] == 1'b0) && (A3 != 5'b0)) begin
                rf[A3] <= WD;
            end
        end
    end

endmodule