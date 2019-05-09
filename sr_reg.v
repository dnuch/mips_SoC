`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 01:42:06 PM
// Design Name: 
// Module Name: sr_reg
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


module sr_reg(
        input set, rst, clk,
        output reg q
    );
    
    always @ (posedge clk, posedge rst)
        if (rst) q <= 1'b0;
        else if (set) q <= 1'b1;
        else q <= q;
        
endmodule
