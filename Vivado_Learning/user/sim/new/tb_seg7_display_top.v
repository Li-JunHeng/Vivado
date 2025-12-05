`timescale 1ns / 1ps

// Testbench for 7-segment display with matrix transform
// Tests both text mode and graphic mode

module tb_seg7_display_top();

    // Test signals
    reg CLK100MHZ;
    reg CPU_RESETN;
    reg disp_mode;
    reg [63:0] i_data;
    wire [7:0] o_sel;
    wire [7:0] o_seg;
    
    // Instantiate the Unit Under Test (UUT)
    seg7_display_top uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .disp_mode(disp_mode),
        .i_data(i_data),
        .o_sel(o_sel),
        .o_seg(o_seg)
    );
    
    // Clock generation - 100MHz (10ns period)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    // Helper task: Decode and display segment
    task display_segment;
        input [7:0] seg;
        input [7:0] sel;
        input mode;
        integer active_digit;
        reg [6:0] seg_code;
        begin
            // Find active digit
            case(sel)
                8'b11111110: active_digit = 0;
                8'b11111101: active_digit = 1;
                8'b11111011: active_digit = 2;
                8'b11110111: active_digit = 3;
                8'b11101111: active_digit = 4;
                8'b11011111: active_digit = 5;
                8'b10111111: active_digit = 6;
                8'b01111111: active_digit = 7;
                default: active_digit = -1;
            endcase
            
            if(active_digit >= 0) begin
                if(mode == 0) begin
                    // Text mode: decode hex digit
                    seg_code = seg[6:0];
                    $write("  [D%0d:", active_digit);
                    case(seg_code)
                        7'b1000000: $write("0");
                        7'b1111001: $write("1");
                        7'b0100100: $write("2");
                        7'b0110000: $write("3");
                        7'b0011001: $write("4");
                        7'b0010010: $write("5");
                        7'b0000010: $write("6");
                        7'b1111000: $write("7");
                        7'b0000000: $write("8");
                        7'b0010000: $write("9");
                        7'b0001000: $write("A");
                        7'b0000011: $write("B");
                        7'b1000110: $write("C");
                        7'b0100001: $write("D");
                        7'b0000110: $write("E");
                        7'b0001110: $write("F");
                        default: $write("?");
                    endcase
                    $write("]");
                end
                else begin
                    // Graph mode: show raw segment data
                    $write("  [D%0d:%02h]", active_digit, seg);
                end
            end
        end
    endtask
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("7-Segment Display Matrix Transform Test");
        $display("========================================");
        
        // Initialization
        CPU_RESETN = 0;
        disp_mode = 0;
        i_data = 64'h0;
        
        // Reset
        $display("\n[%0t ns] Starting reset...", $time);
        #100;
        CPU_RESETN = 1;
        $display("[%0t ns] Reset complete", $time);
        #1000;
        
        // ========== Test 1: Text Mode ==========
        $display("\n========== Test 1: Text Mode (disp_mode=0) ==========");
        disp_mode = 0;
        i_data = 64'h00000000_12345678;  // Display "12345678"
        $display("[%0t ns] Input data (text mode): %h", $time, i_data);
        $display("Expected display: 1 2 3 4 5 6 7 8");
        
        // Wait for complete scan cycle
        repeat(16) @(posedge uut.scan_clk);
        #100;
        
        // Display one complete scan
        $write("[%0t ns] Scanned digits:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 0);
        end
        $display("");
        
        // Test with ABCDEF01
        i_data = 64'h00000000_ABCDEF01;
        $display("\n[%0t ns] Input data (text mode): %h", $time, i_data);
        $display("Expected display: A B C D E F 0 1");
        repeat(8) @(posedge uut.scan_clk);
        $write("[%0t ns] Scanned digits:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 0);
        end
        $display("");
        
        // ========== Test 2: Graph Mode ==========
        $display("\n========== Test 2: Graph Mode (disp_mode=1) ==========");
        disp_mode = 1;
        // Create a pattern: display custom segments on each digit
        // Example: show horizontal bars, vertical bars, etc.
        i_data = 64'hFF_00_FF_00_FF_00_FF_00;  // Alternating pattern
        $display("[%0t ns] Input data (graph mode): %h", $time, i_data);
        $display("Graph mode: Direct segment control (8 bytes)");
        
        repeat(16) @(posedge uut.scan_clk);
        $write("[%0t ns] Segment data:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 1);
        end
        $display("");
        
        // Test with different pattern
        i_data = 64'h01_02_04_08_10_20_40_80;  // Bit shift pattern
        $display("\n[%0t ns] Input data (graph mode): %h", $time, i_data);
        repeat(8) @(posedge uut.scan_clk);
        $write("[%0t ns] Segment data:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 1);
        end
        $display("");
        
        // ========== Test 3: Mode Switching ==========
        $display("\n========== Test 3: Mode Switching ==========");
        i_data = 64'hFFFFFFFF_FFFFFFFF;
        
        $display("[%0t ns] Switching to text mode...", $time);
        disp_mode = 0;
        repeat(8) @(posedge uut.scan_clk);
        $write("[%0t ns] Text mode display:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 0);
        end
        $display("");
        
        $display("[%0t ns] Switching to graph mode...", $time);
        disp_mode = 1;
        repeat(8) @(posedge uut.scan_clk);
        $write("[%0t ns] Graph mode display:", $time);
        repeat(8) begin
            @(posedge uut.scan_clk);
            #10;
            display_segment(o_seg, o_sel, 1);
        end
        $display("");
        
        // ========== Test 4: Reset Test ==========
        $display("\n========== Test 4: Reset Test ==========");
        $display("[%0t ns] Asserting reset...", $time);
        CPU_RESETN = 0;
        #1000;
        $display("[%0t ns] After reset:", $time);
        $display("  i_data_store = %h (should be 0)", uut.i_data_store);
        $display("  seg_addr = %d (should be 0)", uut.seg_addr);
        $display("  o_sel = %b", o_sel);
        $display("  o_seg = %b", o_seg);
        CPU_RESETN = 1;
        #10000;
        
        // ========== Final Summary ==========
        $display("\n========================================");
        $display("Simulation Test Summary");
        $display("========================================");
        $display("Clock divider: 2^15 = %0d cycles", 2**15);
        $display("Scan frequency: 100MHz / 2^15 = 3.05kHz");
        $display("Text mode: Displays hex digits (0-F)");
        $display("Graph mode: Direct segment control");
        $display("Matrix transform test completed!");
        $display("========================================");
        $finish;
    end
    
    // Waveform file generation
    initial begin
        $dumpfile("tb_seg7_display_top.vcd");
        $dumpvars(0, tb_seg7_display_top);
    end

endmodule

