`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: DM_ALU_RF
// Description: 综合实验 - ROM / RF / ALU / DM 显示与交互
//              在 ALU_RF 基础上加入数据存储器 (DM) 小端读写演示
//
// 开关定义（综合）:
//   SW[15] : 时钟速度   (1=慢速, 0=快速)
//   SW[14] : ROM 显示   (优先级最高)
//   SW[13] : RF 显示    (自动轮询 RD1)
//   SW[12] : ALU 显示   (循环 A/B/C/Zero/FFFFFFFF)
//   SW[11] : DM 显示    (读写 DM，观察 dout)
//   SW[10:8]: DM/RF 地址或 RF 写地址
//   SW[7:5] : DM 写数据 / RF A2 或 WD
//   SW[4:3] : ALUOp / DMType (00=Word,01=Half,11=Byte)
//   SW[2]   : 写使能 (RF 或 DM)，受 SW[1] 保护
//   SW[1]   : 调试保护 (1=锁定禁止写，0=允许写)
//////////////////////////////////////////////////////////////////////////////////
module DM_ALU_RF (
    input         clk,          // 100MHz 板载时钟
    input         rstn,         // 复位信号，低电平有效
    input  [15:0] sw_i,         // 拨码开关输入
    output [7:0]  disp_an_o,    // 数码管位选
    output [7:0]  disp_seg_o    // 数码管段选
);

    //================================================================
    // 1. 时钟分频 (用于慢速显示/轮询)
    //================================================================
    reg [31:0] clkdiv;
    wire Clk_CPU; // 约 0.74Hz 或 3Hz，用于循环显示

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            clkdiv <= 32'd0;
        else
            clkdiv <= clkdiv + 1'b1;
    end

    assign Clk_CPU = (sw_i[15]) ? clkdiv[27] : clkdiv[25];


    //================================================================
    // 2. ROM 显示 (SW[14]=1)
    //================================================================
    reg [5:0] rom_addr;
    wire [31:0] instr;

    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            rom_addr <= 6'd0;
        else if (sw_i[14])
            rom_addr <= rom_addr + 1'b1;
    end

    dist_mem_im U_IM (
        .a  (rom_addr),
        .spo(instr)
    );


    //================================================================
    // 3. RF (寄存器堆) 读写 & 自动轮询
    //================================================================
    wire [4:0] rf_A1, rf_A2, rf_A3;
    wire [31:0] rf_WD;
    wire [31:0] rf_RD1, rf_RD2;
    wire        rf_RFWr;
    reg  [4:0]  rf_addr_cnt; // RF 自动轮询地址 (SW[13])

    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            rf_addr_cnt <= 5'd0;
        else if (sw_i[13])
            rf_addr_cnt <= rf_addr_cnt + 1'b1;
        else
            rf_addr_cnt <= 5'd0;
    end

    // 读地址 A1：轮询或手动
    assign rf_A1 = (sw_i[13]) ? rf_addr_cnt : {2'b00, sw_i[10:8]};
    // 读地址 A2：手动
    assign rf_A2 = {2'b00, sw_i[7:5]};
    // 写地址 A3：手动
    assign rf_A3 = {2'b00, sw_i[10:8]};
    // 写数据 WD：3 位扩展
    assign rf_WD = {29'd0, sw_i[7:5]};
    // 写使能：需 SW[1]=0，且在 DM 显示模式下默认关闭以免误写
    assign rf_RFWr = sw_i[2] & (~sw_i[1]) & (~sw_i[11]);

    RF U_RF (
        .clk(clk),
        .rstn(rstn),
        .RFWr(rf_RFWr),
        .sw_i(sw_i),
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(rf_A3),
        .WD(rf_WD),
        .RD1(rf_RD1),
        .RD2(rf_RD2)
    );


    //================================================================
    // 4. ALU 计算 (SW[12] 循环显示)
    //================================================================
    wire [31:0] alu_A = rf_RD1;
    wire [31:0] alu_B = rf_RD2;
    wire [2:0]  alu_op = {1'b0, sw_i[4:3]};
    wire [31:0] alu_C;
    wire        alu_Zero;

    ALU U_ALU (
        .A(alu_A),
        .B(alu_B),
        .ALUOp(alu_op),
        .C(alu_C),
        .Zero(alu_Zero)
    );

    // ALU 循环显示状态机 (A -> B -> C -> Zero -> FFFFFFFF)
    reg [2:0] disp_sel;
    always @(posedge Clk_CPU or negedge rstn) begin
        if (!rstn)
            disp_sel <= 3'd0;
        else if (sw_i[12]) begin
            if (disp_sel == 3'd4)
                disp_sel <= 3'd0;
            else
                disp_sel <= disp_sel + 1'b1;
        end
        else
            disp_sel <= 3'd0;
    end


    //================================================================
    // 5. DM 数据存储器 (SW[11] 读写 & 显示)
    //================================================================
    wire        dm_wr   = sw_i[2] & (~sw_i[1]);          // 写使能，受 SW[1] 保护
    wire [5:0]  dm_addr = {3'b000, sw_i[10:8]};          // 3 位扩展为 6 位
    wire [31:0] dm_din  = {29'd0, sw_i[7:5]};            // 写数据零扩展
    wire [2:0]  dm_type = {1'b0, sw_i[4:3]};             // 00=Word,01=Half,11=Byte
    wire [31:0] dm_dout;

    dm U_DM (
        .clk  (clk),
        .DMWr (dm_wr),
        .addr (dm_addr),
        .din  (dm_din),
        .DMType(dm_type),
        .dout (dm_dout)
    );


    //================================================================
    // 6. 显示数据多路选择 (优先级：ROM > RF > ALU > DM > 默认RF)
    //================================================================
    reg [63:0] final_disp_data;

    always @(*) begin
        if (sw_i[14]) begin
            // ROM 内容
            final_disp_data = {32'd0, instr};
        end
        else if (sw_i[13]) begin
            // RF 自动轮询
            final_disp_data = {32'd0, rf_RD1};
        end
        else if (sw_i[12]) begin
            // ALU 循环
            case (disp_sel)
                3'd0: final_disp_data = {32'd0, alu_A};
                3'd1: final_disp_data = {32'd0, alu_B};
                3'd2: final_disp_data = {32'd0, alu_C};
                3'd3: final_disp_data = {32'd0, 31'd0, alu_Zero};
                3'd4: final_disp_data = {32'd0, 32'hFFFFFFFF};
                default: final_disp_data = 64'd0;
            endcase
        end
        else if (sw_i[11]) begin
            // DM 数据读出
            final_disp_data = {32'd0, dm_dout};
        end
        else begin
            // 默认：RF 手动调试，左 RD2 右 RD1
            final_disp_data = {rf_RD2, rf_RD1};
        end
    end


    //================================================================
    // 7. 数码管显示实例化 (seg7x16)
    //================================================================
    seg7x16 U_SEG7 (
        .clk      (clk),
        .rstn     (rstn),
        .i_data   (final_disp_data),
        .disp_mode(1'b0),       // 本实验固定文本模式
        .o_seg    (disp_seg_o),
        .o_sel    (disp_an_o)
    );

endmodule
