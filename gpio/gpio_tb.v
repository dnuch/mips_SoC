`timescale 1ns / 1ps

module gpio_tb;
    reg clk;
    reg rst;
    reg [1:0] A_tb;
    reg we_tb;
    reg [31:0] gpi1_tb; 
    reg [31:0] gpi2_tb;
    reg [31:0] wd_tb;
    wire [31:0] rd_tb;
    wire [31:0] gpo1_tb;
    wire [31:0] gpo2_tb;   
    
    gpio GPIO_tb(
    .clk    (clk),
    .rst    (rst),
    .A      (A_tb),
    .we     (we_tb),
    .gpi_1  (gpi1_tb), 
    .gpi_2  (gpi2_tb),
    .wd     (wd_tb),
    .rd     (rd_tb),
    .gpo_1  (gpo1_tb),
    .gpo_2  (gpo2_tb)   
    );
    
    initial
    begin
    clk = 0;
    rst = 1;
    tick;
    rst = 0;
    gpi1_tb = 100;
    gpi2_tb = 200;
    wd_tb = 300;
    for (integer i = 0; i < 4; i = i + 1)
        begin
        A_tb =  i;
        for (integer j = 0; j < 2; j = j + 1)
            begin
            we_tb = j;
            tick;
            end            
        end
        $finish;
    end
    
    task tick; 
        begin 
            clk = 1'b0; #5;
            clk = 1'b1; #5;
        end
    endtask
        
    endmodule
