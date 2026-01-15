# Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 100.00 -waveform {0 50} [get_ports {clk}];
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sw_i_IBUF[15]];#add for temp
 set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets BTNC_IBUF] 

# 7seg
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[0] }]; #IO_L24N_T3_A00_D16_14 Sch=ca
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[1] }]; #IO_25_14 Sch=cb
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[2] }]; #IO_25_15 Sch=cc
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[3] }]; #IO_L7P_T2_A26_15 Sch=cd
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[4] }]; #IO_L13P_T2_MRCC_14 Sch=ce
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[5] }]; #IO_L19P_T3_A10_D26_14 Sch=cf
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[6] }]; #IO_L4P_T0_D04_14 Sch=cg
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[7] }]; #IO_L19N_T3_A21_VREF_15 Sch=dp

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[6] }]; #IO_L23P_T3_35 Sch=an[6]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]

##Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { sw_i[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { sw_i[1] }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=sw[1]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sw[2]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { sw_i[3] }]; #IO_L13N_T2_MRCC_14 Sch=sw[3]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { sw_i[4] }]; #IO_L12N_T1_MRCC_14 Sch=sw[4]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { sw_i[5] }]; #IO_L7N_T1_D10_14 Sch=sw[5]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { sw_i[6] }]; #IO_L17N_T2_A13_D29_14 Sch=sw[6]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[7] }]; #IO_L5N_T0_D07_14 Sch=sw[7]
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports { sw_i[8] }]; #IO_L24N_T3_34 Sch=sw[8]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports { sw_i[9] }]; #IO_25_34 Sch=sw[9]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { sw_i[10] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=sw[10]
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[11] }]; #IO_L23P_T3_A03_D19_14 Sch=sw[11]
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { sw_i[12] }]; #IO_L24P_T3_35 Sch=sw[12]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { sw_i[13] }]; #IO_L20P_T3_A08_D24_14 Sch=sw[13]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { sw_i[14] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=sw[14]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { sw_i[15] }]; #IO_L21P_T3_DQS_14 Sch=sw[15]


## LEDs
 set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {led_o[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]
 set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports {led_o[1] }]; #IO_L24P_T3_RS1_15 Sch=led[1]
 set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports {led_o[2] }]; #IO_L17N_T2_A25_15 Sch=led[2]
 set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports {led_o[3] }]; #IO_L8P_T1_D11_14 Sch=led[3]
 set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {led_o[4] }]; #IO_L7P_T1_D09_14 Sch=led[4]
 set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {led_o[5] }]; #IO_L18N_T2_A11_D27_14 Sch=led[5]
 set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { led_o[6] }]; #IO_L17P_T2_A14_D30_14 Sch=led[6]
 set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { led_o[7] }]; #IO_L18P_T2_A12_D28_14 Sch=led[7]
 set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { led_o[8] }]; #IO_L16N_T2_A15_D31_14 Sch=led[8]
 set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { led_o[9] }]; #IO_L14N_T2_SRCC_14 Sch=led[9]
 set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led_o[10] }]; #IO_L22P_T3_A05_D21_14 Sch=led[10]
 set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { led_o[11] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[11]
 set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { led_o[12] }]; #IO_L16P_T2_CSI_B_14 Sch=led[12]
 set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { led_o[13] }]; #IO_L22N_T3_A04_D20_14 Sch=led[13]
 set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { led_o[14] }]; #IO_L20N_T3_A07_D23_14 Sch=led[14]
 set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { led_o[15] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=led[15]

 
 
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { CPU_RESETN }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rstn_IBUF]



# module alu(
#         input signed [31:0] A, B,
#         input        [4:0]  ALUOp,
#         output reg   [31:0] C,
#         output              Zero
#     );
#     always @(*) begin
#         case(ALUOp)
#             5'd0:
#                 C = A + B;        // ADD：加法（地址计算/算术）
#             5'd1:
#                 C = A - B;        // SUB：减法（BEQ/BNE 也常用它做比较）
#             5'd2:
#                 C = A << B[4:0];  // SLL：逻辑左移
#             5'd3:
#                 C = (A < B) ? 1 : 0; // SLT：有符号比较 A<B
#             5'd4:
#                 C = ($unsigned(A) < $unsigned(B)) ? 1 : 0; // SLTU：无符号比较 A<B
#             5'd5:
#                 C = A ^ B;        // XOR：按位异或
#             5'd6:
#                 C = A >> B[4:0];  // SRL：逻辑右移（高位补 0）
#             5'd7:
#                 C = A >>> B[4:0]; // SRA：算术右移（复制符号位）
#             5'd8:
#                 C = A | B;        // OR：按位或
#             5'd9:
#                 C = A & B;        // AND：按位与
#             5'd10:
#                 C = B;           // LUI：Load Upper Immediate（这里直接把扩展后的立即数送出）
#             5'd11: begin
#                 C = ($signed(A) < $signed(B)) ? A : B;
#             end
#             5'd12: begin
#                 C = (A < B) ? 1 : 0;
#             end
#             default:
#                 C = 0;
#         endcase
#     end
#     assign Zero = (C == 0);
# endmodule

