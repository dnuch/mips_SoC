`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 03:38:47 PM
// Design Name: 
// Module Name: factorial_interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module factorial_interface_tb;
    
    reg clk, WE, rst;
    reg [1:0] A;
    reg [3:0] WD;
    wire [31:0] RD;
    
    task tick; 
        begin clk = 1; #5; clk = 0; #5; end 
    endtask
    
    factorial_interface DUT(
        .A(A),
        .WE(WE),
        .rst(rst),
        .clk(clk),
        .WD(WD),
        .RD(RD)
    );
    
    initial begin
        // inits
        WE = 0;
        rst = 1;
        tick;
        // write into n register first with value of 4
        rst = 0;
        A = 0;
        WE = 1;
        WD = 4;
        tick;
        
        WE = 0;
        tick;
        
        // check n register read
        if (RD != 4) begin
            $display("Error: n register RD value is %d and not 4", RD);
            $stop;
        end
        
        // write into go register with 1
        WE = 1;
        A = 1;
        WD = 1;
        tick;
        tick;
        
        // check Go register read
        if (RD != 1) begin
            $display("Error: go register RD value is %d and not 1", RD);
            $stop;
        end
        //tick;
        
        // clock through until result done register is set to one
        WE = 0;
        A = 2;
        tick;
        // loop until done bit is set
        while (!(RD & 2'b10)) begin
            // stop loop if error bit is set
            if (RD & 2'b01) begin
                $display("Error: error register set to true");
                $stop;
            end
            tick;
        end
        
        // check n factorial output
        A = 3;
        tick;
        if (RD != 24) begin
            $display("Error: n factorial register is %d and not 24", RD);
            $stop;
        end
        
        $display("Simulation successful!");
        $finish;
    end
endmodule
