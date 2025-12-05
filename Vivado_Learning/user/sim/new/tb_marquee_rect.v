`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 矩形变换跑马灯测试模块 (支持19帧)
//////////////////////////////////////////////////////////////////////////////////

module tb_marquee_rect;

    // 输入信号
    reg CLK100MHZ;
    reg CPU_RESETN;
    reg [15:0] SW;
    
    // 输出信号
    wire [7:0] SEG;
    wire [7:0] AN;
    
    // 实例化被测模块
    marquee_rect uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .SW(SW),
        .SEG(SEG),
        .AN(AN)
    );
    
    // 时钟生成 (100MHz)
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;  // 10ns周期
    end
    
    // 显示当前数码管状态的任务
    task display_status;
        begin
            $display("========================================");
            $display("Time: %t", $time);
            $display("Mode: %s", SW[0] ? "图像模式" : "文本模式");
            $display("Speed: %s", SW[15] ? "快速" : "慢速");
            $display("Frame Address: %d", uut.led_data_addr);
            $display("AN (位选): %b", AN);
            $display("SEG (段码): %b", SEG);
            $display("========================================");
        end
    endtask
    
    // 测试序列
    initial begin
        // 初始化
        CPU_RESETN = 0;
        SW = 16'h0000;
        
        $display("开始测试矩形变换跑马灯");
        
        // 复位
        #100;
        CPU_RESETN = 1;
        $display("复位完成");
        
        // 测试1：文本模式 + 慢速
        #100;
        SW = 16'h0000;  // SW[0]=0 (文本模式), SW[15]=0 (慢速)
        $display("\n测试1: 文本模式 + 慢速");
        display_status();
        #200000;  // 观察一段时间
        
        // 测试2：文本模式 + 快速
        SW = 16'h8000;  // SW[0]=0 (文本模式), SW[15]=1 (快速)
        $display("\n测试2: 文本模式 + 快速");
        display_status();
        #200000;
        
        // 测试3：图像模式 + 慢速
        SW = 16'h0001;  // SW[0]=1 (图像模式), SW[15]=0 (慢速)
        $display("\n测试3: 图像模式 + 慢速");
        display_status();
        
        // 等待几个帧切换
        repeat(5) begin
            @(posedge uut.Clk_CPU);
            #1000;
            display_status();
        end
        
        // 测试4：图像模式 + 快速
        SW = 16'h8001;  // SW[0]=1 (图像模式), SW[15]=1 (快速)
        $display("\n测试4: 图像模式 + 快速");
        display_status();
        
        // 等待几个帧切换
        repeat(5) begin
            @(posedge uut.Clk_CPU);
            #1000;
            display_status();
        end
        
        // 测试5：验证19帧循环
        $display("\n测试5: 验证19帧循环");
        SW = 16'h8001;  // 图像模式 + 快速
        
        repeat(25) begin  // 观察超过19帧，验证循环
            @(posedge uut.Clk_CPU);
            #1000;
            $display("当前帧地址: %d", uut.led_data_addr);
        end
        
        // 测试完成
        #100000;
        $display("\n测试完成！");
        $finish;
    end
    
    // 监控数码管扫描
    always @(posedge CLK100MHZ) begin
        if (uut.u_seg7x16.seg7_addr == 3'd0 && uut.u_seg7x16.cnt == 0) begin
            // 每次扫描一轮时显示一次信息
            $display("[%t] 数码管扫描完成一轮 - 帧地址: %d", $time, uut.led_data_addr);
        end
    end
    
    // 超时保护
    initial begin
        #50_000_000;  // 50ms仿真时间
        $display("仿真超时！");
        $finish;
    end

endmodule