# module ctrl(
#         input  [6:0] Op, Funct7,
#         input  [2:0] Funct3,
#         output       RegWrite, MemWrite,
#         output [5:0] EXTOp,
#         output reg [4:0] ALUOp,
#         output [1:0] NPCOp, WDSel,
#         output       ALUSrcA, ALUSrcB,
#         output [2:0] DMType
#     );
#     wire rtype = (Op == 7'b0110011);
#     wire i_alu = (Op == 7'b0010011);
#     wire load  = (Op == 7'b0000011);
#     wire store = (Op == 7'b0100011);
#     wire branch= (Op == 7'b1100011);
#     wire jal   = (Op == 7'b1101111);
#     wire jalr  = (Op == 7'b1100111);
#     wire lui   = (Op == 7'b0110111);
#     wire auipc = (Op == 7'b0010111);
#     wire diy_calc   = (Op == 7'b1011011); // 预留给计算指令 (如 MIN, MAX)
#     wire diy_branch = (Op == 7'b1011111); // 预留给分支指令 (如 BGT, BODD)

#     assign RegWrite = rtype | i_alu | load | lui | auipc | jal | jalr | diy_calc;
#     assign MemWrite = store;
#     assign ALUSrcA  = auipc;
#     assign ALUSrcB  = i_alu | load | store | lui | auipc | diy_calc;
#     assign WDSel    = (jal | jalr) ? 2'd2 : (load ? 2'd1 : 2'd0);
#     assign NPCOp    = jalr ? 2'd3 : (jal ? 2'd2 : ((branch | diy_branch) ? 2'd1 : 2'd0));
#     assign EXTOp    = store?1: ((branch | diy_branch)?2: (jal?3: ((lui|auipc)?4: 0)));
#     assign DMType   = Funct3;

#     always @(*) begin
#         if (lui)
#             ALUOp = 5'd10;

#         else if (branch | diy_branch) begin
#             if (diy_branch) begin
#                 ALUOp = 5'd12; // 【DIY】分配 12 号给 DIY 分支 (去 alu.v 改逻辑)
#             end
#             else if (Funct3[2:1] == 2'b00)
#                 ALUOp = 5'd1; // BEQ/BNE -> SUB
#             else if (Funct3[2:1] == 2'b10)
#                 ALUOp = 5'd3; // BLT/BGE -> SLT
#             else
#                 ALUOp = 5'd4; // BLTU/BGEU -> SLTU
#         end
#         else if (load | store | auipc | jal | jalr)
#             ALUOp = 5'd0;

#         else if (rtype || i_alu || diy_calc) begin
#             if (diy_calc) begin
#                 ALUOp = 5'd11; // 【DIY】分配 11 号给 DIY 计算 (去 alu.v 改逻辑)
#             end
#             else begin
#                 case(Funct3)
#                     3'b000:

#                         ALUOp = (rtype && Funct7[5]) ? 5'd1 : 5'd0;
#                     3'b001:
#                         ALUOp = 5'd2;
#                     3'b010:
#                         ALUOp = 5'd3;
#                     3'b011:
#                         ALUOp = 5'd4;
#                     3'b100:
#                         ALUOp = 5'd5;
#                     3'b101:

#                         ALUOp = (Funct7[5]) ? 5'd7 : 5'd6;
#                     3'b110:
#                         ALUOp = 5'd8;
#                     3'b111:
#                         ALUOp = 5'd9;
#                     default:
#                         ALUOp = 5'd0;
#                 endcase
#             end
#         end
#         else
#             ALUOp = 5'd0;
#     end
# endmodule

