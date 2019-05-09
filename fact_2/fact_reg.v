`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2019 01:50:56 PM
// Design Name: 
// Module Name: fact_reg
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


module fact_reg #(parameter w = 32) (
        input wire clk, rst, load_reg,
        input wire [w-1:0] d,
        output reg [w-1:0] q
    );
    
    always @ (posedge clk, posedge rst)
        if (rst) q <= 0;
        else if (load_reg) q <= d;
        else q <= q;
        
endmodule
