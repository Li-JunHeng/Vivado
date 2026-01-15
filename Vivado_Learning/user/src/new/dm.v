`timescale 1ns / 1ps

// =============================================================
// dm：数据存储器 (Data Memory) —— 简化版，按“字节”存储
// -------------------------------------------------------------
// 设计要点：
// - mem[] 是 8 位宽（1 字节）的数组，因此是“字节寻址”。addr 每+1 表示下一个字节。
// - 读数据：组合逻辑 always @(*)，根据 DMType 拼出 32 位 dout，并做符号/零扩展。
// - 写数据：时序逻辑 always @(posedge clk)，只有 DMWr=1 才写入。
//
// DMType 约定（与 RISC-V Funct3 一致）：
//   000: LB/SB   (8-bit,  符号扩展)
//   001: LH/SH   (16-bit, 符号扩展)
//   010: LW/SW   (32-bit)
//   100: LBU     (8-bit,  零扩展)
//   101: LHU     (16-bit, 零扩展)
//
// 初学者提示：
// - {{24{mem[addr][7]}}, mem[addr]}：把最高位(mem[addr][7])复制 24 次，实现符号扩展。
// - 本模块没有做“地址对齐检查”，默认软件/CPU 会给对齐好的地址。
// =============================================================
module dm(
        input clk, DMWr,
        input [7:0] addr,       // <--- 修改1：地址线由 [5:0] 改为 [7:0] (支持256字节)
        input [31:0] din,
        input [2:0] DMType,
        output reg [31:0] dout
    );
    reg [7:0] mem [255:0];  // 存储 256 字节：mem[0]..mem[255]
    integer i;

    // <--- 修改3：循环范围由 64 改为 256
    initial
        for(i=0; i<256; i=i+1)
            mem[i] = 0;

    always @(*) begin
        case(DMType)
            3'b000:
                // LB：读 1 字节，符号扩展到 32 位
                dout = {{24{mem[addr][7]}}, mem[addr]};
            3'b001:
                // LH：读 2 字节（小端序：低地址是低字节），符号扩展到 32 位
                dout = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
            3'b010:
                // LW：读 4 字节（小端序）
                dout = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
            3'b100:
                // LBU：读 1 字节，零扩展
                dout = {24'b0, mem[addr]};
            3'b101:
                // LHU：读 2 字节，零扩展
                dout = {16'b0, mem[addr+1], mem[addr]};
            default:
                dout = 0;
        endcase
    end

    always @(posedge clk) begin
        if (DMWr) begin
            case(DMType)
                3'b000:
                    // SB：写 1 字节
                    mem[addr] <= din[7:0];
                3'b001: begin
                    // SH：写 2 字节（小端序）
                    mem[addr]<=din[7:0];
                    mem[addr+1]<=din[15:8];
                end
                3'b010: begin
                    // SW：写 4 字节（小端序）
                    mem[addr]<=din[7:0];
                    mem[addr+1]<=din[15:8];
                    mem[addr+2]<=din[23:16];
                    mem[addr+3]<=din[31:24];
                end
            endcase
        end
    end
endmodule