# module dm(
#         input clk, DMWr,
#         input [7:0] addr,       // <--- 修改1：地址线由 [5:0] 改为 [7:0] (支持256字节)
#         input [31:0] din,
#         input [2:0] DMType,
#         output reg [31:0] dout
#     );
#     reg [7:0] mem [255:0];  // 存储 256 字节：mem[0]..mem[255]
#     integer i;

#     initial
#         for(i=0; i<256; i=i+1)
#             mem[i] = 0;

#     always @(*) begin
#         case(DMType)
#             3'b000:
#                 dout = {{24{mem[addr][7]}}, mem[addr]};
#             3'b001:
#                 dout = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
#             3'b010:
#                 dout = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
#             3'b100:
#                 dout = {24'b0, mem[addr]};
#             3'b101:
#                 dout = {16'b0, mem[addr+1], mem[addr]};
#             default:
#                 dout = 0;
#         endcase
#     end

#     always @(posedge clk) begin
#         if (DMWr) begin
#             case(DMType)
#                 3'b000:
#                     mem[addr] <= din[7:0];
#                 3'b001: begin
#                     mem[addr]<=din[7:0];
#                     mem[addr+1]<=din[15:8];
#                 end
#                 3'b010: begin
#                     mem[addr]<=din[7:0];
#                     mem[addr+1]<=din[15:8];
#                     mem[addr+2]<=din[23:16];
#                     mem[addr+3]<=din[31:24];
#                 end
#             endcase
#         end
#     end
# endmodule

# module EXT(
#         input  [31:7] instr,
#         input  [5:0]  EXTOp,
#         output reg [31:0] immout
#     );
#     // 下面先把 5 种类型的立即数都“算出来”，最后再按 EXTOp 选择其中一个输出。
#     wire [31:0] i_type = {{20{instr[31]}}, instr[31:20]};
#     wire [31:0] s_type = {{20{instr[31]}}, instr[31:25], instr[11:7]};
#     wire [31:0] b_type = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
#     wire [31:0] j_type = {{11{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
#     wire [31:0] u_type = {instr[31:12], 12'b0};

#     always @(*) begin
#         case(EXTOp)
#             6'd0:
#                 immout = i_type;
#             6'd1:
#                 immout = s_type;
#             6'd2:
#                 immout = b_type;
#             6'd3:
#                 immout = j_type;
#             6'd4:
#                 immout = u_type;
#             default:
#                 immout = 0;
#         endcase
#     end
# endmodule

# module NPC(
#         input  [31:0] PC, Imm, rs1,
#         input  [1:0]  NPCOp,
#         input         ALUZero,
#         input         ALUResult0,
#         input  [2:0]  BrType,
#         output reg [31:0] next_pc
#     );
#     reg flag;

#     always @(*) begin
#         case(BrType)
#             3'b000:
#                 flag = ALUZero;      // BEQ
#             3'b001:
#                 flag = ~ALUZero;     // BNE
#             3'b100:
#                 flag = ALUResult0;   // BLT
#             3'b101:
#                 flag = ~ALUResult0;  // BGE
#             3'b110:
#                 flag = ALUResult0;   // BLTU
#             3'b111:
#                 flag = ~ALUResult0;  // BGEU

#             3'b010: begin
#                 flag = (~ALUResult0) && (~ALUZero);
#             end

#             default:
#                 flag = 0;
#         endcase
#     end

#     always @(*) begin
#         case(NPCOp)
#             2'd0:
#                 next_pc = PC + 4;
#             2'd1:
#                 next_pc = flag ? (PC+Imm) : (PC+4);
#             2'd2:
#                 next_pc = PC + Imm;
#             2'd3:
#                 next_pc = (rs1 + Imm) & ~1;
#             default:
#                 next_pc = PC + 4;
#         endcase
#     end
# endmodule

# module RF (
#         input clk, rstn, RFWr,
#         input [15:0] sw_i,      // 开关输入：本工程用 sw_i[1] 做“调试模式”开关
#         input [4:0] A1, A2, A3,
#         input [31:0] WD,
#         output [31:0] RD1, RD2
#     );
#     reg [31:0] rf[31:0];
#     integer i;

#     assign RD1 = (A1==0) ? 0 : rf[A1];
#     assign RD2 = (A2==0) ? 0 : rf[A2];

#     always @(posedge clk or negedge rstn) begin
#         if (!rstn) begin
#             for (i = 0; i < 32; i = i + 1) begin

