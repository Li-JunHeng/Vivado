`timescale 1ns / 1ps

module tb_led_marquee();
    // Clock and reset
    reg CLK100MHZ;
    reg CPU_RESETN;
    reg [15:0] SW;
    
    // Output
    wire [15:0] LED;
    
    // Instantiate DUT with smaller div_num for faster simulation
    led_marquee #(
        .div_num(5)
    ) uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .SW(SW),
        .LED(LED)
    );
    
    // Generate 100MHz clock
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;
    end
    
    // Test stimulus
    initial begin
        // Initialize
        CPU_RESETN = 0;
        SW = 16'h0000;
        
        // Test 1: Release reset, check initial state
        #100;
        CPU_RESETN = 1;
        #50;
        
        // Test 2: SW[0]=1, marquee should not run
        SW[0] = 1;
        #2000;
        
        // Test 3: SW[0]=0, marquee should run
        SW[0] = 0;
        repeat(18) begin
            #320;
        end
        
        // Test 4: SW[0]=1, marquee should stop
        SW[0] = 1;
        #2000;
        
        // Test 5: Assert reset during operation
        SW[0] = 0;
        #1000;
        CPU_RESETN = 0;
        #100;
        
        // Test 6: Release reset and verify LED returns to initial state
        CPU_RESETN = 1;
        #100;
        
        // Test 7: Verify marquee works after reset
        SW[0] = 0;
        repeat(17) begin
            #320;
        end
        
        // Test 8: Reset during marquee operation
        #500;
        CPU_RESETN = 0;
        #50;
        CPU_RESETN = 1;
        #500;
        
        $finish;
    end
    
endmodule
