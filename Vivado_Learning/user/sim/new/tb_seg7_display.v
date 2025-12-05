`timescale 1ns / 1ps

// Testbench for 7-segment display module
// Tests display of different values

module tb_seg7_display();

    // Test signal definitions
    reg CLK100MHZ;
    reg CPU_RESETN;
    reg [31:0] number;
    wire [7:0] AN;
    wire [7:0] SEG;
    
    // Instantiate the Unit Under Test (UUT)
    seg7_display uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .number(number),
        .AN(AN),
        .SEG(SEG)
    );
    
    // Clock generation - 100MHz (10ns period)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    // Helper task: Decode 7-segment code and display
    task display_segment;
        input [7:0] seg;
        input [7:0] an;
        integer active_digit;
        reg [6:0] seg_code;
        begin
            // Find currently active digit position
            case(an)
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
                seg_code = seg[6:0];
                $write("[Digit %0d] ", active_digit);
                
                // Decode displayed digit
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
                
                $write(" (SEG=%b, AN=%b)\n", seg, an);
            end
        end
    endtask
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("7-Segment Display Module Simulation Test");
        $display("========================================");
        
        // Initialization
        CPU_RESETN = 0;
        number = 32'h00000000;
        
        // Reset
        $display("\n[%0t ns] Starting reset...", $time);
        #100;
        CPU_RESETN = 1;
        $display("[%0t ns] Reset complete", $time);
        
        // Test 1: Display 12345678
        $display("\n[%0t ns] Test 1: Display 12345678 (hex)", $time);
        number = 32'h12345678;
        #2000000;  // Wait 2ms to scan all digits at least once
        
        // Test 2: Display ABCDEF01
        $display("\n[%0t ns] Test 2: Display ABCDEF01 (hex)", $time);
        number = 32'hABCDEF01;
        #2000000;
        
        // Test 3: Display 00000000
        $display("\n[%0t ns] Test 3: Display 00000000 (hex)", $time);
        number = 32'h00000000;
        #2000000;
        
        // Test 4: Display FFFFFFFF
        $display("\n[%0t ns] Test 4: Display FFFFFFFF (hex)", $time);
        number = 32'hFFFFFFFF;
        #2000000;
        
        // Test 5: Increment counter test
        $display("\n[%0t ns] Test 5: Increment counter test", $time);
        repeat(10) begin
            number = number + 32'h11111111;
            $display("[%0t ns] Current display value: %h", $time, number);
            #1000000;
        end
        
        // Test 6: Reset test
        $display("\n[%0t ns] Test 6: Reset test", $time);
        CPU_RESETN = 0;
        #100;
        $display("[%0t ns] After reset AN=%b, SEG=%b", $time, AN, SEG);
        CPU_RESETN = 1;
        #100000;
        
        $display("\n========================================");
        $display("Simulation test completed!");
        $display("========================================");
        $finish;
    end
    
    // Monitor scanning process (optional, for detailed debugging)
    reg [2:0] last_digit_sel;
    initial begin
        last_digit_sel = 3'b111;
        forever begin
            @(posedge uut.scan_clk);
            if(uut.digit_sel != last_digit_sel && CPU_RESETN) begin
                #10;  // Wait for output to stabilize
                display_segment(SEG, AN);
                last_digit_sel = uut.digit_sel;
            end
        end
    end
    
    // Waveform file generation (for GTKWave or other waveform viewers)
    initial begin
        $dumpfile("tb_seg7_display.vcd");
        $dumpvars(0, tb_seg7_display);
    end

endmodule