#                 if (i == 1)
#                     rf[i] <= 32'd84; // x1 (ra) 返回地址，不用动
#                 else if (i == 2)
#                     rf[i] <= 32'd250; // <--- 修改这里：x2 (sp) 设为 250 (接近内存顶端)
#                 else if (i == 10)
#                     rf[i] <= 32'd10;// <--- 现在内存够大了，敢算 Fib(10) 了！
#                 else
#                     rf[i] <= i;       // 其他寄存器还是初始化为 i (保证 x10=10)
#             end
#         end
#         else if (RFWr && (A3!=0) && (sw_i[1]==0)) begin
#             rf[A3] <= WD;
#         end
#     end
# endmodule

# module SCPU_TOP(
#         input clk,
#         input rstn,
#         input [15:0] sw_i,
#         input BTNC, BTNU, BTNL, BTNR, BTND,
#         output [15:0] led_o,
#         output [7:0] disp_an_o,
#         output [7:0] disp_seg_o
#     );

#     reg [31:0] clk_div;
#     always @(posedge clk or negedge rstn)
#         if (!rstn)
#             clk_div <= 0;
#         else
#             clk_div <= clk_div + 1;

#     wire clk_cpu = sw_i[15] ? clk_div[26] : clk_div[2];

#     reg [31:0] PC;
#     wire [31:0] NPC_out;
#     always @(posedge clk_cpu or negedge rstn)
#         if (!rstn)
#             PC <= 0;
#         else if (sw_i[1]==0) // 调试模式(sw_i[1]=1)下暂停 PC 更新，便于观察
#             PC <= NPC_out;

#     wire [31:0] instr, RD1, RD2, immout, alu_out, dm_out, WD;
#     wire [31:0] alu_a, alu_b;
#     wire RegWrite, MemWrite, ALUSrcA, ALUSrcB, Zero;
#     wire [4:0] ALUOp;
#     wire [5:0] EXTOp;
#     wire [2:0] DMType;
#     wire [1:0] WDSel, NPCOp;

#     dist_mem_im U_IM (.a(PC[7:2]), .spo(instr));

#     ctrl U_Ctrl (
#              .Op(instr[6:0]), .Funct7(instr[31:25]), .Funct3(instr[14:12]),
#              .RegWrite(RegWrite), .MemWrite(MemWrite), .EXTOp(EXTOp),
#              .ALUOp(ALUOp), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
#              .DMType(DMType), .WDSel(WDSel), .NPCOp(NPCOp)
#          );

#     RF U_RF (
#            .clk(clk_cpu), .rstn(rstn), .RFWr(RegWrite), .sw_i(sw_i),

#            .A1(sw_i[1]? sw_i[10:6] : instr[19:15]),
#            .A2(instr[24:20]), .A3(instr[11:7]), .WD(WD),
#            .RD1(RD1), .RD2(RD2)
#        );

#     EXT U_EXT (.instr(instr[31:7]), .EXTOp(EXTOp), .immout(immout));

#     assign alu_a = ALUSrcA ? PC : RD1;
#     assign alu_b = ALUSrcB ? immout : RD2;

#     alu U_ALU (.A(alu_a), .B(alu_b), .ALUOp(ALUOp), .C(alu_out), .Zero(Zero));

#     dm U_DM (
#            .clk(clk_cpu), .DMWr(MemWrite), .addr(alu_out[7:0]),
#            .din(RD2), .DMType(DMType), .dout(dm_out)
#        );

#     assign WD = (WDSel==2) ? PC+4 : ((WDSel==1) ? dm_out : alu_out);

#     NPC U_NPC (
#             .PC(PC), .Imm(immout), .rs1(RD1), .NPCOp(NPCOp),
#             .ALUZero(Zero), .ALUResult0(alu_out[0]), .BrType(instr[14:12]),
#             .next_pc(NPC_out)
#         );

#     reg [63:0] display_data;
#     always @(*) begin
#         if (sw_i[1])
#             display_data = {4'hD, 3'b0, sw_i[10:6], 8'b0, RD1[23:0]}; // 调试查RF
#         else if (sw_i[14])
#             display_data = {32'b0, instr};
#         else if (sw_i[13])
#             display_data = {32'b0, alu_out};
#         else if (sw_i[12])
#             display_data = {32'b0, 24'b0, PC[7:0]};
#         else
#             display_data = {32'b0, WD};
#     end

