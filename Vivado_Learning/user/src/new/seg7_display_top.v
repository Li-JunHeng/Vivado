`timescale 1ns / 1ps
// 7-Segment Display Top Module with Matrix Transform
// Supports both text mode (hex digits) and graphic mode (direct segment control)
// Compatible with Nexys A7-100T development board
//
// Display Modes:
// - Text Mode (disp_mode=0): Display 8 hex digits using 32-bit data
// - Graph Mode (disp_mode=1): Direct segment control using 64-bit data

module seg7_display_top(
    input CLK100MHZ,              // System clock (100MHz)
    input CPU_RESETN,             // Reset signal (active low)
    input disp_mode,              // Display mode: 0=text, 1=graph (connected to SW[0])
    input [63:0] i_data,          // Input data: [31:0] for text, [63:0] for graph
    output [7:0] o_sel,           // Digit select signal (AN)
    output [7:0] o_seg            // Segment signal (SEG)
);

    // ========== Clock Divider (2^15) ==========
    reg [14:0] clk_div;
    wire scan_clk;
    
    assign scan_clk = clk_div[14];  // ~3.05kHz scan frequency
    
    always @(posedge CLK100MHZ or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            clk_div <= 15'b0;
        else
            clk_div <= clk_div + 1'b1;
    end
    
    // ========== Data Storage ==========
    reg [63:0] i_data_store;      // Store input data (64-bit for graph mode)
    
    always @(posedge CLK100MHZ or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            i_data_store <= 64'b0;
        else
            i_data_store <= i_data;
    end
    
    // ========== Digit Selection Counter ==========
    reg [2:0] seg_addr;           // Select digit 0-7
    
    always @(posedge scan_clk or negedge CPU_RESETN) begin
        if(!CPU_RESETN)
            seg_addr <= 3'b0;
        else
            seg_addr <= seg_addr + 1'b1;
    end
    
    // ========== Segment Data Register ==========
    reg [7:0] seg_data_r;         // Segment data for current digit
    
    // ========== Display Mode Selection ==========
    always @(*) begin
        if(disp_mode == 1'b0) begin
            // ===== Text Mode: Display hex digits (use lower 32 bits) =====
            case(seg_addr)
                3'd0: seg_data_r = i_data_store[3:0];
                3'd1: seg_data_r = i_data_store[7:4];
                3'd2: seg_data_r = i_data_store[11:8];
                3'd3: seg_data_r = i_data_store[15:12];
                3'd4: seg_data_r = i_data_store[19:16];
                3'd5: seg_data_r = i_data_store[23:20];
                3'd6: seg_data_r = i_data_store[27:24];
                3'd7: seg_data_r = i_data_store[31:28];
                default: seg_data_r = 8'h00;
            endcase
        end
        else begin
            // ===== Graph Mode: Direct segment control (use all 64 bits) =====
            case(seg_addr)
                3'd0: seg_data_r = i_data_store[7:0];
                3'd1: seg_data_r = i_data_store[15:8];
                3'd2: seg_data_r = i_data_store[23:16];
                3'd3: seg_data_r = i_data_store[31:24];
                3'd4: seg_data_r = i_data_store[39:32];
                3'd5: seg_data_r = i_data_store[47:40];
                3'd6: seg_data_r = i_data_store[55:48];
                3'd7: seg_data_r = i_data_store[63:56];
                default: seg_data_r = 8'h00;
            endcase
        end
    end
    
    // ========== Segment Decoder (Text Mode Only) ==========
    reg [7:0] seg_decoded;        // Decoded segment data
    
    always @(*) begin
        if(disp_mode == 1'b0) begin
            // Text mode: Decode 4-bit digit to 7-segment code
            case(seg_data_r[3:0])
                4'h0: seg_decoded = 8'b11000000;  // 0
                4'h1: seg_decoded = 8'b11111001;  // 1
                4'h2: seg_decoded = 8'b10100100;  // 2
                4'h3: seg_decoded = 8'b10110000;  // 3
                4'h4: seg_decoded = 8'b10011001;  // 4
                4'h5: seg_decoded = 8'b10010010;  // 5
                4'h6: seg_decoded = 8'b10000010;  // 6
                4'h7: seg_decoded = 8'b11111000;  // 7
                4'h8: seg_decoded = 8'b10000000;  // 8
                4'h9: seg_decoded = 8'b10010000;  // 9
                4'hA: seg_decoded = 8'b10001000;  // A
                4'hB: seg_decoded = 8'b10000011;  // b
                4'hC: seg_decoded = 8'b11000110;  // C
                4'hD: seg_decoded = 8'b10100001;  // d
                4'hE: seg_decoded = 8'b10000110;  // E
                4'hF: seg_decoded = 8'b10001110;  // F
                default: seg_decoded = 8'b11111111;  // All off
            endcase
        end
        else begin
            // Graph mode: Use segment data directly
            seg_decoded = seg_data_r;
        end
    end
    
    // ========== Output Signals ==========
    reg [7:0] o_sel_r;
    reg [7:0] o_seg_r;
    
    always @(posedge scan_clk or negedge CPU_RESETN) begin
        if(!CPU_RESETN) begin
            o_sel_r <= 8'b11111111;  // All digits off
            o_seg_r <= 8'b11111111;  // All segments off
        end
        else begin
            // Digit select (active low)
            o_sel_r <= ~(8'b00000001 << seg_addr);
            // Segment output
            o_seg_r <= seg_decoded;
        end
    end
    
    assign o_sel = o_sel_r;
    assign o_seg = o_seg_r;

endmodule

