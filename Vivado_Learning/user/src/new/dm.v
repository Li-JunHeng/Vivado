`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dm (Data Memory)
// Description : 64B little-endian data memory for RISC-V lab (word/half/byte)
//               - Word  : DMType = 3'b000
//               - Half  : DMType = 3'b001
//               - Byte  : DMType = 3'b011
// Notes      :
//   * addr    : byte address (6 bits -> 64 bytes)
//   * din     : write data (32-bit), write enable on DMWr
//   * dout    : combinational read, zero-extended for half/byte
//////////////////////////////////////////////////////////////////////////////////
module dm (
    input         clk,      // 时钟
    input         DMWr,     // 写使能
    input  [5:0]  addr,     // 字节地址
    input  [31:0] din,      // 写数据
    input  [2:0]  DMType,   // 读写类型
    output reg [31:0] dout  // 读出数据
);

    // 64 字节数据存储器，按字节寻址
    reg [7:0] dmem [0:63];
    integer i;

    // 初始化为 0，便于上板观察
    initial begin
        for (i = 0; i < 64; i = i + 1)
            dmem[i] = 8'd0;
    end

    // 写操作：按小端序写入
    always @(posedge clk) begin
        if (DMWr) begin
            case (DMType[1:0])
                2'b00: begin
                    // Word write: 4 字节
                    dmem[addr]     <= din[7:0];
                    dmem[addr+1]   <= din[15:8];
                    dmem[addr+2]   <= din[23:16];
                    dmem[addr+3]   <= din[31:24];
                end
                2'b01: begin
                    // Half write: 2 字节
                    dmem[addr]     <= din[7:0];
                    dmem[addr+1]   <= din[15:8];
                end
                2'b11: begin
                    // Byte write: 1 字节
                    dmem[addr]     <= din[7:0];
                end
                default: ; // 未使用的编码，不写
            endcase
        end
    end

    // 读操作：组合逻辑，小端序，半字/字节零扩展
    always @(*) begin
        case (DMType[1:0])
            2'b00: dout = {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]};       // Word
            2'b01: dout = {16'd0, dmem[addr+1], dmem[addr]};                             // Half (Zero-extend)
            2'b11: dout = {24'd0, dmem[addr]};                                           // Byte (Zero-extend)
            default: dout = 32'd0;
        endcase
    end

endmodule