#     seg7x16 u_seg (.clk(clk), .rstn(rstn), .disp_mode(1'b0), .i_data(display_data), .o_seg(disp_seg_o), .o_sel(disp_an_o));

#     assign led_o = sw_i;
# endmodule

# module seg7x16(
#         input clk,
#         input rstn,
#         input disp_mode,      // SW[0]: 0为字符模式, 1为图形模式
#         input [63:0] i_data,  // 要显示的数据
#         output [7:0] o_seg,   // 段选信号 (DP, G, F, E, D, C, B, A)
#         output [7:0] o_sel    // 位选信号 (AN7 ... AN0)
#     );

#     reg [14:0] cnt;
#     wire seg7_clk;

#     always @(posedge clk or negedge rstn) begin
#         if (!rstn)
#             cnt <= 0;
#         else
#             cnt <= cnt + 1'b1;
#     end

#     assign seg7_clk = cnt[14];

#     reg [2:0] seg7_addr;
#     always @(posedge seg7_clk or negedge rstn) begin
#         if (!rstn)
#             seg7_addr <= 0;
#         else
#             seg7_addr <= seg7_addr + 1'b1;
#     end

#     reg [7:0] o_sel_r;
#     always @(*) begin
#         case(seg7_addr)
#             0 :
#                 o_sel_r = 8'b11111110; // AN0
#             1 :
#                 o_sel_r = 8'b11111101; // AN1
#             2 :
#                 o_sel_r = 8'b11111011; // AN2
#             3 :
#                 o_sel_r = 8'b11110111; // AN3
#             4 :
#                 o_sel_r = 8'b11101111; // AN4
#             5 :
#                 o_sel_r = 8'b11011111; // AN5
#             6 :
#                 o_sel_r = 8'b10111111; // AN6
#             7 :
#                 o_sel_r = 8'b01111111; // AN7
#             default :
#                 o_sel_r = 8'b11111111;
#         endcase
#     end

#     reg [7:0] seg_data_r;
#     always @(*) begin
#         if(disp_mode == 1'b0) begin // 字符模式：每一位只取 4 bit（显示 0~F）
#             case(seg7_addr)
#                 0 :
#                     seg_data_r = i_data[3:0];
#                 1 :
#                     seg_data_r = i_data[7:4];
#                 2 :
#                     seg_data_r = i_data[11:8];
#                 3 :
#                     seg_data_r = i_data[15:12];
#                 4 :
#                     seg_data_r = i_data[19:16];
#                 5 :
#                     seg_data_r = i_data[23:20];
#                 6 :
#                     seg_data_r = i_data[27:24];
#                 7 :
#                     seg_data_r = i_data[31:28];
#             endcase
#         end
#         else begin // 图形模式：每一位取 8 bit（直接作为段码输出）
#             case(seg7_addr)
#                 0 :
#                     seg_data_r = i_data[7:0];
#                 1 :
#                     seg_data_r = i_data[15:8];
#                 2 :
#                     seg_data_r = i_data[23:16];
#                 3 :
#                     seg_data_r = i_data[31:24];
#                 4 :
#                     seg_data_r = i_data[39:32];
#                 5 :
#                     seg_data_r = i_data[47:40];
#                 6 :
#                     seg_data_r = i_data[55:48];
#                 7 :
#                     seg_data_r = i_data[63:56];
#             endcase
#         end
#     end

#     reg [7:0] o_seg_r;
#     always @(posedge clk or negedge rstn) begin
#         if(!rstn)
#             o_seg_r <= 8'hFF;
#         else if(disp_mode == 1'b0) begin // 字符模式：0~F -> 七段译码
#             case(seg_data_r[3:0])
#                 4'h0 :
#                     o_seg_r <= 8'hC0;
#                 4'h1 :
#                     o_seg_r <= 8'hF9;
#                 4'h2 :
#                     o_seg_r <= 8'hA4;
#                 4'h3 :
#                     o_seg_r <= 8'hB0;
#                 4'h4 :
#                     o_seg_r <= 8'h99;
#                 4'h5 :
#                     o_seg_r <= 8'h92;
#                 4'h6 :
#                     o_seg_r <= 8'h82;
#                 4'h7 :
#                     o_seg_r <= 8'hF8;
#                 4'h8 :
#                     o_seg_r <= 8'h80;
#                 4'h9 :
#                     o_seg_r <= 8'h90;
#                 4'hA :
#                     o_seg_r <= 8'h88;
#                 4'hB :
#                     o_seg_r <= 8'h83;
#                 4'hC :
#                     o_seg_r <= 8'hC6;
#                 4'hD :
#                     o_seg_r <= 8'hA1;
#                 4'hE :
#                     o_seg_r <= 8'h86;
#                 4'hF :
#                     o_seg_r <= 8'h8E;
#                 default :
#                     o_seg_r <= 8'hFF;
#             endcase
#         end
#         else begin // 图形模式直接输出
#             o_seg_r <= seg_data_r;
#         end
#     end

#     assign o_sel = o_sel_r;
#     assign o_seg = o_seg_r;

# endmodule



# Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 100.00 -waveform {0 50} [get_ports {clk}];
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { rstn }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sw_i_IBUF[15]];#add for temp
 set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets BTNC_IBUF] 

# 7seg
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[0] }]; #IO_L24N_T3_A00_D16_14 Sch=ca
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[1] }]; #IO_25_14 Sch=cb
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[2] }]; #IO_25_15 Sch=cc
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[3] }]; #IO_L7P_T2_A26_15 Sch=cd
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[4] }]; #IO_L13P_T2_MRCC_14 Sch=ce
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[5] }]; #IO_L19P_T3_A10_D26_14 Sch=cf
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[6] }]; #IO_L4P_T0_D04_14 Sch=cg
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { disp_seg_o[7] }]; #IO_L19N_T3_A21_VREF_15 Sch=dp

set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[6] }]; #IO_L23P_T3_35 Sch=an[6]
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { disp_an_o[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]

##Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { sw_i[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { sw_i[1] }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=sw[1]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sw[2]
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { sw_i[3] }]; #IO_L13N_T2_MRCC_14 Sch=sw[3]
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { sw_i[4] }]; #IO_L12N_T1_MRCC_14 Sch=sw[4]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { sw_i[5] }]; #IO_L7N_T1_D10_14 Sch=sw[5]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { sw_i[6] }]; #IO_L17N_T2_A13_D29_14 Sch=sw[6]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[7] }]; #IO_L5N_T0_D07_14 Sch=sw[7]
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports { sw_i[8] }]; #IO_L24N_T3_34 Sch=sw[8]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports { sw_i[9] }]; #IO_25_34 Sch=sw[9]
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { sw_i[10] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=sw[10]
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { sw_i[11] }]; #IO_L23P_T3_A03_D19_14 Sch=sw[11]
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { sw_i[12] }]; #IO_L24P_T3_35 Sch=sw[12]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { sw_i[13] }]; #IO_L20P_T3_A08_D24_14 Sch=sw[13]
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { sw_i[14] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=sw[14]
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { sw_i[15] }]; #IO_L21P_T3_DQS_14 Sch=sw[15]


## LEDs
 set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {led_o[0] }]; #IO_L18P_T2_A24_15 Sch=led[0]
 set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports {led_o[1] }]; #IO_L24P_T3_RS1_15 Sch=led[1]
 set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports {led_o[2] }]; #IO_L17N_T2_A25_15 Sch=led[2]
 set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports {led_o[3] }]; #IO_L8P_T1_D11_14 Sch=led[3]
 set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {led_o[4] }]; #IO_L7P_T1_D09_14 Sch=led[4]
 set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {led_o[5] }]; #IO_L18N_T2_A11_D27_14 Sch=led[5]
 set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { led_o[6] }]; #IO_L17P_T2_A14_D30_14 Sch=led[6]
 set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { led_o[7] }]; #IO_L18P_T2_A12_D28_14 Sch=led[7]
 set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { led_o[8] }]; #IO_L16N_T2_A15_D31_14 Sch=led[8]
 set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { led_o[9] }]; #IO_L14N_T2_SRCC_14 Sch=led[9]
 set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led_o[10] }]; #IO_L22P_T3_A05_D21_14 Sch=led[10]
 set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { led_o[11] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=led[11]
 set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { led_o[12] }]; #IO_L16P_T2_CSI_B_14 Sch=led[12]
 set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { led_o[13] }]; #IO_L22N_T3_A04_D20_14 Sch=led[13]
 set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { led_o[14] }]; #IO_L20N_T3_A07_D23_14 Sch=led[14]
 set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { led_o[15] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=led[15]

 
 
set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { CPU_RESETN }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { BTNC }]; #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rstn_IBUF]